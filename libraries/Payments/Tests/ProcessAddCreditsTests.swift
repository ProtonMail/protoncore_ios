//
//  ProcessAddCreditsTests.swift
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
import StoreKit

import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class ProcessAddCreditsTests: XCTestCase {

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
        testStoreKitManagerDelegate = TestStoreKitManagerDelegate(api: testApi, tokenStorage: tokenStorage, servicePlanDataService: servicePlan)
        testStoreKitManagerDelegate._userId = "12345"
        testStoreKitManagerDelegate._activeUsername = "Test User"
        storeKitManager.delegate = testStoreKitManagerDelegate
    }
    
    func configureStoreKit() {
        let paymentsQueue = SKPaymentQueueMock()
        paymentsQueue.transactionState = .purchased
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKitManager.updateAvailableProductsList()
        storeKitManager.pendingRetryIn = 0.2
        
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }

    // MARK: Subscription renewal flow
    
    func testBuyCreditSuccess() throws {
        /// Test scenario:
        /// 1. Precondition - Plus plan
        /// 2. Do purchase
        /// Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        configureStoreKit()
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserAddCredits)
        
        // already existing plus plan, do credit only (2)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyCreditTokenError() throws {
        /// Test scenario:
        /// 1. Precondition - Plus plan
        /// 2. Do purchase with get token error answer
        /// Expected: Error

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        configureStoreKit()
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserAddCredits)
        
        // already existing plus plan, do credit only (2)
        paymentsApi.tokenAnswer = .error(20999)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 20999)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testBuyCreditSuccessPaymentAlreadyRegistered() throws {
        // Test scenario:
        // 1. Precondition - Plus plan
        // 2. Do purchase with payment already registered error
        // Expected: Success

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        configureStoreKit()
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserAddCredits)
        
        // already existing plus plan, do credit only (2)
        paymentsApi.creditAnswer = .errorAlredyRegistered
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTAssertNil(token)
            expectation2.fulfill()
        } errorCompletion: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testBuyCreditError() throws {
        /// Test scenario:
        /// 1. Precondition - Plus plan
        /// 2. Do purchase with cretit answer error
        /// Expected: Error

        let expectation1 = self.expectation(description: "Success completion block called")
        
        // Payment API configuration
        configureStoreKit()
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.mailPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        
        // check processing type before purchase
        XCTAssertEqual(storeKitManager.processingType, .existingUserAddCredits)
        
        // already existing plus plan, do credit only (2)
        paymentsApi.creditAnswer = .error(22100)
        let productId = AccountPlan.mailPlus.storeKitProductId!
        storeKitManager.purchaseProduct(identifier: productId) { token in
            XCTFail()
        } errorCompletion: { error in
            XCTAssertEqual((error as? ResponseError)?.responseCode, 22100)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
