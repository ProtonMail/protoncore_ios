//
//  PMSettingsSectionViewModelTests.swift
//  ProtonCore-Settings - Created on 16.11.22.
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

@available(iOS 13.0, *)
final class PMSettingsSectionViewModelTests: XCTestCase {
    private var delegate: TelemetrySettingsDelegateMock!
    private var service: TelemetrySettingsServiceMock!
    
    override func setUp() {
        super.setUp()
        delegate = TelemetrySettingsDelegateMock()
        service = TelemetrySettingsServiceMock()
    }
    
    func test_telemetry_returnsPMSettingsSectionViewModel() {
        let result = PMSettingsSectionViewModel.telemetry(
            delegate: delegate,
            telemetrySettingsService: service
        )
        
        XCTAssertEqual(result.title, "Telemetry")
        XCTAssertEqual(result.rows.count, 1)
        XCTAssertNil(result.footer)
    }
    
    class TelemetrySettingsDelegateMock: TelemetrySettingsDelegate {
        func didSetTelemetry(isEnabled: Bool) {}
    }
    
    class TelemetrySettingsServiceMock: TelemetrySettingsServiceProtocol {
        func setIsTelemetryEnabled(state: Bool) {}
        var isTelemetryEnabled: Bool = false
    }
}
