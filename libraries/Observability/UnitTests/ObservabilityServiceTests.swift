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

import ProtonCoreNetworking
@testable import ProtonCoreObservability
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreUtilities
import XCTest

@available(iOS 13.0, *)
final class ObservabilityServiceTests: XCTestCase {
    private var sut: ObservabilityServiceImpl!
    
    private var apiService: APIServiceMock!
    private var mockTimer: ObservabilityTimerMock!
    private var mockQueue: CompletionBlockExecutor!
    private var aggregatorMock: ObservabilityAggregatorMock!
    private var completionMock: ((URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) -> Void)?
    private var completionBlockCalled = false
    
    override func setUp() {
        super.setUp()
        setupMock()
        sut = ObservabilityServiceImpl(
            requestPerformer: apiService,
            timer: mockTimer,
            aggregator: aggregatorMock,
            reportingQueue: mockQueue,
            completion: completionMock
        )
    }
    
    private func setupMock() {
        apiService = APIServiceMock()
        mockTimer = ObservabilityTimerMock()
        mockQueue = .immediateExecutor
        aggregatorMock = ObservabilityAggregatorMock()
        completionMock = { [weak self] (task, result) in
            self?.completionBlockCalled = true
        }
    }

    func test_report_callsAggregateExactlyOnce() {
        // When
        sut.report(.dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(aggregatorMock.aggregateCallCount, 1)
    }
    
    func test_report_registersTimerExactlyOnce() {
        // When
        sut.report(.dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(mockTimer.registerCallCount, 1)
    }
    
    func test_report_startsTimerExactlyOnce() {
        // When
        sut.report(.dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(mockTimer.startCallCount, 1)
    }
    
    func test_report_multipleCallsOnlyStartTimerOnce() {
        // When
        sut.report(.dummyEvent(status: .successful))
        sut.report(.dummyEvent(status: .successful))
        sut.report(.dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(mockTimer.startCallCount, 1)
    }
    
    func test_report_multipleCallsOnlyRegisterTimerOnce() {
        // When
        sut.report(.dummyEvent(status: .successful))
        sut.report(.dummyEvent(status: .successful))
        sut.report(.dummyEvent(status: .successful))

        // Then
        XCTAssertEqual(mockTimer.registerCallCount, 1)
    }
    
    func test_clearsAggregatedEventsAfterXSeconds() async {
        // Given
        let aggregator = ObservabilityAggregatorMock()
        let expectation = expectation(description: "test_clearsAggregatedEventsAfterXSeconds")
        let completion = { (task: URLSessionDataTask?, result: Result<JSONDictionary, PMAPIService.APIError>) in
            XCTAssertEqual(aggregator.clearCallCount, 1)
            expectation.fulfill()
        }

        let sut = ObservabilityServiceImpl(
            requestPerformer: setupService(),
            timer: ObservabilityTimerImpl(interval: 1),
            aggregator: aggregator,
            reportingQueue: .immediateExecutor,
            completion: completion
        )

        // When
        sut.report(.dummyEvent(status: .successful))

        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    func test_apiRequestAfterXSeconds() async {
        // Given
        let service = setupService()
        let expectation = expectation(description: "test_apiRequestAfterXSeconds")
        let completion = { (task: URLSessionDataTask?, result: Result<JSONDictionary, PMAPIService.APIError>) in
            XCTAssertEqual(service.requestJSONStub.wasCalledExactlyOnce, true)
            expectation.fulfill()
        }

        let sut = ObservabilityServiceImpl(
            requestPerformer: service,
            timer: ObservabilityTimerImpl(interval: 1),
            aggregator: ObservabilityAggregatorMock(),
            reportingQueue: .immediateExecutor,
            completion: completion
        )

        sut.report(.dummyEvent(status: .successful))

        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    func test_reportingEventsIsThreadSafe() async {
        // Given
        let sut = ObservabilityServiceImpl(
            requestPerformer: setupService(),
            timer: ObservabilityTimerImpl(interval: 1),
            aggregator: ObservabilityAggregatorMock(),
            reportingQueue: .immediateExecutor
        )

        // When
        _ = await performConcurrentlySettingExpectations(amount: 100) { _, continuation in
            sut.report(.dummyEvent(status: .successful))
            continuation.resume()
        }
    }
    
    func test_reportEventIsDoneInAQueue() {
        // Given
        let expectation = expectation(description: "test_reportEventIsDoneInAQueue")
        let aggregatorMock = ObservabilityAggregatorMock()
        let service = setupService()

        let beforeWork = {
            XCTAssertEqual(aggregatorMock.clearCallCount, 0)
            XCTAssertTrue(service.requestJSONStub.wasNotCalled)
        }

        let afterWork🍻 = {
            XCTAssertEqual(aggregatorMock.clearCallCount, 1)
            XCTAssertTrue(service.requestJSONStub.wasCalledExactlyOnce)
            expectation.fulfill()
        }

        let sut = ObservabilityServiceImpl(
            requestPerformer: service,
            timer: ObservabilityTimerImpl(interval: 1),
            aggregator: aggregatorMock,
            reportingQueue: .immediateSniffingExecutor(
                assertionsBeforeTheWorkIsExecuted: beforeWork,
                assertionsAfterTheWorkIsExecuted: afterWork🍻
            )
        )

        // When
        sut.report(.dummyEvent(status: .successful))
        wait(for: [expectation], timeout: 2)
    }
    
    private func setupService() -> APIServiceMock {
        let service = APIServiceMock()
        service.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(.init()))
        }
        return service
    }
}

struct DummyLabels: Encodable, Equatable {
    let status: SuccessOrFailureOrCanceledStatus
}

extension ObservabilityEvent where Payload == PayloadWithLabels<DummyLabels> {
    public static func dummyEvent(status: SuccessOrFailureOrCanceledStatus) -> Self {
        .init(name: "dummy_event_name", labels: .init(status: status))
    }
}

final class ObservabilityAggregatorMock: ObservabilityAggregator {
    var aggregatedEvents: Atomic<[AggregableObservabilityEvent]> = Atomic([])
    
    var aggregateCallCount = 0
    var clearCallCount = 0
    
    func aggregate<Labels>(event: ObservabilityEvent<PayloadWithLabels<Labels>>) where Labels: Encodable, Labels: Equatable {
        aggregatedEvents.mutate { events in
            events.append(.init(event: event))
        }
        aggregateCallCount += 1
    }
    
    func clear() {
        aggregatedEvents.mutate { events in
            events.removeAll()
        }
        clearCallCount += 1
    }
}

final class ObservabilityTimerMock: ObservabilityTimer {
    var registerCallCount = 0
    var startCallCount = 0
    var stopCallCount = 0
    
    func register(_ ticker: @escaping ProtonCoreObservability.Ticker) {
        registerCallCount += 1
    }
    
    func start() {
        startCallCount += 1
    }
    
    func stop() {
        stopCallCount += 1
    }
}

extension CompletionBlockExecutor {
    static func immediateSniffingExecutor(
        assertionsBeforeTheWorkIsExecuted: @escaping () -> Void,
        assertionsAfterTheWorkIsExecuted: @escaping () -> Void) -> Self {
        .init { _, work in
            assertionsBeforeTheWorkIsExecuted()
            work()
            assertionsAfterTheWorkIsExecuted()
        }
    }
}
