//
//  APIHeaderTests.swift
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

import XCTest
@testable import ProtonCorePaymentsV2

final class APIHeaderTests: XCTestCase {

    func test_APICodeError_equality_equal() throws {
        let value1 = APICodeError(rawValue: 2000)
        let value2 = APICodeError(rawValue: 2000)

        XCTAssertEqual(value1, value2)
    }

    func test_APICodeError_equality_not_equal() throws {
        let value1 = APICodeError(rawValue: 2)
        let value2 = APICodeError(rawValue: 2000)

        XCTAssertNotEqual(value1, value2)
    }

    func test_APICodeError_comparable() throws {
        guard let value1 = APICodeError(rawValue: 2000), let value2 = APICodeError(rawValue: 2) else {
            XCTFail("Unable to create testable APICodeError values")
            return
        }

        XCTAssertTrue(value1.rawValue > value2.rawValue)
    }
}
