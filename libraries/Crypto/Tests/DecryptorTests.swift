//
//  DecryptorTests.swift
//  ProtonCore-Crypto-Tests - Created on 07/15/22.
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

class DecryptorTests: CryptoTestBase {

    func testDecryptStringNoVerify() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing decrypt a string without verify signature"
        let pubKey = privKey.publicKey
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        cleartext: clearText)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let plainText: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessage)
            XCTAssertEqual(plainText, clearText)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testDecryptDataNoVerify() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearData = random(length: 200)
        let pubKey = privKey.publicKey
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        clearData: clearData)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let plainData: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessage)
            XCTAssertEqual(clearData, plainData)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testDecryptSplitData() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let pubKey = privKey.publicKey
        do {
            let clearText = "testing decrypt split data.(data packet and key packet"
            let encryptMsg: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       cleartext: clearText)
            let split = try encryptMsg.split()
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let plainData: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey], split: split)
            
            let plainString = String(data: plainData, encoding: .utf8)
            
            XCTAssertEqual(clearText, plainString)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testDecryptKeyPacket() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let pubKey = privKey.publicKey
        do {
            let clearText = "testing decrypt key packet only. return a raw session key."
            let encryptMsg: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       cleartext: clearText)
            let split = try encryptMsg.split()
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let sessionKey: SessionKey = try Decryptor.decryptSessionKey(decryptionKeys: [decryptionKey], keyPacket: split.keyPacket)
            XCTAssertTrue(sessionKey.sessionKey.count > 0)
            XCTAssertTrue(sessionKey.algo == .AES256)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testDecryptKeyPacketVerify() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let pubKey = privKey.publicKey
        do {
            let clearText = "testing decrypt key packet and verify the signature."
            let signerKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                            passphrase: Passphrase.init(value: privKeyPassphrase))
            let encryptMsg: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       cleartext: clearText, signerKey: signerKey)
            let split = try encryptMsg.split()
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let sessionKey: SessionKey = try Decryptor.decryptSessionKey(decryptionKeys: [decryptionKey], keyPacket: split.keyPacket)
            XCTAssertTrue(sessionKey.sessionKey.count > 0)
            XCTAssertTrue(sessionKey.algo == .AES256)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
}
