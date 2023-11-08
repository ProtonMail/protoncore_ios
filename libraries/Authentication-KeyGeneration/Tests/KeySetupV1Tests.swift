//
//  KeySetupV1Tests.swift
//  ProtonCore-Authentication-KeyGeneration-Tests - Created on 21.12.2020.
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

import ProtonCoreDataModel
import ProtonCoreAuthentication
import ProtonCoreObfuscatedConstants
import ProtonCoreCrypto
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif
@testable import ProtonCoreAuthenticationKeyGeneration

@available(*, deprecated, message: "This class is purposefully testing the deprecated API")
class KeySetupV1Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    let addressJson = """
        { "ID": "testId", "email": "test@example.org", "send": 1, "receive": 1, "status": 1, "type": 1, "order": 1, "displayName": "", "signature": "" }
    """
    var testAddress: Address {
        return try! JSONDecoder().decode(Address.self, from: addressJson.data(using: .utf8)!)
    }

    func testAddressKeyGeneration() {
        let keySetup = AddressKeySetupV1()
        do {
            let salt = try PasswordHash.random(bits: 128)
            let key = try keySetup.generateAddressKey(keyName: "Test key", email: "test@test.com", password: "password", salt: salt)
            XCTAssertFalse(key.armoredKey.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAddressKeyGenerationFail() {
        let keySetup = AddressKeySetupV1()
        do {
            _ = try keySetup.generateAddressKey(keyName: "Test key", email: "test@test.com", password: "password", salt: Data())
            XCTFail("should not be here")
        } catch let error {
            XCTAssertEqual(error as? KeySetupError, .invalidSalt)
        }
    }

    func testAddressKeyRouteSetup() {
        let keySetup = AddressKeySetupV1()

        do {
            let salt = try PasswordHash.random(bits: 128)
            let key = try keySetup.generateAddressKey(keyName: "Test key", email: "test@test.com", password: "password", salt: salt)
            let route = try keySetup.setupCreateAddressKeyRoute(key: key, modulus: ObfuscatedConstants.modulus, modulusId: ObfuscatedConstants.modulusId,
                                                                addressId: "addressId", isPrimary: true)
            XCTAssertFalse(route.addressID.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
            XCTAssertEqual(route.isPrimary, true)
            XCTAssertNotNil(route.signedKeyList["Data"])
            XCTAssertNotNil(route.signedKeyList["Signature"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAccountKeyGeneration() {
        let keySetup = AccountKeySetupV1()
        do {
            let key = try keySetup .generateAccountKey(addresses: [testAddress], password: "password")
            XCTAssertFalse(key.addressKeys.isEmpty)
            XCTAssertNotEqual(key.password.value, "password")
            XCTAssertFalse(key.passwordSalt.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAccountKeyRouteSetup() {
        let keySetup = AccountKeySetupV1()

        do {
            let key = try keySetup.generateAccountKey(addresses: [testAddress], password: "password")
            let route = try keySetup.setupSetupKeysRoute(password: "password", key: key, modulus: ObfuscatedConstants.modulus, modulusId: ObfuscatedConstants.modulusId)
            XCTAssertFalse(route.addresses.isEmpty)
            XCTAssertFalse(route.privateKey.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
