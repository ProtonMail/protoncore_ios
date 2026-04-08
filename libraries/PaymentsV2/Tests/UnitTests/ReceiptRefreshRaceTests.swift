//
//  ReceiptRefreshRaceTests.swift
//  ProtonCore-PaymentsV2 - Created on 07/04/2026.
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

import Foundation
import XCTest

final class ReceiptRefreshRaceTests: XCTestCase {

    func testRaceConditions() async {
        let iterations = 200
        var failures = 0

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask {
                    await self.runTestCase(&failures)
                }
            }
        }

        if failures > 0 {
            XCTFail("Detected \(failures) race failures")
        }
    }

    private func runTestCase(_ failures: inout Int) async {
        let request = SafeReceiptRefreshRequestMocked()

        let shouldCancel = Bool.random()
        let shouldFail = Bool.random()

        Task {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 10...150) * 1_000_000)
            if shouldCancel {
                request.cancel()
            }
        }

        do {
            try await request.begin(with: shouldFail ? .failure(MockError.test) : .success)
        } catch is CancellationError {
            // Request cancelled
        } catch {
            if !shouldFail {
                debugPrint("Unexpected error: \(error)")
                failures += 1
            }
        }
    }

    enum MockError: Error {
        case test
    }
}
