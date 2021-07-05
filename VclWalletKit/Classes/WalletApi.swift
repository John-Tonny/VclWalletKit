//
//  WalletApi.swift
//  kkk
//
//  Created by john on 2021/6/19.
//
import UIKit
import Foundation
import Alamofire
import BitcoinKit
import HdWalletKit
import OpenSslKit
import Secp256k1Kit


public class WalletApi {
    let bwsUrl: String
    
    public init(bwsUrl: String) {
        self.bwsUrl = bwsUrl
    }
        
    public func getWalletStatus(credentials: Credentials, handler: @escaping (Credentials?, WalletModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v3/wallets/?r=\(getRandom())&twoStep=1&includeExtendedInfo=1&serverMessageArray=1"
        let url = self.bwsUrl + api
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        // let decoder = JSONDecoder()
        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in/*.responseDecodable(decoder: decoder) { (response: DataResponse<WalletModel, AFError>) in */
            switch response.result {
            case .success(let value):
                var result = toModel(WalletModel.self, value: value)
                if(result != nil ) {
                    var i = 0
                    for copayer in result!.wallet.copayers {
                        let customData = SjclEncryptMessage.decrypt(msg: copayer.customData, encryptKey: credentials.personalEncryptingKey)
                        if(customData != nil) {
                            let decoder = JSONDecoder()
                            let customData1 = try!decoder.decode(WalletCustomData.self, from: customData!.data(using: .utf8)!)
                            let privateKey = customData1.walletPrivKey
                            credentials.addWalletPrivateKey(privateKey: privateKey )
                            let copayerName = SjclEncryptMessage.decrypt(msg: copayer.name, encryptKey: credentials.sharedEncryptingKey!)
                            if(copayerName != nil){
                                result!.wallet.copayers[i].name = copayerName!
                            }
                        }
                        i += 1
                    }
                    if(credentials.sharedEncryptingKey != nil){
                        let walletName = SjclEncryptMessage.decrypt(msg: result!.wallet.name, encryptKey: credentials.sharedEncryptingKey!)
                        if(walletName != nil) {
                            result!.wallet.name = walletName!
                        }
                    }
                    handler(credentials, result, nil)
                }else {
                    handler(credentials, nil, "Error while get wallet: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, nil, "Error while get wallet: \(String(describing: error))")
                return
            }
        }
    }
    
    public func getAddress(credentials: Credentials, handler: @escaping ([AddressModel]?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v1/addresses/?r=\(getRandom())"
        let url = self.bwsUrl + api
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel([AddressModel].self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while get address: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while get address: \(String(describing: error))")
                return
            }
        }
    }
     
    public func getTxHistory(credentials: Credentials, handler: @escaping ([TransactionHistoryModel]?, String?)->()) {

        checkCredentials(credentials: credentials)

        let api = "/v1/txhistory/?r=\(getRandom())&includeExtendedInfo=1"
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let result = toModel([TransactionHistoryModel].self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while get txHistory: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while get txHistory: \(String(describing: error))")
                return
            }
        }
    }

    public func getTxProposal(credentials: Credentials, handler: @escaping ([TxProposalModel]?, String?)->()) {

        checkCredentials(credentials: credentials)

        let api = "/v2/txproposals/"
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel([TxProposalModel].self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while get txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while get txProposal: \(String(describing: error))")
                return
            }
        }
    }

    public func getMasternodes(credentials: Credentials, txid: String? = nil, vout: Int? = nil, handler: @escaping ([MasternodeModel]?, String?)->()) {

        checkCredentials(credentials: credentials)

        let masternodeRequest = MasternodeBaseRequest(coin: "vcl", txid: txid, vout: vout, address: nil, payee: nil)
        let api = "/v1/masternode/" + masternodeRequest.getCompactQuery()
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(MasternodeModel.self, value: value)
                if(result != nil ) {
                    var arr = [MasternodeModel]()
                    arr.append(result!)
                    handler(arr, nil)
                }else {
                    let result1 = toModel([MasternodeModel].self, value: value)
                    if(result1 != nil ) {
                        handler(result1, nil)
                    }else {
                        handler(nil, "Error while get masternodes: \(String(describing: value))")
                    }
                }
            case .failure(let error):
                handler(nil, "Error while get masternodes: \(String(describing: error))")
                return
            }
        }
    }
    
    public func getMasternodeStatus(credentials: Credentials, txid: String? = nil, vout: Int? = nil, handler: @escaping ([MasternodeStatusModel]?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let masternodeRequest = MasternodeBaseRequest(coin: "vcl", txid: txid, vout: vout, address: nil, payee: nil)
        let api = "/v1/masternode/status/" + masternodeRequest.getCompactQuery()
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                var arr = [MasternodeStatusModel]()
                if(value is Dictionary<String, Any>){
                    let value1 = value as! Dictionary<String,
                                                      Any>
                    var masternodeStatus = toModel(MasternodeStatusModel.self, value: value1)
                    if(masternodeStatus != nil ) {
                        arr.append(masternodeStatus!)
                    }else {
                        for (key, item) in value1 {
                            masternodeStatus = toModel(MasternodeStatusModel.self, value: item)
                            if(masternodeStatus != nil ) {
                                masternodeStatus!.id = key
                                arr.append(masternodeStatus!)
                            }else {
                                handler(nil, "Error while get masternodeStatus: json error")
                            }
                        }
                    }
                }
                handler(arr, nil)
            case .failure(let error):
                handler(nil, "Error while get masternodeStatus: \(String(describing: error))")
                return
            }
        }
    }
 
    public func getMasternodePing(credentials: Credentials, txid: String, vout: Int, handler: @escaping (MasternodePingModel?, String?)->()) {

        checkCredentials(credentials: credentials)

        let masternodeRequest = MasternodeBaseRequest(coin: "vcl", txid: txid, vout: vout, address: nil, payee: nil)
        let api = "/v1/masternode/ping/" + masternodeRequest.getQuery()
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(MasternodePingModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while get masternodePing: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while get masternodePing: \(String(describing: error))")
                return
            }
        }
    }
    
    public func getMasternodeCollateral(credentials: Credentials, handler: @escaping ([MasternodeCollateralModel]?, String?)->()) {
        
        checkCredentials(credentials: credentials)
        
        let masternodeRequest = MasternodeBaseRequest(coin: nil, txid: nil, vout: nil, address: nil, payee: nil)
        let api = "/v1/masternode/collateral/" + masternodeRequest.getQuery()
        let url = self.bwsUrl + api
        
        let headers = HTTPHeaders(credentials.getHeaders(method: "get", url: api, args: "{}"))

        Alamofire.AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel([MasternodeCollateralModel].self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while get masternodeCollateral: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while get masternodeCollateral: \(String(describing: error))")
                return
            }
        }
    }

    public func broadcastMasternode(credentials: Credentials, rawTx: String, masternodeKey: String, handler: @escaping (MasternodeBroadcastModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let masternodeRequest = MasternodeBaseRequest(coin: nil, txid: nil, vout: nil, address: nil, payee: nil)
        let api = "/v1/masternode/broadcast/" + masternodeRequest.getQuery()
        let url = self.bwsUrl + api
        
        let masternodeBroadcastRequest = MasternodeBroadcastRequest(rawTx: rawTx, masternodeKey: masternodeKey)
                
        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(masternodeBroadcastRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: masternodeBroadcastRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON{ response in
            switch response.result {
            case .success(let value):
                var result = MasternodeBroadcastModel(id: nil, outpoint: nil, addr: nil, overall: nil, error: nil)
                var info: MasternodeBroadcastModel?
                if(value is Dictionary<String, Any>){
                    let value1 = value as! Dictionary<String,
                                                      Any>
                    for (key, item) in value1 {
                        if(item is Dictionary<String, Any>){
                            info = toModel(MasternodeBroadcastModel.self, value: item)
                            if(info != nil ) {
                                info!.id = key
                            }else {
                                handler(nil, "Error while masternode broadcast: json error")
                            }
                        }else{
                            if(key == "overall"){
                                result.overall = item as? String
                            }else if(key == "error"){
                                result.error = item as? String
                            }
                        }
                    }
                }
                if(result.error == nil) {
                    result.id = info?.id
                    result.outpoint = info?.outpoint
                    result.addr = info?.addr
                    handler(result, nil)
                }else {
                    handler(nil, "Error while masternode broadcast: \(String(describing: result.error!))")
                }
            case .failure(let error):
                handler(nil, "Error while masternode broadcast: \(String(describing: error))")
                return
            }
        }
    }
    
    public func createWallet(credentials: Credentials, walletName: String, m: Int = 1, n: Int = 1, handler: @escaping (CreateWalletModel?, String?)->()) throws {
        
        checkCredentials(credentials: credentials, extended: true)

        let api = "/v2/wallets/"
        let url = self.bwsUrl + api
        
        var usePurpose48: Bool = false
        if (n>1) {
            usePurpose48 = true
        }
        
        guard let encWalletName = SjclEncryptMessage.encrypt(msg: walletName, encryptKey: credentials.sharedEncryptingKey!) else{
                handler(nil, "Error while create wallet: sjcl加密错误")
            return
        }
                               
        let creatWalletRequest = CreateWalletRequest(name:  encWalletName, m: m, n: n, pubKey: credentials.walletPublickey!, coin: "vcl", network: "livenet", singleAddress: false, usePurpose48: usePurpose48, useNativeSegwit: false)
                
        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(creatWalletRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: creatWalletRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(CreateWalletModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while create wallet: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while create wallet: \(String(describing: error))")
                return
            }
        }
    }
    
    public func joinWallet(credentials: Credentials, walletId: String, handler: @escaping (JoinWalletModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v2/wallets/\(walletId)/copayers"
        let url = self.bwsUrl + api
        
        let encoder = JSONEncoder()
        let customData = WalletCustomData(walletPrivKey: credentials.walletPrivateKey!)
        let jsonCustomData = try!encoder.encode(customData)
        let strCustomData = String(data: jsonCustomData, encoding: .utf8)!
        let encCustomData = SjclEncryptMessage.encrypt(msg: strCustomData, encryptKey: credentials.personalEncryptingKey)
        
        let encCopayerName = SjclEncryptMessage.encrypt(msg: "VclCopayer", encryptKey: credentials.sharedEncryptingKey!)
                               
        let copayerSignature = try!signMessage(data: [encCopayerName!, credentials.xPublicKey, credentials.requestPublicKey], privateKey: credentials.walletPrivateKey!.hexadecimal()!)
            
        let joinWalletRequest = JoinWalletRequest(walletId: walletId, name: encCopayerName!, xPubKey: credentials.xPublicKey, requestPubKey: credentials.requestPublicKey, customData: encCustomData!, copayerSignature:copayerSignature, coin: "vcl")
                
        let jsonJoin = try!encoder.encode(joinWalletRequest)
        let strJoin = String(data: jsonJoin, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strJoin))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: joinWalletRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(JoinWalletModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while join wallet: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while join wallet: \(String(describing: error))")
                return
            }
        }
    }

    public func createTxProposal(credentials: Credentials, address: String, amount: Double, msg: String, handler: @escaping (TxProposalModel?, String?)->()) {

        checkCredentials(credentials: credentials)

        let api = "/v2/txproposals/"
        let url = self.bwsUrl + api
        
        let outputs = [OutputModel(toAddress: address, amount: getSatoshis(amount: amount), message: nil)]
        let transactionRequest = TransactionRequest(outputs: outputs, excludeUnconfirmedUtxos: false, dryRun: false, operation: "send", customData: msg, excludeMasternode: true)
                
        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(transactionRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: transactionRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(TxProposalModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while create txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while create txProposal: \(String(describing: error))")
                return
            }
        }
    }

    public func publishTxProposal(credentials: Credentials, txProposal: TxProposalModel, handler: @escaping (TxProposalModel?, String?)->()) {

        checkCredentials(credentials: credentials)
        
        let api = "/v2/txproposals/\(txProposal.id!)/publish"
        let url = self.bwsUrl + api
        
        let proposalSignature = TxBuilder.publishTxp(credentials: credentials, txp: txProposal, privateKey: credentials.requestPrivateKey.raw)
        let publishRequest = PublishRequest(proposalSignature: proposalSignature)

        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(publishRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: publishRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(TxProposalModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while publish txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while publish txProposal: \(String(describing: error))")
                return
            }
        }
    }
    
    public func pushTxProposal(credentials: Credentials, txProposal: TxProposalModel, handler: @escaping (TxProposalModel?, String?)->()) {

        checkCredentials(credentials: credentials)

        let api = "/v2/txproposals/\(txProposal.id!)/signatures/"
        let url = self.bwsUrl + api
        
        let signatures = TxBuilder.signTxp(credentials: credentials, txp: txProposal)
        let pushRequest = PushRequest(signatures: signatures)

        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(pushRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: pushRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(TxProposalModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while push txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while push txProposal: \(String(describing: error))")
                return
            }
        }
    }
 
    public func broadcastTxProposal(credentials: Credentials, txProposal: TxProposalModel, handler: @escaping (TxProposalModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v1/txproposals/\(txProposal.id!)/broadcast/"
        let url = self.bwsUrl + api
                
        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: "{}"))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: nil,
                             encoding: URLEncoding.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(TxProposalModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while broadcast txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while broadcast txProposal: \(String(describing: error))")
                return
            }
        }
    }
    
    public func broadcastTxProposal(credentials: Credentials, txpId: String, handler: @escaping (TxProposalModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v1/txproposals/\(txpId)/broadcast/"
        let url = self.bwsUrl + api
                
        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: "{}"))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: nil,
                             encoding: URLEncoding.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(TxProposalModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while broadcast txProposal: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while broadcast txProposal: \(String(describing: error))")
                return
            }
        }
    }

    public func removeTxProposal(credentials: Credentials, txpId: String, handler: @escaping (Bool?, String?)->()) {
        
        checkCredentials(credentials: credentials)

        let api = "/v1/txproposals/\(txpId)"
        let url = self.bwsUrl + api
                
        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: "{}"))

        Alamofire.AF.request(url,
                             method: .delete,
                             parameters: nil,
                             encoding: URLEncoding.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                if(value is Dictionary<String, Any>){
                    handler(nil, "Error while remove txProposal: \(String(describing: value))")
                }else {
                    handler(true, nil)
                }
            case .failure(let error):
                handler(nil, "Error while remove txProposal: \(String(describing: error))")
                return
            }
        }
    }
    
    public func broadcastRawTx(credentials: Credentials, rawTx: String, network: String = "livenet", handler: @escaping (String?, String?)->()) {

        checkCredentials(credentials: credentials)

        let api = "/v1/broadcast_raw/"
        let url = self.bwsUrl + api
        
        let broadcastRaxTxRequest = BroadcastRawTxRequest(network: network, rawTx: rawTx)
                
        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(broadcastRaxTxRequest)
        let strData = String(data: jsonData, encoding: .utf8)!

        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: broadcastRaxTxRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = value as? String
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while broadcast rawTx: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while broadcast rawTx: \(String(describing: error))")
                return
            }
        }
    }
    public func createAddress(credentials: Credentials, ignoreMaxGap: Bool = false, handler: @escaping (AddressModel?, String?)->()) {
        
        checkCredentials(credentials: credentials)
        
        let api = "/v4/addresses/"
        let url = self.bwsUrl + api
                
        let createAddressRequest = CreateAddressRequest(ignoreMaxGap: ignoreMaxGap)
        
        let encoder = JSONEncoder()
        let jsonData = try!encoder.encode(createAddressRequest)
        let strData = String(data: jsonData, encoding: .utf8)!
        let headers = HTTPHeaders(credentials.getHeaders(method: "post", url: api, args: strData))

        Alamofire.AF.request(url,
                             method: .post,
                             parameters: createAddressRequest,
                             encoder: JSONParameterEncoder.default,
                             headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let result = toModel(AddressModel.self, value: value)
                if(result != nil ) {
                    handler(result, nil)
                }else {
                    handler(nil, "Error while create address: \(String(describing: value))")
                }
            case .failure(let error):
                handler(nil, "Error while create address: \(String(describing: error))")
                return
            }
        }
    }
    
    public func openWallet(credentials: Credentials, handler: @escaping (Credentials?, WalletModel?, String?)->()) {
        self.getWalletStatus(credentials: credentials, handler: handler)
    }
    
    public func importWallet(credentials: Credentials, handler: @escaping (Credentials?, WalletModel?, String?)->()) {
        self.getWalletStatus(credentials: credentials, handler: handler)
    }

    public func createAndJoinWallet(credentials: Credentials, walletName: String, m: Int = 1, n: Int = 1, handler: @escaping (JoinWalletModel?, String?)->()) {
        
        func createWalletCallback(createWalletModel: CreateWalletModel?, errMsg: String?) {
            if(errMsg == nil ) {
                self.joinWallet(credentials: credentials, walletId: createWalletModel!.walletId, handler: handler)
            }else{
                handler(nil, errMsg)
            }
        }

        try!self.createWallet(credentials: credentials, walletName: walletName, m: m, n: n, handler: createWalletCallback)
        
    }

    public func activateMasternode(credentials: Credentials, txid: String, vout: Int, masternodeKey: String, addr: String, port: Int, handler: @escaping (MasternodeBroadcastModel?, String?)->()) {
        
        func maternodePingCallback(masternodePingModel: MasternodePingModel?, errMsg: String?) {
            if(errMsg == nil ) {
                let signPrivateKey = try!credentials.privateKey(subPath: getDerivedSubPath(path: masternodePingModel!.path))
                let pingPrivateKey = getPrivateKeyFromWif(data: masternodeKey)
                let rawTx = signMasternode(txid: masternodePingModel!.txid, vout: Int(masternodePingModel!.vout)!, signPrivateKey: signPrivateKey, pingHash: masternodePingModel!.pingHash, pingPrivateKey: pingPrivateKey, addr: addr, port: port)
                
                self.broadcastMasternode(credentials: credentials, rawTx: rawTx, masternodeKey: masternodeKey, handler: handler)
            }else{
                handler(nil, errMsg)
            }
        }
        
        getMasternodePing(credentials: credentials, txid: txid, vout: vout, handler: maternodePingCallback)
        
    }
    
    public func sendToAddress(credentials: Credentials, address: String, amount: Double, msg: String, handler: @escaping (TxProposalModel?, String?)->()) {
                
        func createTxProposalCallback(value: TxProposalModel?, errMsg: String?) {
            if (errMsg == nil) {
                self.publishTxProposal(credentials: credentials, txProposal: value!, handler: publishTxProposalCallback)
            }else{
                handler(nil, errMsg)
            }
        }
        func publishTxProposalCallback(value: TxProposalModel?, errMsg: String?) {
            if (errMsg == nil) {
                self.pushTxProposal(credentials: credentials, txProposal: value!, handler: pushTxProposalCallback)
            }else{
                handler(nil, errMsg)
            }
        }
        func pushTxProposalCallback(value: TxProposalModel?, errMsg: String?) {
            if (errMsg == nil) {
                self.broadcastTxProposal(credentials: credentials, txProposal: value!, handler: handler)
            }else{
                handler(nil, errMsg)
            }
        }
        
        try!self.createTxProposal(credentials: credentials, address: address, amount: amount, msg: msg, handler: createTxProposalCallback)

    }
}


