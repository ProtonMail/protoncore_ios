//
//  KeySetupTests.swift
//  ProtonCore-Authentication-KeyGeneration-Tests - Created on 06/01/2020
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

import XCTest

import ProtonCoreDataModel
import ProtonCoreAuthentication
import ProtonCoreObfuscatedConstants
import ProtonCoreHash
@testable import ProtonCoreAuthenticationKeyGeneration
import SwiftOTP
import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif

class KeySetupTests: XCTestCase {

    let strUserkeySalt = "72dc01d02f58dbca117393bff474a8ed"
    let strUserPassword = "12345678"

    let addressJson = """
        { "ID": "testId", "email": "test@example.org", "send": 1, "receive": 1, "status": 1, "type": 1, "order": 1, "displayName": "", "signature": "" }
    """

    let extAddressJson = """
        { "ID": "testId", "email": "externalTest@example.org", "send": 1, "receive": 1, "status": 1, "type": 5, "order": 1, "displayName": "", "signature": "" }
    """
    var testAddress: Address {
        return try! JSONDecoder().decode(Address.self, from: addressJson.data(using: .utf8)!)
    }

    var testExternalAddress: Address {
        return try! JSONDecoder().decode(Address.self, from: extAddressJson.data(using: .utf8)!)
    }

    func testUser(key: Key) -> User {
        User(
            ID: "12345",
            name: "test",
            usedSpace: 0,
            usedBaseSpace: 0,
            usedDriveSpace: 0,
            currency: "CHF",
            credit: 0,
            maxSpace: 100000,
            maxBaseSpace: 50000,
            maxDriveSpace: 50000,
            maxUpload: 100000,
            role: 0,
            private: 1,
            subscribed: [],
            services: 0,
            delinquent: 0,
            orgPrivateKey: nil,
            email: "test@user.ch",
            displayName: "test",
            keys: [key]
        )
    }

    func testAddress(key: Key, type: Address.AddressType) -> Address {
        Address(addressID: "testId", domainID: nil, email: "test@example.org", send: .active, receive: .active, status: .enabled, type: type, order: 1, displayName: "", signature: "", hasKeys: 1, keys: [key])
    }

    private var testBundle: Bundle!
    func content(of name: String) -> String {
        let url = testBundle.url(forResource: name, withExtension: "txt")!
        let content = try! String.init(contentsOf: url)
        return content
    }

    override func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
        #if SPM
        self.testBundle = .module
        #else
        self.testBundle = Bundle(for: type(of: self))
        #endif
    }

    func testAddressKeyGeneration() {
        let keySetup = AddressKeySetup()
        do {
            let userkey = self.content(of: "privatekey_userkey")
            let salt = Data.init(hex: strUserkeySalt)
            let key = try keySetup.generateAddressKey(keyName: "Test key",
                                                      email: "test@test.com",
                                                      armoredUserKey: userkey,
                                                      password: "12345678",
                                                      salt: salt)
            XCTAssertFalse(key.armoredKey.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressKeyGenerationFail() {
        let keySetup = AddressKeySetup()
        do {
            let userkey = self.content(of: "privatekey_userkey")
            _ = try keySetup.generateAddressKey(keyName: "Test key", email: "test@test.com",
                                                armoredUserKey: userkey,
                                                password: "password",
                                                salt: Data())
            XCTFail("should not be here")
        } catch let error {
            XCTAssertEqual(error as? KeySetupError, .invalidSalt)
        }
    }

    func testAddressKeyRouteSetup() {
        let keySetup = AddressKeySetup()

        do {
            let userkey = self.content(of: "privatekey_userkey")
            let salt = Data.init(hex: strUserkeySalt)
            let key = try keySetup.generateAddressKey(keyName: "Test key", email: "test@test.com", armoredUserKey: userkey,
                                                      password: "12345678", salt: salt)
            let route = try keySetup.setupCreateAddressKeyRoute(key: key, addressId: "addressId", isPrimary: true)
            XCTAssertFalse(route.addressID.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
            XCTAssertEqual(route.isPrimary, true)
            XCTAssertNotNil(route.signedKeyList["Data"])
            XCTAssertNotNil(route.signedKeyList["Signature"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAccountKeyGeneration() {
        let keySetup = AccountKeySetup()
        do {
            let key = try keySetup.generateAccountKey(addresses: [testAddress], password: "password")
            XCTAssertFalse(key.addressKeys.isEmpty)
            XCTAssertFalse(key.userKey.armoredKey.isEmpty)
            XCTAssertFalse(key.userKey.passwordSalt.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAccountKeyRouteSetup() {
        let keySetup = AccountKeySetup()

        do {
            let key = try keySetup.generateAccountKey(addresses: [testAddress], password: "password")
            let route = try keySetup.setupSetupKeysRoute(password: "password",
                                                         accountKey: key, modulus: ObfuscatedConstants.modulus,
                                                         modulusId: ObfuscatedConstants.modulusId)
            XCTAssertFalse(route.addresses.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    ///
    func testGenerateRandomSecretEmpty() throws {
        let addrKeySetup = AddressKeySetup()
        let secret = try addrKeySetup.generateRandomSecret()
        XCTAssertFalse(secret.isEmpty)
    }

    func testGenerateRandomSecretSize() throws {
        let addrKeySetup = AddressKeySetup()
        let secret = try addrKeySetup.generateRandomSecret()
        XCTAssertEqual(secret.count, 64)
    }

    ///
    func testAccountSetupExternal() {
        let keySetup = AccountKeySetup()

        do {
            // try to generate external address key
            let rawPassword = "password"
            let key = try keySetup.generateAccountKey(addresses: [testExternalAddress], password: rawPassword)
            XCTAssertFalse(key.userKey.armoredKey.isEmpty)
            let hashedPassword = PasswordHash.passphrase(rawPassword, salt: key.userKey.passwordSalt)
            XCTAssertTrue(hashedPassword.value == key.userKey.password.value)
            let testString = "encrypt&decrypt"
            let encrypted = try key.userKey.armoredKey.encrypt(clearText: testString)

            let clear: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: key.userKey.armoredKey,
                                                                                          passphrase: key.userKey.password)],
                                                      encrypted: encrypted)
            XCTAssertEqual(clear, testString)
            XCTAssertTrue(key.addressKeys.count == 1)
            for addkey in key.addressKeys {
                let token: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: key.userKey.armoredKey,
                                                                                              passphrase: key.userKey.password)],
                                                          encrypted: addkey.token)
                let encrypted = try addkey.armoredKey.encrypt(clearText: testString)
                let clear: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: addkey.armoredKey,
                                                                                              passphrase: Passphrase.init(value: token))],
                                                          encrypted: encrypted)
                XCTAssertEqual(clear, testString)

                let data = key.addressKeys.first?.signedKeyList["Data"] as! String
                let dict = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [[String: Any]]
                XCTAssertNotNil(dict?.first?["SHA256Fingerprints"])
                let flags = dict?.first?["Flags"] as? UInt8
                XCTAssertEqual(flags, KeyFlags.signupExternalKeyFlags.rawValue)
                XCTAssertEqual((flags! & KeyFlags.signifyingExternalAddress.rawValue), KeyFlags.signifyingExternalAddress.rawValue)
                XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
                XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
                let signature = addkey.signedKeyList["Signature"] as! String
                let verified = try Sign.verifyDetached(signature: ArmoredSignature.init(value: signature), plainText: data, verifierKey: addkey.armoredKey, verificationContext: VerificationContext(value: AddressKeySetup.signedKeyListSignatureContext.value, required: .always))
                XCTAssertTrue(verified)
            }

            let route = try keySetup.setupSetupKeysRoute(password: rawPassword,
                                                         accountKey: key, modulus: ObfuscatedConstants.modulus,
                                                         modulusId: ObfuscatedConstants.modulusId)
            XCTAssertFalse(route.addresses.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressSetupExternalAndInternal() {
        let keySetup = AccountKeySetup()

        do {
            // try to generate external address key
            let rawPassword = "password"
            let key = try keySetup.generateAccountKey(addresses: [testAddress, testExternalAddress], password: rawPassword)
            XCTAssertFalse(key.userKey.armoredKey.isEmpty)
            let hashedPassword = PasswordHash.passphrase(rawPassword, salt: key.userKey.passwordSalt)
            XCTAssertTrue(hashedPassword.value == key.userKey.password.value)
            let testString = "encrypt&decrypt"

            let encrypted = try key.userKey.armoredKey.encrypt(clearText: testString)
            let clear: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: key.userKey.armoredKey,
                                                                                          passphrase: key.userKey.password)],
                                                      encrypted: encrypted)
            XCTAssertEqual(clear, testString)
            XCTAssertTrue(key.addressKeys.count == 2)
            for (index, addkey) in key.addressKeys.enumerated() {
                let token: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: key.userKey.armoredKey,
                                                                                              passphrase: key.userKey.password)],
                                                          encrypted: addkey.token)
                let encrypted = try addkey.armoredKey.encrypt(clearText: testString)
                let clear: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: addkey.armoredKey,
                                                                                              passphrase: Passphrase.init(value: token))],
                                                          encrypted: encrypted)
                XCTAssertEqual(clear, testString)

                XCTAssertNotNil(addkey.signedKeyList["Data"])
                XCTAssertNotNil(addkey.signedKeyList["Signature"])
                let data = addkey.signedKeyList["Data"] as! String
                let dict = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [[String: Any]]
                XCTAssertNotNil(dict?.first?["SHA256Fingerprints"])

                let flags = dict?.first?["Flags"] as? UInt8
                switch index {
                case 0:
                    // internal address
                    XCTAssertEqual(flags, KeyFlags.signupKeyFlags.rawValue)
                    XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
                    XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
                case 1:
                    // external address
                    XCTAssertEqual(flags, KeyFlags.signupExternalKeyFlags.rawValue)
                    XCTAssertEqual((flags! & KeyFlags.signifyingExternalAddress.rawValue), KeyFlags.signifyingExternalAddress.rawValue)
                    XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
                    XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
                default:
                    XCTFail("Index not expected")
                }
                let signature = addkey.signedKeyList["Signature"] as! String
                let verified = try Sign.verifyDetached(signature: ArmoredSignature.init(value: signature), plainText: data, verifierKey: addkey.armoredKey, verificationContext: VerificationContext(value: AddressKeySetup.signedKeyListSignatureContext.value, required: .always))
                XCTAssertTrue(verified)
            }
            let route = try keySetup.setupSetupKeysRoute(password: rawPassword,
                                                         accountKey: key, modulus: ObfuscatedConstants.modulus,
                                                         modulusId: ObfuscatedConstants.modulusId)
            XCTAssertFalse(route.addresses.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
            XCTAssertTrue(route.addresses.count == 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressSetupExternal() {
        let keySetup = AddressKeySetup()

        do {
            let userkey = self.content(of: "privatekey_userkey")
            let salt = Data.init(hex: strUserkeySalt)
            let rawPassword = "12345678"
            let key = try keySetup.generateAddressKey(keyName: "Test key", email: "external@test.com", armoredUserKey: userkey,
                                                      password: rawPassword, salt: salt, addrType: .externalAddress)
            let hashedPassword = PasswordHash.passphrase(rawPassword, salt: salt)

            let route = try keySetup.setupCreateAddressKeyRoute(key: key, addressId: "addressId", isPrimary: true)
            XCTAssertFalse(route.addressID.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
            XCTAssertEqual(route.isPrimary, true)
            XCTAssertNotNil(route.signedKeyList["Data"])
            XCTAssertNotNil(route.signedKeyList["Signature"])

            XCTAssertFalse(key.armoredKey.isEmpty)
            let testString = "encrypt&decrypt"
            let token: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: ArmoredKey.init(value: userkey),
                                                                                          passphrase: hashedPassword)],
                                                      encrypted: key.token)
            let encrypted = try key.armoredKey.encrypt(clearText: testString)

            let clear: String = try Decryptor.decrypt(decryptionKeys: [DecryptionKey.init(privateKey: key.armoredKey,
                                                                                          passphrase: Passphrase.init(value: token))],
                                                      encrypted: encrypted)
            XCTAssertEqual(clear, testString)
            let data = key.signedKeyList["Data"] as! String
            let dict = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [[String: Any]]
            XCTAssertNotNil(dict?.first?["SHA256Fingerprints"])
            let flags = dict?.first?["Flags"] as? UInt8
            XCTAssertEqual(flags, KeyFlags.signupExternalKeyFlags.rawValue)
            XCTAssertEqual((flags! & KeyFlags.signifyingExternalAddress.rawValue), KeyFlags.signifyingExternalAddress.rawValue)
            XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
            XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
            let signature = key.signedKeyList["Signature"] as! String
            let verified = try Sign.verifyDetached(signature: ArmoredSignature.init(value: signature), plainText: data, verifierKey: key.armoredKey, verificationContext: VerificationContext(value: AddressKeySetup.signedKeyListSignatureContext.value, required: .always))
            XCTAssertTrue(verified)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressActivationInternal() {
        let keyActivation = AddressKeyActivation()
        do {
            let passphrase = "hello world"
            let privateKey = self.content(of: "testdata_privatekey")
            let publicKey = privateKey.publicKey
            let activation = try passphrase.encryptNonOptional(withPubKey: publicKey, privateKey: privateKey, passphrase: passphrase)

            let testKey = Key(keyID: "keyID", privateKey: privateKey, activation: activation)

            let keyActivationEndpoint = try keyActivation.activeAddressKeys(user: testUser(key: testKey), address: testAddress(key: testKey, type: .protonDomain), mailboxPassword: passphrase)

            let data = keyActivationEndpoint?.signedKeyList["Data"] as! String
            let dict = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [[String: Any]]
            XCTAssertNotNil(dict?.first?["SHA256Fingerprints"])
            let flags = dict?.first?["Flags"] as? UInt8
            XCTAssertEqual(flags, KeyFlags.signupKeyFlags.rawValue)
            XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
            XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
            XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
            let armoredUserKey = ArmoredKey.init(value: privateKey)
            let signature = keyActivationEndpoint?.signedKeyList["Signature"] as! String
            let verified = try Sign.verifyDetached(signature: ArmoredSignature.init(value: signature), plainText: data, verifierKey: armoredUserKey, verificationContext: VerificationContext(value: AddressKeySetup.signedKeyListSignatureContext.value, required: .always))
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressActivationExternal() {
        let keyActivation = AddressKeyActivation()
        do {
            let passphrase = "hello world"
            let privateKey = self.content(of: "testdata_privatekey")
            let publicKey = privateKey.publicKey
            let activation = try passphrase.encryptNonOptional(withPubKey: publicKey, privateKey: privateKey, passphrase: passphrase)
            let testKey = Key(keyID: "keyID", privateKey: privateKey, activation: activation)

            let keyActivationEndpoint = try keyActivation.activeAddressKeys(user: testUser(key: testKey), address: testAddress(key: testKey, type: .externalAddress), mailboxPassword: passphrase)

            let data = keyActivationEndpoint?.signedKeyList["Data"] as! String
            let dict = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [[String: Any]]
            XCTAssertNotNil(dict?.first?["SHA256Fingerprints"])
            let flags = dict?.first?["Flags"] as? UInt8
            XCTAssertEqual(flags, KeyFlags.signupExternalKeyFlags.rawValue)
            XCTAssertEqual((flags! & KeyFlags.signifyingExternalAddress.rawValue), KeyFlags.signifyingExternalAddress.rawValue)
            XCTAssertEqual((flags! & KeyFlags.verifySignatures.rawValue), KeyFlags.verifySignatures.rawValue)
            XCTAssertEqual((flags! & KeyFlags.encryptNewData.rawValue), KeyFlags.encryptNewData.rawValue)
            let armoredUserKey = ArmoredKey.init(value: privateKey)
            let signature = keyActivationEndpoint?.signedKeyList["Signature"] as! String
            let verified = try Sign.verifyDetached(signature: ArmoredSignature.init(value: signature), plainText: data, verifierKey: armoredUserKey, verificationContext: VerificationContext(value: AddressKeySetup.signedKeyListSignatureContext.value, required: .always))
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
