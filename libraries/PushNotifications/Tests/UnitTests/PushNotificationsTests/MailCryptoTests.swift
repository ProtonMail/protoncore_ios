//
//  MailCryptoTests.swift
//  
//
//  Created by Victor Jalencas on 25/6/23.
//

import XCTest
@testable import ProtonCorePushNotifications
import ProtonCoreCryptoGoImplementation
import ProtonCoreCrypto

final class MailCryptoTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    func testGenerateRandomKeyPair() throws {
        let keyPair = try MailCrypto.generateRandomKeyPair()
        let privateKey = ArmoredKey(value: keyPair.privateKey)
        let publicKey = ArmoredKey(value: keyPair.publicKey)
        let passphrase = Passphrase(value: keyPair.passphrase)
        let message = "Hello my friend!"

        let encrypted = try Encryptor.encrypt(publicKey: publicKey, cleartext: message)
        let unwrappedEncrypted = try XCTUnwrap(encrypted)
        XCTAssertNotEqual(message, unwrappedEncrypted.value)

        let decrypted: String = try Decryptor.decrypt(
            decryptionKeys: [DecryptionKey(privateKey: privateKey, passphrase: passphrase)],
            encrypted: encrypted
        )
        XCTAssertEqual(message, decrypted)
    }
}
