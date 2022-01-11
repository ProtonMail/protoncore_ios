//
//  PaymentsUIViewModelTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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
import ProtonCore_CoreTranslation
@testable import ProtonCore_Payments
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_PaymentsUI

final class PaymentsUIViewModelTests: XCTestCase {

    let timeout = 1.0

    var storeKitManager: StoreKitManagerMock!
    var servicePlan: ServicePlanDataServiceMock!

    override func setUp() {
        super.setUp()
        storeKitManager = StoreKitManagerMock()
        servicePlan = ServicePlanDataServiceMock()
    }

    func testFetchSignupPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test", iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==")]
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansWithBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test", iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==")]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansWithAdditionalBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.plansStub.fix { counter in
            if counter == 1 { return [] } else { return [Plan.empty.updated(name: "test", iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==")] }
        }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(servicePlan.updateServicePlansSuccessFailureStub.wasCalledExactlyOnce)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchSignupPlansNoPurchasablePlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test", title: "test title", state: 0)]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertTrue(returnedPlans?.count == 0)
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    // MARK: Current plan mode
    
    func testFetchCurrentPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", iD: "ziWi-ZOb28XR4sCGFCEpqQbd1FITVWYfTfKYUmV_wKKR3GsveN4HZCh9er5dhelYylEp-fhjBbUPDMHGU699fw==")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withoutPlans)
    }
    
    func testFetchCurrentPlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [""], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "")
        XCTAssertTrue(returnedFooterType == .disabled)
    }

    // MARK: Update plan mode
    func testFetchUpdatePlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchUpdatePlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchUpdatePlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertTrue(returnedFooterType == .withoutPlans)
    }
    
    func testFetchUpdatePlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModelViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [], clientApp: .mail, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "")
        XCTAssertTrue(returnedFooterType == .disabled)
    }
    
    func testFetchCurrentPlansVPN() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "Plus", iD: "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==", pricing: ["12": 9600]), Plan.empty.updated(name: "Basic", iD: "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["Plus", "Basic", "free"], clientApp: .vpn, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertEqual(returnedPlans?.last?.last?.name, "Basic")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }
    
    func testFetchCurrentPlansVPNFilteredPlusPlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "Plus", iD: "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==", pricing: ["12": 9600]), Plan.empty.updated(name: "Basic", iD: "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["Basic", "free"], clientApp: .vpn, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Basic")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }

    func testFetchCurrentPlansVPNFilteredBasicPlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "Plus", iD: "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==", pricing: ["12": 9600]), Plan.empty.updated(name: "Basic", iD: "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModelViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["Plus", "free"], clientApp: .vpn, updateCredits: false)
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        XCTAssertEqual(returnedPlans?.count, 2)
        XCTAssertEqual(returnedPlans?.first?.first?.name, "Free")
        XCTAssertEqual(returnedPlans?.last?.first?.name, "Plus")
        XCTAssertTrue(returnedFooterType == .withPlans)
    }
}
