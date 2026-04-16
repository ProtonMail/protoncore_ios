//
//  LogHelperTests.swift
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

import Foundation
@testable import ProtonCorePaymentsV2
import XCTest

final class LogHelperTests: XCTestCase {

    private var logHelper: LogHelper!

    // MARK: Overrides

    override func setUp() async throws {
        logHelper = LogHelper()
        try await super.setUp()
    }

    override func tearDown() async throws {
        logHelper.deleteLog()
        logHelper = nil
        try await super.tearDown()
    }

    // MARK: Helper

    private func fileContent() -> String? {
        let url = URL.applicationSupportDirectory.appending(path: "payment_log.txt")
        return try? String(contentsOf: url)
    }

    // MARK: Cases

    func test_init_no_file_exists() {
        XCTAssertNil(fileContent(), "Log file should not exist before logging.")
    }

    func test_logEvent_creates_file() {
        logHelper.logEvent(["key": "value"])

        XCTAssertNotNil(fileContent(), "Log file content should exist after initial logEvent.")
    }

    func test_logEvent_content_contains_logged_event() {
        logHelper.logEvent(["entry_1_key": "entry_1_value"])

        let content = fileContent()
        XCTAssertNotNil(content)
        XCTAssertTrue(content?.contains("entry_1_key") == true)
        XCTAssertTrue(content?.contains("entry_1_value") == true)
    }

    func test_logEvent_multiple_events_append_to_file() {
        logHelper.logEvent(["event_1_key": "event_1_value"])
        let sizeAfterFirst = fileContent()?.count ?? 0

        logHelper.logEvent(["event_2_key": "event_2_value"])
        let sizeAfterSecond = fileContent()?.count ?? 0

        XCTAssertGreaterThan(sizeAfterSecond, sizeAfterFirst, "Log file count should grow after each entry.")
    }

    func test_returnTransactionLog_returns_nil_if_no_file_exists() {
        XCTAssertNil(logHelper.returnTransactionLog(), "Log file URL should be null when no events are logged")
    }

    func test_returnTransactionLog_returns_url_after_logEvent() {
        logHelper.logEvent(["event_1_key": "event_1_value"])

        XCTAssertNotNil(logHelper.returnTransactionLog(), "Log file URL should not be null after an event is logged")
    }

    func test_deleteLog_removes_log_file() {
        logHelper.logEvent(["event_1_key": "event_1_value"])
        XCTAssertNotNil(fileContent())

        logHelper.deleteLog()

        XCTAssertNil(fileContent(), "Log file should not exist are deletLog is called.")
    }

    func test_log_entries_are_in_ascending_timestamp_order() throws {
        let dateFormatTemplate = "dd-MM-yyyy HH:mm:ss.SSS"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatTemplate

        logHelper.logEvent(["event_1_key": "event_1_value"])
        sleep(1)
        logHelper.logEvent(["event_2_key": "event_2_value"])

        let content = try XCTUnwrap(fileContent())
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        XCTAssertEqual(lines.count, 2)
        let firstTimestamp = String(lines[0].prefix(dateFormatTemplate.count))
        let secondTimestamp = String(lines[1].prefix(dateFormatTemplate.count))
        let firstDate = try XCTUnwrap(formatter.date(from: firstTimestamp), "Could not parse first timestamp.")
        let secondDate = try XCTUnwrap(formatter.date(from: secondTimestamp), "Could not parse second timestamp.")

        XCTAssertLessThan(firstDate, secondDate, "First log entry should be earlier than the second.")
    }
}

#endif
