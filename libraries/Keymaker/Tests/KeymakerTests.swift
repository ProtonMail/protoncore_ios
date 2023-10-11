//
//  KeymakerTests.swift
//  ProtonCore-Keymaker-Tests - Created on 4/05/2022.
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

@testable import ProtonCoreKeymaker

class KeymakerTests: XCTestCase {
    var sut: Keymaker!
    var keychainMock: KeychainMock!
    var protectorMock: ProtectionStrategyMock!

    override func setUp() async throws {
        keychainMock = KeychainMock(service: "whatever", accessGroup: "whatever")
        sut = Keymaker(autolocker: nil, keychain: keychainMock)
        protectorMock = ProtectionStrategyMock()
        ProtectionStrategyMock.underlyingKeychainLabel = "whatever"
        protectorMock.keychain = keychainMock

        try await super.setUp()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func test__VerifyProtector__EverythingIsOk__KeyIsVerified() async {
        let expectedCypherBits = Data([8, 9, 244])
        keychainMock.dataForKeyClosure = { _ in return expectedCypherBits }
        protectorMock.unlockCypherBitsClosure = { cypherBits in
            XCTAssertEqual(expectedCypherBits, cypherBits)
            return cypherBits.bytes
        }

        do {
            try await sut.verify(protector: protectorMock)
        } catch {
            XCTFail("Verification failed with: \(error)")
        }
    }

    func test__VerifyProtector__GettingCyberBitsFails__VerificationFails() async {
        keychainMock.dataForKeyClosure = { _ in return nil }

        do {
            try await sut.verify(protector: protectorMock)
            XCTFail("Verification should throw error.")
        } catch {
            guard let err = error as? Keymaker.Errors, err == .cypherBitsIsNil else {
                XCTFail("Expected that error is Keymaker.Errors.cypherBitsIsNil but it is: \(error)")
                return
            }
        }
    }

    func test__VerifyProtector__UnlockFails__VerificationFails() async {
        let expectedCypherBits = Data([8, 9, 244])
        keychainMock.dataForKeyClosure = { _ in return expectedCypherBits }
        protectorMock.unlockCypherBitsClosure = { _ in
            throw Keymaker.Errors.cypherBitsIsNil
        }

        do {
            try await sut.verify(protector: protectorMock)
            XCTFail("Verification should throw error.")
        } catch {
            guard let err = error as? Keymaker.Errors, err == .cypherBitsIsNil else {
                XCTFail("Expected that error is Keymaker.Errors.cypherBitsIsNil but it is: \(error)")
                return
            }
        }
    }

    func testIsMainKeyInMemory_whenItIsInMemory_itShouldReturnTrue() {
        sut.forceInjectMainKey(NoneProtection.generateRandomValue(length: 32))
        XCTAssertTrue(sut.isMainKeyInMemory)
    }

    func testIsMainKeyInMemory_whenItIsNotInMemory_itShouldReturnTrue() {
        XCTAssertFalse(sut.isMainKeyInMemory)
    }
}
