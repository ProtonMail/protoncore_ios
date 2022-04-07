//
//  ServicePlanDetailsExtensionsTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
@testable import ProtonCore_PaymentsUI

final class StorageFormatterTests: XCTestCase {

    var storageFormatter: StorageFormatter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        storageFormatter = StorageFormatter()
    }
    
    func getString(value: Int64) -> String {
        var formattedString = storageFormatter.format(value: value)
        formattedString.removeAll { $0.isPunctuation }
        return formattedString
    }
    
    func testKBFormatting() {
        XCTAssertEqual(getString(value: 1024), "1 KB")
        XCTAssertEqual(getString(value: 1024 * 3), "3 KB")
        XCTAssertEqual(getString(value: 1024 * 10), "10 KB")
        XCTAssertEqual(getString(value: 1024 * 100), "100 KB")
    }
    
    func testMBFormatting() {
        XCTAssertEqual(getString(value: 1024 * 1024), "1 MB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 10), "10 MB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 100), "100 MB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 500), "500 MB")
    }
    
    func testGBFormatting() {
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024), "1 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 10), "10 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 15), "15 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 16), "16 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 17), "17 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 60), "60 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 500), "500 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 1024), "1024 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 2048), "2048 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 2560), "2560 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 3000), "3000 GB")
        XCTAssertEqual(getString(value: 1024 * 1024 * 1024 * 3072), "3072 GB")
    }
}
