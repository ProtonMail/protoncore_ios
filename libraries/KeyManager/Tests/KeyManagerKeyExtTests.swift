//
//  KeyManagerKeyExtTests.swift
//  ProtonCore-KeyManager-Tests - Created on 4/19/21.
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
@testable import ProtonCore_KeyManager

class KeyManagerKeyExtTests: TestCaseBase {

    func testKeysBinPrivKeys() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let binKeys = [key].binPrivKeys
        XCTAssertTrue(binKeys.count > 0)
    }
    
    func testKeysBinPrivKeyArray() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let binKeys = [key].binPrivKeysArray
        XCTAssertTrue(!binKeys.isEmpty)
    }
    
    func testKeyBinPrivKeys() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let binKey = key.binPrivKeys
        XCTAssertTrue(!binKey.isEmpty)
    }
    
    func testKeyPublicKey() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let pubKey = key.publicKey
        XCTAssertTrue(pubKey.contains("-----BEGIN PGP PUBLIC KEY BLOCK-----"))
    }
    
    func testKeyFingerprint() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let fingerprint = key.fingerprint
        XCTAssertFalse(fingerprint.isEmpty)
    }

    func testKeyShortFingerprint() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: "",
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        let fingerprint = key.shortFingerprint
        XCTAssertFalse(fingerprint.isEmpty)
    }
    
    func testKeyDecPassphraseMigrated() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let addrTokenSignature = content(of: "data1_address_key_token_sign")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignature,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        let addrClearPwd = content(of: "data1_address_key_clear_pass")
        
        let addrPwd = try? key.passphrase(userBinKeys: [userkey.unArmor!], mailboxPassphrase: userPassphrase)
        XCTAssertTrue(addrPwd == addrClearPwd)
    }
    
    func testKeyDecPassphraseMigratedWrongSig() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let addrTokenSignatureFake = content(of: "data1_address_key_token_sign_fake")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignatureFake,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        XCTAssertThrowsError(try key.passphrase(userBinKeys: [userkey.unArmor!], mailboxPassphrase: userPassphrase)){ error in
            XCTAssertEqual(error as! Key.Errors, Key.Errors.tokenSignatureVerificationFailed)
        }
    }
    
    func testKeyDecPassphraseMigratedWrongCiphertext() {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = "fake token"
        let addrTokenSignature = content(of: "data1_address_key_token_sign")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignature,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        XCTAssertThrowsError(try key.passphrase(userBinKeys: [userkey.unArmor!], mailboxPassphrase: userPassphrase)){ error in
            XCTAssertEqual(error as! Key.Errors, Key.Errors.tokenDecryptionFailed)
        }
    }
    
    func testKeyDecPassphraseNonMigrated() {
        let addrPriv = content(of: "data1_address_key")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: nil, signature: nil,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        
        let addrPwd = try? key.passphrase(userBinKeys: [userkey.unArmor!], mailboxPassphrase: userPassphrase)
        XCTAssertTrue(addrPwd == userPassphrase)
    }
    
    func testKeyDecryptMessage() throws {
        let addrPriv = content(of: "data1_address_key")
        let addrToken = content(of: "data1_address_key_token")
        let addrTokenSignature = content(of: "data1_address_key_token_sign")
        let key = Key.init(keyID: "RURLmXOKy9onIRPIIztVh0mZaFLZjWkOrd5H-_jEZzCwmmEgYLXxtwpx0xUTk9nYvbDh9sG_P_KeeyRBCDgCIQ==",
                           privateKey: addrPriv, keyFlags: 3, token: addrToken, signature: addrTokenSignature,
                           activation: nil, active: 0, version: 3, primary: 1, isUpdated: false)
        
        let userkey = content(of: "data1_user_key")
        let userPassphrase = content(of: "data1_user_passphrse")
        let addrClearPwd = content(of: "data1_address_key_clear_pass")
        
        let addrPwd = try? key.passphrase(userBinKeys: [userkey.unArmor!], mailboxPassphrase: userPassphrase)
        XCTAssertTrue(addrPwd == addrClearPwd)
        
        let test = "test"
        let encrypted = try test.encryptNonOptional(withPubKey: addrPriv.publicKey, privateKey: addrPriv, passphrase: addrPwd!)
        let out = try key.decryptMessageNonOptional(encrypted: encrypted, userBinKeys: [userkey.unArmor!], passphrase: userPassphrase)
        XCTAssertTrue(test == out)
    }
}
