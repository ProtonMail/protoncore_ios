//
//  StringExtensionsTests.swift
//  ProtonCore-Utilities-Tests - Created on 4/19/21.
//
//  Copyright (c) 2019 Proton Technologies AG
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

@testable import ProtonCore_Utilities

class StringExtensionsTests: XCTestCase {
    
    func testToutf8Ext() {
        let test = "��"
        let data = test.utf8
        XCTAssertNotNil(data)
        let verify = String.init(data: data!, encoding: .utf8)
        XCTAssertEqual(test, verify)
    }

    func testInitials() {
        XCTAssertEqual("".initials(), "?")
        XCTAssertEqual("q".initials(), "Q")
        XCTAssertEqual("熊貓".initials(), "熊")
        let n4 = "Lorem ipsum dolor sit amet"
        XCTAssertEqual(n4.initials(), "LA")
        XCTAssertEqual("🐼 Dog".initials(), "🐼D")
        XCTAssertEqual("22 - Name Mame".initials(), "2M")
        let n7 = "Thomas Anderson (@neo)"
        XCTAssertEqual(n7.initials(), "TA")
    }

}
