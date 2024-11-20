//
//  AeadCrypto.swift
//  ProtonCore-Crypto - Created on 15.11.24.
//
//  Copyright (c) 2024 Proton Technologies AG
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
import ProtonCoreCrypto

final class AeadCryptoTests: XCTestCase {
    var sut: AeadCrypto!

    override func setUpWithError() throws {
        sut = AeadCrypto()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testEncryptAndDecryptStringWorks() throws {
        let plain = "test-plain-text"
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plain, key: key)
        let decrypted = try sut.decrypt(base64EncryptedString: encrypted, key: key)

        XCTAssertEqual(plain, decrypted)
    }

    func testEncryptAndDecryptDataWorks() throws {
        let plainData = "test-plain-text".data(using: .utf8)!
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plainData, key: key)
        let decrypted = try sut.decrypt(value: encrypted, key: key)

        XCTAssertEqual(plainData, decrypted)
    }

    func testEncryptAndDecryptStringFails() throws {
        let plain = "test-plain-text"
        let key = getRandomKey()
        let key2 = getRandomKey()

        let encrypted = try sut.encrypt(value: plain, key: key)
        XCTAssertThrowsError(try sut.decrypt(base64EncryptedString: encrypted, key: key2))
    }

    func testEncryptAndDecryptDataFails() throws {
        let plainData = "test-plain-text".data(using: .utf8)!
        let key = getRandomKey()
        let key2 = getRandomKey()

        let encrypted = try sut.encrypt(value: plainData, key: key)
        XCTAssertThrowsError(try sut.decrypt(value: encrypted, key: key2))
    }

    func testEncryptDecryptEmptyString() throws {
        let plain = ""
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plain, key: key)
        let decrypted = try sut.decrypt(base64EncryptedString: encrypted, key: key)

        XCTAssertEqual(plain, decrypted)
    }

    func testEncryptDecryptEmptyBytes() throws {
        let plainData = Data(count: 0)
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plainData, key: key)
        let decrypted = try sut.decrypt(value: encrypted, key: key)

        XCTAssertEqual(decrypted.count, 0)
    }

    func testEncryptDecryptAadWorks() throws {
        let plain = ""
        let key = getRandomKey()
        let aad = getRandomAad()

        let encrypted = try sut.encrypt(value: plain, key: key, aad: aad)
        let decrypted = try sut.decrypt(base64EncryptedString: encrypted, key: key, aad: aad)

        XCTAssertEqual(plain, decrypted)
    }

    func testEncryptDecryptAadFails() throws {
        let plain = ""
        let key = getRandomKey()
        let aad = getRandomAad()
        let aad2 = getRandomAad()

        let encrypted = try sut.encrypt(value: plain, key: key, aad: aad)
        XCTAssertThrowsError(try sut.decrypt(base64EncryptedString: encrypted, key: key, aad: aad2))
    }

    func testEncryptDecrypt71CharsUsingLatin1String() throws {
        let plain = "ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾ÀÁÂÃÄÅÆ¼½¾"
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plain, key: key)
        let decrypted = try sut.decrypt(base64EncryptedString: encrypted, key: key)

        XCTAssertEqual(plain, decrypted)
    }

    func testEncryptDecrypt100KByteData() throws {
        let plainData = getRandomBytes(count: 100 * 1000)
        let key = getRandomKey()

        let encrypted = try sut.encrypt(value: plainData, key: key)
        let decrypted = try sut.decrypt(value: encrypted, key: key)

        XCTAssertEqual(plainData, decrypted)
    }

    // MARK: Private

    private func getRandomKey() -> Data {
        getRandomBytes(count: 32)
    }

    private func getRandomAad() -> Data {
        getRandomBytes(count: 16)
    }

    private func getRandomBytes(count: Int) -> Data {
        var keyData = Data(count: count)
        _ = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!)
        }
        return keyData
    }
}
