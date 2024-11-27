//
//  DeviceSecretRepositoryTests.swift
//  ProtonCore-Login-Tests - Created on 13.11.24.
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
import ProtonCoreKeymaker
@testable import ProtonCoreLogin

final class DeviceSecretRepositoryTests: XCTestCase {

    var keychain: Keychain!
    var provider: SecItemMethodsProviderMock!
    var sut: DeviceSecretRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        provider = SecItemMethodsProviderMock()
        keychain = Keychain(service: "test.service", accessGroup: "test.access.group", secItemMethodsProvider: provider)
        sut = DeviceSecretRepository(keychain: keychain)
    }

    override func tearDownWithError() throws {
        super.tearDown()
        keychain = nil
        sut = nil
        provider = nil
    }

    func testStoreDataSuccess() throws {
        let userId = "user12345"
        let secret = DeviceSecret(userId: userId, deviceId: "deviceId", secret: "secret", token: "token")

        provider.dataToReturn = NSData(data: try! JSONEncoder().encode(secret))

        try sut.upsert(deviceSecret: secret)
        
        let result = try sut.getByUserId(userId: userId)

        XCTAssertEqual(secret, result)
    }

    func testDeleteSuccess() throws {
        let userId = "user12345"
        let secret = DeviceSecret(userId: userId, deviceId: "deviceId", secret: "secret", token: "token")

        provider.dataToReturn = NSData(data: try! JSONEncoder().encode(secret))

        try sut.upsert(deviceSecret: secret)
        let insert = try sut.getByUserId(userId: userId)

        XCTAssertEqual(secret, insert)

        try sut.delete(for: userId)

        provider.resultCopyMatching = errSecItemNotFound

        let result = try sut.getByUserId(userId: userId)

        XCTAssertNil(result)
    }

}
