//
//  WalletModel.swift
//  kkk
//
//  Created by john on 2021/6/20.
//

import Foundation
import HdWalletKit

public struct WalletModel: Codable {
    var wallet: WalletCoreModel
    let preferences: PreferencesModel?
    let pendingTxps: [PendingTxpsModel]
    let pendingAtomicSwapTxps: [PendingTxpsModel]?
    let balance: BalanceModel
    
    struct PreferencesModel: Codable {
        let copayerId: String?
        let createdOn: Int?
        let email: String?
        let language: String?
        let unit: String?
        let version: String?
        let walletId: String?
    }
}

struct WalletCoreModel: Codable {
    let addressType: String
    let coin: String
    var copayers: [CopayerModel]
    let createdOn: Int
    let derivationStrategy: String
    let id: String
    let m: Int
    let n: Int
    var name: String
    let network: String
    let scanStatus: String?
    let singleAddress: Bool
    let status: String
    let version: String
    let addressManager: AddressManagerModel
    let pubKey: String
    let publicKeyRing: [PublicKeyRingModel]
}

struct AddressManagerModel: Codable {
    let version: Int
    let derivationStrategy: String
    let receiveAddressIndex: Int
    let changeAddressIndex: Int
    let copayerIndex: Int
}

struct CopayerModel: Codable{
    let coin: String
    let createdOn: Int
    let id: String
    var name: String
    let requestPubKeys: [RequestPubKeyMode]
    let version: Int
    let xPubKey: String
    let requestPubKey: String
    let signature: String
    let customData: String
}

struct RequestPubKeyMode: Codable {
    let key: String
    let signature: String
}

struct PublicKeyRingModel: Codable {
    let xPubKey: String
    let requestPubKey: String
}

public struct PendingTxpsModel: Codable {
    let version: Int
    let createdOn: Int
    let id: String
    let walletId: String
    let creatorId: String
    let coin: String
    let network: String
    let outputs: [OutputModel]
    let amount: Int
    let message: String?
    let payProUrl: String?
    let changeAddress: ChangeAddressModel
    let inputs: [InputModel]
    let walletM: Int
    let walletN: Int
    let requiredSignatures: Int
    let requiredRejections: Int
    let status: String
    let inputPaths: [String]
    let actions: [ActionModel]
    let outputOrder: [UInt]
    let fee: Int
    let feeLevel: String
    let feePerKb: Int
    let excludeUnconfirmedUtxos: Bool
    let addressType: String
    let customData: String
    let proposalSignature: String
    let isInstantSend: Bool?
    let derivationStrategy: String
    let creatorName: String
    let txid: String?
    let broadcastedOn: Int?
    let proposalSignaturePubKey: String?
    let proposalSignaturePubKeySig: String?
    let raw: String?

    let atomicswap: AtomicswapDataModel?
    let atomicswapAddr: String?
    let atomicswapSecretHash: String?
}

struct OutputModel: Codable {
    let toAddress: String?
    let amount: Int?
    let message: String?
}

struct InputModel: Codable {
    let txid: String
    let vout: UInt
    let address: String
    let scriptPubKey: String
    let satoshis:Int
    let confirmations: Int
    let locked: Bool
    let path: String
    let publicKeys: [String]?
}

struct ActionModel: Codable {
    let version: String?
    let createdOn: Int?
    let copayerId: String?
    let type: String?
    let signatures: [String]?
    let xpub: String?
    let comment: String?
}

struct ChangeAddressModel: Codable {
    let version: String
    let createdOn: Int
    let address: String
    let walletId: String
    let coin: String
    let network: String
    let isChange: Bool
    let path: String
    let publicKeys: [String]?
    let type: String
    let hasActivity: Bool?
    let beRegistered: Bool?
}

struct AtomicswapDataModel: Codable{
    let  secretHash: String
    let initiate: Bool
    let secret: String
    let contract: String
    let redeem: Bool
    let atomicSwap: Bool
    let lockTime: Int
}

struct BalanceModel: Codable {
    var totalAmount = 0
    var lockedAmount = 0
    var totalConfirmedAmount = 0
    var lockedConfirmedAmount = 0
    var availableAmount = 0
    var availableConfirmedAmount = 0
    var byAddress: [ByAddressModel]
    
    /*
    enum BalanceKeys: String, CodingKey {
        case totalAmount = "totalAmount"
        case lockedAmount = "lockedAmount"
        case totalConfirmedAmount = "totalConfirmedAmount"
        case lockedConfirmedAmount = "lockedConfirmedAmount"
        case availableAmount = "availableAmount"
        case availableConfirmedAmount = "availableConfirmedAmount"
        //case picURL = "pic_url"
    }

    init(from decoder: Decoder) throws{
        let value = try? decoder.container(keyedBy: BalanceKeys.self)
        
        totalAmount = (try? value?.decode(Int.self, forKey: .totalAmount)) ?? 0
        // picURL = (try? value?.decode(String.self, forKey: .picURL)) ?? ""
        
        totalAmount = (try? value?.decode(Int.self, forKey: .totalAmount)) ?? 0
        lockedAmount = (try? value?.decode(Int.self, forKey: .lockedAmount)) ?? 0
        totalConfirmedAmount = (try? value?.decode(Int.self, forKey: .totalConfirmedAmount)) ?? 0
        lockedConfirmedAmount = (try? value?.decode(Int.self, forKey: .lockedConfirmedAmount)) ?? 0
        availableAmount = (try? value?.decode(Int.self, forKey: .availableAmount)) ?? 0
        availableConfirmedAmount = (try? value?.decode(Int.self, forKey: .availableConfirmedAmount)) ?? 0
    }
    */
}

struct ByAddressModel: Codable{
    let address: String
    let path: String
    let amount: Int
}

public struct AddressModel: Codable {
    let address: String
    let coin: String
    let createdOn: Int
    let isChange: Bool
    let network: String
    let path: String
    let publicKeys: [String]
    let type: String
    let version: String
    let walletId: String
    let hasActivity: Bool?
    let beRegistered: Bool?
}

public struct TransactionHistoryModel: Codable{
    let id: String
    let txid: String
    let confirmations: Int
    let blockheight: Int
    let fees: Int?
    let time: Int
    let size: Int
    let amount: Int
    let action: String
    let addressTo: String?
    let outputs: [OutputModel]
    let dust: Bool
    let encryptedMessage: String?
    let message: String?
    let creatorName: String?
    let hasUnconfirmedInputs: Bool?
    let customData: String?
}

public struct MasternodeModel: Codable {
    let createdOn: Int
    let walletId: String
    let txid: String
    let masternodeKey: String
    let coin: String
    let network: String
    let address: String
    let payee: String
    let status: String
    let daemonversion: String
    let sentinelversion: String
    let sentinelstate: String
    let lastseen: Int
    let activeseconds: Int
    let lastpaidtime: Int
    let lastpaidblock: Int
    let pingretries: Int
}

public struct MasternodePingModel: Codable {
    let txid: String
    let vout: String
    let coin: String
    let network: String
    let address: String
    let publicKeys: [String]
    let path: String
    let confirmations: Int
    let currentHeight: Int
    let pingHeight: Int
    let pingHash: String
}

public struct MasternodeStatusModel: Codable {
    var id: String?
    let address: String
    let payee: String
    let status: String
    // let pprotocol: String
    let daemonversion: String
    let sentinelversion: String
    let sentinelstate: String
    let lastseen: Int
    let activeseconds: Int
    let lastpaidtime: Int
    let lastpaidblock: Int
    let pingretries: UInt
}

public struct MasternodeBroadcastModel: Codable {
    var id: String?
    var outpoint: String?
    var addr: String?
    var overall: String?
    var error: String?
}

public struct MasternodeRemoveModel: Codable {
    let n: UInt
    let ok: String
}

public struct MasternodeCollateralModel: Codable {
    let address: String
    let satoshis: Int
    let amount: Int
    let scriptPubKey: String
    let txid: String
    let vout: Int
    let locked: Bool
    let coinbase: Bool
    let confirmations: Int
    let path: String
    let publicKeys: [String]
}

public struct CreateWalletModel: Codable {
    let walletId: String
}

public struct JoinWalletModel: Codable {
    let copayerId: String
    let wallet: WalletCoreModel
}

public struct TxProposalModel: Codable {
    let type: String?
    let creatorName: String?
    let createdOn: Int?
    let txid: String?
    let id: String?
    let walletId: String?
    let creatorId: String?
    let coin: String?
    let network: String?
    let message: String?
    let payProUrl: String?
    let from: String?
    let changeAddress: ChangeAddressModel?
    let inputs: [InputExtendedModel]?
    let outputs: [OutputExtendedModel]
    let outputOrder: [UInt]
    let walletM: UInt
    let walletN: UInt
    let requiredSignatures: UInt
    let requiredRejections: UInt
    let status: String
    let actions: [ActionModel]?
    let feeLevel: String?
    let feePerKb: Int
    let excludeUnconfirmedUtxos: Bool
    let addressType: String
    let customData: String?
    let amount: Int
    let fee: Int
    let version: UInt
    let broadcastedOn: Int?
    let inputPaths: [String]
    let proposalSignature: String?
    let proposalSignaturePubKey: String?
    let proposalSignaturePubKeySig: String?
    let signingMethod: String
    let lowFees: Bool?
    let nonce: Int?
    let gasPrice: Int?
    let gasLimit: Int? // Backward compatibility for BWC <= 8.9.0
    let data: String?  // Backward compatibility for BWC <= 8.9.0
    let tokenAddress: String?
    let multisigContractAddress: String?
    let destinationTag: String?
    let invoiceID: String?
    let lockUntilBlockHeight: Int?
    let atomicswap: AtomicswapDataModel?
    let atomicswapAddr: String?
    let atomicswapSecretHash: String?
    
}

struct InputExtendedModel: Codable {
    let address: String
    let amount: Double
    let coinbase: Bool
    let confirmations: Int
    let locked: Bool
    let path: String
    let publicKeys: [String]
    let satoshis: Int
    let scriptPubKey: String
    let txid: String
    let vout: Int
}

struct OutputExtendedModel: Codable {
    let amount: Int
    let address: String?
    let toAddress: String?
    let message: String?
    let data: String?
    let gasLimit: Int?
    let script: String?
}

public struct ResponseErrorModel: Codable {
    let error: String
}

public struct InputCopy: Codable {
    public var previousOutputTxHash: Data
    public var previousOutputIndex: Int
    public var signatureScript: Data
    public var sequence: Int
        
    public init(withPreviousOutputTxHash previousOutputTxHash: Data, previousOutputIndex: Int, script: Data, sequence: Int) {
        self.previousOutputTxHash = previousOutputTxHash
        self.previousOutputIndex = previousOutputIndex
        self.signatureScript = script
        self.sequence = sequence
    }
}

struct HDPrivateKeyHash: Equatable {
    static func == (lhs: HDPrivateKeyHash, rhs: HDPrivateKeyHash) -> Bool {
        return lhs.path == rhs.path
    }
    
    var path: String
    var privateKey: HDPrivateKey
}

