//
//  UserAgentTests.swift
//  ProtonCore-Networking-Tests - Created on 04/20/18.
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

import OHHTTPStubs

@testable import ProtonCore_Networking

class UserAgentTests: XCTestCase {

    let concurrentQueue = DispatchQueue(label: "com.protoncore.Concurrent", attributes: .concurrent)

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
#if DEBUG_CORE_INTERNALS
    func testUAConcurrent() {
        for _ in 1...50 {
            concurrentQueue.sync {
                _ = UserAgent.default.ua
                XCTAssertTrue(UserAgent.default.initCount == 1)
            }
        }
    }
#endif
    
    func testDarwinVersion() {
        let dv = UserAgent.default.DarwinVersion()
        XCTAssertFalse(dv.isEmpty)
    }

    func testCFNetworkVersion() {
        let cfnv = UserAgent.default.DarwinVersion()
        XCTAssertFalse(cfnv.isEmpty)
    }
}
