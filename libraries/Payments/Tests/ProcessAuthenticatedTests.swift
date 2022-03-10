//
//  ProcessAuthenticatedTests.swift
//  ProtonCore-Payments-Tests - Created on 26/12/2020.
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
import StoreKit
import ProtonCore_TestingToolkit
import ProtonCore_Networking
@testable import ProtonCore_Payments

final class ProcessAuthenticatedTests: XCTestCase {

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
                "Plans": []
            ]
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

    func testBuyAlreadyConsumed() {
        // Test scenario:
        // 1. Do purchase with already consumed token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            completion?(nil, PaymentTokenStatus(status: .consumed).toSuccessfulResponse, nil)
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testBuyFailed() {
        // Test scenario:
        // 1. Do purchase with failed token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            completion?(nil, PaymentTokenStatus(status: .failed).toSuccessfulResponse, nil)
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.finishTransactionStub.getCallCounter == 0)
        guard case .errored(.wrongTokenStatus(.failed)) = returnedResult else { XCTFail(); return }
    }

    func testBuyNotSupported() {
        // Test scenario:
        // 1. Do purchase with not supported token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            completion?(nil, PaymentTokenStatus(status: .notSupported).toSuccessfulResponse, nil)
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertTrue(processDependencies.finishTransactionStub.getCallCounter == 0)
        guard case .errored(.wrongTokenStatus(.notSupported)) = returnedResult else { XCTFail(); return }
    }

    func testBuyChargeableWhenAmountDueIsTheSameAsAmount() {
        // Test scenario:
        // 1. Do purchase chargeable token when amountDue is amount
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in
            return success()
        }
        
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/subscription") {
                completion?(nil, testSubscriptionDict, nil)
            } else {
                XCTFail(); completion?(nil, nil, nil) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testBuyChargeableWhenAmountDueIsDifferentThanAmount() {
        // Test scenario:
        // 1. Do purchase chargeable token when amountDue is not amount
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 80)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testSubscriptionDict = self.testSubscriptionDict
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .consumed) }
        var returnedParameters: Any?
        processDependencies.updateCurrentSubscriptionStub.bodyIs { _, success, fail in
            return success()
        }
        apiService.requestStub.bodyIs { _, _, path, parameters, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/credit") {
                completion?(nil, testSubscriptionDict, nil)
            } else if path.contains("/subscription") {
                returnedParameters = parameters
                completion?(nil, testSubscriptionDict, nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertEqual((returnedParameters as? [String: Any])?["Amount"] as? Int, 0) // buy for zero!
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testRetryProcessForPending() {
        // Test scenario:
        // 1. Do purchase pending token
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 80)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .pending) }
        var tokenToReturn = PaymentTokenStatus(status: .pending)
        apiService.requestStub.bodyIs { _, _, path, parameters, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, tokenToReturn.toSuccessfulResponse, nil)
                tokenToReturn = PaymentTokenStatus(status: .consumed)
            } else {
                XCTFail(); completion?(nil, nil, nil)
            }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testBuyPlanSubscriptionTokenErrorSandbox() {
        // Test scenario:
        // 1. Token answer - errorSandboxReceipt
        // 2. Do purchase
        // Expected: Error: errorSandboxReceipt

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, ["Code": 22914], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .erroredWithUnspecifiedError(let returnedError) = returnedResult else { XCTFail(); return }
        XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22914)
    }

    func testBuyPlanSubscriptionTokenErrorAlreadyRegitered() {
        // Test scenario:
        // 1. Token answer - errorAlreadyRegistered
        // 2. Do purchase
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, ["Code": 22916], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }

        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        XCTAssertTrue(paymentTokenStorageMock.clearStub.wasCalledExactlyOnce)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testBuyPlanSubscriptionTokenError() {
        // Test scenario:
        // 1. Token answer - error
        // 2. Do purchase
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, ["Code": 22000], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
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

    func testBuyPlanSubscriptionError() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/subscription") {
                completion?(nil, ["Code": 22000], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        guard case .erroredWithUnspecifiedError(let error) = returnedResult else { XCTFail(); return }
        XCTAssertEqual((error as? ResponseError)?.responseCode, 22000)
    }

    func testBuyPlanSubscriptionPaymentAmmountMismatchError() {
        // Test scenario:
        // 1. SubscriptionAnswer set error
        // 2. Do purchase
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        let testSubscriptionDict = self.testSubscriptionDict
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/credit") {
                completion?(nil, testSubscriptionDict, nil)
            } else if path.contains("/subscription") {
                completion?(nil, ["Code": 22101], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .errored(.creditsApplied) = returnedResult else { XCTFail(); return }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchErrorRegistered() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - errorAlredyRegistered (22916)
        // Expected: Success

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/credit") {
                completion?(nil, ["Code": 22916], nil)
            } else if path.contains("/subscription") {
                completion?(nil, ["Code": 22101], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }
        var returnedTransaction: SKPaymentTransaction?
        processDependencies.finishTransactionStub.fixture = { returnedTransaction = $0 }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedTransaction, transaction)
        guard case .finished = returnedResult else { XCTFail(); return }
    }

    func testBuyPlanSubscriptionCreditErrorAmountMismatchError() {
        // Test scenario:
        // 1. ValidateSubscription amountDue set to more than 4800
        // 2. CreditAnswer - errorAmountMismatchCode (22101)
        // 3. Do purchase
        // 4. CreditAnswer - error
        // Expected: Error: error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "test", amount: 100, amountDue: 100)
        let out = ProcessAuthenticated(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { _ in PaymentToken(token: "test token", status: .chargeable) }
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/tokens") {
                completion?(nil, PaymentTokenStatus(status: .chargeable).toSuccessfulResponse, nil)
            } else if path.contains("/credit") {
                completion?(nil, ["Code": 22000], nil)
            } else if path.contains("/subscription") {
                completion?(nil, ["Code": 22101], nil)
            } else { XCTFail(); completion?(nil, nil, nil) }
        }

        // when
        var returnedResult: ProcessCompletionResult?
        queue.async {
            try! out.process(transaction: transaction, plan: plan) { returnedResult = $0; expectation.fulfill() }
        }

        // then
        waitForExpectations(timeout: timeout)
        guard case .erroredWithUnspecifiedError(let returnedError) = returnedResult else { XCTFail(); return }
        XCTAssertEqual((returnedError as? ResponseError)?.responseCode, 22000)
    }
}
