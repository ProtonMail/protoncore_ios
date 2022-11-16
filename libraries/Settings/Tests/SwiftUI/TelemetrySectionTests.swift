//
//  TelemetryServiceTests.swift
//  ProtonCore-Settings - Created on 09.11.2022.
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
@testable import ProtonCore_Settings

final class TelemetrySectionTests: XCTestCase {

    private var testUserDefaults: UserDefaults!
    
    override func setUp() {
        testUserDefaults = UserDefaults(suiteName: #file)
        testUserDefaults.removePersistentDomain(forName: #file)
        super.setUp()
    }
    
    @available(iOS 13.0, *)
    func testTelemetrySettingsViewModel() {
        let expect1 = expectation(description: "delegate expectation 1")
        let expect2 = expectation(description: "delegate expectation 2")
        
        let delegate: TelemetrySettingsDelegate = {
            class TestDelegate: TelemetrySettingsDelegate {
                let expect1: XCTestExpectation
                let expect2: XCTestExpectation
                var counter = 0
                
                init(expect1: XCTestExpectation, expect2: XCTestExpectation) {
                    self.expect1 = expect1
                    self.expect2 = expect2
                }
                
                func didSetTelemetry(isEnabled: Bool) {
                    switch counter {
                    case 0:
                        XCTAssertFalse(isEnabled)
                        expect1.fulfill()
                    case 1:
                        XCTAssertTrue(isEnabled)
                        expect2.fulfill()
                    default: XCTFail("Not expected case")
                    }
                    counter += 1
                }
            }
            return TestDelegate(expect1: expect1, expect2: expect2)
        }()
        
        let model = TelemetrySettingsViewModel(delegate: delegate, telemetrySettingsService: TelemetrySettingsService(userDefaults: testUserDefaults))
        model.isActive = false
        model.isActive = true
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
