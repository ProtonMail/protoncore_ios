//
//  TransactionsObserverTests.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
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

#if os(iOS)

import Combine
@testable import ProtonCorePaymentsV2
import XCTest

final class TransactionsObserverTests: XCTestCase, @unchecked Sendable {

    private var sut: TransactionsObserver!
    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        sut = TransactionsObserver.shared
        let configuration = TransactionsObserverConfiguration(remoteManager: MockRemoteManager())
        sut.setConfiguration(configuration)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        cancellable = nil
    }

    func test_start_observer() async throws {
        cancellable = sut.$isON
            .dropFirst()
            .sink { state in
                XCTAssertTrue(state)
            }

        try await sut.start()
    }

    func test_stop_observer() async throws {
        cancellable = sut.$isON
            .dropFirst()
            .sink { state in
                XCTAssertFalse(state)
            }

        sut.stop()
    }

    func test_validate_transactions_set_queue_behaviour() async throws {
        let firstCall = sut.beginProcessingTransaction(id: 50)
        let secondCall = sut.beginProcessingTransaction(id: 50)

        XCTAssertTrue(firstCall == true)
        XCTAssertTrue(secondCall == false)

        let thirdCall = sut.beginProcessingTransaction(id: 51)
        sut.endProcessingTransaction(id: 51)
        let forthCall = sut.beginProcessingTransaction(id: 51)

        XCTAssertTrue(thirdCall == true)
        XCTAssertTrue(forthCall == true)
    }

    actor Counter {
        private(set) var value = 0
        func increment() { value += 1 }
    }

    func test_processTransactionImmediately_only_one_request_executed_for_same_Id() async {
        @Sendable
        func processImmediately(id: UInt64, execute: @escaping () async -> Void) async -> Bool {
            guard sut.beginProcessingTransaction(id: id) else { return false }
            defer { sut.endProcessingTransaction(id: id) }
            await execute()
            return true
        }

        let counter = Counter()
        let transactionId: UInt64 = 123

        async let firstResult: Bool = processImmediately(id: transactionId) {
            await counter.increment()
        }

        async let secondResult: Bool = processImmediately(id: transactionId) {
            await counter.increment()
        }

        let (first, second) = await (firstResult, secondResult)

        // At this point we don't know which request initiated first.
        // if only one request was executed, first and second cannot be both true or false
        XCTAssertNotEqual(first, second)
        // the logic OR must be true
        XCTAssertTrue(first || second)

        let count = await counter.value
        XCTAssertEqual(count, 1)
    }

    func test_beginProcessingTransaction_threads_safety() async throws {
        let id: UInt64 = 123
        let priority: [TaskPriority] = [.background, .medium, .low, .utility, .high]

        var results = [Bool]()
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<100 {
                group.addTask(priority: priority.randomElement()) { [sut] in
                    guard let observer = sut else { return false }
                    return observer.beginProcessingTransaction(id: id)
                }
            }

            for await result in group {
                results.append(result)
            }
        }

        sut.endProcessingTransaction(id: id)

        let executions = results.filter { $0 }
        XCTAssertTrue(executions.count == 1)
    }

    func test_beginProcessingTransaction_threads_safety_on_multiple_ids() async throws {
        let ids: [UInt64] = [123, 233, 143, 1, 2]
        let priority: [TaskPriority] = [.background, .medium, .low, .utility, .high]

        var results = [Bool]()
        await withTaskGroup(of: Bool.self) { group in
            ids.forEach { id in
                for _ in 0..<50 {
                    group.addTask(priority: priority.randomElement()) { [sut] in
                        guard let observer = sut else { return false }
                        return observer.beginProcessingTransaction(id: id)
                    }
                }
            }

            for await result in group {
                results.append(result)
            }
        }

        ids.forEach { id in
            sut.endProcessingTransaction(id: id)
        }

        let executions = results.filter { $0 }
        XCTAssertTrue(executions.count == ids.count)
    }
}
#endif
