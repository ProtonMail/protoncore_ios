//
//  PaymentTokenRequestTests.swift
//  ProtonCore-Payments-Tests - Created on 31/8/2023.
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
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePayments

final class PaymentTokenRequestTests: XCTestCase {

    var sut: PaymentTokenRequest!

    override func setUp() {
        // Given
        super.setUp()
        sut = PaymentTokenRequest(api: APIServiceMock(),
                                  amount: 1295,
                                  receipt: "Receipt",
                                  transactionId: "TID",
                                  bundleId: "BID",
                                  productId: "PID")
    }

    func testParameters() {
        // Then
        let payment = sut.parameters!["Payment"] as! [String: Any]
        let details = payment["Details"] as! [String: String]

        XCTAssertEqual(1295, sut.parameters!["Amount"] as! Int)
        XCTAssertEqual("USD", sut.parameters!["Currency"] as! String)
        XCTAssertEqual("apple", payment["Type"] as! String)
        XCTAssertEqual("TID", details["TransactionID"])
        XCTAssertEqual("BID", details["BundleID"])
        XCTAssertEqual("PID", details["ProductID"])
    }

    func testMethod() {
        // Then
        XCTAssertEqual(.post, sut.method)
    }

    func testPath() {
        // Then
        XCTAssertEqual("/payments/v4/tokens", sut.path)
    }

    func testAuth() {
        // Then
        XCTAssertFalse(sut.isAuth)
    }
}
