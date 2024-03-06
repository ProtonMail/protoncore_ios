//
//  ObservabilityAggregatorTests.swift
//  ProtonCore-Observability-Unit-UnitTests - Created on 06.02.23.
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

@testable import ProtonCoreObservability
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import XCTest

@available(iOS 13.0, *)
final class ObservabilityAggregatorTests: XCTestCase {
    var sut: ObservabilityAggregatorImpl!

    override func setUp() {
        super.setUp()
        sut = ObservabilityAggregatorImpl()
    }

    func test_aggregate_addsEventsToArray() {
        // Given
        XCTAssertEqual(sut.aggregatedEvents.value.count, 0)

        // When
        sut.aggregate(event: .dummyEvent(status: .successful))
        sut.aggregate(event: .dummyEvent(status: .failed))

        // Then
        XCTAssertEqual(sut.aggregatedEvents.value.count, 2)
    }

    func test_aggregate_aggregatesSimilarEvents() {
        // Given
        let expectedEvent = ObservabilityEvent(name: "dummy_event_name", value: 3, labels: DummyLabels.init(status: .successful))
        // When
        sut.aggregate(event: .dummyEvent(status: .successful))
        sut.aggregate(event: .dummyEvent(status: .successful))
        sut.aggregate(event: .dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(sut.aggregatedEvents.value.count, 1)
        XCTAssertTrue(sut.aggregatedEvents.value[0].isSameAs(event: expectedEvent))
    }

    func test_clear_removesAllElementsFromAggregatedEvents() {
        // Given
        sut.aggregate(event: .dummyEvent(status: .successful))
        sut.aggregate(event: .dummyEvent(status: .failed))

        // When
        sut.clear()

        // Then
        XCTAssertEqual(sut.aggregatedEvents.value.count, 0)
    }

    func test_aggregateIsThreadSafe() async {
        _ = await performConcurrentlySettingExpectations(amount: 100) { [weak self] _, continuation in
            guard let self else { XCTFail("self is nil"); return }
            self.sut.aggregate(event: .dummyEvent(status: .successful))
            self.sut.aggregate(event: .dummyEvent(status: .failed))
            continuation.resume()
        }
    }
}
