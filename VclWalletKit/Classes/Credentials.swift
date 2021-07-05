//
//  Credentials.swift
//  kkk
//
//  Created by john on 2021/6/28.
//

import Foundation
import BitcoinCore
import HdWalletKit
import OpenSslKit
import Secp256k1Kit

public class Credentials {
    public let hdWallet: HDWallet
    private let purpose: UInt32
    private let coinType: UInt32
    private let account: UInt32 = 0
    private let p2pkhVersion: UInt8
    private let p2shVersion: UInt8
    private let wifVersion: UInt8
    
    let addressConvert: Base58AddressConverter
    
    public let copayId: String
    public let personalEncryptingKey: String
    
    public let masterPrivateKey: HDPrivateKey
    public let requestPrivateKey: HDPrivateKey
    
    public let xPublicKey: String
    public let requestPublicKey: String
    
    public var walletPrivateKey: String?
    public var walletPublickey: String?
    public var sharedEncryptingKey: String?
    
    public var mnemonic: [String]

    public init(mnemonic: [String]? = nil, coinType: UInt32 = 57, xPrivKey: UInt32 = 76066276, xPubKey: UInt32 = 76067358, gapLimit: Int = 5, purpose: Purpose = .bip44, p2pkhVersion: UInt8 = 63, p2shVersion: UInt8 = 5, wifVersion: UInt8 = 128) throws {
        
        var words = mnemonic
        if(mnemonic == nil || mnemonic!.count == 0) {
            words = try!Mnemonic.generate()
        }
        guard words!.count == 12 else { fatalError("invalid mnemonic length(12)") }
         
        self.mnemonic = words!
        self.purpose =  purpose.rawValue
        self.coinType = coinType
        self.p2pkhVersion = p2pkhVersion
        self.p2shVersion = p2shVersion
        self.wifVersion = wifVersion

        self.addressConvert = Base58AddressConverter.init(addressVersion: self.p2pkhVersion, addressScriptVersion: self.p2shVersion)

        let seed = Mnemonic.seed(mnemonic: self.mnemonic)
        self.hdWallet = HDWallet(seed: seed, coinType: coinType, xPrivKey: xPrivKey, xPubKey: xPubKey)
                        
        let path = "m/\(self.purpose)'/\(self.coinType)'/\(self.account)'"
        self.masterPrivateKey = try!self.hdWallet.privateKey(path: path)
        self.xPublicKey = self.masterPrivateKey.publicKey().extended()
        self.copayId = Kit.sha256(self.xPublicKey.data(using: .utf8)!).hexadecimal()
         
        self.requestPrivateKey = try!hdWallet.privateKey(path: "m/1'/0")
        self.requestPublicKey = self.requestPrivateKey.publicKey().raw.hexadecimal()
        let entropySource = Kit.sha256(self.requestPrivateKey.raw)
        let array = [UInt8](Kit.hmacsha256(data: entropySource, key: "personalKey".data(using: .utf8)!))
        self.personalEncryptingKey = Data(array.prefix(16)).base64EncodedString()
        
        if( mnemonic == nil) {
            var  bytes =  Data(count: 32)
            let _ = bytes.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!.assumingMemoryBound(to: UInt8.self))
            }
            self.walletPrivateKey = bytes.hexadecimal()
            
            let hashPrivkey = Kit.sha256(bytes)
            let hashArray = [UInt8](hashPrivkey)
            self.sharedEncryptingKey = Data(hashArray.prefix(16)).base64EncodedString()
            
            self.walletPublickey = Kit.createPublicKey(fromPrivateKeyData: bytes, compressed: true).hexadecimal()
        }
    }

    public func privateKey(account: Int, index: Int, chain: HDWallet.Chain) throws -> HDPrivateKey {
        try self.hdWallet.privateKey(path: "m/\(self.purpose)'/\(self.coinType)'/\(self.account)'/\(chain.rawValue)/\(index)")
    }
    
    public func privateKey(subPath: String) throws -> HDPrivateKey {
        return try privateKey(path: "m/\(self.purpose)'/\(self.coinType)'/\(self.account)'/" + subPath)
    }
    
    public func privateKey(path: String) throws -> HDPrivateKey {
        try self.hdWallet.privateKey(path: path)     }

    public func publicKey(account: Int, index: Int, chain: HDWallet.Chain) throws -> HDPublicKey {
        try self.hdWallet.privateKey(account: account, index: index, chain: chain).publicKey()
    }

    public func publicKeys(account: Int, indices: Range<UInt32>, chain: HDWallet.Chain) throws -> [HDPublicKey] {
        try self.hdWallet.publicKeys(account: account, indices: indices, chain: chain)
    }

    public func getCopayerId(path: String) throws -> String? {
        let privKey = try!privateKey(path:path)
        let xpubKey = privKey.publicKey().extended()
        return Kit.sha256(xpubKey.data(using: .utf8)!).hexadecimal()
    }
    
    public func signRequest(method: String, url: String, args: String) -> String? {
        let message = [method, url, args].joined(separator: "|")
        let hashMessage = Kit.sha256sha256(message.data(using: .ascii)!)
        
        let req = try!Kit.sign(data: hashMessage, privateKey: self.requestPrivateKey.raw)
        
        return req.hexadecimal()
    }

    public func getHeaders(method: String, url: String, args: String) -> [String:String] {
        let signature = signRequest(method: method, url: url, args: args)
        let xidentity: String! = self.copayId
        let xsignature: String! = signature
        
        return ["x-identity": xidentity, "x-signature": xsignature, "Content-Type": #"application/json"#, "x-client-version" : "bwc-5.1.2"]
        //return ["x-identity": xidentity, "x-signature": xsignature]
    }
    
    public func addWalletPrivateKey(privateKey: String) {
        let bytes = privateKey.hexadecimal()!
        self.walletPrivateKey = privateKey
        let hashPrivkey = Kit.sha256(bytes)
        let hashArray = [UInt8](hashPrivkey)
        self.sharedEncryptingKey = Data(hashArray.prefix(16)).base64EncodedString()
        self.walletPublickey = Kit.createPublicKey(fromPrivateKeyData: bytes, compressed: true).hexadecimal()
    }
    
    public func getScriptFromAddress(address: String) throws -> Data {
        return try!self.addressConvert.convert(address: address).lockingScript
    }

    public func getScriptFromPublicKey(hdPublicKey: HDPublicKey, type: ScriptType) throws -> Address {
        
        let publicKey = PublicKey(withAccount: 0, index: 0, external: true, hdPublicKeyData: hdPublicKey.raw)
        return try!self.addressConvert.convert(publicKey: publicKey, type: type)
    }
    
}
