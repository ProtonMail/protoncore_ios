//
//  NSCoderExtTests.swift
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

@testable import ProtonCore_Utilities

class NSCoderExtTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testDecoderStringForKey() {
        @objc(Test) class Test: NSObject, NSCoding {
            var test1: String? = "Test1"
            var test2: String? = "Test2"
            var test3: String? = "Test3"
            var test4: String? = "Test4"
            var test5: String?
            
            override init() { }
            
            required init?(coder: NSCoder) {
                self.test1 = coder.string(forKey: "Key1")
                self.test2 = coder.string(forKey: "Key2")
                self.test3 = coder.string(forKey: "Key3")
                self.test4 = coder.string(forKey: "Key4")
                self.test5 = coder.string(forKey: "Key5")
            }
            
            func encode(with coder: NSCoder) {
                coder.encode(test1, forKey: "Key1")
                coder.encode(test2, forKey: "Key2")
                coder.encode(test3, forKey: "Key3")
                coder.encode(test4, forKey: "Key4")
                coder.encode(nil, forKey: "Key5")
            }
        }

        let test = Test()
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: test)
        
        // load tasks
        let outTest = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? Test
        XCTAssertNotNil(outTest)
        XCTAssertTrue("Test1" == outTest!.test1)
        XCTAssertTrue("Test2" == outTest!.test2)
        XCTAssertTrue("Test3" == outTest!.test3)
        XCTAssertTrue("Test4" == outTest!.test4)
        XCTAssertNil(outTest!.test5)
    }
}
