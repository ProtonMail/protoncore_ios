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

    private var sut: LogHelper!

    override func setUp() {
        super.setUp()
        sut = LogHelper()
    }

    override func tearDown() async throws {
        await sut.deleteLogs()
        sut = nil
        try await super.tearDown()
    }

    private func fileURL() -> String? {
        let url = URL.documentsDirectory.appending(path: "TransactionLog.txt")
        return try? String(contentsOf: url)
    }

    private func dateFromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"

        return formatter.date(from: string)
    }

    func test_init_no_logs() async {
        await sut.load()
        XCTAssertTrue(sut.transactionLogs.isEmpty)
        // No file should exist
        XCTAssertNil(fileURL())
    }

    func test_log_event_without_saving() async {

        await sut.logEvent(["Log 1": "event1",
                            "Log 2": 12])
        await sut.logEvent(["Log 3": "event 3",
                            "Log 4": 12122])

        XCTAssertTrue(sut.transactionLog.count == 2, "LogHelper should have 2 elements inside transactionLog")
        XCTAssertTrue(sut.transactionLogs.isEmpty, "Logs haven't been saved to transactionLogs should be empty")
    }

    func test_log_event_with_saving() async throws {

        await sut.logEvent(["Log 1": "event1",
                            "Log 2": 12])
        await sut.logEvent(["Log 3": "event 3",
                            "Log 4": 12122], type: .close)

        XCTAssertTrue(sut.transactionLog.count == 2)
        XCTAssertTrue(sut.transactionLogs.count == 1)
    }

    func test_multiple_log_event_with_saving() async throws {

        await sut.logEvent(["Log 1": "event1",
                            "Log 2": 12], type: .close)
        await sut.logEvent(["Log 3": "event 3",
                            "Log 4": 12122], type: .close)
        await sut.logEvent(["Log 5": "event 3",
                            "Log 6": 12122])

        XCTAssertTrue(sut.transactionLog.count == 3)
        XCTAssertTrue(sut.transactionLogs.count == 2)
        // File should exist
        XCTAssertNotNil(fileURL())
    }

    func test_sync_log_event() {
        let expectation = XCTestExpectation(description: "logEventSync completes")

        sut.logEventSync(["Log 1": "event1",
                          "Log 2": 12])
        sleep(1) // Simulate delay in logging
        sut.logEventSync(["Log 3": "event 3",
                          "Log 4": 12122])
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            Task {
                XCTAssertTrue(self.sut.transactionLog.count == 2)
                XCTAssertTrue(self.sut.transactionLogs.isEmpty)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_log_order() async throws {
        await sut.logEvent(["Log 1": "event1",
                            "Log 2": 12])
        sleep(1) // Simulate delay in logging
        await sut.logEvent(["Log 3": "event 3",
                            "Log 4": 12122])

        guard let firstItem = sut.transactionLog.first?.keys, let secondItem = sut.transactionLog.last?.keys, let firstDate = firstItem.first, let secondDate = secondItem.first else {
            XCTFail("Fail to extract keys from logs")
            return
        }

        guard let firstLogDate = dateFromString(firstDate), let secondLogDate = dateFromString(secondDate) else {
            XCTFail("Fail to generate dates from logs")
            return
        }

        XCTAssertTrue(firstLogDate < secondLogDate)
    }

    func test_file_deleted_after_request() async throws {
        await sut.logEvent(["Log 1": "event1",
                            "Log 2": 12])
        await sut.logEvent(["Log 3": "event 3",
                            "Log 4": 12122], type: .close)

        let logFileURL = await sut.returnTransactionLog()
        // Afer log is closed, the file should exist
        XCTAssertNotNil(fileURL())
        // Requesting the log should return a valid fileURL
        XCTAssertNotNil(logFileURL)
    }
}
#endif
