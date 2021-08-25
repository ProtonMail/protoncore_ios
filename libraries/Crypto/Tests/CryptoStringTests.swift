//
//  CryptoStringTests.swift
//  ProtonCore-KeyManager-Tests - Created on 4/19/21.
//
//  Copyright (c) 2021 Proton Technologies AG
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
#if canImport(ProtonCore_Crypto_VPN)
@testable import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
@testable import ProtonCore_Crypto
#endif

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
        let message = content(of: "testdata_message_one")
        XCTAssertNoThrow(try message.split())
    }
    
    func testSplitBad() {
        let message = "content(of: testdata_message_one)"
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
    
    func testCheckPasswordBad() {
        let privateKey = "content(of: testdata_privatekey)"
        let check = privateKey.check(passphrase: self.password1)
        XCTAssertFalse(check)
    }
    
    // MARK: test string extension part
    
    func testDecryptMessage() {
        let privateKey = content(of: "testdata_privatekey")
        let encryptedMessage = content(of: "testdata_message_one")
        let rawKey = privateKey.unArmor!
        let clear = try! encryptedMessage.decryptMessage(binKeys: [rawKey], passphrase: self.passphrase)
        XCTAssertTrue(clear!.isEmpty)
        
        let encrypted = try! self.plaintext.encrypt(withPrivKey: privateKey, mailbox_pwd: self.passphrase)
        let clearText = try! encrypted!.decryptMessage(binKeys: [rawKey], passphrase: self.passphrase)!
        
        XCTAssertTrue(clearText == self.plaintext)
    }
    
    func testDecryptMessageWithSinglKeyException() {
        let privateKey = content(of: "testdata_privatekey")
        let encryptedMessage = content(of: "testdata_message_one")
        XCTAssertThrowsError(try encryptedMessage.decryptMessageWithSinglKey(privateKey, passphrase: self.passphrase))
    }
    
    func testDecryptMessageWithSinglKey() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        let encrypted = try! self.plaintext.encrypt(withPubKey: publicKey, privateKey: privateKey, passphrase: passphrase2)
        let clearText = try! encrypted!.decryptMessageWithSinglKey(privateKey, passphrase: passphrase2)!
        XCTAssertTrue(clearText == self.plaintext)
    }

    func testDecryptMessageWithSinglKeyWithoutSign() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        let encrypted = try! self.plaintext.encrypt(withPubKey: publicKey, privateKey: "", passphrase: "")
        let clearText = try! encrypted!.decryptMessageWithSinglKey(privateKey, passphrase: passphrase2)!
        XCTAssertTrue(clearText == self.plaintext)
    }
    
    func testDecryptMessageWithSinglKeyWrongSignPassphrase() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        XCTAssertThrowsError(try self.plaintext.encrypt(withPubKey: publicKey, privateKey: privateKey, passphrase: ""))
    }
    
    func testDecryptMessageWithSinglKeyBad() {
        let privateKey = content(of: "testdata_privatekey2")
        let publicKey = privateKey.publicKey
        XCTAssertThrowsError(try self.plaintext.encrypt(withPubKey: publicKey, privateKey: "privateKeys", passphrase: self.passphrase2))
    }
    
    func testEcryptWithPassword() {
        let encrypted = try! self.plaintext.encrypt(withPwd: self.password2)
        let clearText = try! encrypted?.decrypt(withPwd: self.password2)!
        XCTAssertTrue(clearText == self.plaintext)
    }
}
