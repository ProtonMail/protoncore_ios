//
//  ValidationManagerTests.swift
//  ProtonCore-Payments-Tests - Created on 16/03/2021.
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

class ValidationManagerTests: XCTestCase {

    var storeKitManager: StoreKitManager!
    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    let testAuthDelegate = TestAuthDelegate()
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    let paymentsQueue = SKPaymentQueueMock()
    let paymentsApi = PaymentsApiMock()
    let userCachedStatus = UserCachedStatus()
    let tokenStorage = TokenStorage.default
    var testStoreKitManagerDelegate: TestStoreKitManagerDelegate!
    var servicePlan: ServicePlanDataService!
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
        storeKitManager.receiptError = nil
        storeKitManager.delegate = testStoreKitManagerDelegate
    }

    enum ProductList {
        case mail, vpn
    }
    
    func configureStoreKit(productList: ProductList) {
        storeKitManager.paymentQueue = paymentsQueue
        storeKitManager.subscribeToPaymentQueue()
        switch productList {
        case .mail:
            storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        case .vpn:
            storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.vpnBasic.storeKitProductId!, AccountPlan.vpnPlus.storeKitProductId!]))
        }
        storeKitManager.updateAvailableProductsList()
        storeKitManager.paymentsApi = paymentsApi
        paymentsApi.subscriptionRequestAnswer = .free
        paymentsApi.creditAnswer = .success
        paymentsApi.tokenAnswer = .success
        paymentsApi.tokenStatusAnswer = .chargeable
        paymentsApi.validateSubscription = .success(amountDue: 4800)
        paymentsApi.subscriptionAnswer = .success
    }
    
    func updateMailProductList() {
        storeKitManager.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
    }
    
    // Test from any plan to mailPlus plan

    func testCanPurchaseMailPlusFromFree() throws {
        // Test scenario:
        // 1. Precondition - free plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success
        
        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .free // (1)
        
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

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertTrue(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail()
        }
    }

    func testCanPurchaseMailPlusFromPlusWithAddons() throws {
        // Test scenario:
        // 1. Precondition - Plus plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .mailPlusAddons() // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromMailPlus() throws {
        // Test scenario:
        // 1. Precondition - mail plus plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertTrue(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail()
        }
    }

    func testCanPurchaseMailPlusFromMailPlus1month() throws {
        // Test scenario:
        // 1. Precondition - mail plus 1 month plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .mailPlus1m // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromMailPlus2years() throws {
        // Test scenario:
        // 1. Precondition - mail plus 2 years plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .mailPlus2y // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromVpnBasic() throws {
        // Test scenario:
        // 1. Precondition - vpn basic plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .vpnBasic // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromVpnBasicWithAddons() throws {
        // Test scenario:
        // 1. Precondition - vpn basic plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .vpnBasicAddons // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromVpnPlus() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .vpnPlus // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseMailPlusFromVpnPlusWithAddons() throws {
        // Test scenario:
        // 1. Precondition - vpn basic plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .mail)
        paymentsApi.subscriptionRequestAnswer = .vpnPlusAddons // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.mailPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    // Test from any plan to vpnBasic plan

    func testCanPurchaseVpnBasicFromFree() throws {
        // Test scenario:
        // 1. Precondition - free plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .free // (1)
        
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

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertTrue(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail()
        }
    }

    func testCanPurchaseVpnBasicFromVpnBasicWithAddons() throws {
        // Test scenario:
        // 1. Precondition - Plus plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnBasicAddons // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnBasicFromMailPlus() throws {
        // Test scenario:
        // 1. Precondition - mail plus plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .mailPlus() // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnBasicFromMailPlusWithAddons() throws {
        // Test scenario:
        // 1. Precondition - mail plus plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .mailPlusAddons() // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

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

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnBasicFromVpnPlus() throws {
        // Test scenario:
        // 1. Precondition - vpn basic plan
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnPlus // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnBasicFromVpnPlusWithAddons() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan with addons
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnPlusAddons // (1)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnBasicFromVpnBasicWithCreditBelowLimit() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan with credit 4700 (below limit)
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnBasic // (1)
        paymentsApi.usersAnswer = .credit(4700)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertTrue(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail()
        }
    }

    func testCanPurchaseVpnBasicFromVpnBasicWithCreditAboveLimit() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan with credit 4800 (above limit)
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnBasic // (1)
        paymentsApi.usersAnswer = .credit(4800)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnBasic.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }

    func testCanPurchaseVpnPlusFromVpnPlusWithCreditBelowLimit() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan with credit 9500 (below limit)
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Success

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnPlus // (1)
        paymentsApi.usersAnswer = .credit(9500)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnPlus])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnPlus.storeKitProductId!
        XCTAssertTrue(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail()
        }
    }

    func testCanPurchaseVpnPlusFromVpnPlusWithCreditAboveLimit() throws {
        // Test scenario:
        // 1. Precondition - vpn plus plan with credit 9700 (above limit)
        // 2. isValidPurchase, canPurchaseProduct
        // Expected: Errors.invalidPurchase

        // Payment API configuration
        configureStoreKit(productList: .vpn)
        paymentsApi.subscriptionRequestAnswer = .vpnBasic // (1)
        paymentsApi.usersAnswer = .credit(9700)
        
        let expectation1 = self.expectation(description: "Success completion block called")

        // update current subscription
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [.vpnBasic])
            expectation1.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }

        let productId = AccountPlan.vpnPlus.storeKitProductId!
        XCTAssertFalse(storeKitManager.validationManager.isValidPurchase(identifier: productId)) // (2)
        let result = storeKitManager.validationManager.canPurchaseProduct(identifier: productId) // (2)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error as? StoreKitManager.Errors, StoreKitManager.Errors.invalidPurchase)
        }
    }
}
