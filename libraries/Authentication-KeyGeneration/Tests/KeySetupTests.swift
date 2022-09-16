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

import ProtonCore_DataModel
import ProtonCore_Authentication
import ProtonCore_ObfuscatedConstants
import ProtonCore_Hash
@testable import ProtonCore_Authentication_KeyGeneration
import SwiftOTP
import ProtonCore_Crypto

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
    
    private var testBundle: Bundle!
    func content(of name: String) -> String {
        let url = testBundle.url(forResource: name, withExtension: "txt")!
        let content = try! String.init(contentsOf: url)
        return content
    }
    
    override func setUp() {
        super.setUp()
        self.testBundle = Bundle(for: type(of: self))
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
    func testGenerateRandomSecretEmpty() {
        let addrKeySetup = AddressKeySetup()
        let secret = addrKeySetup.generateRandomSecret()
        XCTAssertFalse(secret.isEmpty)
    }
    
    func testGenerateRandomSecretSize() {
        let addrKeySetup = AddressKeySetup()
        let secret = addrKeySetup.generateRandomSecret()
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
                
                for (key, value) in addkey.signedKeyList {
                    XCTAssertTrue(["Data", "Signature"].contains(key))
                    let v = value as! String
                    if key == "Data" {
                        XCTAssertTrue(v.contains("SHA256Fingerprints"))
                        if index == 0 {
                            XCTAssertTrue(v.contains("\"Flags\":3"))
                        } else if index == 1 {
                            XCTAssertTrue(v.contains("\"Flags\":7"))
                        }
                    }
                }
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
            XCTAssertTrue(data.contains("SHA256Fingerprints"))
            XCTAssertTrue(data.contains("\"Flags\":7"))
            let signature = key.signedKeyList["Signature"] as! String
            let verified = try Sign.verifyDetached(signature:ArmoredSignature.init(value: signature),
                                                   plainText: data, verifierKey: key.armoredKey)
            XCTAssertTrue(verified)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
