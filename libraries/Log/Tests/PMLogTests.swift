//
//  PMLogTests.swift
//  ProtonCore-Log-Tests - Created on 12/11/2020.
//
//  Copyright (c) 2020 Proton Technologies AG
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

import XCTest

@testable import ProtonCore_Log

class PMLogTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        if let file = PMLog.logFile {
            try? FileManager.default.removeItem(at: file)
        }
    }

    func testDebugMessage() {
        PMLog.debug("This is a debug message")
        XCTAssertTrue(PMLog.logsContent().contains("DEBUG : PMLogTests.swift : testDebugMessage() : 36 : 20 - This is a debug message"))
    }

    func testInfoMessage() {
        PMLog.info("This is an info message")
        XCTAssertTrue(PMLog.logsContent().contains("INFO : PMLogTests.swift : testInfoMessage() : 41 : 19 - This is an info message"))
    }

    func testErrorMessage() {
        PMLog.error("This is an error message")
        XCTAssertTrue(PMLog.logsContent().contains("ERROR : PMLogTests.swift : testErrorMessage() : 46 : 20 - This is an error message"))
    }

    func testExternalLogger() {
        var externalError: String?

        PMLog.callback = { message, level in
            guard level == .error else {
                return
            }

            externalError = message
        }

        PMLog.debug("Debug message")
        XCTAssertNil(externalError)

        PMLog.error("Error message")
        XCTAssertEqual(externalError, "Error message")
    }
}
