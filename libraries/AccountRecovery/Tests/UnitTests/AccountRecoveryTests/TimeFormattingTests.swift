//
//  TimeFormattingTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 1/8/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
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
#if os(iOS)
import XCTest
import ProtonCoreAccountRecovery

final class TimeFormattingTests: XCTestCase {

    let intervals: [TimeInterval] = [0, 59, 60, 61, 3599, 3600, 3601, 3600 * 72 - 1, 3600 * 72, 3600 * 72 + 1, 24 * 3600 * 14 - 1, 24 * 3600 * 14, 24 * 3600 * 14 + 1 ]

    let expectedResults = [ "0 seconds", "59 seconds", "1 minute", "1 minute", "59 minutes", "1 hour", "1 hour" ]

    let expectedResultsUsingDays = [ "2 days", "3 days", "3 days", "13 days", "14 days", "14 days" ]

    let expectedResultsNotUsingDays = [ "71 hours", "72 hours", "72 hours", "335 hours", "336 hours", "336 hours" ]

    func testAllowingDays() {
        let results = intervals.map { $0.asRemainingTimeString(allowingDays: true) }

        let allExpectedResultsUsingDays = expectedResults.appending(expectedResultsUsingDays)

        XCTAssertEqual(allExpectedResultsUsingDays, results)
    }

    func testNotAllowingDays() {
        let results = intervals.map { $0.asRemainingTimeString(allowingDays: false) }

        let allExpectedResultsNotUsingDays = expectedResults.appending(expectedResultsNotUsingDays)

        XCTAssertEqual(allExpectedResultsNotUsingDays, results)
    }}
#endif
