//
//  Based64Tests.swift
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
#if canImport(ProtonCore_Crypto_VPN)
@testable import ProtonCore_Crypto_VPN
#elseif canImport(ProtonCore_Crypto)
@testable import ProtonCore_Crypto
#endif

class Based64Tests: CryptoTestBase {
    
    func testEncodeString() {
        let check = "jlksdjfkljasdflkjlsdf"
        let encoded = Based64.encode(value: check)
        let decoded = Based64.decode(based64: encoded)
        XCTAssertEqual(String(data: decoded, encoding: .utf8), check)
    }
    
    func testEncodeData() {
        let check = self.random(length: 32)
        let encoded = Based64.encode(raw: check)
        let decoded = Based64.decode(based64: encoded)
        XCTAssertEqual(decoded, check)
    }
}
