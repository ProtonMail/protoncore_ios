//
//  SubscriptionRequestTests.swift
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

final class V4SubscriptionRequestTests: XCTestCase {
    var sut: SubscriptionRequest!

    override func setUp() {
        super.setUp()
        sut = V4SubscriptionRequest(api: APIServiceMock(), planId: "planId", amount: 123, cycle: 12, paymentAction: .token(token: "token"))
    }

    func test_tokenParameters() {
        // Given
        let token = "thisIsAToken"
        sut = V4SubscriptionRequest(api: APIServiceMock(), planId: "planId", amount: 123, cycle: 13, paymentAction: .token(token: token))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "USD")
        XCTAssertEqual(sut.parameters!["PaymentToken"] as! String, token)
        XCTAssertEqual(sut.parameters!["Cycle"] as! Int, 13)
    }

    func test_appleParameters() {
        // Given
        sut = V4SubscriptionRequest(api: APIServiceMock(), planId: "planId", amount: 123, cycle: 11, paymentAction: .apple(receipt: "receipt"))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "USD")
        XCTAssertEqual((sut.parameters!["Payment"] as! [String: Any])["Type"] as! String, "apple")
        XCTAssertEqual(sut.parameters!["External"] as! Int, 1)
        XCTAssertEqual(sut.parameters!["Cycle"] as! Int, 11)
}

    func test_method() {
        XCTAssertEqual(sut.method, .post)
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/payments/v4/subscription")
    }
}

final class V5SubscriptionRequestTests: XCTestCase {
    var sut: V5SubscriptionRequest!

    override func setUp() {
        super.setUp()
        sut = V5SubscriptionRequest(api: APIServiceMock(), planName: "testName", amount: 123, currencyCode: "EUR", cycle: 12, paymentAction: .token(token: "token"))
    }

    func test_tokenParameters() {
        // Given
        let token = "thisIsAToken"
        sut = V5SubscriptionRequest(api: APIServiceMock(), planName: "testName", amount: 123, currencyCode: "EUR", cycle: 13, paymentAction: .token(token: token))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "EUR")
        XCTAssertEqual(sut.parameters!["PaymentToken"] as! String, token)
        XCTAssertEqual(sut.parameters!["Cycle"] as! Int, 13)
    }

    func test_appleParameters() {
        // Given
        sut = V5SubscriptionRequest(api: APIServiceMock(), planName: "testName", amount: 123, currencyCode: "CHF", cycle: 11, paymentAction: .apple(receipt: "receipt"))

        // Then
        XCTAssertEqual(sut.parameters!["Amount"] as! Int, 123)
        XCTAssertEqual(sut.parameters!["Currency"] as! String, "CHF")
        XCTAssertEqual((sut.parameters!["Payment"] as! [String: Any])["Type"] as! String, "apple")
        XCTAssertEqual(sut.parameters!["External"] as! Int, 1)
        XCTAssertEqual(sut.parameters!["Cycle"] as! Int, 11)
}

    func test_method() {
        XCTAssertEqual(sut.method, .post)
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/payments/v5/subscription")
    }
}
