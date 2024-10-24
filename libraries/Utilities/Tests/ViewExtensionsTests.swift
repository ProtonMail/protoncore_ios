//
//  StringExtensionsTests.swift
//  ProtonCore-Utilities-Tests - Created on 4/19/21.
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
import SwiftUI

@testable import ProtonCoreUtilities

final class ViewExtensionsTests: XCTestCase {

    func testViewIfTrueCondition() throws {
        let expectation = XCTestExpectation(description: "View if modifier called")

        _ = Text("Test")
            .if(true) { view in
                expectation.fulfill()
                return view.font(.headline)
            }

        wait(for: [expectation], timeout: 1)
    }

    func testViewIfFalseCondition() throws {
        let expectation = XCTestExpectation(description: "View if modifier not called")
        expectation.isInverted = true

        _ = Text("Test")
            .if(false) { view in
                expectation.fulfill()
                return view.font(.headline)
            }

        wait(for: [expectation], timeout: 1)
    }
}
