//
//  CreditRequestTests.swift
//  ProtonCore-Payments-Tests - Created on 12/09/2022.
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

final class CreditRequestTests: XCTestCase {
    var sut: CreditRequest!

    override func setUp() {
        super.setUp()
        sut = CreditRequest(api: APIServiceMock(), amount: 123, paymentAction: .token(token: "token"))
    }

    func test_tokenParameters() {
        // Given
        let token = "thisIsAToken"
        sut = CreditRequest(api: APIServiceMock(), amount: 123, paymentAction: .token(token: token))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "USD")
        XCTAssertEqual(sut.parameters!["PaymentToken"] as! String, token)
    }

    func test_appleParameters() {
        // Given
        sut = CreditRequest(api: APIServiceMock(), amount: 123, paymentAction: .apple(receipt: "receipt"))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "USD")
        XCTAssertEqual((sut.parameters!["Payment"] as! [String: Any])["Type"] as! String, "apple")
    }

    func test_method() {
        XCTAssertEqual(sut.method, .post)
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/payments/v4/credit")
    }
}
