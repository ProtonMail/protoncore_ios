//
//  ArmoredTests.swift
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
import ProtonCoreCryptoGoInterface
import ProtonCoreCrypto

class ArmoredTests: CryptoTestBase {
    
    func testArmoredKey() {
        XCTAssertNotEqual("\(ArmoredKey.self)", "\(String.self)")
        XCTAssertNotEqual("\(ArmoredMessage.self)", "\(String.self)")
        XCTAssertNotEqual("\(ArmoredSignature.self)", "\(String.self)")
        
        XCTAssertEqual("\(ArmoredKey.self)", "\(Armored<ArmoredType.Key>.self)")
        XCTAssertEqual("\(ArmoredMessage.self)", "\(Armored<ArmoredType.Message>.self)")
        XCTAssertEqual("\(ArmoredSignature.self)", "\(Armored<ArmoredType.Signature>.self)")
        
        let check = "Test"
        let armoredKey: ArmoredKey = ArmoredKey.init(value: check)
        XCTAssertEqual(check, armoredKey.value)
    }
    
    func testUnArmoredKey() {
        XCTAssertNotEqual("\(UnArmoredKey.self)", "\(Data.self)")
        XCTAssertEqual("\(UnArmoredKey.self)", "\(UnArmored<UnArmoredType.Key>.self)")
        
        let check = random(length: 32)
        let unarmored: UnArmoredKey = UnArmoredKey.init(value: check)
        XCTAssertEqual(check, unarmored.value)
    }
    
    func testArmoredExtensionSplit() {
        let testMessage = content(of: "testdata_pgp_message")
        let armoredMessage = ArmoredMessage.init(value: testMessage)
        XCTAssertNoThrow( try armoredMessage.split() )
    }
    
    func testExtensionEncryptPrivateKey() {
        
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing Armored<Key> extension. encrypt clear text. no signature."
        do {
            let armoredKey = ArmoredKey.init(value: privKey)
            let armoredMessage: ArmoredMessage = try armoredKey.encrypt(clearText: clearText)
            
            let decryptionKey = DecryptionKey.init(privateKey: armoredKey,
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let check: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessage)
            XCTAssertEqual(check, clearText)
        } catch {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testExtensionEncryptPublicKey() {
        
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing Armored<Key> extension. encrypt clear text. no signature."
        let pubKey = privKey.publicKey
        do {
            let armoredKey = ArmoredKey.init(value: pubKey)
            let armoredMessage: ArmoredMessage = try armoredKey.encrypt(clearText: clearText)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let check: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessage)
            XCTAssertEqual(check, clearText)
        } catch {
            XCTFail("Should not happen: \(error)")
        }
    }
}
