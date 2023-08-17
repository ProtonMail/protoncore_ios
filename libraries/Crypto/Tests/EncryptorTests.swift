//
//  EncryptorTests.swift
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

class EncryptorTests: CryptoTestBase {

    func testEncryptNoSign() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing encrypt clear text. no signature."
        let pubKey = privKey.publicKey
        do {
            let armoredMessageA: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        cleartext: clearText,
                                                                        signerKey: nil)
            
            let armoredMessageB: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: privKey),
                                                                        cleartext: clearText,
                                                                        signerKey: nil)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let checkA: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageA)
            let checkB: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageB)
            
            XCTAssertEqual(checkA, checkB)
            XCTAssertEqual(checkB, clearText)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptNoSignWithWrongPassword() {
        let failed = expectation(description: "should call completion block")
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = "wrong password"
        let clearText = "testing encrypt clear text with wrong password. no signature."
        let pubKey = privKey.publicKey
        do {
            let armoredMessageA: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        cleartext: clearText,
                                                                        signerKey: nil)
            XCTAssertTrue(!armoredMessageA.value.isEmpty)
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let checkA: String = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageA)
            XCTAssertEqual(checkA, clearText)
        } catch {
            failed.fulfill()
        }
        wait(for: [failed], timeout: 1.0)
    }
    
    func testEncryptSign() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing encryption & sign"
        let pubKey = privKey.publicKey
        
        let privKeyB = self.content(of: "user_b_privatekey")
        let privKeyPassphraseB = self.content(of: "user_b_privatekey_passphrase")
        
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKeyB),
                                         passphrase: Passphrase.init(value: privKeyPassphraseB))
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       cleartext: clearText,
                                                                       signerKey: signingKey)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let verifyKey = ArmoredKey.init(value: privKeyB.publicKey)
            let verifiedString: VerifiedString = try Decryptor.decryptAndVerify(decryptionKeys: [decryptionKey],
                                                                                value: armoredMessage, verificationKeys: [verifyKey])
            
            switch verifiedString {
            case .unverified(let value, let error):
                XCTFail("Should not happen: \(value) : \(error)")
            case .verified(let value):
                XCTAssertEqual(clearText, value)
            }
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptSignWrongVerify() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing encryption and sign. verify with a wrong public key"
        let pubKey = privKey.publicKey
        
        let privKeyB = self.content(of: "user_b_privatekey")
        let privKeyPassphraseB = self.content(of: "user_b_privatekey_passphrase")
        
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKeyB),
                                         passphrase: Passphrase.init(value: privKeyPassphraseB))
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       cleartext: clearText,
                                                                       signerKey: signingKey)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let verifyKey = ArmoredKey.init(value: pubKey)
            let verifiedString: VerifiedString = try Decryptor.decryptAndVerify(decryptionKeys: [decryptionKey],
                                                                                value: armoredMessage,
                                                                                verificationKeys: [verifyKey])
            
            switch verifiedString {
            case .unverified(let value, let error):
                XCTAssertEqual(value, clearText)
                XCTAssertTrue(error is SignatureVerifyError)
            case .verified(let value):
                XCTFail("\(value)")
            }
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptDataNoSign() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearData = self.random(length: 200)
        let pubKey = privKey.publicKey
        do {
            let armoredMessageA: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        clearData: clearData,
                                                                        signerKey: nil)
            
            let armoredMessageB: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: privKey),
                                                                        clearData: clearData,
                                                                        signerKey: nil)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let checkA: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageA)
            let checkB: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageB)
            
            XCTAssertEqual(checkA, checkB)
            XCTAssertEqual(checkB, clearData)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptDataNoSignWithWrongPassword() {
        let failed = expectation(description: "should call completion block")
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = "wrong password"
        let clearData = self.random(length: 200)
        let pubKey = privKey.publicKey
        do {
            let armoredMessageA: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                        clearData: clearData,
                                                                        signerKey: nil)
            XCTAssertTrue(!armoredMessageA.value.isEmpty)
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let checkA: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey], encrypted: armoredMessageA)
            XCTAssertEqual(checkA, clearData)
        } catch {
            failed.fulfill()
        }
        wait(for: [failed], timeout: 1.0)
    }
    
    func testEncryptDataSign() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearData = self.random(length: 200)
        let pubKey = privKey.publicKey
        
        let privKeyB = self.content(of: "user_b_privatekey")
        let privKeyPassphraseB = self.content(of: "user_b_privatekey_passphrase")
        
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKeyB),
                                         passphrase: Passphrase.init(value: privKeyPassphraseB))
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       clearData: clearData,
                                                                       signerKey: signingKey)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let verifyKey = ArmoredKey.init(value: privKeyB.publicKey)
            let verifiedData: VerifiedData = try Decryptor.decryptAndVerify(decryptionKeys: [decryptionKey],
                                                                            value: armoredMessage, verificationKeys: [verifyKey])
            switch verifiedData {
            case .unverified(let value, let error):
                XCTFail("Should not happen: \(value) : \(error)")
            case .verified(let value):
                XCTAssertEqual(clearData, value)
            }
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptDataSignWrongVerify() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearData = self.random(length: 200)
        let pubKey = privKey.publicKey
        
        let privKeyB = self.content(of: "user_b_privatekey")
        let privKeyPassphraseB = self.content(of: "user_b_privatekey_passphrase")
        
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKeyB),
                                         passphrase: Passphrase.init(value: privKeyPassphraseB))
        do {
            let armoredMessage: ArmoredMessage = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: pubKey),
                                                                       clearData: clearData,
                                                                       signerKey: signingKey)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let verifyKey = ArmoredKey.init(value: pubKey)
            let verifiedData: VerifiedData = try Decryptor.decryptAndVerify(decryptionKeys: [decryptionKey],
                                                                                value: armoredMessage,
                                                                                verificationKeys: [verifyKey])
            
            switch verifiedData {
            case .unverified(let value, let error):
                XCTAssertEqual(value, clearData)
                XCTAssertTrue(error is SignatureVerifyError)
            case .verified(let value):
                XCTFail("\(value)")
            }
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptDataSignSplit() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearData = self.random(length: 200)
        let pubKey = privKey.publicKey
        
        let privKeyB = self.content(of: "user_b_privatekey")
        let privKeyPassphraseB = self.content(of: "user_b_privatekey_passphrase")
        
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKeyB),
                                         passphrase: Passphrase.init(value: privKeyPassphraseB))
        do {
            let splitMessage: SplitPacket = try Encryptor.encryptSplit(publicKey: ArmoredKey.init(value: pubKey),
                                                                       clearData: clearData,
                                                                       signerKey: signingKey)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let verifyKey = ArmoredKey.init(value: privKeyB.publicKey)
            let verifiedString: VerifiedData = try Decryptor.decryptAndVerify(decryptionKeys: [decryptionKey],
                                                                              value: splitMessage,
                                                                              verificationKeys: [verifyKey])
            
            switch verifiedString {
            case .unverified(let value, let error):
                XCTFail("Should not happen. \(value) : \(error)")
            case .verified(let value):
                XCTAssertEqual(clearData, value)
            }
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testEncryptSessionKey() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let random = self.random(length: 32)
        let pubKey = privKey.publicKey
        do {
            
            let sessionKeyCheck = SessionKey.init(sessionKey: random, algo: Algorithm.AES256)
            let based64KeyPacket = try Encryptor.encryptSession(publicKey: ArmoredKey.init(value: pubKey),
                                                                sessionKey: sessionKeyCheck)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            
            let sessionKey = try Decryptor.decryptSessionKey(decryptionKeys: [decryptionKey],
                                                             keyPacket: based64KeyPacket.decode)
            XCTAssertEqual(sessionKey.sessionKey, sessionKeyCheck.sessionKey)
            XCTAssertEqual(sessionKey.algo.value, sessionKeyCheck.algo.value)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    #if !(SPM && os(macOS))
    func testEncryptStream() {
        do {
            let cleartextUrl = self.url(of: "user_a_clear_message")
            let clear = try String(contentsOf: cleartextUrl)
            
            /// on simulator unit tests the document directory is not created by default. call this first if you are looking for  documentDirectory
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let cyphertextUrl = url.appendingPathComponent("test.dat")
            let privKey = self.content(of: "user_a_privatekey")
            let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
            let pubKey = privKey.publicKey
            
            let keyPacket = try Encryptor.encryptStream(publicKey: ArmoredKey.init(value: pubKey),
                                                        clearFile: cleartextUrl,
                                                        cyphertextFile: cyphertextUrl, chunkSize: 2_000_000)
            let size = try FileManager.default.attributesOfItem(atPath: cyphertextUrl.path)[.size] as! UInt64
            XCTAssertTrue(size > 0)
            let dataPacket = try Data(contentsOf: cyphertextUrl)
            XCTAssertNotNil(dataPacket)
            XCTAssertTrue(!keyPacket.isEmpty)
            
            let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: privKey),
                                                   passphrase: Passphrase.init(value: privKeyPassphrase))
            let clearData: Data = try Decryptor.decrypt(decryptionKeys: [decryptionKey],
                                                        split: SplitPacket.init(dataPacket: dataPacket, keyPacket: keyPacket))
            
            let strClear = String(data: clearData, encoding: .utf8)
            
            XCTAssertTrue(clear == strClear)
            
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    #endif
    
    func testEncryptSignWithCriticalContext() throws {
        let signKey = self.content(of: "user_a_privatekey")
        let signKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let decryptKey = self.content(of: "user_b_privatekey")
        let decryptKeyPassphrase = self.content(of: "user_b_privatekey_passphrase")
        let encryptKey = decryptKey.publicKey
        let verifyKey = signKey.publicKey
        let clearText = "testing encryption & sign"
        let contextValue = "test-context"
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: signKey),
                                         passphrase: Passphrase.init(value: signKeyPassphrase))
        let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: decryptKey),
                                               passphrase: Passphrase.init(value: decryptKeyPassphrase))
        let encryptedAndSigned = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: encryptKey),
                                                       cleartext: clearText,
                                                       signerKey: signingKey,
                                                       signatureContext: SignatureContext.init(value: contextValue, isCritical: true))
        let decryptedWithoutContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)]
        )
        if case .verified = decryptedWithoutContext {
            XCTFail()
        }
        let decryptedWithContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)],
            verificationContext: VerificationContext(value: contextValue, required: .always)
        )
        if case .unverified = decryptedWithContext {
            XCTFail()
        }
        let decryptedWithWrongContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)],
            verificationContext: VerificationContext(value: contextValue + "wrong", required: .always)
        )
        if case .verified = decryptedWithWrongContext {
            XCTFail()
        }
    }
    
    func testEncryptSignWithNonCriticalContext() throws {
        let signKey = self.content(of: "user_a_privatekey")
        let signKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let decryptKey = self.content(of: "user_b_privatekey")
        let decryptKeyPassphrase = self.content(of: "user_b_privatekey_passphrase")
        let encryptKey = decryptKey.publicKey
        let verifyKey = signKey.publicKey
        let clearText = "testing encryption & sign"
        let contextValue = "test-context"
        let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: signKey),
                                         passphrase: Passphrase.init(value: signKeyPassphrase))
        let decryptionKey = DecryptionKey.init(privateKey: ArmoredKey.init(value: decryptKey),
                                               passphrase: Passphrase.init(value: decryptKeyPassphrase))
        let encryptedAndSigned = try Encryptor.encrypt(publicKey: ArmoredKey.init(value: encryptKey),
                                                       cleartext: clearText,
                                                       signerKey: signingKey,
                                                       signatureContext: SignatureContext.init(value: contextValue, isCritical: false))
        let decryptedWithoutContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)]
        )
        if case .unverified = decryptedWithoutContext {
            XCTFail()
        }
        let decryptedWithContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)],
            verificationContext: VerificationContext(value: contextValue, required: .always)
        )
        if case .unverified = decryptedWithContext {
            XCTFail()
        }
        let decryptedWithWrongContext = try Decryptor.decryptAndVerify(
            decryptionKey: decryptionKey,
            value: encryptedAndSigned,
            verificationKeys: [ArmoredKey.init(value: verifyKey)],
            verificationContext: VerificationContext(value: contextValue + "wrong", required: .always)
        )
        if case .verified = decryptedWithWrongContext {
            XCTFail()
        }
    }
    
}
