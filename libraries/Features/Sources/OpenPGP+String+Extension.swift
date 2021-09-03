//
//  OpenPGPExtension.swift
//  ProtonMail
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import ProtonCore_Authentication
import ProtonCore_Common
#if canImport(ProtonCore_Crypto_VPN)
import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
import ProtonCore_Crypto
#endif
import ProtonCore_DataModel
import ProtonCore_KeyManager

// MARK: - OpenPGP String extension

extension String {
    
    func verifyMessage(verifier: [Data], binKeys: [Data], passphrase: String, time : Int64) throws -> ExplicitVerifyMessage? {
        return try Crypto().decryptVerify(encrytped: self, publicKey: verifier, privateKey: binKeys, passphrase: passphrase, verifyTime: time)
    }
    
    func verifyMessage(verifier: [Data], userKeys: [Data], keys: [Key], passphrase: String, time : Int64) throws -> ExplicitVerifyMessage? {
        var firstError : Error?
        for key in keys {
            do {
                if let token = key.token, key.signature != nil { //have both means new schema. key is
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        //PMLog.D(signature)
                        return try Crypto().decryptVerify(encrytped: self,
                                                          publicKey: verifier,
                                                          privateKey: key.privateKey,
                                                          passphrase: plaitToken, verifyTime: time)
                    }
                } else if let token = key.token { //old schema with token - subuser. key is embed singed
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        //TODO:: try to verify signature here embeded signature
                        return try Crypto().decryptVerify(encrytped: self,
                                                          publicKey: verifier,
                                                          privateKey: key.privateKey,
                                                          passphrase: plaitToken, verifyTime: time)
                    }
                } else {//normal key old schema
                    return try Crypto().decryptVerify(encrytped: self,
                                                      publicKey: verifier,
                                                      privateKey: userKeys,
                                                      passphrase: passphrase, verifyTime: time)
                }
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
                //PMLog.D(error.localizedDescription)
            }
        }
        if let error = firstError {
            throw error
        }
        return nil
    }
    
    public func encrypt(withKey key: Key, userKeys: [Data], mailbox_pwd: String) throws -> String? {
        if let token = key.token, key.signature != nil { //have both means new schema. key is
            if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: mailbox_pwd) {
                //PMLog.D(signature)
                return try Crypto().encrypt(plainText: self,
                                            publicKey: key.publicKey,
                                            privateKey: key.privateKey,
                                            passphrase: plaitToken)
            }
        } else if let token = key.token { //old schema with token - subuser. key is embed singed
            if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: mailbox_pwd) {
                //TODO:: try to verify signature here embeded signature
                return try Crypto().encrypt(plainText: self,
                                            publicKey: key.publicKey,
                                            privateKey: key.privateKey,
                                            passphrase: plaitToken)
            }
        }
        return try Crypto().encrypt(plainText: self,
                                    publicKey:  key.publicKey,
                                    privateKey: key.privateKey,
                                    passphrase: mailbox_pwd)
    }

    internal func decryptBody(keys: [Key], passphrase: String) throws -> String? {
        var firstError : Error?
        for key in keys {
            do {
                return try self.decryptMessageWithSinglKey(key.privateKey, passphrase: passphrase)
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
                //PMLog.D(error.localizedDescription)
            }
        }
        
        if let error = firstError {
            throw error
        }
        return nil
    }
    
    internal func decryptBody(keys: [Key], userKeys: [Data], passphrase: String) throws -> String? {
        var firstError : Error?
        for key in keys {
            do {
                if let token = key.token, key.signature != nil { //have both means new schema. key is
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        //TODO:: try to verify signature here Detached signature
                        // if failed return a warning
//                        PMLog.D(signature)
                        return try self.decryptMessageWithSinglKey(key.privateKey, passphrase: plaitToken)
                    }
                } else if let token = key.token { //old schema with token - subuser. key is embed singed
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        //TODO:: try to verify signature here embeded signature
                        return try self.decryptMessageWithSinglKey(key.privateKey, passphrase: plaitToken)
                    }
                } else {//normal key old schema
                    return try self.decryptMessage(binKeys: keys.binPrivKeysArray, passphrase: passphrase)
                }
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
                //PMLog.D(error.localizedDescription)
            }
        }
        
        if let error = firstError {
            throw error
        }
        return nil
    }
}
