//
//  AccountKeySetup.swift
//  ProtonCore-Authentication-KeyGeneration - Created on 06/01/2020
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

/// class for key migeration phase 2
final class AccountKeySetup {
    
    /// account level key. on phase 2 user key used for
    struct UserKey {
        /// armored key
        let armoredKey: String
        
        /// user key password salt - shoudle be 128 bits
        let passwordSalt: Data
        
        /// hashed password with password salt. this is the key passphrase
        let hashedPassword: String
    }
    
    /// address key
    struct AddressKey {
        
        /// address id
        let addressId: String
        
        /// armored key
        let armoredKey: String
        
        /// on phase 2. token used to encrypt address key
        let token: String
        
        /// detached signaute.
        let signature: String
        
        /// signed key metadata
        ///     simple:
        ///     let keylist: [[String: Any]] = [[
        ///         "Fingerprint": "key.fingerprint",  //address key fingerprint
        ///         "SHA256Fingerprints": "key.sha256fingerprint" // address key sha256Fingerprint,
        ///         "Primary": 1,    // 1 or 0   is it a primary key
        ///         "Flags": 3    // key flags.   send | receive | etc
        ///     ]]
        ///
        ///     let signedKeyList: [String: Any] = [
        ///         "Data": JSON(keylist),      // encode key list to json
        ///         "Signature": SIGNED((JSON(keylist))    // user address key sign detached.
        ///     ]
        let signedKeyList: [String: Any]
    }

    /// new account key struct
    struct GeneratedAccountKey {
        
        /// account level user key
        let userKey: UserKey
        
        /// user address keys
        let addressKeys: [AddressKey]
    }
    
    /// generate account user-key address key. used right after create a new user and address.
    ///   at this moment address doesn't have any key yet
    /// - Parameters:
    ///   - addresses: address object get from api
    ///   - password: user login password
    /// - Returns: `GeneratedAccountKey`
    func generateAccountKey(addresses: [Address], password: String) throws -> GeneratedAccountKey {
        /// generate key salt 128 bits
        let newPasswordSalt: Data = PMNOpenPgp.randomBits(128)
        /// generate key hashed password.
        let newHashedPassword = PasswordHash.hashPassword(password, salt: newPasswordSalt)
        guard let firstAddr = addresses.first(where: { $0.type != .externalAddress }) else {
            throw KeySetupError.keyGenerationFailed
        }
        var error: NSError?
        // in our system the PGP `User ID Packet-Tag 13` we use email address as username and email address
        let armoredUserKey = HelperGenerateKey(firstAddr.email, firstAddr.email, newHashedPassword.data(using: .utf8), "x25519", 0, &error)
        if let err = error {
            throw err
        }
        
        /// blow logic could be in function `setupSetupKeysRoute`.
        ///   - but for the securty reason. we generate the password and token here.
        ///   - we dont want it keep in the memory and pass cross different functions.
        ///   - so we genrete here and encrypt it here try to keep it in this function scope.        ///

        let addressKeys = try addresses.filter { $0.type != .externalAddress }.map { addr -> AddressKey in
            /// generate address key secret size 32 bytes or 256 bits
            let secret = PasswordHash.random(bits: 256) // generate random 32 bytes
            /// hex string of secret data
            let hexSecret = HMAC.hexStringFromData(secret)
            
            assert(hexSecret.count == 64)
            
            /// generate a new key.  id: address email.  passphrase: hexed secret (should be 64 bytes) with default key type
            var error: NSError?
            let armoredAddrKey = HelperGenerateKey(addr.email, addr.email, hexSecret.data(using: .utf8), "x25519", 0, &error)
            if let err = error {
                throw err
            }
            
            /// generate token.   token is hexed secret encrypted by `UserKey.publicKey`. Note: we don't need to inline sign
            let token = try hexSecret.encryptNonOptional(publicKey: armoredUserKey.publicKey)
            /// gnerenate a detached signature.  sign the hexed secret by
            let tokenSignature = try Crypto().signDetached(plainText: hexSecret, privateKey: armoredUserKey, passphrase: newHashedPassword)

            /// build key matadata list
            let keylist: [[String: Any]] = [[
                "Fingerprint": armoredAddrKey.fingerprint,
                "SHA256Fingerprints": armoredAddrKey.sha256Fingerprint,
                "Primary": 1,
                "Flags": 3 // key flags.  bitmap  send | receive 
            ]]
            
            /// encode to json format
            let jsonKeylist = keylist.json()
            
            /// sign detached. keylist.json signed by primary address key. on signup situation this is the address key we are going to submit.
            let signed = try Crypto().signDetached(plainText: jsonKeylist, privateKey: armoredAddrKey, passphrase: hexSecret)
            let signedKeyList: [String: Any] = [
                "Data": jsonKeylist,
                "Signature": signed
            ]

            return AddressKey(addressId: addr.addressID, armoredKey: armoredAddrKey,
                              token: token, signature: tokenSignature, signedKeyList: signedKeyList)
        }
        
        return GeneratedAccountKey(userKey: UserKey(armoredKey: armoredUserKey,
                                                    passwordSalt: newPasswordSalt,
                                                    hashedPassword: newHashedPassword),
                                   addressKeys: addressKeys)
    }

    /// build up the setupkey route data
    /// - Parameters:
    ///   - password: NO NEED
    ///   - accountKey: generated account key
    ///   - modulus: srp modulus
    ///   - modulusId: modulus id
    /// - Returns: `AuthService.SetupKeysEndpoint`
    func setupSetupKeysRoute(password: String, accountKey: GeneratedAccountKey,
                             modulus: String, modulusId: String) throws -> AuthService.SetupKeysEndpoint {

        // for the login password needs to set 80 bits & srp auth use 80 bits
        let newSaltForKey: Data = PMNOpenPgp.randomBits(80)

        // generate new verifier
        guard let authForKey = try SrpAuthForVerifier(password, modulus, newSaltForKey) else {
            throw KeySetupError.cantHashPassword
        }
        
        let verifierForKey = try authForKey.generateVerifier(2048)

        let passwordAuth = PasswordAuth(modulus_id: modulusId, salt: newSaltForKey.encodeBase64(), verifer: verifierForKey.encodeBase64())

        let addressData = accountKey.addressKeys.map { addressKey -> [String: Any] in
            let address: [String: Any] = [
                "AddressID": addressKey.addressId,
                "PrivateKey": addressKey.armoredKey,
                "Token": addressKey.token,
                "Signature": addressKey.signature,
                "SignedKeyList": addressKey.signedKeyList
            ]
            return address
        }
        return AuthService.SetupKeysEndpoint(addresses: addressData,
                                             privateKey: accountKey.userKey.armoredKey,
                                             keySalt: accountKey.userKey.passwordSalt.encodeBase64(),
                                             passwordAuth: passwordAuth)
    }    
}
