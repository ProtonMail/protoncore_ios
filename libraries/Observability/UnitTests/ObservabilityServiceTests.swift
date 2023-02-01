//
//  ObservabilityServiceTests.swift
//  ProtonCore-Observability-Unit-UnitTests - Created on 30.01.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_Observability

final class ObservabilityServiceTests: XCTestCase {
    var sut: ObservabilityService!
    var apiService: APIServiceMock!
    
    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
        sut = ObservabilityServiceImpl(apiService: apiService)
    }
    
    func test_reportWithUnauthSessionIsDisabled_doesNotCallRequest() {
        // When
        sut.report(.dummyEvent(status: .successful))
        
        // Then
        XCTAssertTrue(apiService.requestJSONStub.wasNotCalled)
    }
    
    func test_report_callsRequestExactlyOnce() {
        withFeatureSwitches([.unauthSession]) {
            
            // When
            sut.report(.dummyEvent(status: .successful))
            
            // Then
            XCTAssertTrue(apiService.requestJSONStub.wasCalledExactlyOnce)
        }
    }
}

private extension ObservabilityService {
    func report<Payload: Encodable>(_ event: ObservabilityEvent<Payload>) {
        report(event, completion: nil)
    }
}

private struct DummyLabels: Encodable {
    let status: SuccessOrFailureOrCancelledStatus
}

extension ObservabilityEvent where Payload == CounterPayloadWithLabels<DummyLabels> {
    public static func dummyEvent(status: SuccessOrFailureOrCancelledStatus) -> Self {
        .init(name: "dummy_event_name", labels: .init(status: status))
    }
}
