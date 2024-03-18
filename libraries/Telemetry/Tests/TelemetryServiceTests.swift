//
//  TelemetryServiceTests.swift
//  ProtonCore-Telemetry - Created on 26.02.2024.
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

import XCTest
import ProtonCoreNetworking
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsFeatureFlag

@testable import ProtonCoreTelemetry

final class TelemetryServiceTests: XCTestCase {

    var apiService: APIServiceMock!
    var telemetrySettings: TelemetrySettingsServiceMock!
    var sut: TelemetryService!

    let measurementGroup = "account.test.event"

    override func setUp() {
        super.setUp()
        telemetrySettings = TelemetrySettingsServiceMock()
        apiService = APIServiceMock()
        sut = TelemetryService(telemetrySettingsService: telemetrySettings)
        sut.setApiService(apiService: apiService)
    }

    func test_GivenTelemetrySettingsIsEnabled_WhenReportEvent_ApiServiceIsCalled() async {
        await withFeatureFlags([.telemetrySignUpMetrics]) {
            telemetrySettings.isTelemetryEnabled = true
            let testEvent = TelemetryEvent(
                source: .user,
                screen: .welcome,
                action: .clicked,
                measurementGroup: measurementGroup,
                values: [
                    .timestamp(1234)
                ],
                dimensions: [
                    .flow("flow_item")
                ]
            )
            
            apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
                if path.contains("/data/v1/stats") {
                    let params = parameters as! [String: Any]
                    XCTAssertTrue((params["MeasurementGroup"] as! String) == self.measurementGroup)
                    XCTAssertTrue((params["Event"] as! String) == "user.welcome.clicked")
                    XCTAssertTrue((params["Values"] as! [String: Float])["timestamp"] == 1234 )
                    XCTAssertTrue((params["Dimensions"] as! [String: String])["flow"] == "flow_item" )
                    completion(nil, .success([:]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }
            
            await sut.report(event: testEvent)
            
            XCTAssertTrue(apiService.requestJSONStub.wasCalled)
        }
    }

    func test_GivenTelemetrySettingsIsDisabled_WhenReportEvent_ApiServiceIsNotCalled() async {
        await withFeatureFlags([.telemetrySignUpMetrics]) {
            telemetrySettings.isTelemetryEnabled = false
            let testEvent = TelemetryEvent(
                source: .user,
                screen: .welcome,
                action: .clicked,
                measurementGroup: measurementGroup
            )

            apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
                if path.contains("/data/v1/stats") {
                    let params = parameters as! [String: Any]
                    XCTAssertTrue((params["MeasurementGroup"] as! String) == self.measurementGroup)
                    XCTAssertTrue((params["Event"] as! String) == "user.welcome.clicked")
                    completion(nil, .success([:]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            await sut.report(event: testEvent)

            XCTAssertFalse(apiService.requestJSONStub.wasCalled)
        }
    }

    func test_GivenTelemetryFFDisabled_ApiServiceIsNotCalled() async {
        await withFeatureFlags([]) {
            telemetrySettings.isTelemetryEnabled = true
            let testEvent = TelemetryEvent(
                source: .user,
                screen: .welcome,
                action: .clicked,
                measurementGroup: measurementGroup,
                values: [
                    .timestamp(1234)
                ],
                dimensions: [
                    .flow("flow_item")
                ]
            )

            apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
                if path.contains("/data/v1/stats") {
                    let params = parameters as! [String: Any]
                    XCTAssertTrue((params["MeasurementGroup"] as! String) == self.measurementGroup)
                    XCTAssertTrue((params["Event"] as! String) == "user.welcome.clicked")
                    XCTAssertTrue((params["Values"] as! [String: Float])["timestamp"] == 1234 )
                    XCTAssertTrue((params["Dimensions"] as! [String: String])["flow"] == "flow_item" )
                    completion(nil, .success([:]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            await sut.report(event: testEvent)

            XCTAssertFalse(apiService.requestJSONStub.wasCalled)
        }
    }
}
