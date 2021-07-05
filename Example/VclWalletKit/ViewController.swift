//
//  ViewController.swift
//  VclWalletKit
//
//  Created by John-Tonny on 07/02/2021.
//  Copyright (c) 2021 John-Tonny. All rights reserved.
//

import UIKit
import VclWalletKit

class ViewController: UIViewController {
    private var bwsApi: WalletApi?
    private var credentials: Credentials?
    
    @IBOutlet weak var txtTxid: UITextField!
    @IBOutlet weak var txtVout: UITextField!
    
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var tvInfo: UITextView!
    @IBOutlet weak var tvMnemonic: UITextView!
    
    @IBAction func btnGetMasternodeStatus(_ sender: Any) {
        if(self.credentials == nil) {
            tvInfo.text = "请先打开钱包！！！"
            return
        }
        
        func myHandler(data: [MasternodeStatusModel]?, errMsg: String? ){
            if( errMsg == nil){
                var info = ""
                for status in data! {
                    info += modelToString(data: status) + "\n"
                }
                tvInfo.text = info
            }else {
                tvInfo.text = errMsg
            }
        }
        
        var txid: String?
        var vout: Int?
        if(txtTxid.text != "" && txtVout.text != ""){
            txid = txtTxid.text!
            vout = Int(txtVout.text!)
        }
        
        self.bwsApi!.getMasternodeStatus(credentials: self.credentials!, txid: txid, vout: vout,  handler: myHandler)

    }
    @IBAction func btnGetMasternodes(_ sender: Any) {
        if(self.credentials == nil) {
             tvInfo.text = "请先打开钱包！！！"
             return
         }
         
         func myHandler(data: [MasternodeModel]?, errMsg: String? ){
             if( errMsg == nil){
                 tvInfo.text = modelToString(data: data!)
                 var info = ""
                 for status in data! {
                     info += modelToString(data: status) + "\n"
                 }
                 tvInfo.text = info
             }else {
                 tvInfo.text = errMsg
             }
         }
         var txid: String?
         var vout: Int?
         if(txtTxid.text != "" && txtVout.text != ""){
             txid = txtTxid.text!
             vout = Int(txtVout.text!)
         }
         
         self.bwsApi!.getMasternodes(credentials: self.credentials!, txid: txid, vout: vout,  handler: myHandler)

    }
    
    @IBAction func btnGetMasternodeCollateral(_ sender: Any) {
        if(self.credentials == nil) {
            tvInfo.text = "请先打开钱包！！！"
            return
        }
        
        func myHandler(data: [MasternodeCollateralModel]?, errMsg: String? ){
            if( errMsg == nil){
                tvInfo.text = modelToString(data: data!)
            }else {
                tvInfo.text = errMsg
            }
        }
        
        self.bwsApi!.getMasternodeCollateral(credentials: self.credentials!, handler: myHandler)
    }
    
    @IBAction func btnSendToAddress(_ sender: Any) {
        if(self.credentials == nil) {
            tvInfo.text = "请先打开钱包！！！"
            return
        }
        func myHandler(data: TxProposalModel?, errMsg: String? ){
            if( errMsg == nil){
                tvInfo.text = modelToString(data: data!)
            }else {
                tvInfo.text = errMsg
            }
        }
        
        self.bwsApi!.sendToAddress(credentials: self.credentials!, address: "SWQ6ssBEakJpd26jW46sj7U6TW3Wj6dXDL", amount: 0.1234, msg: "testIos", handler: myHandler)
    }
    
    @IBAction func btnCreateWallet(_ sender: Any) {
        func myHandler(data: JoinWalletModel?, errMsg: String? ){
             if( errMsg == nil){
                 tvInfo.text = modelToString(data: data!)
             }else {
                 tvInfo.text = errMsg
             }
         }
         
         self.credentials = try!Credentials()
         var words = ""
         for data in self.credentials!.mnemonic {
             words += data + " "
         }
         tvMnemonic.text =  words
         try!self.bwsApi!.createAndJoinWallet(credentials: self.credentials!, walletName: "vclWallet",  handler: myHandler)
      }
    
    @IBAction func btnActivateMasternode(_ sender: Any) {
        if(self.credentials == nil) {
            tvInfo.text = "请先打开钱包！！！"
            return
        }
        func myHandler(data: MasternodeBroadcastModel?, errMsg: String? ){
            if( errMsg == nil){
                tvInfo.text = modelToString(data: data)
            }else {
                tvInfo.text = errMsg
            }
        }
        
        let txid = txtTxid.text!
        let vout = Int(txtVout.text!)
        let address = txtAddress.text!
        let port = Int(txtPort.text!)
        let masternodeKey = "5KZwZZgC82e9VovPLwUSw6BAGama6QiTRmukryz8m51bRiqrTfk"
        self.bwsApi!.activateMasternode(credentials: self.credentials!, txid: txid, vout: vout!, masternodeKey: masternodeKey, addr: address, port: port!, handler: myHandler)
    }
    
    @IBAction func btnGetTxHistory(_ sender: Any) {
        if(self.credentials == nil) {
             tvInfo.text = "请先打开钱包！！！"
             return
         }
         func myHandler(data: [TransactionHistoryModel]?, errMsg: String? ){
             if( errMsg == nil){
                 for item in data! {
                     tvInfo.text = modelToString(data: item)
                     break
                 }
             }else {
                 tvInfo.text = errMsg
             }
         }
         
         self.bwsApi!.getTxHistory(credentials: self.credentials!, handler: myHandler)
        }
    
    @IBAction func btnCreateAddress(_ sender: Any) {
        if(self.credentials == nil) {
            tvInfo.text = "请先打开钱包！！！"
            return
        }
        func myHandler(data: AddressModel?, errMsg: String? ){
            if( errMsg == nil){
                tvInfo.text = modelToString(data: data!)
            }else {
                tvInfo.text = errMsg
            }
        }
        
        let ignoreMaxGap = false
        self.bwsApi!.createAddress(credentials: self.credentials!, ignoreMaxGap: ignoreMaxGap, handler: myHandler)
    }
    
    @IBAction func btnImportWallet(_ sender: Any) {
        btnOpenWallet(sender)
    }
    
    @IBAction func btnOpenWallet(_ sender: Any) {
        func myHandler(credentials: Credentials?, walletModel: WalletModel?, errMsg: String? ){
             if( errMsg == nil){
                 tvInfo.text = modelToString(data: walletModel!)
             }else {
                 tvInfo.text = errMsg
             }
         }
         
         if(tvMnemonic.text == "" || tvMnemonic.text == nil){
             tvInfo.text = "请先输入助记词！！！"
             return
         }
         
         var mnemonics = [String]()
         for chunk in tvMnemonic.text!.split(separator: " ") {
             let word = String(chunk)
             mnemonics.append(word)
         }
         
         self.credentials = try!Credentials(mnemonic: mnemonics)
         self.bwsApi!.openWallet(credentials: self.credentials!, handler: myHandler)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.bwsApi = WalletApi(bwsUrl: "http://52.82.67.41:3232/bws/api")

        txtTxid.allowsEditingTextAttributes = true
         
        txtVout.allowsEditingTextAttributes = true
        txtAddress.allowsEditingTextAttributes = true
        txtPort.allowsEditingTextAttributes  = true
         
        tvMnemonic.allowsEditingTextAttributes = true
        tvMnemonic.borderWidth  = 1
        tvInfo.borderWidth = 1
        tvInfo.allowsEditingTextAttributes = true
         
         
        txtTxid.text = "a60d49836e45058feb6d0acc3c087a991e5ea37c2b5a5c81f89ad61cac58c8a5"
        txtVout.text = "0"
        txtAddress.text = "47.104.25.28"
        txtPort.text = "9900"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
}

