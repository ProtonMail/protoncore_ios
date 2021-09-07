//
//  PMChallengeTests.swift
//  ProtonCore-Challenge-Tests - Created on 6/19/20.
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
import UIKit
@testable import ProtonCore_Challenge

final class PMChallengeTests: XCTestCase {
    func testSingleton() {
        let shared1 = PMChallenge.shared()
        let addr1 = Unmanaged.passUnretained(shared1).toOpaque()
        
        let shared2 = PMChallenge.shared()
        let addr2 = Unmanaged.passUnretained(shared2).toOpaque()
        XCTAssertTrue(addr1 == addr2)
    }
    
    func testRelease() {
        let shared1 = PMChallenge.shared()
        let addr1 = Unmanaged.passUnretained(shared1).toOpaque()
        PMChallenge.release()
        
        let shared2 = PMChallenge.shared()
        let addr2 = Unmanaged.passUnretained(shared2).toOpaque()
        XCTAssertTrue(addr1 != addr2)
    }
    
    func testStorageCapacity() {
        let capacity = FileManager.deviceCapacity()
        XCTAssertNotNil(capacity, "Capacity is nil, find another way to fetch it")
    }
    
    func testTextFieldDelegateInterceptor() {
        let obj = MockObject()
        let textField = UITextField()
        textField.delegate = obj
        XCTAssertNoThrow(try PMChallenge.shared().observeTextField(textField, type: .username), "Should not throw error")
        let interceptor = textField.delegate as? TextFieldDelegateInterceptor
        XCTAssertNotNil(interceptor, "Replace textfield delegate failed")
        XCTAssertEqual(interceptor?.type, PMChallenge.TextFieldType.username, "TextField type is not equal")
    }
    
    func testChallengeFetchValue() {
        var challenge = PMChallenge.Challenge()
        challenge.fetchValues()
        // Can't be initialize value
        XCTAssertNotEqual(challenge.deviceName, -1, "device name")
        XCTAssertNotEqual(challenge.appLang, "", "app lang")
        XCTAssertNotEqual(challenge.regionCode, "", "region code")
        XCTAssertNotEqual(challenge.timezone, "", "timezone")
        XCTAssertNotEqual(challenge.timezoneOffset, 0, "timezone offset")
        XCTAssertNotEqual(challenge.keyboards, [], "keyboard")
    }
    
    func testChallengeExport() {
        var challenge = PMChallenge.Challenge()
        challenge.fetchValues()
        
        XCTAssertNoThrow(try challenge.asString())
        XCTAssertNoThrow(try challenge.asDictionary())
    }
}
