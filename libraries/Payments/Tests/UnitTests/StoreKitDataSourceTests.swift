//
//  StoreKitDataSourceTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
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
import StoreKit
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

@testable import ProtonCorePayments

final class StoreKitDataSourceTests: XCTestCase {

    func testNoProductsAreAvailableAtTheBeginning() async throws {
        let out = StoreKitDataSource() { SKRequestMock(productIdentifiers: $0) }
        XCTAssertEqual(out.availableProducts, [])
        XCTAssertEqual(out.unavailableProductsIdentifiers, [])
    }

    func testFetchingProductsCausesRequestConfigAndStartsTheAsyncOperationWhichEndsWithDelegateMethodBeingCalled() async throws {
        let request = SKRequestMock(productIdentifiers: [])
        let out = StoreKitDataSource() { _ in request }

        // run async task
        let task = Task {
            try await out.fetchAvailableProducts(productIdentifiers: [])
        }
        // call delegate after a wait 0.1s, to ensure the async task completes
        Task {
            try await Task.sleep(nanoseconds: 100_000_000)
            out.productsRequest(request, didReceive: SKProductsResponseMock())
        }
        // wait on the completion of the async task
        try await task.value
        XCTAssertTrue(request.delegateStub.setWasCalledExactlyOnce)
        XCTAssertFalse(request.delegateStub.getWasCalled)
        XCTAssertTrue(request.startStub.wasCalledExactlyOnce)
    }

    func testProductResponseIsParsed() async throws {
        let out = StoreKitDataSource()
        let available: [SKProduct] = [
            .init(identifier: "unavailable1", price: "100", priceLocale: .autoupdatingCurrent),
            .init(identifier: "unavailable2", price: "200", priceLocale: .autoupdatingCurrent)
        ]
        let unavailable = ["unavailable1", "unavailable2"]
        let response = SKProductsResponseMock()
        response.productsStub.fixture = available
        response.invalidProductIdentifiersStub.fixture = unavailable
        try await withCheckedThrowingContinuation { continuation in
            out.requestContinuation = continuation
            out.productsRequest(SKRequestMock(productIdentifiers: []), didReceive: response)
        }
        XCTAssertEqual(out.availableProducts, available)
        XCTAssertEqual(out.unavailableProductsIdentifiers, unavailable)
    }

    func testProductFetchErrorIsParsed() async throws {
        let out = StoreKitDataSource()
        let available: [SKProduct] = [
            .init(identifier: "unavailable1", price: "100", priceLocale: .autoupdatingCurrent),
            .init(identifier: "unavailable2", price: "200", priceLocale: .autoupdatingCurrent)
        ]
        let unavailable = ["unavailable1", "unavailable2"]
        let response = SKProductsResponseMock()
        response.productsStub.fixture = available
        response.invalidProductIdentifiersStub.fixture = unavailable
        enum TestError: Error { case testError }

        do {
            try await withCheckedThrowingContinuation { continuation in
                out.requestContinuation = continuation
                out.request(SKRequestMock(productIdentifiers: []), didFailWithError: TestError.testError)
            }
            XCTFail("expected to throw error")
        } catch {
            guard .testError == error as? TestError else { XCTFail("wrong error thrown"); return }
            XCTAssertTrue(out.availableProducts.isEmpty)
            XCTAssertTrue(out.unavailableProductsIdentifiers.isEmpty)
        }
    }
}
