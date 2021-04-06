//
//  ServicePlanDataServiceTests.swift
//  ProtonCore-Payments-Tests - Created on 21/12/2020.
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

class ServicePlanDataServiceTests: XCTestCase {

    let testApi = PMAPIService(doh: TestDoHMail.default, sessionUID: "testSessionUID")
    var authCredential: AuthCredential?
    var userInfo: UserInfo?
    let testAuthDelegate = TestAuthDelegate()
    
    let testAPIServiceDelegate = TestAPIServiceDelegate()
    var userCachedStatus: UserCachedStatus!
    var servicePlan: ServicePlanDataService!
    let paymentsApiMock = PaymentsApiMock()
    let servicePlansMock = ServicePlansMock()
    let timeout = 10.0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // setup testApi
        TestDoHMail.default.status = .off
        testApi.authDelegate = testAuthDelegate
        testApi.serviceDelegate = testAPIServiceDelegate
        PMAPIService.noTrustKit = true
        
        // setup ServicePlanDataService
        userCachedStatus = UserCachedStatus()
        servicePlan = ServicePlanDataService(localStorage: userCachedStatus, apiService: testApi)
        servicePlan.paymentsApi = paymentsApiMock
     }
    
    // empty service plan
    let emptyServicePlanDetails = ServicePlanDetails(features: 0, iD: "", maxAddresses: 0, maxDomains: 0, maxMembers: 0, maxSpace: 0, maxVPN: 0, name: "", quantity: 0, services: 0, title: "", type: 0)
    
    // free service plan
    let freeServicePlanDetails = ServicePlanDetails(features: 0, iD: nil, maxAddresses: 1, maxDomains: 0, maxMembers: 1, maxSpace: 524288000, maxVPN: 0, name: "free", quantity: 1, services: 1, title: "ProtonMail Free", type: 1)
    
    // mail plus service plan
    let mailPlusServicePlanDetails = ServicePlanDetails(features: 0, iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==", maxAddresses: 5, maxDomains: 1, maxMembers: 1, maxSpace: 5368709120, maxVPN: 0, name: "plus", quantity: 1, services: 1, title: "ProtonMail Plus", type: 1)
    
    // vpn plus service plan
    let vpnPlusServicePlanDetails = ServicePlanDetails(features: 0, iD: "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==", maxAddresses: 0, maxDomains: 0, maxMembers: 0, maxSpace: 0, maxVPN: 5, name: "vpnplus", quantity: 1, services: 4, title: "ProtonVPN Plus", type: 1)

    func testUpdateServicePlans() throws {
        let expectation = self.expectation(description: "Success completion block called")
        
        servicePlan.updateServicePlans {
            XCTAssertTrue(self.servicePlan.isIAPAvailable)
            XCTAssertTrue(self.servicePlan.isIAPUpgradePlanAvailable)
            XCTAssertEqual(self.servicePlan.defaultPlanDetails, self.freeServicePlanDetails)
            XCTAssertEqual(self.servicePlan.detailsOfServicePlan(named: "free"), self.freeServicePlanDetails)
            XCTAssertEqual(self.servicePlan.detailsOfServicePlan(named: "plus"), self.mailPlusServicePlanDetails)
            XCTAssertEqual(self.servicePlan.detailsOfServicePlan(named: "vpnplus"), self.vpnPlusServicePlanDetails)
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testUpdateCurrentSubscriptionFree() throws {
        // paymentsApiMock setup
        paymentsApiMock.subscriptionRequestAnswer = .free
        paymentsApiMock.tokenAnswer = .success
        paymentsApiMock.tokenStatusAnswer = .chargeable
        paymentsApiMock.subscriptionAnswer = .success
        
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.start, nil)
            XCTAssertEqual(self.servicePlan.currentSubscription?.end, nil)
            XCTAssert(self.servicePlan.currentSubscription?.paymentMethods == nil)
            XCTAssertEqual(self.servicePlan.currentSubscription?.cycle, nil)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [AccountPlan.free])
            XCTAssertEqual(self.servicePlan.currentSubscription?.details, self.emptyServicePlanDetails)
            XCTAssertEqual(self.servicePlan.currentSubscription?.hasExistingProtonSubscription, false)
            XCTAssertEqual(self.servicePlan.currentSubscription?.hadOnlinePayments, false)
            XCTAssertEqual(self.servicePlan.currentSubscription?.endDate, nil)
            XCTAssertEqual(self.servicePlan.currentSubscription?.hasSpecialCoupon, false)
            XCTAssertEqual(self.servicePlan.proceedTier54, 0)
            XCTAssertEqual(self.servicePlan.credits?.credit, 0)
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testUpdateCurrentSubscriptionMailPlus() throws {
        // paymentsApiMock setup
        paymentsApiMock.subscriptionRequestAnswer = .mailPlus()
        paymentsApiMock.tokenAnswer = .success
        paymentsApiMock.tokenStatusAnswer = .chargeable
        paymentsApiMock.subscriptionAnswer = .success
        paymentsApiMock.usersAnswer = .credit(500)

        // storeKit setup
        let storeKit = StoreKitManager.default
        storeKit.request = SKRequestMock(productIdentifiers: Set([AccountPlan.mailPlus.storeKitProductId!]))
        storeKit.updateAvailableProductsList()
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.updateCurrentSubscription {
            XCTAssertEqual(self.servicePlan.currentSubscription?.start, Date(timeIntervalSince1970: 1608217199))
            XCTAssertEqual(self.servicePlan.currentSubscription?.end, Date(timeIntervalSince1970: 1639753199))
            XCTAssertEqual(self.servicePlan.currentSubscription?.paymentMethods?.count, 1)
            if let paymentMethods = self.servicePlan.currentSubscription?.paymentMethods {
                XCTAssertEqual(paymentMethods.first?.type, .apple)
            }
            XCTAssertEqual(self.servicePlan.currentSubscription?.cycle, 12)
            XCTAssertEqual(self.servicePlan.currentSubscription?.plans, [AccountPlan.mailPlus])
            XCTAssertEqual(self.servicePlan.currentSubscription?.details, self.mailPlusServicePlanDetails)
            XCTAssertEqual(self.servicePlan.currentSubscription?.hasExistingProtonSubscription, true)
            XCTAssertEqual(self.servicePlan.currentSubscription?.hadOnlinePayments, false)
            XCTAssertEqual(self.servicePlan.currentSubscription?.endDate, Date(timeIntervalSince1970: 1639753199))
            XCTAssertEqual(self.servicePlan.currentSubscription?.hasSpecialCoupon, false)
            XCTAssertEqual(self.servicePlan.proceedTier54, 49.0)
            XCTAssertEqual(self.servicePlan.credits?.credit, 500 / 100)
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
