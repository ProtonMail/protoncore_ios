//
//  ComposeTests.swift
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

final class ComposeTests: XCTestCase {

    func test_Compose() throws {

        let element1 = TestElement1(title: "Test")
        let element2 = TestElement2(value: 200)
        let composedElement = Compose(element1, element2)

        XCTAssertEqual(composedElement.title, "Test")
        XCTAssertEqual(composedElement.value, 200)
    }
}

private struct TestElement1 {
    var title: String
}

private struct TestElement2 {
    var value: Int
}
