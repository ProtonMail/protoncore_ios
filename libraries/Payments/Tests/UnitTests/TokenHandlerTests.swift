//
//  TokenHandlerTests.swift
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
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreNetworking
@testable import ProtonCorePayments

final class TokenHandlerTests: XCTestCase {

    let timeout = 1.0

    let queue = DispatchQueue.global(qos: .userInitiated)

    var apiService: APIServiceMock!
    var paymentsApi: PaymentsApiMock!
    var processDependencies: ProcessDependenciesMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!

    let payment = SKPayment(product: SKProduct(identifier: "ios_test_12_usd_non_renewing", price: "0.0", priceLocale: .current))

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

    func testTokenSoredChargeableTokenSuccess() {
        // Test scenario:
        // 1. Do getToken
        // Expected: tokenCompletion

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 1)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { _ in testToken }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                XCTFail()
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTAssertEqual(token, testToken)
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTokenSoredPendingPendingChargeableTokenSuccess() {
        // Test scenario:
        // 1. Do getToken
        // Expected: tokenCompletion

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 12)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { _ in testToken }

        apiService.requestJSONStub.bodyIs { count, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                if count < 3 {
                    completion(nil, .success(PaymentTokenStatus(status: .pending).toSuccessfulResponse))
                } else {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                }
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                XCTFail()
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTAssertEqual(token, testToken)
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTokenSoredFailedWrongTokenStatus() {
        // Test scenario:
        // 1. Do getToken
        // Expected: completion errored wrongTokenStatus

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 2)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { _ in testToken }

        apiService.requestJSONStub.bodyIs { count, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .failed).toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                switch status {
                case .errored(let error):
                    XCTAssertEqual(error, .wrongTokenStatus(.failed))
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }, finishCompletion: { result in
                XCTFail()
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTFail()
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTokenSoredNotSupporteddWrongTokenStatus() {
        // Test scenario:
        // 1. Do getToken
        // Expected: completion errored wrongTokenStatus

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 6)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { _ in testToken }

        apiService.requestJSONStub.bodyIs { count, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .notSupported).toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                switch status {
                case .errored(let error):
                    XCTAssertEqual(error, .wrongTokenStatus(.notSupported))
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }, finishCompletion: { result in
                XCTFail()
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTFail()
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
    }

    func testTokenSoredConsumedTokenSuccess() {
        // Test scenario:
        // 1. Do getToken
        // Expected: finish completion

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 12)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { _ in testToken }

        apiService.requestJSONStub.bodyIs { count, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .consumed).toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                switch result {
                case .finished(let paymentSucceeded):
                    XCTAssertEqual(paymentSucceeded, .withPurchaseAlreadyProcessed)
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTFail()
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
    }

    func testChargeableTokenSuccess() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do getToken
            // Expected: tokenCompletion

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 3)
            let out = TokenHandler(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            let testToken = PaymentToken(token: "test token", status: .chargeable)
            paymentTokenStorageMock.getStub.bodyIs { count in
                if count > 1 {
                    return PaymentToken(token: "test token", status: .chargeable)
                } else {
                    return nil
                }
            }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(testToken.toSuccessfulResponse))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            // when
            queue.async {
                try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                    XCTFail()
                    expectation.fulfill()
                }, finishCompletion: { result in
                    XCTFail()
                    expectation.fulfill()
                }, tokenCompletion: { token in
                    XCTAssertEqual(token, testToken)
                    expectation.fulfill()
                })
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 2)
        }
    }

    func testChargeableTokenSandboxReceiptError() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do getToken
            // Expected: finishCompletion isSandboxReceiptError

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 1)
            let out = TokenHandler(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { count in
                if count > 1 {
                    return PaymentToken(token: "test token", status: .chargeable)
                } else {
                    return nil
                }
            }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22914]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            // when
            queue.async {
                try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                    XCTFail()
                    expectation.fulfill()
                }, finishCompletion: { result in
                    if case .erroredWithUnspecifiedError(let error) = result {
                        XCTAssertEqual(error.responseCode, 22914)
                    } else {
                        XCTFail()
                    }
                    expectation.fulfill()
                }, tokenCompletion: { token in
                    XCTFail()
                    expectation.fulfill()
                })
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
        }
    }

    func testChargeableApplePaymentAlreadyRegisteredError() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do getToken
            // Expected: finishCompletion isApplePaymentAlreadyRegisteredError

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 2)
            let out = TokenHandler(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { count in
                if count > 1 {
                    return PaymentToken(token: "test token", status: .chargeable)
                } else {
                    return nil
                }
            }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(["Code": 22916]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            // when
            queue.async {
                try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                    XCTFail()
                    expectation.fulfill()
                }, finishCompletion: { result in
                    if case .finished(.withPurchaseAlreadyProcessed) = result { } else {
                        XCTFail()
                    }
                    expectation.fulfill()
                }, tokenCompletion: { token in
                    XCTFail()
                    expectation.fulfill()
                })
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
        }
    }

    func testChargeableUnhandledError() {
        withFeatureFlags([.dynamicPlans]) { // remove enclosure with CP-6369
            // Test scenario:
            // 1. Do getToken
            // Expected: catch unhandled error

            // given
            let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: "identifier", transactionState: .purchased)
            let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 4)
            let out = TokenHandler(dependencies: processDependencies)
            let expectation = self.expectation(description: "Completion block called")
            paymentTokenStorageMock.getStub.bodyIs { count in
                if count > 1 {
                    return PaymentToken(token: "test token", status: .chargeable)
                } else {
                    return nil
                }
            }

            apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/tokens/") {
                    completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
                } else if path.contains("/tokens") {
                    completion(nil, .success(["Code": 999]))
                } else {
                    XCTFail()
                    completion(nil, .success([:]))
                }
            }

            // when
            queue.async {
                do {
                    try out.getToken(transaction: transaction, plan: plan, completion: { _ in
                        XCTFail()
                        expectation.fulfill()
                    }, finishCompletion: { result in
                        XCTFail()
                        expectation.fulfill()
                    }, tokenCompletion: { token in
                        XCTFail()
                        expectation.fulfill()
                    })
                } catch let error {
                    XCTAssertEqual(error.responseCode, 999)
                    expectation.fulfill()
                }
            }

            // then
            waitForExpectations(timeout: timeout)
            XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
        }
    }

    // Remove with CP-6369

    func testChargeableTokenSuccessWithoutSubscriptionsFF() {
        // Test scenario:
        // 1. Do getToken
        // Expected: tokenCompletion

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 1)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        let testToken = PaymentToken(token: "test token", status: .chargeable)
        paymentTokenStorageMock.getStub.bodyIs { count in
            if count > 1 {
                return PaymentToken(token: "test token", status: .chargeable)
            } else {
                return nil
            }
        }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(testToken.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                XCTFail()
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTAssertEqual(token, testToken)
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 2)
    }

    //
    func testChargeableTokenSandboxReceiptErrorWithoutSubscriptionsFF() {
        // Test scenario:
        // 1. Do getToken
        // Expected: finishCompletion isSandboxReceiptError

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 6)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { count in
            if count > 1 {
                return PaymentToken(token: "test token", status: .chargeable)
            } else {
                return nil
            }
        }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(["Code": 22914]))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                if case .erroredWithUnspecifiedError(let error) = result {
                    XCTAssertEqual(error.responseCode, 22914)
                } else {
                    XCTFail()
                }
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTFail()
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
    }

    func testChargeableApplePaymentAlreadyRegisteredErrorWithoutSubscriptionsFF() {
        // Test scenario:
        // 1. Do getToken
        // Expected: finishCompletion isApplePaymentAlreadyRegisteredError

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 6)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { count in
            if count > 1 {
                return PaymentToken(token: "test token", status: .chargeable)
            } else {
                return nil
            }
        }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(["Code": 22916]))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            try! out.getToken(transaction: transaction, plan: plan, completion: { status in
                XCTFail()
                expectation.fulfill()
            }, finishCompletion: { result in
                if case .finished(.withPurchaseAlreadyProcessed) = result { } else {
                    XCTFail()
                }
                expectation.fulfill()
            }, tokenCompletion: { token in
                XCTFail()
                expectation.fulfill()
            })
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
    }

    func testChargeableUnhandledErrorWithoutSubscriptionsFF() {
        // Test scenario:
        // 1. Do getToken
        // Expected: catch unhandled error

        // given
        let transaction = SKPaymentTransactionMock(payment: payment, transactionDate: nil, transactionIdentifier: nil, transactionState: .purchased)
        let plan = PlanToBeProcessed(protonIdentifier: "testID", planName: "testName", amount: 100, amountDue: 100, cycle: 2)
        let out = TokenHandler(dependencies: processDependencies)
        let expectation = self.expectation(description: "Completion block called")
        paymentTokenStorageMock.getStub.bodyIs { count in
            if count > 1 {
                return PaymentToken(token: "test token", status: .chargeable)
            } else {
                return nil
            }
        }

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/tokens/") {
                completion(nil, .success(PaymentTokenStatus(status: .chargeable).toSuccessfulResponse))
            } else if path.contains("/tokens") {
                completion(nil, .success(["Code": 999]))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        // when
        queue.async {
            do {
                try out.getToken(transaction: transaction, plan: plan, completion: { _ in
                    XCTFail()
                    expectation.fulfill()
                }, finishCompletion: { result in
                    XCTFail()
                    expectation.fulfill()
                }, tokenCompletion: { token in
                    XCTFail()
                    expectation.fulfill()
                })
            } catch let error {
                XCTAssertEqual(error.responseCode, 999)
                expectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(paymentTokenStorageMock.getStub.callCounter, 1)
    }
}
