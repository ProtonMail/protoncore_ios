//
//  PaymentStatusRequestTests.swift
//  ProtonCore-Payments-Tests - Created on 05/12/2023.
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
import OHHTTPStubs
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreServices
import ProtonCoreNetworking
@testable import ProtonCorePayments

final class V4PaymentStatusRequestTests: XCTestCase {
    var sut: V4PaymentStatusRequest!

    override func setUp() {
        super.setUp()
        sut = V4PaymentStatusRequest(api: APIServiceMock())
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/payments/v4/status/apple")
    }
}

final class V5PaymentStatusRequestTests: XCTestCase {
    var sut: V5PaymentStatusRequest!

    override func setUp() {
        super.setUp()
        sut = V5PaymentStatusRequest(api: APIServiceMock())
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/payments/v5/status/apple")
    }
}
