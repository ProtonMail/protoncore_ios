//
//  SignerTests.swift
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

class SignerTests: CryptoTestBase {

    func testSignStringDetachedWithTrimming() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign string. detached signature.with trailing spaces:  \t\r\n"
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainText: clearText, trimTrailingSpaces: true)
            let verifiedWithTrimming = try Sign.verifyDetached(signature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertTrue(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(signature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertFalse(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testSignStringDetachedWithoutTrimming() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign string. detached signature.with trailing spaces:  \t "
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainText: clearText, trimTrailingSpaces: false)
            let verifiedWithTrimming = try Sign.verifyDetached(signature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertFalse(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(signature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertTrue(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testSignDataDetached() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign binary. detached signature."
        let clearData = clearText.data(using: .utf8)!
        
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainData: clearData)
            let verified = try Sign.verifyDetached(signature: signature, plainData: clearData, verifierKey: ArmoredKey.init(value: pubKey))
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testSignDataWithKeysDetached() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign binary. detached signature."
        let clearData = clearText.data(using: .utf8)!
        
        let privKey1 = self.content(of: "user_b_privatekey")
        
        let pubKey = privKey.publicKey
        let pubKey2 = privKey1.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainData: clearData)
            let verified = try Sign.verifyDetached(signature: signature,
                                                   plainData: clearData,
                                                   verifierKeys: [ArmoredKey.init(value: pubKey),
                                                                  ArmoredKey.init(value: pubKey2)])
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
    
    func testSignStringDetachedVerifyUnArmoredSignatureWithTrimming() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign string. detached signature. With trailing spaces:  \t\r\n"
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainText: clearText, trimTrailingSpaces: true).unArmor()
            let verifiedWithTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertTrue(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertFalse(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testSignStringDetachedVerifyUnArmoredSignatureWithoutTrimming() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign string. detached signature. With trailing spaces:  \t\r\n"
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainText: clearText, trimTrailingSpaces: false).unArmor()
            let verifiedWithTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertFalse(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertTrue(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testVerifyDetachedGopenpgpv2_4_10() {
        let pubKey = self.content(of: "testdata_public_key")
        let clearText = "This is a test\nWith trailing spaces:    \n  With leading spaces\nWith trailing tabs:\t\t\n\tWith leading tabs\nWith trailing carriage returns:\r\n\rWith leading carriage returns\n\t \r With a mix \t\r\n"
        let signature = self.content(of: "testdata_signature_gopenpgp_v2_4_10")
        do {
            let verifiedWithTrimming = try Sign.verifyDetached(armoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertTrue(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(armoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertFalse(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testVerifyDetachedGopenpgpv2_5_0() {
        let pubKey = self.content(of: "testdata_public_key")
        let clearText = "This is a test\nWith trailing spaces:    \n  With leading spaces\nWith trailing tabs:\t\t\n\tWith leading tabs\nWith trailing carriage returns:\r\n\rWith leading carriage returns\n\t \r With a mix \t\r\n"
        let signature = self.content(of: "testdata_signature_gopenpgp_v2_5_0")
        do {
            let verifiedWithTrimming = try Sign.verifyDetached(armoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertFalse(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(armoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertTrue(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testVerifyDetachedGopenpgpv2_4_10() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign string. detached signature. With trailing spaces:  \t\r\n"
        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainText: clearText, trimTrailingSpaces: false).unArmor()
            let verifiedWithTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: true)
            XCTAssertFalse(verifiedWithTrimming)
            let verifiedWithoutTrimming = try Sign.verifyDetached(unArmoredSignature: signature, plainText: clearText, verifierKey: ArmoredKey.init(value: pubKey), trimTrailingSpaces: false)
            XCTAssertTrue(verifiedWithoutTrimming)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }


    func testSignDataDetachedVerifyUnArmoredSignature() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign binary. detached signature."
        let clearData = clearText.data(using: .utf8)!

        let pubKey = privKey.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainData: clearData).unArmor()
            let verified = try Sign.verifyDetached(unArmoredSignature: signature, plainData: clearData,
                                                   verifierKey: ArmoredKey.init(value: pubKey))
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }

    func testSignDataWithKeysDetachedVerifyUnArmoredSignature() {
        let privKey = self.content(of: "user_a_privatekey")
        let privKeyPassphrase = self.content(of: "user_a_privatekey_passphrase")
        let clearText = "testing sign binary. detached signature."
        let clearData = clearText.data(using: .utf8)!
        let privKey1 = self.content(of: "user_b_privatekey")
        let pubKey = privKey.publicKey
        let pubKey2 = privKey1.publicKey
        do {
            let signingKey = SigningKey.init(privateKey: ArmoredKey.init(value: privKey),
                                             passphrase: Passphrase.init(value: privKeyPassphrase))
            let signature = try Sign.signDetached(signingKey: signingKey, plainData: clearData).unArmor()
            let verified = try Sign.verifyDetached(unArmoredSignature: signature,
                                                   plainData: clearData,
                                                   verifierKeys: [ArmoredKey.init(value: pubKey),
                                                                  ArmoredKey.init(value: pubKey2)])
            XCTAssertTrue(verified)
        } catch let error {
            XCTFail("Should not happen: \(error)")
        }
    }
}
