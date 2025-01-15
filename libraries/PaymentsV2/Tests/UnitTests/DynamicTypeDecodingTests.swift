//
//  DynamicTypeDecodingTests.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
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

@testable import ProtonCorePaymentsV2
import XCTest

final class DynamicTypeDecodingTests: XCTestCase {

    func test_entitlements_decoding() throws {

        let data = Bundle.main.loadJsonData(from: "plans_entitlements_types.json")
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCamelCase
        let decodedData = try decoder.decode([Entitlement].self, from: jsonData)

        XCTAssertEqual(decodedData.count, 2)
        XCTAssertNotNil(decodedData)
    }

    func test_decorations_decoding() throws {

        let data = Bundle.main.loadJsonData(from: "plans_decorations.json")
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCamelCase
        let decodedData = try decoder.decode([Decoration].self, from: jsonData)

        XCTAssertEqual(decodedData.count, 2)
        XCTAssertNotNil(decodedData)
    }
}
