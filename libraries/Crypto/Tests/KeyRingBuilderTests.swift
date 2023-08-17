//
//  KeyRingBuilder.swift
//  ProtonCore-Crypto-Tests - Created on 12/12/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import ProtonCoreCryptoGoInterface
@testable import ProtonCoreCrypto
import XCTest

final class KeyRingBuilderTests: CryptoTestBase {

    private var sut: KeyRingBuilder!
    private var privateKey: ArmoredKey!
    private var privateKey2: ArmoredKey!
    private let wrongKey = ArmoredKey(value: "Key that can't parse")
    private let privateKeyPassphrase = Passphrase(value: "hello world")
    private let privateKeyPassphrase2 = Passphrase(value: "123")
    private let wrongPassphrase = Passphrase(value: "wrong password")
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        privateKey = ArmoredKey(value: content(of: "testdata_privatekey"))
        privateKey2 = ArmoredKey(value: content(of: "testdata_privatekey2"))
        sut = KeyRingBuilder()
    }
    
    func testBuildPrivateKeyRingUnlockAllKeys() throws {
        let decryptionKeys: [DecryptionKey] = [.init(privateKey: privateKey, passphrase: privateKeyPassphrase), .init(privateKey: privateKey2, passphrase: privateKeyPassphrase2)]
        let privateKeyRing = try sut.buildPrivateKeyRingUnlock(privateKeys: decryptionKeys)
        XCTAssertEqual(2, privateKeyRing.countEntities())
    }
    
    func testBuildPrivateKeyRingKeepAllKeysThatCanUnlock() throws {
        let decryptionKeys: [DecryptionKey] = [.init(privateKey: privateKey, passphrase: privateKeyPassphrase), .init(privateKey: privateKey2, passphrase: wrongPassphrase)]
        let privateKeyRing = try sut.buildPrivateKeyRingUnlock(privateKeys: decryptionKeys)
        XCTAssertEqual(1, privateKeyRing.countEntities())
    }
    
    func testBuildPrivateKeyRingFailsIfNoKeyCanBeUnlocked() {
        let decryptionKeys: [DecryptionKey] = [.init(privateKey: privateKey, passphrase: wrongPassphrase), .init(privateKey: privateKey2, passphrase: wrongPassphrase)]
        XCTAssertThrowsError(
            _ = try sut.buildPrivateKeyRingUnlock(privateKeys: decryptionKeys)
        )
    }
    
    func testBuildPrivateKeyRingKeepAllKeysThatCanParse() throws {
        let decryptionKeys: [DecryptionKey] = [.init(privateKey: privateKey, passphrase: privateKeyPassphrase), .init(privateKey: wrongKey, passphrase: privateKeyPassphrase)]
        let privateKeyRing = try sut.buildPrivateKeyRingUnlock(privateKeys: decryptionKeys)
        XCTAssertEqual(1, privateKeyRing.countEntities())
    }
    
    func testBuildPrivateKeyRingFailsIfNoKeyCanBeParsed() {
        let decryptionKeys: [DecryptionKey] = [.init(privateKey: wrongKey, passphrase: privateKeyPassphrase), .init(privateKey: wrongKey, passphrase: privateKeyPassphrase)]
        XCTAssertThrowsError(
            _ = try sut.buildPrivateKeyRingUnlock(privateKeys: decryptionKeys)
        )
    }
    
    func testBuildPublicKeyRingParsesAllKeys() throws {
        let armoredKeys: [ArmoredKey] = [privateKey, privateKey2]
        let publicKeyRing = try sut.buildPublicKeyRing(armoredKeys: armoredKeys)
        XCTAssertEqual(2, publicKeyRing.countEntities())
    }
    
    func testBuildPublicKeyRingKeepsAllKeysThatCanParse() throws {
        let armoredKeys: [ArmoredKey] = [privateKey, wrongKey]
        let publicKeyRing = try sut.buildPublicKeyRing(armoredKeys: armoredKeys)
        XCTAssertEqual(1, publicKeyRing.countEntities())
    }
    
    func testBuildPublicKeyRingFailsIfNoKeyCanBeParsed() {
        let armoredKeys: [ArmoredKey] = [wrongKey, wrongKey]
        XCTAssertThrowsError(
            _ = try sut.buildPublicKeyRing(armoredKeys: armoredKeys)
        )
    }
}
