//
//  EncryptionKitTests.swift
//  proton-push-notifications - Created on 14/6/23.
//
//  Copyright (c) 2023 Proton AG
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
@testable import ProtonCorePushNotifications
import ProtonCoreCryptoGoImplementation
import ProtonCoreCrypto

final class EncryptionKitTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    func testGenerateRandomKeyPair() throws {
        let encryptionKit = try EncryptionKit.generateRandomKeyPair()
        let privateKey = ArmoredKey(value: encryptionKit.privateKey)
        let publicKey = ArmoredKey(value: encryptionKit.publicKey)
        let passphrase = Passphrase(value: encryptionKit.passphrase)
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
