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

@testable import ProtonCore_Utilities
import XCTest

class CompletionBlockExecutorTests: XCTestCase {
    
    var sut: CompletionBlockExecutor!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testDefaultInit_ExecutingWork_ItExecutesScheduledWork() {
        var scheduledWork: (() -> Void)?
        
        sut = CompletionBlockExecutor(executionContext: { work in
            scheduledWork = work
        })
        
        var completed: Bool = false
        
        sut.execute(completionBlock: {
            completed = true
        })
        
        XCTAssertFalse(completed)
        
        scheduledWork?()
        
        XCTAssertTrue(completed)
    }
    
    func testImmediateExecutor_ExecutingWork_ItExecutesScheduledWork() {
        sut = .immediateExecutor
        
        var completed: Bool = false
        
        sut.execute(completionBlock: {
            completed = true
        })
        
        XCTAssertTrue(completed)
    }
    
    func testAsyncMainExecutor_ExecutingWork_ItExecutesScheduledWork() {
        sut = .asyncMainExecutor
        
        let mainQueueFinishedExpectation = expectation(
            description: "The main queue has finished executing work expectation."
        )
        var completed: Bool = false
        
        sut.execute(completionBlock: {
            completed = true
            mainQueueFinishedExpectation.fulfill()
        })
        
        XCTAssertFalse(completed)
        
        wait(for: [mainQueueFinishedExpectation], timeout: 0.1)
        
        XCTAssertTrue(completed)
    }
    
}
