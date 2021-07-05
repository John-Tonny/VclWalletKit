//
//  Transaction.swift
//  kkk
//
//  Created by john on 2021/6/23.
//

import Foundation
import BitcoinCore
import HdWalletKit
import OpenSslKit
import Secp256k1Kit

public class TxBuilder {

    public static func publishTxp(credentials: Credentials, txp: TxProposalModel, privateKey: Data) -> String {
        
        let signType = 1
        let fullTransaction = self.getFullTransaction(credentials: credentials, txp: txp)
                
        let raw = TransactionSerializer.serialize(transaction: fullTransaction) + UInt32(signType)
        
        return signMessage(data: raw, privateKey: privateKey)
    }
    
    public static func signTxp(credentials: Credentials, txp: TxProposalModel) -> [String] {
        
        let fullTransaction = self.getFullTransaction(credentials: credentials, txp: txp)
        
        var hdPrivateKeyHashs = [HDPrivateKeyHash]()
        var privateKeys = [HDPrivateKey]()
        var signatureIndexs = [SignatureIndex]()
        
        for input in txp.inputs! {
            let privateKey = try!credentials.privateKey(subPath:  getDerivedSubPath(path: input.path))
            hdPrivateKeyHashs.append(HDPrivateKeyHash(path: input.path, privateKey: privateKey))
        }

        privateKeys = hdPrivateKeyHashs.removeDuplicates().map { $0.privateKey}
        
        for key in privateKeys {
            let signatureIndex = try!getSignatures(credentials: credentials, fullTransaction: fullTransaction, privateKey: key)
            signatureIndexs += signatureIndex
        }
        
        var signatures = [String]()
        let sortedSignatures = signatureIndexs.sorted { $0.index < $1.index }
        for signature in sortedSignatures {
            signatures.append(signature.signature)
        }
        
        return signatures
     }

    public static func getSignatures(credentials: Credentials, fullTransaction: FullTransaction, privateKey: HDPrivateKey) throws -> [SignatureIndex] {
        
        var fullTransaction = fullTransaction
        
        let inputsCopy = fullTransaction.inputs.map { InputCopy(withPreviousOutputTxHash: $0.previousOutputTxHash, previousOutputIndex: $0.previousOutputIndex, script: $0.signatureScript, sequence: $0.sequence)}
        
        var signatureIndexs = [SignatureIndex]()
        var index = 0
        for input in fullTransaction.inputs {
            let script = input.signatureScript
            let addr = try!credentials.getScriptFromPublicKey(hdPublicKey: privateKey.publicKey(), type: .p2pkh)
            if( script == addr.lockingScript ) {
                let signatureIndex = self.calcSignature(fullTransaction: fullTransaction, index: index, script: script, privateKey: privateKey)
                signatureIndexs.append(signatureIndex)
                
                fullTransaction.inputs[index].signatureScript = Data()
                var i = 0
                for input in inputsCopy {
                    fullTransaction.inputs[i].signatureScript = input.signatureScript
                    i += 1
                }
            }
            index += 1
        }
        return signatureIndexs
    }
    
    public static func calcSignature(fullTransaction: FullTransaction, index: Int, script: Data, privateKey: HDPrivateKey) -> SignatureIndex {
        
        let signType = 1
        for input in fullTransaction.inputs {
            input.signatureScript = Data()
        }
        fullTransaction.inputs[index].signatureScript = script

        let raw = TransactionSerializer.serialize(transaction: fullTransaction) + UInt32(signType)
        return SignatureIndex(signature: signData(data: raw, privateKey: privateKey.raw), index: index)
    }
    
    public static func getFullTransaction(credentials:Credentials, txp: TxProposalModel) -> FullTransaction {
        let sequence = 4294967295
        let header = Transaction(version: 2, lockTime: 0)

        var inputs = [Input]()
        var totalAmount = 0
        for input in txp.inputs! {
            let script = input.scriptPubKey.hexadecimal()
            
            inputs.append(Input(
                            withPreviousOutputTxHash: input.txid.reversed(),
                            previousOutputIndex: input.vout,
                            script: script!,
                            sequence: sequence))
            totalAmount += input.satoshis
        }
        
        var outputs = [Output]()
        var totalOutputAmount = 0
        var index = 0
        for output in txp.outputs {
            let lockingScript = try!credentials.getScriptFromAddress(address: output.toAddress!)
            outputs.append(Output(withValue: output.amount, index: index, lockingScript: lockingScript, transactionHash: Data(), type: .p2pkh))
            index +=  1
            totalOutputAmount += output.amount
        }
        
        let changeAmount = totalAmount - totalOutputAmount - txp.fee
        
        if (changeAmount > 0) {
            let lockingScript = try!credentials.getScriptFromAddress(address: txp.changeAddress!.address)
            outputs.append(Output(withValue: changeAmount, index: index, lockingScript: lockingScript, transactionHash: Data(), type: .p2pkh))
        }
                
        return FullTransaction(header:header, inputs:inputs, outputs: outputs)
    }
}
    




