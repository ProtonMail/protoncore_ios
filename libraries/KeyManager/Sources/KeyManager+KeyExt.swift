//
//  Key+Ext.swift
//  ProtonCore-KeyManager - Created on 4/19/21.
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
import Crypto
import ProtonCore_Crypto
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
    
    // Mark - Key v2
    
    /// Key_1_2  the func to get the real passphrase that can decrypt the body. TODO:: add unit tests
    /// - Parameters:
    ///   - userBinKeys: user keys need to unarmed to binary
    ///   - passphrase: user key
    /// - Throws: crypt exceptions
    /// - Returns: passphrase
    public func passphrase(userBinKeys: [Data], passphrase: String) throws -> String {
        if let token = self.token, self.signature != nil { // have both means new schema. key is
            if let plainToken = try token.decryptMessage(binKeys: userBinKeys, passphrase: passphrase) {
                return plainToken
            }
        } else if let token = self.token { // old schema with token - subuser. key is embed singed
            if let plainToken = try token.decryptMessage(binKeys: userBinKeys, passphrase: passphrase) {
                // TODO:: try to verify signature here embeded signature
                return plainToken
            }
        }
        return passphrase
    }
    
    public func passphrase(userKey: Key, passphrase: String) throws -> String {
        return try self.passphrase(userBinKeys: [userKey.binPrivKeys], passphrase: passphrase)
    }
    
    // Backup function
    //    func addressPassphrase(for addressKey: Key) throws -> String {
    //        let (userKey, passphrase) = try self.userKeyAndPassphrase(for: addressKey)
    //
    //        return try addressKey.passphrase(userKey: userKey, passphrase: passphrase)
    //
    //
    //        switch (addressKey.token, addressKey.signature) {
    //        case (.none, .none):  // old schema
    //            guard let passphrase = passphrases?[addressKey.keyID] else {
    //                throw Errors.noRequiredPassphrase
    //            }
    //            return passphrase
    //
    //        case let (.some(token), .none): // old schema with subuser
    //            let (userKey, passphrase) = try self.userKeyAndPassphrase(for: addressKey)
    //            let clearToken = try Decryptor.decrypt(decryptionKeys: [.init(privateKey: userKey.privateKey, passphrase: passphrase)], value: token)
    //            return clearToken
    //
    //        case let (.some(token), .some(signature)): // new schema
    //            let (userKey, passphrase) = try self.userKeyAndPassphrase(for: addressKey)
    //            let clearToken = try Decryptor.decryptNewKey(token: token, userKey: userKey.privateKey, passphrase: passphrase, signature: signature)
    //            return clearToken
    //
    //        default:
    //            assert(false, "Could not find address passphrase - should not happen in real life")
    //            throw Errors.noRequiredPassphrase
    //        }
    //    }
    
    // TODO:: later we need move this one to [key] extension. that can save a few loops when using the old schema
    public func decryptMessage(encrypted: String, userBinKeys privateKeys: [Data], passphrase: String) throws -> String? {
        if let token = self.token, self.signature != nil { // have both means new schema. key is
            // newScheme += 1
            if let plaitToken = try token.decryptMessage(binKeys: privateKeys, passphrase: passphrase) {
                // TODO:: try to verify signature here Detached signature
                // if failed return a warning
                return try encrypted.decryptMessageWithSinglKey(self.privateKey, passphrase: plaitToken)
            }
        } else if let token = self.token { // old schema with token - subuser. key is embed singed
            // oldSchemaWithToken += 1
            if let plaitToken = try token.decryptMessage(binKeys: privateKeys, passphrase: passphrase) {
                // TODO:: try to verify signature here embeded signature
                return try encrypted.decryptMessageWithSinglKey(self.privateKey, passphrase: plaitToken)
            }
        } else {// normal key old schema
            // oldSchema += 1
            return try encrypted.decryptMessageWithSinglKey(self.privateKey, passphrase: passphrase)
            // TODO:: will need to use decryptMessage(binKeys: self.binPrivKeysArray, passphrase: passphrase)
        }
        return nil
    }
}
