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

import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
import Foundation
import ProtonCoreAuthentication
import ProtonCoreDataModel
import ProtonCoreUtilities

/// class for key migeration phase 2
final class AccountKeySetup {

    enum Constants {
        static let ssoKeyGenerationContext = "account.key-token.user-unprivatization"
    }

    /// account level key. on phase 2 user key used for
    struct UserKey {
        /// armored key
        let armoredKey: ArmoredKey

        /// user key password salt - shoudle be 128 bits
        let passwordSalt: Data

        /// hashed password with password salt. this is the key passphrase
        let password: Passphrase
    }

    /// address key
    struct AddressKey {

        /// address id
        let addressId: String

        /// armored key
        let armoredKey: ArmoredKey

        /// address passphrase
        let passphrase: Passphrase

        /// on phase 2. token used to encrypt address key
        let token: ArmoredMessage

        /// detached signaute.
        let signature: ArmoredSignature

        /// signed key metadata
        ///     simple:
        ///     let keylist: [[String: Any]] = [[
        ///         "Fingerprint": "key.fingerprint",  //address key fingerprint
        ///         "SHA256Fingerprints": "key.sha256fingerprint" // address key sha256Fingerprint,
        ///         "Primary": 1,    // 1 or 0   is it a primary key
        ///         "Flags": 3    //ref keyFlags in dataModel
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
        let newPasswordSalt: Data = try PasswordHash.random(bits: PasswordSaltSize.accountKey.int32Bits)
        /// generate key hashed password.
        let userKeyPassphrase = PasswordHash.passphrase(password, salt: newPasswordSalt)

        guard let firstAddr = addresses.first else {
            throw KeySetupError.keyGenerationFailed
        }

        // in our system the PGP `User ID Packet-Tag 13` we use email address as username and email address
        let armoredUserKey = try Generator.generateECCKey(email: firstAddr.email, passphase: userKeyPassphrase)

        /// blow logic could be in function `setupSetupKeysRoute`.
        ///   - but for the securty reason. we generate the password and token here.
        ///   - we dont want it keep in the memory and pass cross different functions.
        ///   - so we genrete here and encrypt it here try to keep it in this function scope.        ///

        let addressKeys = try addresses.map { addr -> AddressKey in
            /// generate addr passphrase
            let addrPassphrase = try PasswordHash.genAddrPassphrase()

            /// generate a new key.  id: address email.  passphrase: hexed secret (should be 64 bytes) with default key type
            let armoredAddrKey = try Generator.generateECCKey(email: addr.email, passphase: addrPassphrase)

            /// generate token.   token is hexed secret encrypted by `UserKey.publicKey`. Note: we don't need to inline sign
            let token = try addrPassphrase.encrypt(publicKey: armoredUserKey)

            /// generate a detached signature.  sign the hexed secret by user key
            let userSigner = SigningKey.init(privateKey: armoredUserKey,
                                             passphrase: userKeyPassphrase)
            /// sign addr passphrase
            let tokenSignature = try addrPassphrase.signDetached(signer: userSigner)

            let keyFlags: KeyFlags
            if addr.type == .externalAddress {
                keyFlags = .signupExternalKeyFlags
            } else {
                keyFlags = .signupKeyFlags
            }
            /// build key matadata list
            let keylist: [[String: Any]] = [[
                "Fingerprint": armoredAddrKey.fingerprint,
                "SHA256Fingerprints": armoredAddrKey.sha256Fingerprints,
                "Primary": 1,
                "Flags": keyFlags.rawValue
            ]]

            /// encode to json format
            let jsonKeylist = keylist.json()

            /// sign detached. keylist.json signed by primary address key. on signup situation this is the address key we are going to submit.
            let addSigner = SigningKey.init(privateKey: armoredAddrKey,
                                            passphrase: addrPassphrase)
            let signed = try Sign.signDetached(signingKey: addSigner, plainText: jsonKeylist, signatureContext: AddressKeySetup.signedKeyListSignatureContext)
            let signedKeyList: [String: Any] = [
                "Data": jsonKeylist,
                "Signature": signed.value
            ]

            return AddressKey(addressId: addr.addressID, armoredKey: armoredAddrKey,
                              passphrase: addrPassphrase,
                              token: token, signature: tokenSignature,
                              signedKeyList: signedKeyList)
        }

        return GeneratedAccountKey(userKey: UserKey(armoredKey: armoredUserKey,
                                                    passwordSalt: newPasswordSalt,
                                                    password: userKeyPassphrase),
                                   addressKeys: addressKeys)
    }

    /// build up the setupkey route data
    /// - Parameters:
    ///   - password: NO NEED
    ///   - accountKey: generated account key
    ///   - modulus: srp modulus
    ///   - modulusId: modulus id
    ///   - orgPublicKey: Organization public key
    ///   - deviceSecret: 32-byte random string as base64. Used in GlobalSSO for `auth/v4/devices`
    /// - Returns: `AuthService.SetupKeysEndpoint`
    func setupSetupKeysRoute(
        password: String,
        accountKey: GeneratedAccountKey,
        modulus: String,
        modulusId: String,
        orgPublicKey: ArmoredKey? = nil,
        deviceSecret: String? = nil
    ) throws -> AuthService.SetupKeysEndpoint {

        let addressData = accountKey.addressKeys.map { addressKey -> [String: Any] in
            let address: [String: Any] = [
                "AddressID": addressKey.addressId,
                "PrivateKey": addressKey.armoredKey.value,
                "Token": addressKey.token.value,
                "Signature": addressKey.signature.value,
                "SignedKeyList": addressKey.signedKeyList
            ]
            return address
        }

        /// for the login password needs to set 80 bits & srp auth use 80 bits
        let newSaltForKey: Data = try PasswordHash.random(bits: PasswordSaltSize.login.int32Bits)

        /// generate new verifier
        guard let authForKey = try SrpAuthForVerifier(password, modulus, newSaltForKey) else {
            throw KeySetupError.cantHashPassword
        }

        let verifierForKey = try authForKey.generateVerifier(2048)

        let passwordAuth = PasswordAuth(modulusID: modulusId, salt: newSaltForKey.encodeBase64(), verifier: verifierForKey.encodeBase64())

        /// Global SSO or magic link
        var orgPrimaryUserKey: ArmoredKey?
        var orgActivationToken: ArmoredSignature?
        if let orgPublicKey {
            (orgPrimaryUserKey, orgActivationToken) = try generateOrgUserKeys(
                accountKey: accountKey,
                orgPublicKey: orgPublicKey
            )
        }

        /// Global SSO
        var encryptedSecret: String?
        if let deviceSecret {
            encryptedSecret = try GetEncryptedSecret().invoke(
                passphrase: accountKey.userKey.password.value,
                deviceSecret: deviceSecret
            )
        }

        return AuthService.SetupKeysEndpoint(
            addresses: addressData,
            privateKey: accountKey.userKey.armoredKey,
            keySalt: accountKey.userKey.passwordSalt.encodeBase64(),
            passwordAuth: passwordAuth,
            orgPrimaryUserKey: orgPrimaryUserKey,
            orgActivationToken: orgActivationToken,
            encryptedSecret: encryptedSecret
        )
    }

    private func generateOrgUserKeys(
        accountKey: GeneratedAccountKey,
        orgPublicKey: ArmoredKey
    ) throws -> (orgPrimaryUserKey: ArmoredKey, orgActivationToken: ArmoredSignature) {
        /// generate 32 byte secret and encode it to hex
        let randomSecret = try PasswordHash.genAddrPassphrase()
        /// encrypt it to the organization key, signing it with the newly created address key and the context account.key-token.user-unprivatization
        guard let primaryAddressKey = accountKey.addressKeys.first else {
            throw KeySetupError.keyGenerationFailed
        }
        let signingKey = SigningKey(privateKey: primaryAddressKey.armoredKey, passphrase: primaryAddressKey.passphrase)
        let orgActivationToken: ArmoredMessage = try Crypto().encryptAndSign(
            plainRaw: .left(randomSecret.value),
            publicKey: orgPublicKey,
            signingKey: signingKey,
            signatureContext: SignatureContext(value: Constants.ssoKeyGenerationContext, isCritical: true)
        )

        /// encrypt a copy of the primary key with the random secret encoded to hex as OrgPrimaryUserKey
        let orgPrimaryUserKey = try Crypto.updatePassphrase(
            privateKey: accountKey.userKey.armoredKey,
            oldPassphrase: accountKey.userKey.password,
            newPassphrase: randomSecret
        )

        return (orgPrimaryUserKey, ArmoredSignature(value: orgActivationToken.value))
    }
}
