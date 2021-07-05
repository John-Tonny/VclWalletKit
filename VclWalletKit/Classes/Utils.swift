//
//  Utils.swift
//  kkk
//
//  Created by john on 2021/6/28.
//

import Foundation
import BitcoinKit
import BitcoinCore
import HdWalletKit
import OpenSslKit
import Secp256k1Kit

public func signMessage(data: Data, privateKey: Data) -> String {
    let flatMessage = data.hexadecimal().data(using: .ascii)
    let hashMessage = Kit.sha256sha256(flatMessage!)
    let signature = try!Kit.sign(data: hashMessage, privateKey: privateKey)
   return signature.hexadecimal()
}

public func signMessage(data: [String], privateKey: Data) -> String {
    let message = data.joined(separator: "|")
    let flatMessage = message.data(using: .ascii)!
    let hashMessage = Kit.sha256sha256(flatMessage).hexadecimal()
    let signature = try!Kit.sign(data: hashMessage.hexadecimal()!, privateKey: privateKey)
   return signature.hexadecimal()
}

public func signCompactMessage(data: Data, privateKey: Data) -> String {
    let flatMessage = data.hexadecimal().data(using: .ascii)
    let hashMessage = Kit.sha256sha256(flatMessage!)
    let signature = try!Kit.compactSign(hashMessage, privateKey: privateKey)
    return signature.hexadecimal()
}

public func signData(data: Data, privateKey: Data) -> String {
    let hashMessage = Kit.sha256sha256(data)
    let signature = try!Kit.sign(data: hashMessage, privateKey: privateKey)
    return signature.hexadecimal()
}

public func signCompactData(data: Data, privateKey: Data, publicKey: Data, commpressed: Bool) -> String {
    let hashMessage = Kit.sha256sha256(data)
    let signature = try!Kit.compactSign(hashMessage, privateKey: privateKey)

    let recId = 27 + (commpressed ? 4 : 0)
    var index = 0
    for i in 0...4 {
        var result = Data()
        result += signature
        result += UInt8(i)
        if(Kit.ellipticIsValid(signature: result, of: hashMessage, publicKey: publicKey, compressed: commpressed)){
            index = i
            break
        }
    }
    var res = Data()
    res += UInt8(recId + index)
    res += signature

    return res.hexadecimal()
}


public func getPrivateKeyFromWif(data: String) -> String {
    let hex = Base58.decode(data)
    
    return String(hex.hexadecimal().dropFirst(2).dropLast(8))
}

public func getDerivedSubPath(path: String) throws -> String {
    var path = path
    if path.contains("m/") {
        path = String(path.dropFirst(2))
    } else if path.contains("/") {
        path = String(path.dropFirst(1))
    }
    return path
}

public func signMasternode(txid: String, vout: Int, signPrivateKey: HDPrivateKey, pingHash: String, pingPrivateKey: String, addr: String, port: Int) -> String {
    let CLIENT_VERSION = 31800
    let CLIENT_SENTINEL_VERSION = 1000000
    let CLIENT_MASTERNODE_VERSION = 1010191

    func serialize_input(txid: String, vout: Int) -> Data {
        var data = txid.reversed()
        data += UInt32(vout)
        return data
    }
    
    func hash_decode(pingHash: String) -> Data {
        return pingHash.reversed()
    }

    func get_address(addr: String, port: Int) -> Data {
        var data = "00000000000000000000ffff".hexadecimal()!
        for chunk in addr.split(separator: ".")  {
            let b = chunk
            guard let ip = UInt8(b) else {
                fatalError("invalid ip addr")
            }
            data += ip
        }
        return data + UInt8(port/256) + UInt8(port%256)
    }

    func get_now_time() -> Data {
        var data = Data()
        data += Date().timeStamp
        return data
    }
    
    func get_varintNum(n: UInt64) -> Data {
        var data = Data();
        if (n < 253) {
            data += UInt8(n)
        } else if (n < 0x10000) {
            data += UInt8(0)
            data += UInt16(n)
        } else if (n < 0x100000000) {
            data += UInt8(254)
            data += UInt32(n)
        } else {
            data += UInt8(255)
            data += UInt64(n)
        }
        return data
    }
    
    var presult = serialize_input(txid: txid, vout: vout)
    presult += hash_decode(pingHash: pingHash)
    let pingTime = get_now_time()
    presult += pingTime
    presult += UInt8(1)
    presult += UInt32(CLIENT_SENTINEL_VERSION/1000000)
    presult += UInt32(CLIENT_MASTERNODE_VERSION/1000000)
    
    let pubKey = Kit.createPublicKey(fromPrivateKeyData: pingPrivateKey.hexadecimal()!, compressed: false)

    let pingSig = signCompactData(data: presult, privateKey: pingPrivateKey.hexadecimal()!, publicKey: pubKey, commpressed: false).hexadecimal()
    
    var result = serialize_input(txid: txid, vout: vout);
    result += get_address(addr: addr, port: port);
    
    let signPubKey = signPrivateKey.publicKey().raw
    result += get_varintNum(n: UInt64(signPubKey.count))
    result += signPubKey;

    result += get_varintNum(n: UInt64(pubKey.count))
    result += pubKey;

    let signTime = get_now_time()
    result += signTime
    result += UInt32(CLIENT_VERSION);
    let sig = signCompactData(data: result, privateKey: signPrivateKey.raw, publicKey: signPubKey, commpressed: true).hexadecimal()

    var sresult = Data()
    sresult += UInt8(1)
    sresult += serialize_input(txid: txid, vout: vout)
    sresult += get_address(addr: addr, port: port)

    sresult += get_varintNum(n: UInt64(signPubKey.count))
    sresult += signPubKey;

    sresult += get_varintNum(n: UInt64(pubKey.count))
    sresult += pubKey;

    sresult += get_varintNum(n: UInt64(sig!.count))
    sresult += sig!;
    sresult += signTime;
    sresult += UInt32(CLIENT_VERSION);

    sresult += serialize_input(txid: txid, vout: vout)
    sresult += hash_decode(pingHash: pingHash)
    sresult += pingTime;

    sresult += get_varintNum(n: UInt64(pingSig!.count))
    sresult += pingSig!

    sresult += UInt8(1)
    sresult += UInt32(CLIENT_SENTINEL_VERSION)
    sresult += UInt32(CLIENT_MASTERNODE_VERSION)

    sresult += UInt32(0)
    
    return sresult.hexadecimal()
    
}

public func getSatoshis(amount: Double) -> Int {
    return Int(amount * pow(10.0, 8.0))
}

public func getRandom() -> Int {
    return Int.random(in: 10000..<99999)
}

public func checkCredentials(credentials: Credentials, extended: Bool = false){
    guard credentials.mnemonic.count == 12 else { fatalError("invalid mnemonics length(12)")
    }

    if(extended) {
        guard credentials.sharedEncryptingKey != nil else { fatalError("invalid sharedEncryptingKey")
        }
    }

}

public func toModel<T>(_ type: T.Type, value: Any?) -> T? where T: Decodable {
    guard let value = value else { return nil }
    return toModel(type, value: value)
}

public func toModel<T>(_ type: T.Type, value: Any) -> T? where T : Decodable {
    guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
    return try? decoder.decode(type, from: data)
}

public func modelToString<T: Codable>(data: T) -> String {
    let encoder = JSONEncoder()
    let jsonData = try!encoder.encode(data)
    let strData = String(data: jsonData, encoding: .utf8)!
    return strData
}
