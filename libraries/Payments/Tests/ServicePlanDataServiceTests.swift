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

import XCTest
import StoreKit
import ProtonCore_TestingToolkit
import ProtonCore_Networking
@testable import ProtonCore_Payments

final class ServicePlanDataServiceTests: XCTestCase {

    let timeout = 1.0

    var paymentsApi: PaymentsApiMock!
    var apiService: APIServiceMock!
    var alertManagerMock: AlertManagerMock!
    var paymentsAlertMock: PaymentsAlertManager!
    var paymentsQueue: SKPaymentQueueMock!
    // swiftlint:disable:next weak_delegate
    var storeKitManagerDelegate: StoreKitManagerDelegateMock!
    var paymentTokenStorageMock: PaymentTokenStorageMock!
    var servicePlanDataStorageMock: ServicePlanDataStorageMock!

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
        paymentsApi = PaymentsApiMock()
        apiService = APIServiceMock()
        alertManagerMock = AlertManagerMock()
        paymentsAlertMock = PaymentsAlertManager(alertManager: alertManagerMock)
        paymentsQueue = SKPaymentQueueMock()
        storeKitManagerDelegate = StoreKitManagerDelegateMock()
        paymentTokenStorageMock = PaymentTokenStorageMock()
        servicePlanDataStorageMock = ServicePlanDataStorageMock()
    }

    func testUpdateServicePlansNoneAvailable() {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { [] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        // statusRequest
        // plansRequest
        // defaultPlanRequest
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/status") {
                completion?(nil, ["Code": 1000, "Apple": true], nil)
            } else if path.contains("/plans/default") {
                completion?(nil, Plan.empty.toSuccessfulResponse(underKey: "Plans"), nil)
            } else if path.contains("/plans") {
                completion?(nil, [Plan.empty].toSuccessfulResponse(underKey: "Plans"), nil)
            } else {
                XCTFail()
            }
        }
        let expectation = self.expectation(description: "Success completion block called")
        out.updateServicePlans {
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(out.availablePlansDetails, [])
        XCTAssertEqual(out.defaultPlanDetails, Plan.empty)
    }

    func testUpdateServicePlansSomeAvailable() {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { ["ios_test_12_usd_non_renewing"] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        // statusRequest
        // plansRequest
        // defaultPlanRequest
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/status") {
                completion?(nil, ["Code": 1000, "Apple": true], nil)
            } else if path.contains("/plans/default") {
                completion?(nil, Plan.empty.updated(name: "free").toSuccessfulResponse(underKey: "Plans"), nil)
            } else if path.contains("/plans") {
                completion?(nil, [Plan.empty.updated(name: "test")].toSuccessfulResponse(underKey: "Plans"), nil)
            } else {
                XCTFail()
            }
        }
        let expectation = self.expectation(description: "Success completion block called")
        out.updateServicePlans {
            expectation.fulfill()
        } failure: { error in
            XCTFail()
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(out.availablePlansDetails, [Plan.empty.updated(name: "test")])
        XCTAssertEqual(out.defaultPlanDetails, Plan.empty.updated(name: "free"))
    }

    func testUpdateCurrentSubscriptionExists() {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { ["ios_test_12_usd_non_renewing"] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        // getSubscriptionRequest
        // organizationsRequest
        let testSubscriptionDict = self.testSubscriptionDict
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/subscription") {
                completion?(nil, testSubscriptionDict, nil)
            } else if path.contains("/organizations") {
                completion?(nil, Organization.dummy.toSuccessfulResponse(underKey: "Organization"), nil)
            } else {
                XCTFail()
            }
        }
        let expectation = self.expectation(description: "Success completion block called")
        out.updateCurrentSubscription(updateCredits: false) {
            expectation.fulfill()
        } failure: { _ in
            XCTFail()
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(out.currentSubscription?.organization, Organization.dummy)
        XCTAssertEqual(out.currentSubscription?.couponCode, "test code")
    }

    func testUpdateCurrentSubscriptionNoSubscription() {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { ["ios_test_12_usd_non_renewing"] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/subscription") {
                completion?(nil, ["Code": 22110], nil)
            } else {
                XCTFail()
            }
        }
        let expectation = self.expectation(description: "Success completion block called")
        out.updateCurrentSubscription(updateCredits: false) {
            expectation.fulfill()
        } failure: { _ in
            XCTFail()
        }
        waitForExpectations(timeout: timeout)
        XCTAssertNotNil(out.currentSubscription)
        XCTAssertNil(out.credits)
    }

    func testUpdateCurrentSubscriptionNoAccess() {
        let out = ServicePlanDataService(inAppPurchaseIdentifiers: { ["ios_test_12_usd_non_renewing"] },
                                         paymentsApi: paymentsApi,
                                         apiService: apiService,
                                         localStorage: servicePlanDataStorageMock,
                                         paymentsAlertManager: paymentsAlertMock)
        apiService.requestStub.bodyIs { _, _, path, _, _, _, _, _, _, completion in
            if path.contains("/subscription") {
                completion?(URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 403)),
                            nil,
                            NSError(domain: "test", code: 100, userInfo: nil))
            } else {
                XCTFail()
            }
        }
        let expectation = self.expectation(description: "Success completion block called")
        out.updateCurrentSubscription(updateCredits: false) {
            expectation.fulfill()
        } failure: { _ in
            XCTFail()
        }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(out.currentSubscription!.isEmptyBecauseOfUnsufficientScopeToFetchTheDetails)
        XCTAssertNil(out.credits)
    }
}
