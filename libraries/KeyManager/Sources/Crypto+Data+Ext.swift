//
//  Crypto+Data.swift
//  ProtonCore-Crypto - Created on 9/11/19.
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCore_Crypto
import ProtonCore_DataModel

extension Data {
    
    public func decryptAttachment(keyPackage: Data, userKeys: [Data], passphrase: String, keys: [Key]) throws -> Data? {
        var firstError: Error?
        for key in keys {
            do {
                if let token = key.token, key.signature != nil { // have both means new schema. key is
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        return try Crypto().decryptAttachment(keyPacket: keyPackage,
                                                              dataPacket: self,
                                                              privateKey: key.privateKey,
                                                              passphrase: plaitToken)
                    }
                } else if let token = key.token { // old schema with token - subuser. key is embed singed
                    if let plaitToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        // TODO:: try to verify signature here embeded signature
                        return try Crypto().decryptAttachment(keyPacket: keyPackage,
                                                              dataPacket: self,
                                                              privateKey: key.privateKey,
                                                              passphrase: plaitToken)
                    }
                } else {// normal key old schema
                    return try Crypto().decryptAttachment(keyPacket: keyPackage,
                                                          dataPacket: self,
                                                          privateKey: userKeys,
                                                          passphrase: passphrase)
                }
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
            }
        }
        if let error = firstError {
            throw error
        }
        return nil
    }
    
    // key packet part
    public func getSessionFromPubKeyPackage(userKeys: [Data], passphrase: String, keys: [Key]) throws -> SymmetricKey? {
        var firstError: Error?
        for key in keys {
            do {
                if let token = key.token, key.signature != nil { // have both means new schema. key is
                    if let plainToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        return try Crypto().getSession(keyPacket: self, privateKey: key.privateKey, passphrase: plainToken)
                    }
                } else if let token = key.token { // old schema with token - subuser. key is embed singed
                    if let plainToken = try token.decryptMessage(binKeys: userKeys, passphrase: passphrase) {
                        // TODO:: try to verify signature here embeded signature
                        return try Crypto().getSession(keyPacket: self, privateKey: key.privateKey, passphrase: plainToken)
                    }
                } else {// normal key old schema
                    return try Crypto().getSession(keyPacket: self, privateKeys: userKeys, passphrase: passphrase)
                }
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
            }
        }
        if let error = firstError {
            throw error
        }
        return nil
    }
}
