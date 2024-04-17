//
//  DataExtensionsTests.swift
//  proton-push-notifications - Created on 14/6/23.
//
//  Copyright (c) 2023 Proton AG
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
@testable import ProtonCorePushNotifications

final class DataExtensionsTests: XCTestCase {

    func testHexRepresentation() {
        let testData = Data([0xfe, 0x99, 0x00, 0xcc, 0x2a, 0x4f])

        XCTAssertEqual("fe9900cc2a4f", testData.toHexRepresentation())
    }
}
