//
//  CryptoStringTests.swift
//  ProtonCore-Crypto-Tests - Created on 4/19/21.
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
@testable import ProtonCore_Crypto

class CryptoStringTests: XCTestCase {
    
    let passphrase = "hello world"
    let passphrase2 = "123"
    let plaintext = "short message\nnext line\n한국어/조선말"
    let password1 = "I am a password"
    let password2 = "I am another password"
    
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
    
    // MARK: testing genernal crypto func wrapper
    
    func testPublicKeySucessed() {
        let privateKey = self.content(of: "testdata_privatekey")
        let pubkey = privateKey.publicKey
        XCTAssertTrue(pubkey.contains("-----BEGIN PGP PUBLIC KEY BLOCK-----"))
        XCTAssertTrue(pubkey.fingerprint == privateKey.fingerprint)
    }
    
    func testPublicKeyFailedOne() {
        let privateKey = "bad"
        let pubkey = privateKey.publicKey
        XCTAssertTrue(pubkey.isEmpty)
    }
    
    func testFingerprint() {
        let privateKey = self.content(of: "testdata_privatekey")
        let fingerprint = privateKey.fingerprint
        XCTAssertTrue(fingerprint.isEmpty == false)
    }
    
    func testSHA256Fingerprint() {
        let privateKey = self.content(of: "testdata_privatekey")
        let fingerprint = privateKey.sha256Fingerprint
        XCTAssertTrue(fingerprint.count == 2)
        XCTAssertTrue(fingerprint[0] == "d94dce8fd130d22bed5790ebf7f0d2817ca3033dd0ebed1292c8f925a0b52558")
        XCTAssertTrue(fingerprint[1] == "8476a4c3478e5af08a0e4654583c42a0d4643041f54bc0783096197e71c2e2fe")
    }
    
    func testFingerprintBad() {
        let privateKey = "self.content(of: testdata_privatekey)"
        let fingerprint = privateKey.fingerprint
        XCTAssertTrue(fingerprint.isEmpty)
    }
    
    func testUnarmor() {
        let privateKey = self.content(of: "testdata_privatekey")
        let rawData = privateKey.unArmor
        XCTAssertTrue(rawData != nil)
    }
    
    func testGetSignature() {
        let signature = self.content(of: "testdata_signed_message")
        let signedMessage = try! signature.getSignature()
        XCTAssertFalse(signedMessage!.isEmpty)
    }
    
    func testGetSignatureFail() {
        let signature = self.content(of: "testdata_signed_message_bad")
        XCTAssertThrowsError(try signature.getSignature())
    }
    
    func testSplit() {
        let message = content(of: "testdata_pgp_message")
        XCTAssertNoThrow(try message.split())
    }
    
    func testSplitBad() {
        let message = "wrong_message"
        XCTAssertThrowsError(try message.split())
    }
    
    func testCheckPassword() {
        let privateKey = content(of: "testdata_privatekey")
        let check = privateKey.check(passphrase: self.passphrase)
        XCTAssertTrue(check)
    }
    
    func testCheckPasswordWrong() {
        let privateKey = content(of: "testdata_privatekey")
        let check = privateKey.check(passphrase: self.password1)
        XCTAssertFalse(check)
    }
    
    // MARK: test string extension part
    
    func testDecryptMessage() {
        let privateKey = content(of: "testdata_privatekey")
        let corruptedMessage = content(of: "testdata_message_no_mdc")
        let rawKey = privateKey.unArmor!
        do {
            _ = try corruptedMessage.decryptMessageNonOptional(binKeys: [rawKey], passphrase: self.passphrase)
        } catch {
            XCTAssertEqual(error as! CryptoError, CryptoError.messageCouldNotBeDecrypted)
        }
        
        let encrypted = try! self.plaintext.encryptNonOptional(withPrivKey: privateKey, mailbox_pwd: self.passphrase)
        let clearText = try! encrypted.decryptMessageNonOptional(binKeys: [rawKey], passphrase: self.passphrase)
        
        XCTAssertEqual(clearText, self.plaintext)
    }
    
    func testDecryptMessageWithSinglKeyException() {
        let privateKey = content(of: "testdata_privatekey")
        let corruptedMessage = content(of: "testdata_message_no_mdc")
        XCTAssertThrowsError(try corruptedMessage.decryptMessageWithSingleKeyNonOptional(ArmoredKey.init(value: privateKey),
                                                                                         passphrase: Passphrase.init(value: self.passphrase)))
    }
    
    func testDecryptMessageWithSinglKey() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        let encrypted = try! self.plaintext.encryptNonOptional(withPubKey: publicKey, privateKey: privateKey, passphrase: passphrase2)
        let clearText = try! encrypted.decryptMessageWithSingleKeyNonOptional(ArmoredKey.init(value: privateKey),
                                                                              passphrase: Passphrase.init(value: self.passphrase2))
        XCTAssertEqual(clearText, self.plaintext)
    }

    func testDecryptMessageWithSinglKeyWithoutSign() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        let encrypted = try! self.plaintext.encryptNonOptional(withPubKey: publicKey, privateKey: "", passphrase: "")
        let clearText = try! encrypted.decryptMessageWithSingleKeyNonOptional(ArmoredKey.init(value: privateKey),
                                                                              passphrase: Passphrase.init(value: self.passphrase2))
        XCTAssertEqual(clearText, self.plaintext)
    }
    
    func testDecryptMessageWithSinglKeyWrongSignPassphrase() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        XCTAssertThrowsError(try self.plaintext.encryptNonOptional(withPubKey: publicKey, privateKey: privateKey, passphrase: ""))
    }
    
    func testDecryptMessageWithSinglKeyBad() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        XCTAssertThrowsError(try self.plaintext.encryptNonOptional(withPubKey: publicKey, privateKey: "privateKeys", passphrase: self.passphrase2))
    }
    
    func testEcryptWithPassword() {
        let encrypted = try! self.plaintext.encryptNonOptional(password: self.password2)
        let clearText = try! encrypted.decryptNonOptional(password: self.password2)
        XCTAssertTrue(clearText == self.plaintext)
    }
}
