//
//  DateParserTests.swift
//  ProtonCore-Utilities-Tests - Created on 7/28/21.
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

@testable import ProtonCoreUtilities

class DateParserTests: XCTestCase {
    
    func testSucess() {
        let testString1 = "Thu, 29 Jul 2021 03:00:37 GMT"
        let date1 = DateParser.parse(time: testString1)
        XCTAssertNotNil(date1)
        let testString2 = "Wed, 21 Oct 2015 07:28:00 GMT"
        let date2 = DateParser.parse(time: testString2)
        XCTAssertNotNil(date2)
    }

    func testFail() {
        let testString1 = "20130623T13:22-0500"
        let date1 = DateParser.parse(time: testString1)
        XCTAssertNil(date1)
        let testString2 = "5:45:22 AM and 5:45:22 PM"
        let date2 = DateParser.parse(time: testString2)
        XCTAssertNil(date2)
        let testString3 = "2013年6月23日"
        let date3 = DateParser.parse(time: testString3)
        XCTAssertNil(date3)
    }

}
