//
//  AccountMigrationTests.swift
//  ProtonCore-Login-Unit-Tests 
//
//  Copyright (c) 2025 Proton Technologies AG
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
@testable import ProtonCoreLogin

final class SecurePassphrasePayloadTests: XCTestCase {
    func testEncodeAndDecode() throws {
        let passphrase = "testPassphrase"
        let encryptionKey = Data(Array(repeating: UInt8.random(in: 0..<100), count: 32))

        let payload1 = try SecurePassphrasePayload(passphrase: passphrase, encryptionKey: encryptionKey)

        XCTAssertEqual(payload1.passphrase, passphrase)

        let payload2 = try SecurePassphrasePayload(encryptedPayload: payload1.encryptedPayload, encryptionKey: encryptionKey)

        XCTAssertEqual(payload2.passphrase, payload1.passphrase)
    }
}
