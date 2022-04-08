//
//  Key+Ext.swift
//  ProtonCore-KeyManager - Created on 4/19/21.
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
#if canImport(ProtonCore_Crypto_VPN)
import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
import ProtonCore_Crypto
#endif
import ProtonCore_DataModel

/// Array<Key> extensions
extension Array where Element: Key {
    
    /// loop and combin all keys in binary
    public var binPrivKeys: Data {
        var out = Data()
        var error: NSError?
        for key in self {
            if let privK = ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }
    
    public var binPrivKeysArray: [Data] {
        var out: [Data] = []
        var error: NSError?
        for key in self {
            if let privK = ArmorUnarmor(key.privateKey, &error) {
                out.append(privK)
            }
        }
        return out
    }
}

extension Key {
    
    /// TODO:: need to handle the nil case
    internal var binPrivKeys: Data {
        var error: NSError?
        return ArmorUnarmor(self.privateKey, &error)!
    }
    
    public var publicKey: String {
        return self.privateKey.publicKey
    }
    
    public var fingerprint: String {
        return self.privateKey.fingerprint
    }
    
    @available(*, deprecated, renamed: "shortFingerprint", message: "fix typo")
    public var shortFingerpritn: String {
        return self.shortFingerprint
    }
    
    public var shortFingerprint: String {
        let fignerprint = self.fingerprint
        if fignerprint.count > 8 {
            return String(fignerprint.prefix(8))
        }
        return fignerprint
    }

    public enum Errors: Error {
        case tokenDecryptionFailed
        case tokenSignatureVerificationFailed
        case buildKeyRingFailed
    }

    // Mark - Key v2
    @available(*, deprecated, renamed: "passphrase(userBinKeys:mailboxPassphrase:)")
    public func passphrase(userBinKeys: [Data], passphrase mailboxPassphrase: String) throws -> String {
        try passphrase(userBinKeys: userBinKeys, mailboxPassphrase: mailboxPassphrase)
    }
    /// Key_1_2  the func to get the real passphrase that can decrypt the body. TODO:: add unit tests
    /// - Parameters:
    ///   - userBinKeys: user keys need to unarmed to binary
    ///   - mailboxPassphrase: user password hashed with the key salt
    /// - Throws: crypt exceptions
    /// - Returns: passphrase
    public func passphrase(userBinKeys: [Data], mailboxPassphrase: String) throws -> String {
        guard let token = self.token, let signature = self.signature else {
            return mailboxPassphrase
        }
        
        let plainToken: String
        do {
            plainToken = try token.decryptMessageNonOptional(binKeys: userBinKeys, passphrase: mailboxPassphrase)
        } catch {
            throw Errors.tokenDecryptionFailed
        }

        guard let verificationKeyRing = try Decryptor.buildPublicKeyRing(binKeys: userBinKeys) else {
            throw Errors.buildKeyRingFailed
        }

        let verification = try Decryptor.verifyDetached(signature: signature,
                                                       plainText: plainToken,
                                                       keyRing: verificationKeyRing,
                                                       verifyTime: 0) // Temporary, to support devices with wrong local time
        if verification != true {
            throw Errors.tokenSignatureVerificationFailed
        }
        return plainToken
    }

    @available(*, deprecated, message: "Use version passphrase(userKeys:mailboxPassphrase), all user keys are needed")
    public func passphrase(userKey: Key, passphrase mailboxPassphrase: String) throws -> String {
        try passphrase(userKey: userKey, mailboxPassphrase: mailboxPassphrase)
    }
    
    @available(*, deprecated, message: "Use passphrase(userKeys:mailboxPassphrase), all user keys are needed, not only the primary.")
    public func passphrase(userKey: Key, mailboxPassphrase: String) throws -> String {
        return try self.passphrase(userBinKeys: [userKey.binPrivKeys], mailboxPassphrase: mailboxPassphrase)
    }
    
    public func passphrase(userKeys: [Key], mailboxPassphrase: String) throws -> String {
        return try self.passphrase(userBinKeys: userKeys.map(\.binPrivKeys), mailboxPassphrase: mailboxPassphrase)
    }
    
    @available(*, deprecated, message: "Please use the non-optional variant")
    public func decryptMessage(encrypted: String, userBinKeys privateKeys: [Data], passphrase: String) throws -> String? {
        let addressKeyPassphrase = try self.passphrase(userBinKeys: privateKeys, mailboxPassphrase: passphrase)
        return try encrypted.decryptMessageWithSinglKey(self.privateKey, passphrase: addressKeyPassphrase)
    }
    
    public func decryptMessageNonOptional(encrypted: String, userBinKeys privateKeys: [Data], passphrase: String) throws -> String {
        let addressKeyPassphrase = try self.passphrase(userBinKeys: privateKeys, mailboxPassphrase: passphrase)
        return try encrypted.decryptMessageWithSingleKeyNonOptional(self.privateKey, passphrase: addressKeyPassphrase)
    }
}
