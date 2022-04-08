//
//  OpenPGP+String+Extension.swift
//  ProtonCore-Features - Created on 22.05.2018.
//
//  Copyright (c) 2022 Proton Technologies AG
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
    
    func verifyMessage(verifier: [Data], binKeys: [Data], passphrase: String, time: Int64) throws -> ExplicitVerifyMessage {
        return try Crypto().decryptVerifyNonOptional(encrypted: self, publicKey: verifier, privateKey: binKeys, passphrase: passphrase, verifyTime: time)
    }
    
    func verifyMessage(verifier: [Data], userKeys: [Data], keys: [Key], passphrase: String, time: Int64) throws -> ExplicitVerifyMessage? {
        var firstError: Error?
        for key in keys {
            do {
                let addressKeyPassphrase = try key.passphrase(userBinKeys: userKeys, mailboxPassphrase: passphrase)
                return try Crypto().decryptVerifyNonOptional(encrypted: self,
                                                             publicKey: verifier,
                                                             privateKey: key.privateKey,
                                                             passphrase: addressKeyPassphrase,
                                                             verifyTime: time)
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
    
    public func encrypt(withKey key: Key, userKeys: [Data], mailbox_pwd: String) throws -> String? {
        let addressKeyPassphrase = try key.passphrase(userBinKeys: userKeys, mailboxPassphrase: mailbox_pwd)
        return try Crypto().encryptNonOptional(plainText: self,
                                               publicKey: key.publicKey,
                                               privateKey: key.privateKey,
                                               passphrase: addressKeyPassphrase)
    }

    internal func decryptBody(keys: [Key], passphrase: String) throws -> String? {
        var firstError: Error?
        for key in keys {
            do {
                return try self.decryptMessageWithSingleKeyNonOptional(key.privateKey, passphrase: passphrase)
            } catch let error {
                if firstError == nil {
                    firstError = error
                }
                // PMLog.D(error.localizedDescription)
            }
        }
        
        if let error = firstError {
            throw error
        }
        return nil
    }
    
    internal func decryptBody(keys: [Key], userKeys: [Data], passphrase: String) throws -> String? {
        var firstError: Error?
        for key in keys {
            do {
                let addressKeyPassphrase = try key.passphrase(userBinKeys: userKeys, mailboxPassphrase: passphrase)
                return try self.decryptMessageWithSingleKeyNonOptional(key.privateKey, passphrase: addressKeyPassphrase)
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
