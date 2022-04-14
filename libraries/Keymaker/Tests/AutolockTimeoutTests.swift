//
//  AutolockTimeoutTests.swift
//  ProtonCore-Keymaker-Tests - Created on 04/05/2022.
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

@testable import ProtonCore_Keymaker

class AutolockTimeoutTests: XCTestCase {
    
    func testInital() throws {
        let testOne = AutolockTimeout(rawValue: -10000)
        XCTAssertTrue(testOne == .never)
        XCTAssertFalse(testOne == .always)
        XCTAssertFalse(testOne == .minutes(2929))
        
        let testTwo = AutolockTimeout(rawValue: -1)
        XCTAssertTrue(testTwo == .never)
        XCTAssertFalse(testTwo == .always)
        XCTAssertFalse(testTwo == .minutes(2929))
        
        let testThree = AutolockTimeout(rawValue: 0)
        XCTAssertTrue(testThree == .always)
        XCTAssertFalse(testThree == .never)
        XCTAssertFalse(testThree == .minutes(2929))
        
        let testFour = AutolockTimeout(rawValue: 1)
        XCTAssertTrue(testFour == .minutes(1))
        XCTAssertFalse(testFour == .always)
        XCTAssertFalse(testFour == .never)
        XCTAssertFalse(testFour == .minutes(2929))
        
        let testFive = AutolockTimeout(rawValue: 100)
        XCTAssertTrue(testFive == .minutes(100))
        XCTAssertFalse(testFive == .never)
        XCTAssertFalse(testFive == .always)
        XCTAssertFalse(testFive == .minutes(2929))
    }
    
    func testValues() throws {
        let testOne: AutolockTimeout = .never
        let testTwo: AutolockTimeout = .always
        let testThree: AutolockTimeout = .minutes(100)
        let testFour: AutolockTimeout = AutolockTimeout(rawValue: -1000)
        let testFive: AutolockTimeout = .minutes(1)
        
        XCTAssertTrue(testOne.rawValue == -1)
        XCTAssertTrue(testTwo.rawValue == 0)
        XCTAssertTrue(testThree.rawValue == 100)
        XCTAssertTrue(testFour.rawValue == -1)
        XCTAssertTrue(testFive.rawValue == 1)
    }
}
