//
//  SjclEncryptMessage.swift
//  kkk
//
//  Created by john on 2021/6/21.
//

import Foundation
import JavaScriptCore

public class SjclEncryptMessage {
 
    public static func encrypt(msg: String, encryptKey: String) -> String? {

        let jsContext = JSContext()
        // set up exception handler for javascript errors
        jsContext?.exceptionHandler = { context, exception in
            if let exec = exception {
                print("JS Exception:", exec.toString()!)
            }
        }

        guard let path = Bundle(for: Credentials.self).path(forResource: "VclWalletKit", ofType: "bundle") else {
            return nil
        }
        guard let jsBundle = Bundle(path: path) else {
            return nil
        }

        if let jsSourcePath = jsBundle.path(forResource: "sjcl", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                jsContext?.evaluateScript(jsSourceContents)
                let ret = jsContext?.evaluateScript("sjcl.encrypt(sjcl.codec.base64.toBits(\"" + encryptKey + "\"),'" + msg + "'," + "{ks: 128, iter: 1})")
                return ret?.toString()! ?? nil
                
            } catch {
                return nil
            }
        }
        return nil
    }
    
    public static func decrypt(msg: String, encryptKey: String) -> String? {
        let jsContext = JSContext()
        // set up exception handler for javascript errors
        jsContext?.exceptionHandler = { context, exception in
            if let exec = exception {
                print("JS Exception:", exec.toString()!)
            }
        }
        
        guard let path = Bundle(for: Credentials.self).path(forResource: "VclWalletKit", ofType: "bundle") else {
            return nil
        }
        guard let jsBundle = Bundle(path: path) else {
            return nil
        }

        if let jsSourcePath = jsBundle.path(forResource: "sjcl", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                jsContext?.evaluateScript(jsSourceContents)
                let ret = jsContext?.evaluateScript("sjcl.decrypt(sjcl.codec.base64.toBits(\"" + encryptKey + "\"),'" + msg + "'," + "{ks: 128, iter: 1})")
                return ret?.toString()! ?? nil
            } catch {
                return nil
            }
        }
        return nil
    }
}


