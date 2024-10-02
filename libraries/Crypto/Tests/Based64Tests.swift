//
//  Base64Tests.swift
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

class Base64Tests: CryptoTestBase {

    func testEncodeString() {
        let check = "jlksdjfkljasdflkjlsdf"
        let encoded = Base64.encode(value: check)
        let decoded = Base64.decode(base64: encoded)
        XCTAssertEqual(String(data: decoded, encoding: .utf8), check)
    }

    func testEncodeData() {
        let check = self.random(length: 32)
        let encoded = Base64.encode(raw: check)
        let decoded = Base64.decode(base64: encoded)
        XCTAssertEqual(decoded, check)
    }
}
