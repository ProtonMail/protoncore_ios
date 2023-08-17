//
//  TelemetrySettingsViewModelTests.swift
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

#if os(iOS)

import XCTest
@testable import ProtonCoreSettings

@available(iOS 13.0, *)
final class TelemetrySettingsViewModelTests: XCTestCase {
    
    var sut: TelemetrySettingsViewModel!
   
    private var testUserDefaults: UserDefaults!
    private var telemetryDelegate: TelemetrySettingsDelegateMock!
    private var telemetrySettingsService: TelemetrySettingsService!
    
    override func setUp() {
        super.setUp()
        setupMocks()
        sut = TelemetrySettingsViewModel(
            delegate: telemetryDelegate,
            telemetrySettingsService: telemetrySettingsService
        )
    }
    
    private func setupMocks() {
        testUserDefaults = UserDefaults(suiteName: #file)
        testUserDefaults.removePersistentDomain(forName: #file)
        telemetrySettingsService = TelemetrySettingsService(userDefaults: testUserDefaults)
        telemetryDelegate = TelemetrySettingsDelegateMock()
    }
    
    func test_setIsActive_callsDidSetTelemetry() {
        // Given
        XCTAssertEqual(telemetryDelegate.didSetTelemetryCallCount, 0)
        
        // When
        sut.isActive = true
        sut.isActive = false
        
        // Then
        XCTAssertEqual(telemetryDelegate.didSetTelemetryCallCount, 2)
    }

    func test_setIsActiveSameValue_callsNotDidSetTelemetry() {
        // Given
        XCTAssertEqual(telemetryDelegate.didSetTelemetryCallCount, 0)

        // When
        sut.isActive = true
        sut.isActive = true

        // Then
        XCTAssertEqual(telemetryDelegate.didSetTelemetryCallCount, 1)
    }
    
    func test_changeValue_setsIsActive() {
        // Given
        XCTAssertFalse(sut.isActive)
        
        // When
        sut.changeValue(to: true, success: { _ in })
        
        // Then
        XCTAssertTrue(sut.isActive)
    }
    
    func test_changeValue_callsSuccess() {
        // Given
        var successCalled = false
        
        // When
        sut.changeValue(to: true, success: { result in
            successCalled = true
        })
        
        // Then
        XCTAssertTrue(successCalled)
    }

    class TelemetrySettingsDelegateMock: TelemetrySettingsDelegate {
        var didSetTelemetryCallCount: Int
        
        init() {
            didSetTelemetryCallCount = 0
        }
        
        func didSetTelemetry(isEnabled: Bool) {
            didSetTelemetryCallCount += 1
        }
    }
    
}

#endif
