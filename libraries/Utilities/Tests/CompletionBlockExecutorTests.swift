//
//  CompletionBlockExecutorTests.swift
//  ProtonCore-Utilities-Tests - Created on 14.02.22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

@testable import ProtonCoreUtilities
import XCTest

class CompletionBlockExecutorTests: XCTestCase {

    var sut: CompletionBlockExecutor!

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDefaultInit_ExecutingWork_ItExecutesScheduledWork() {
        // GIVEN
        var scheduledWork: (() -> Void)?
        sut = CompletionBlockExecutor { _, work in scheduledWork = work }
        var completed: Bool = false

        // WHEN
        sut.execute(completionBlock: {
            completed = true
        })

        // THEN
        XCTAssertFalse(completed)
        scheduledWork?()
        XCTAssertTrue(completed)
    }

    func testAsyncMainExecutor_ExecutingWork_PassesAfterParameter() {
        // GIVEN
        var afterValue: DispatchTimeInterval?
        sut = CompletionBlockExecutor(executionContext: { after, _ in afterValue = after })

        // WHEN
        sut.execute(after: .seconds(1)) {}

        // THEN
        XCTAssertEqual(afterValue, .seconds(1))
    }

    func testImmediateExecutor_ExecutingWork_ItExecutesScheduledWork() {
        // GIVEN
        sut = .immediateExecutor
        var completed: Bool = false

        // WHEN
        sut.execute { completed = true }

        // THEN
        XCTAssertTrue(completed)
    }

    func testImmediateExecutor_ExecutingWork_IgnoresAfterParameter() {
        // GIVEN
        sut = .immediateExecutor
        var completed: Bool = false

        // WHEN
        sut.execute(after: .seconds(60)) { completed = true }

        // THEN
        XCTAssertTrue(completed)
    }

    func testAsyncMainExecutor_ExecutingWork_ItExecutesScheduledWork() {
        // GIVEN
        sut = .asyncMainExecutor
        let mainQueueFinishedExpectation = expectation(
            description: "The main queue has finished executing work expectation."
        )
        var completed: Bool = false

        // WHEN
        sut.execute {
            completed = true
            mainQueueFinishedExpectation.fulfill()
        }

        // THEN
        XCTAssertFalse(completed)
        wait(for: [mainQueueFinishedExpectation], timeout: 0.1)
        XCTAssertTrue(completed)
    }

    func testAsyncMainExecutor_ExecutingWork_UsesAfterParameter() {
        // GIVEN
        sut = .asyncMainExecutor
        let mainQueueFinishedExpectation = expectation(
            description: "The main queue has finished executing work expectation."
        )
        mainQueueFinishedExpectation.isInverted = true
        var completed: Bool = false

        // WHEN
        sut.execute(after: .never) {
            completed = true
            mainQueueFinishedExpectation.fulfill()
        }

        // THEN
        XCTAssertFalse(completed)
        wait(for: [mainQueueFinishedExpectation], timeout: 0.1)
        XCTAssertFalse(completed)
    }

}
