//
//  PlansDataSourceIntegrationTests.swift
//  ProtonCorePaymentsTests - Created on 03.08.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if os(iOS)

import XCTest
import OHHTTPStubs

import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
@testable import ProtonCorePayments

#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif

final class PlansDataSourceIntegrationTests: XCTestCase {

    // MARK: - fetchIAPAvailability

    func test_fetchIAPAvailability_parsesCorrectly() async throws {
        // Given
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        mockPaymentStatus()
        let request = V5PaymentStatusRequest(api: api)

        // When
        let paymentStatusResponse = try await request.response(responseObject: PaymentStatusResponse())
        guard let isAvailable = paymentStatusResponse.isAvailable else {
            XCTFail("Expected: payment status")
            return
        }

        // Then
        XCTAssertTrue(isAvailable)
    }

    // MARK: - fetchPaymentMethods

    func test_fetchPaymentMethods_parsesCorrectly() async throws {
        // Given
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        mockPaymentMethods()
        let request = V5MethodRequest(api: api)

        // When
        let methodsResponse = try await request.response(responseObject: MethodResponse())
        guard let methods = methodsResponse.methods else {
            XCTFail("Expected: method response")
            return
        }

        // Then
        XCTAssertEqual(methodsResponse.methods?.count, 1)
        XCTAssertEqual(methodsResponse.methods?[0].type, "card")
    }
}

extension PlansDataSourceIntegrationTests {
    private func mockPaymentStatus() {
        mock(filename: "PaymentStatus", title: "Payment status /payment/v5/status/apple mock", path: "/payments/v5/status/apple")
    }

    private func mockPaymentMethods() {
        mock(filename: "PaymentMethods", title: "Payment method /payment/v5/methods mock", path: "/payments/v5/methods")
    }

    private func mock(filename: String, title: String, path: String, statusCode: Int32 = 200) {
        weak var usersStub = stub(condition: pathEndsWith(path)) { request in
            let bundle = Bundle.module

            let url = bundle.url(forResource: filename, withExtension: "json")!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
        }

        usersStub?.name = title
    }
}

#endif
