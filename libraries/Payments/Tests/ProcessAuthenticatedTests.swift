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
// swiftlint:disable weak_delegate

import XCTest

import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class ProcessAuthenticatedTests: XCTestCase {

    var storeKitManager: StoreKitManager!
    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    var authCredential: AuthCredential?
    var userInfo: UserInfo?
    let testAuthDelegate = TestAuthDelegate()
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    let tokenStorage = TokenStorage.default
    let userCachedStatus = UserCachedStatus()
    var testStoreKitManagerDelegate: TestStoreKitManagerDelegate!
    var servicePlan: ServicePlanDataService!
    let servicePlansMock = ServicePlansMock()
    let paymentsApi = PaymentsApiMock()
    let alertManagerMock = AlertManagerMock()
    let paymentsQueue = SKPaymentQueueMock()
    let timeout = 10.0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // setup testApi
        TestDoHMail.default.status = .off
        testApi.authDelegate = testAuthDelegate
        testApi.serviceDelegate = testAPIServiceDelegate
        PMAPIService.noTrustKit = true
        
        // Setup Service plan data service
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        servicePlan.paymentsApi = paymentsApi
        servicePlan.updateServicePlans {
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        // setup StoreKitmanager
        storeKitManager = StoreKitManager.default
        tokenStorage.clear()
        testStoreKitManagerDelegate = TestStoreKitManagerDelegate(api: testApi, tokenStorage: tokenStorage, servicePlanDataService: servicePlan)
        testStoreKitManagerDelegate._userId = "12345"
        testStoreKitManagerDelegate._activeUsername = "Test User"
        storeKitManager.delegate = testStoreKitManagerDelegate
        
        // Payment API configuration
        configureStoreKit()
    }
    
    func configureStoreKit() {
        paymentsQueue.transactionState = .purchased
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        storeKitManager.paymentsAlertManager = PaymentsAlertManager(alertManager: alertManagerMock)
        storeKitManager.pendingRetryIn = 0.2
        
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }
    
    // MARK: Diagram: Upgrade free plan to paid one (starting with iOS 2.3.2)
    
    func testBuyPlanSubscriptionSuccess() throws {
        /// Test scenario:
        /// 1. Do purchase
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (1)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionPurchasingPurchasedSuccess() throws {
        /// Test scenario:
        /// 1. Change transactionState to purchasing (show Apple dialog)
        /// 2. Do purchase
        /// 3. On deferredCompletion change state to purchased and continue purchasing (confirm Apple dialog)
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // SKPaymentQueue configuration
        paymentsQueue.transactionState = .purchasing // (1)

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        } 
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        let expectation3 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation3.fulfill()
        } errorCompletion: { error in
            XCTFail()
        } deferredCompletion: {
            self.paymentsQueue.continueWithOtherState(state: .purchased) // (3)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionSuccessWithExistingToken() throws {
        /// Test scenario:
        /// 1. Crete token with state chargable
        /// 2. Do purchase
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Create token
        let paymentToken = PaymentToken(token: "1234567890", status: .chargeable) // (1)
        tokenStorage.add(paymentToken)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionTokenErrorSandbox() throws {
        /// Test scenario:
        /// 1. Token answer - errorSandboxReceipt
        /// 2. Do purchase
        /// Expected: Error: errorSandboxReceipt

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenAnswer = .errorSandboxReceipt // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22914)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionTokenErrorAlreadyRegitered() throws {
        /// Test scenario:
        /// 1. Token answer - errorAlreadyRegistered
        /// 2. Do purchase
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenAnswer = .errorAlreadyRegistered // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertNil(self.paymentsApi.lastAmount)
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionTokenError() throws {
        /// Test scenario:
        /// 1. Token answer - error
        /// 2. Do purchase
        /// Expected: Error: error

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenAnswer = .error(22000) // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22000)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionTokenStatusPendingChargeable() throws {
        /// Test scenario:
        /// 1. Token status - pending
        /// 2. Do purchase
        /// 3. Token status - change to chargeable
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .pending(nextState: .pending(nextState: .chargeable)) // (1, 3)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionTokenStatusFailed() throws {
        /// Test scenario:
        /// 1. Token status - failed
        /// 2. Do purchase
        /// Expected: Error: Errors.wrongTokenStatus(.failed)

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .failed() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.wrongTokenStatus(.failed))
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testBuyPlanSubscriptionTokenStatusNotSupported() throws {
        /// Test scenario:
        /// 1. Token status - notSupported
        /// 2. Do purchase
        /// Expected: Error: Errors.wrongTokenStatus(.notSupported)

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .notSupported() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.wrongTokenStatus(.notSupported))
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testBuyPlanSubscriptionTokenStatusConsumed() throws {
        /// Test scenario:
        /// 1. Token status - consumed
        /// 2. Do purchase
        /// Expected: Success
        
        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.tokenStatusAnswer = .consumed() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertNil(self.paymentsApi.lastAmount)
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testBuyPlanCreditSubscriptionSuccess() throws {
        /// Test scenario:
        /// 1. ValidateSubscription amountDue set to more than 4800
        /// 2. Do purchase with Credit and Subscription
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.validateSubscription = .success(amountDue: 9600) // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 0)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionError() throws {
        /// Test scenario:
        /// 1. SubscriptionAnswer set error
        /// 2. Do purchase
        /// Expected: Error: error

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.subscriptionAnswer = .error(22000) // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22000)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionValidationError() throws {
        /// Test scenario:
        /// 1. ValidateSubscription set error
        /// 2. Do purchase without credit if validateSubscription has error
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.validateSubscription = .error(1022) // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertEqual(self.paymentsApi.lastAmount, 4800)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionCreditErrorAmountMismatchSuccess() throws {
        /// Test scenario:
        /// 1. ValidateSubscription amountDue set to more than 4800
        /// 2. CreditAnswer - errorAmountMismatchCode (22101)
        /// 3. Do purchase
        /// 4. CreditAnswer - success
        /// Expected: Error: Errors.creditsApplied

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.validateSubscription = .success(amountDue: 9600) // (1)
        paymentsApi.creditAnswer = .errorNextState(CreditAnswer.errorAmountMismatchCode, nextState: .success) // (2, 4)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (3)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.creditsApplied)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionCreditErrorAmountMismatchErrorRegistered()
    throws {
        /// Test scenario:
        /// 1. ValidateSubscription amountDue set to more than 4800
        /// 2. CreditAnswer - errorAmountMismatchCode (22101)
        /// 3. Do purchase
        /// 4. CreditAnswer - errorAlredyRegistered (22916)
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.validateSubscription = .success(amountDue: 9600) // (1)
        paymentsApi.creditAnswer = .errorNextState(CreditAnswer.errorAmountMismatchCode, nextState: .errorAlredyRegistered) // (2, 4)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (3)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            XCTAssertNil(self.paymentsApi.lastAmount)
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyPlanSubscriptionCreditErrorAmountMismatchError() throws {
        /// Test scenario:
        /// 1. ValidateSubscription amountDue set to more than 4800
        /// 2. CreditAnswer - errorAmountMismatchCode (22101)
        /// 3. Do purchase
        /// 4. CreditAnswer - error
        /// Expected: Error: error

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        paymentsApi.validateSubscription = .success(amountDue: 9600) // (1)
        paymentsApi.creditAnswer = .errorNextState(CreditAnswer.errorAmountMismatchCode, nextState: .error(22000)) // (2, 4)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.free])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserNewSubscription)
        
        // purchase plan (3)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22000)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
