//
//  AddressKeyActivation.swift
//  ProtonCore-Authentication-KeyGeneration - Created on 05/23/2020
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

#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import OpenPGP
import Foundation
import ProtonCore_Authentication
import ProtonCore_DataModel
import ProtonCore_Utilities
import ProtonCore_Hash
import ProtonCore_Crypto

final class AddressKeyActivation {
    
    enum KeyActivationError: Error {
        case noUserKey
    }
    
    /// V1 key activation flow
    /// - Parameters:
    ///   - user: user object. we will use the user.keys
    ///   - address: addresses
    ///   - mailboxPassword: mailbox password
    /// - Returns: activation endpoint
    func activeAddressKeysV1(user: User, address: Address, mailboxPassword: String) throws -> AuthService.KeyActivationEndpointV1? {
        for index in address.keys.indices {
            let key = address.keys[index]
            if let activation = key.activation {
                
                guard let firstUserKey = user.keys.first else {
                    throw KeyActivationError.noUserKey
                }
                
                let token = try activation.decryptMessageWithSingleKeyNonOptional(firstUserKey.privateKey, passphrase: mailboxPassword)
                let new_private_key = try Crypto.updatePassphrase(privateKey: key.privateKey, oldPassphrase: token, newPassphrase: mailboxPassword)
                let keylist: [[String: Any]] = [[
                    "Fingerprint": key.privateKey.fingerprint,
                    "Primary": 1,
                    "Flags": KeyFlags.signupKeyFlags.rawValue
                ]]
                let jsonKeylist = keylist.json()
                let signed = try Crypto().signDetached(plainText: jsonKeylist, privateKey: new_private_key, passphrase: mailboxPassword)
                let signedKeyList: [String: Any] = [
                    "Data": jsonKeylist,
                    "Signature": signed
                ]
                let api = AuthService.KeyActivationEndpointV1(addrID: key.keyID, privKey: new_private_key, signedKL: signedKeyList)
                return api
            }
        }
        
        return nil
    }
    
    /// V2 key activation flow
    /// - Parameters:
    ///   - user: User
    ///   - address: address
    ///   - hashedPassword: hased password
    /// - Returns: api endpoint
    func activeAddressKeys(user: User, address: Address, mailboxPassword: String) throws -> AuthService.KeyActivationEndpoint? {
        for index in address.keys.indices {
            let key = address.keys[index]
            if let activation = key.activation {
                
                guard let firstUserKey = user.keys.first else {
                    throw KeyActivationError.noUserKey
                }
                
                let token = try activation.decryptMessageWithSingleKeyNonOptional(firstUserKey.privateKey, passphrase: mailboxPassword)
                                
                // generate random 32 bytes
                let secret = PasswordHash.random(bits: 256)
                /// hex string of secret data
                let hexSecret = HMAC.hexStringFromData(secret)
                
                // use the new hexed secret to update the address private key
                let updatedPrivateKey = try Crypto.updatePassphrase(privateKey: key.privateKey, oldPassphrase: token, newPassphrase: hexSecret)
                
                /// encrypt token
                let encToken = try Crypto().encryptNonOptional(plainText: hexSecret, publicKey: firstUserKey.privateKey.publicKey)
                /// gnerenate a detached signature.  sign the hexed secret by
                let tokenSignature = try Crypto().signDetached(plainText: hexSecret, privateKey: firstUserKey.privateKey, passphrase: mailboxPassword)
                
                let keylist: [[String: Any]] = [[
                    "Fingerprint": updatedPrivateKey.fingerprint,
                    "SHA256Fingerprints": updatedPrivateKey.sha256Fingerprint,
                    "Primary": 1,
                    "Flags": KeyFlags.signupKeyFlags.rawValue
                ]]
                let jsonKeylist = keylist.json()
                let signed = try Crypto().signDetached(plainText: jsonKeylist, privateKey: updatedPrivateKey, passphrase: hexSecret)
                let signedKeyList: [String: Any] = [
                    "Data": jsonKeylist,
                    "Signature": signed
                ]
                
                let api = AuthService.KeyActivationEndpoint(addrID: key.keyID, privKey: updatedPrivateKey, signedKL: signedKeyList,
                                                            token: encToken, signature: tokenSignature, primary: key.primary)
                return api
            }
        }
        
        return nil
    }
}
