//
//  ProcessAddCreditsTests.swift
//  ProtonCore-Payments-Tests - Created on 26/05/2022.
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
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
import ProtonCoreNetworking
@testable import ProtonCorePayments

final class ProcessAddCreditsTests: XCTestCase {

    let timeout = 1.0

    let queue = DispatchQueue.global(qos: .userInitiated)

    var apiService: APIServiceMock!
    var paymentsApi: PaymentsApiMock!
    var processDependencies: ProcessDependenciesMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!

    let payment = SKPayment(product: SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: .current))

    var testSubscriptionDict: [String: Any] {
        [
            "Code": 1000,
            "Subscription": [
                "PeriodStart": 0,
                "PeriodEnd": 0,
                "CouponCode": "test code",
                "Cycle": 12,
                "Plans": [String]()
            ] as [String: Any]
        ]
    }

    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
        paymentsApi = PaymentsApiMock()
        storeKitManagerDelegate = StoreKitManagerDelegateMock()
        paymentTokenStorageMock = PaymentTokenStorageMock()
        processDependencies = ProcessDependenciesMock()
        processDependencies.apiServiceStub.fixture = apiService
        processDependencies.paymentsApiProtocolStub.fixture = paymentsApi
        processDependencies.storeKitDelegateStub.fixture = storeKitManagerDelegate
        processDependencies.tokenStorageStub.fixture = paymentTokenStorageMock
    }

    func testBuyCreditSuccess() {
        // Test scenario:
        // 1. Do purchase chargeable token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle:12)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 1000]))
            } else if path.contains("/subscription") {
                completion(nil, .success(self.testSubscriptionDict))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.resolvingIAPToCredits) = returnedResult else { XCTFail(); return }
        guard case .finished(.resolvingIAPToCredits) = processCompletionResult else { XCTFail(); return }
    }

    func testBuyCreditSuccessWithSubscriptionError() {
        // Test scenario:
        // 1. Do purchase chargeable token with subscription error
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 1)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")

        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 1000]))
            } else if path.contains("/subscription") {
                completion(nil, .success(["Code": 22100]))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.resolvingIAPToCredits) = returnedResult else { XCTFail(); return }
        guard case .finished(.resolvingIAPToCredits) = processCompletionResult else { XCTFail(); return }
    }

    // To be removed with CP-6369
    func testBuyCreditOldTokenError() throws {
        withFeatureSwitches([]) {
            // Test scenario:
            // 1. Do purchase with get token error answer
            // Expected: Success

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 15)
            let out = ProcessAddCredits(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:])) }
            }

            // when
            var returnedError: Error?
            queue.async {
                do {
                    try out.process(transaction: transaction, plan: plan) { _ in XCTFail() }
                } catch {
                    returnedError = error
                    expectation.fulfill()
                }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22000)
        }
    }

    func testBuyCreditTokenError() throws {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do purchase with get token error answer
            // Expected: Success

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 24)
            let out = ProcessAddCredits(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22000]))
                } else {
                    XCTFail(); completion(nil, .success([:])) }
            }

            // when
            var returnedError: Error?
            queue.async {
                do {
                    try out.process(transaction: transaction, plan: plan) { _ in XCTFail() }
                } catch {
                    returnedError = error
                    expectation.fulfill()
                }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22000)
        }
    }

    func testBuyCreditSuccessPaymentAlreadyRegistered() {
        // Test scenario:
        // 1. Do purchase with payment already registered error
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 6)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }
        var processCompletionResult: ProcessCompletionResult?
        processDependencies.refreshCompletionHandlerStub.fixture = { processCompletionResult = $0 }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 22916]))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0; $1?() }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished(.withPurchaseAlreadyProcessed) = returnedResult else { XCTFail(); return }
        guard case .finished(.withPurchaseAlreadyProcessed) = processCompletionResult else { XCTFail(); return }
    }

    func testBuyCreditErrorSandboxReceiptError() {
        // Test scenario:
        // 1. Do purchase with payment already registered error
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 12)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 22914]))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        if case .erroredWithUnspecifiedError(let error) = returnedResult {
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22914)
        } else {
            XCTFail()
            return
        }
    }

    func testBuyCreditError() {
        // Test scenario:
        // 1. Do purchase with cretit answer error
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 18)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .success(["Code": 22100]))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        if case .erroredWithUnspecifiedError(let error) = returnedResult {
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22100)
        } else {
            XCTFail()
        }
    }

    func testBuyCreditErrorApiMightBeBlocked() {
        // Test scenario:
        // 1. Do purchase with cretit answer error
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100, cycle: 3)
        let out = ProcessAddCredits(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in return success() }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion(nil, .success(PaymentToken(token: "test token", status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/credit") {
                completion(nil, .failure(.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: PSTranslation._core_api_might_be_blocked_message.l10n)))
            } else {
                XCTFail(); completion(nil, .success([:])) }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        guard case .erroredWithUnspecifiedError(StoreKitManagerErrors.apiMightBeBlocked) = returnedResult else { XCTFail(); return }
    }
}
