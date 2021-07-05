//
//  WalletApiRequest.swift
//  kkk
//
//  Created by john on 2021/6/22.
//

import Foundation

public struct CreateWalletRequest: Codable{
    let name: String
    let m: Int
    let n: Int
    let pubKey: String
    let coin: String
    let network: String
    let singleAddress: Bool
    let usePurpose48: Bool
    let useNativeSegwit: Bool
}

public struct JoinWalletRequest: Codable {
    let walletId: String
    let name: String
    let xPubKey: String
    let requestPubKey: String
    let customData: String
    let copayerSignature: String
    let coin: String
}

public struct WalletCustomData: Codable {
    let walletPrivKey: String
}

public struct TransactionRequest: Codable {
    let outputs: [OutputModel]
    /// let feeLevel: String
    // let message: String?
    let excludeUnconfirmedUtxos: Bool
    let dryRun: Bool
    let operation: String
    let customData: String
    // let payProUrl: String
    let excludeMasternode: Bool
}

public struct PublishRequest: Codable {
    let proposalSignature: String
}

public struct PushRequest: Codable {
    let signatures: [String]
}

public struct MasternodeBroadcastRequest: Codable {
    let coin: String = "vcl"
    let rawTx: String
    let masternodeKey: String
}

public struct BroadcastRawTxRequest: Codable {
    let network: String
    let rawTx: String
}

public struct MasternodeBaseRequest: Codable {
    let coin: String?
    let txid: String?
    let vout: Int?
    let address: String?
    let payee: String?

    func getQuery() -> String {
        var query = "?r=\(getRandom())"
        
        if(coin != nil){
            query += "&coin=\(String(describing: coin!))"
        }
        if(txid != nil){
            query += "&txid=\(String(describing: txid!))"
        }
        if(vout != nil){
            query += "&vout=\(String(describing: vout!))"
        }
        if(address != nil){
            query += "&address=\(String(describing: address!))"
        }
        if(payee != nil){
            query += "&payee=\(String(describing: payee!))"
        }
        return query
    }
    
    func getCompactQuery() -> String {
        var query = "?r=\(getRandom())"
        
        if(coin != nil){
            query += "&coin=\(String(describing: coin!))"
        }
        if(txid != nil){
            query += "&txid=\(String(describing: txid!))-\(String(describing: vout!))"
        }
        if(address != nil){
            query += "&address=\(String(describing: address!))"
        }
        if(payee != nil){
            query += "&payee=\(String(describing: payee!))"
        }
        return query
    }
    
}

public struct CreateAddressRequest: Codable {
    let ignoreMaxGap: Bool
}

struct TStrInt: Codable {
    var int:Int {
        didSet {
            let stringValue = String(int)
            if  stringValue != string {
                string = stringValue
            }
        }
    }
    
    var string:String {
        didSet {
            if let intValue = Int(string), intValue != int {
                int = intValue
            }
        }
    }
    
    //自定义解码(通过覆盖默认方法实现)
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let stringValue = try? singleValueContainer.decode(String.self)
        {
            string = stringValue
            int = Int(stringValue) ?? 0
            
        } else if let intValue = try? singleValueContainer.decode(Int.self)
        {
            int = intValue
            string = String(intValue);
        } else
        {
            int = 0
            string = ""
        }
    }
}















public struct SignatureIndex : Encodable {
    let signature: String
    let index: Int
}

