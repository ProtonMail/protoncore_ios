//
//  PaymentsUIViewModelTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
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
import ProtonCore_CoreTranslation
@testable import ProtonCore_Payments
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_PaymentsUI

@available(iOS 13, *)
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
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "plus")]
        let out = PaymentsUIViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchSignupPlansWithBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchSignupPlansWithAdditionalBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.plansStub.fix { counter in
            if counter == 1 { return [] } else { return [Plan.empty.updated(name: "plus")] }
        }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchSignupPlansNoPurchasablePlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "test", title: "test title", state: 0)]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    // MARK: Current plan mode

    func testFetchCurrentPlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        switch returnedPlans?.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_plus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "plus")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        switch returnedPlans?.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withoutPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [""], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details:
                XCTFail()
            case .unavailable:
                XCTAssertTrue(true)
            }
        default:
            XCTFail()
        }
        if case .disabled = returnedFooterType { } else { XCTFail() }
    }

    // MARK: Update plan mode

    func testFetchUpdatePlansNoBackendFetch() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Free")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchUpdatePlansWithFetchFromBackend() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "plus", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["plus", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }
    
    func testFetchUpdatePlansWithFetchFromBackendNoPlansToUpdateNoShownPlanNames() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        servicePlan.isIAPAvailableStub.fixture = true
        servicePlan.updateCurrentSubscriptionSuccessFailureStub.bodyIs { _, _, completion, errorCompletion in completion() }
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withoutPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchUpdatePlansWithSubscription() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_test_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "test", title: "test title")]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy.updated(planDetails: [Plan.empty.updated(name: "test2", title: "test2 title")])
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["test", "free", "test2"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withoutPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchUpdatePlansNoBackendFetchDisabledFooter() {
        let expectation = self.expectation(description: "Success completion block called")
        servicePlan.currentSubscriptionStub.fixture = Subscription.userHasUnsufficientScopeToFetchSubscription
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: [], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details:
                XCTFail()
            case .unavailable:
                XCTAssertTrue(true)
            }
        default:
            XCTFail()
        }
        if case .disabled = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansVPN() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        switch returnedPlans?.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        switch returnedPlans?.last?.last?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansVPNFilteredPlusPlan() {
        let expectation = self.expectation(description: "Success completion block called")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
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
        switch returnedPlans?.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        switch returnedPlans?.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    func testFetchCurrentPlansVPNFilteredBasicPlan() async {
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = ["ios_vpnbasic_12_usd_non_renewing", "ios_vpnplus_12_usd_non_renewing"]
        servicePlan.availablePlansDetailsStub.fixture = [Plan.empty.updated(name: "vpnplus", pricing: ["12": 9600]), Plan.empty.updated(name: "vpnbasic", pricing: ["12": 4800])]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, _ in Plan.empty.updated(name: "free", title: "free title") }
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let (returnedPlans, returnedFooterType): ([[PlanPresentation]], FooterType) = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, footerType)):
                    continuation.resume(returning: (plans, footerType))
                }
            }
        }
        XCTAssertEqual(returnedPlans.count, 2)
        switch returnedPlans.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        switch returnedPlans.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
        default:
            XCTFail()
        }
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
    }

    enum PresentedPriceTestingHelper {
        static let plusPlan = Plan.empty.updated(name: "vpnplus",
                                          iD: "S6oNe_lxq3GNMIMFQdAwOOk5wNYpZwGjBHFr5mTNp9aoMUaCRNsefrQt35mIg55iefE3fTq8BnyM4znqoVrAyA==",
                                          pricing: ["1": 1000, "12": 10000, "24": 18000],
                                          cycle: 12)
        static let basicPlan = Plan.empty.updated(name: "vpnbasic",
                                                  iD: "cjGMPrkCYMsx5VTzPkfOLwbrShoj9NnLt3518AH-DQLYcvsJwwjGOkS8u3AcnX4mVSP6DX2c6Uco99USShaigQ==",
                                                  pricing: ["1": 500, "12": 4800, "24": 8800],
                                                  cycle: 12)
        static let free = Plan.empty.updated(name: "free", title: "free title")
        static let basicIAP = "ios_vpnbasic_12_usd_non_renewing"
        static let plusIAP = "ios_vpnplus_12_usd_non_renewing"

        static func priceLabelForProduct(id storeKitId: String) -> (NSDecimalNumber, Locale)? {
            if storeKitId == plusIAP { return (NSDecimalNumber(value: 120), Locale(identifier: "en_US")) }
            if storeKitId == basicIAP { return (NSDecimalNumber(value: 60), Locale(identifier: "en_US")) }
            XCTFail(); return nil
        }

        static func detailsOfPlan(name: String) -> Plan? {
            if name == plusPlan.name { return plusPlan }
            if name == basicPlan.name { return plusPlan }
            if name == free.name { return free }
            XCTFail(); return nil
        }
    }

    func testCurrentPlan_PresentedPrice_Free_NoPaymentMethod() async {
        // GIVEN: user has no subscription and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = nil
        servicePlan.paymentMethodsStub.fixture = []

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the free plan and upgrade plans with IAP prices
        XCTAssertEqual(planPresentations.count, 2)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
                XCTAssertEqual(details.price, "$0")
                XCTAssertEqual(details.cycle, nil)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentations.last!.count, 2)
        switch planPresentations.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
            XCTAssertEqual(details.price, "$120.00")
            XCTAssertEqual(details.cycle, "for 1 year")
        default:
            XCTFail()
        }
        switch planPresentations.last?.last?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
            XCTAssertEqual(details.price, "$60.00")
            XCTAssertEqual(details.cycle, "for 1 year")
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle1_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 1 and price 2.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 1, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "€2.00")
                XCTAssertEqual(details.cycle, "for 1 month")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle12_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 12 and price 2.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 12, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price returned by storekit with yearly cycle
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "$120.00")
                XCTAssertEqual(details.cycle, "for 1 year")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle24_NoPaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 24 and price 4.00 EUR and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 24, amount: 400, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = []

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "€4.00")
                XCTAssertEqual(details.cycle, "for 2 years")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Free_PaymentMethod() async {
        // GIVEN: user has no subscription and no payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = nil
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the free plan and upgrade plans with IAP prices
        XCTAssertEqual(planPresentations.count, 2)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Free")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentations.last!.count, 2)
        switch planPresentations.last?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
            XCTAssertEqual(details.price, "$120.00")
            XCTAssertEqual(details.cycle, "for 1 year")
        default:
            XCTFail()
        }
        switch planPresentations.last?.last?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
            XCTAssertEqual(details.price, "$60.00")
            XCTAssertEqual(details.cycle, "for 1 year")
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle1_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 1 and price 2.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 1, amount: 200, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "€2.00")
                XCTAssertEqual(details.cycle, "for 1 month")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle12_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 12 and price 3.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 12, amount: 300, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "€3.00")
                XCTAssertEqual(details.cycle, "for 1 year")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testCurrentPlan_PresentedPrice_Cycle24_PaymentMethod() async {
        // GIVEN: user has plus subscription with cycle 24 and price 4.00 EUR and card payment methods
        storeKitManager.priceLabelForProductStub.bodyIs { PresentedPriceTestingHelper.priceLabelForProduct(id: $1) }
        servicePlan.detailsOfServicePlanStub.bodyIs { PresentedPriceTestingHelper.detailsOfPlan(name: $1) }
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan], cycle: 24, amount: 400, currency: "EUR")
        servicePlan.paymentMethodsStub.fixture = [PaymentMethod(type: "card")]

        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan,
                                               shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
                XCTAssertEqual(details.price, "€4.00")
                XCTAssertEqual(details.cycle, "for 2 years")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
    
    /* planRefreshHandler tests  */

    func testUpdatePlans_UnfinishedPurchasePlan() {
        // GIVEN: user has has no subscription
        let expectation1 = self.expectation(description: "fetchPlans handler")
        let expectation2 = self.expectation(description: "planRefreshHandler")
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.plansStub.fixture = [Plan.empty.updated(name: "vpnplus"), Plan.empty.updated(name: "vpnbasic")]
        servicePlan.updateServicePlansSuccessFailureStub.bodyIs { _, _, completion, _ in completion() }
        let out = PaymentsUIViewModel(mode: .signup, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic"], clientApp: .mail, planRefreshHandler: { result in
            XCTAssertNil(result)
            expectation2.fulfill()
        }, extendSubscriptionHandler: { XCTFail() })
        var returnedPlans: [[PlanPresentation]]?
        var returnedFooterType: FooterType?
        
        // WHEN: we compute plans presentation
        out.fetchPlans(backendFetch: true) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, footerType)):
                returnedPlans = plans
                returnedFooterType = footerType
                expectation1.fulfill()
            }
        }
        
        // THEN: we should show Plus and Basic plans to buy
        XCTAssertEqual(returnedPlans?.count, 1)
        XCTAssertEqual(returnedPlans?.flatMap { $0 }.count, 2)
        let planPresentation = returnedPlans?.first
        switch planPresentation?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
            XCTAssertEqual(details.isSelectable, true)
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentation?.first?.isCurrentlyProcessed, false)
        switch planPresentation?.last?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
            XCTAssertEqual(details.isSelectable, true)
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentation?.last?.isCurrentlyProcessed, false)
        if case .withPlansToBuy = returnedFooterType { } else { XCTFail() }
        
        // THEN: we start to process Plus plan
        out.unfinishedPurchasePlan = InAppPurchasePlan(protonName: "vpnplus", listOfIAPIdentifiers: ["ios_vpnplus_12_usd_non_renewing"])
        
        // THEN: we should show plans to buy with Plus plan currently processing and Basic plan not selectable
        switch planPresentation?.first?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Plus")
            XCTAssertEqual(details.isSelectable, true)
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentation?.first?.isCurrentlyProcessed, true)
        switch planPresentation?.last?.planPresentationType {
        case .plan(let details):
            XCTAssertEqual(details.name, "Basic")
            XCTAssertEqual(details.isSelectable, false)
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentation?.last?.isCurrentlyProcessed, false)
        waitForExpectations(timeout: timeout)
    }
    
    func testCurrentPlan_UnfinishedPurchasePlan_ExtendSubscription() {
        // GIVEN: user has plus subscription
        let expectation1 = self.expectation(description: "planRefreshHandler")
        let expectation2 = self.expectation(description: "extendSubscriptionHandler")
        let expectation3 = self.expectation(description: "planRefreshHandler")
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan])
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        
        // WHEN: we compute price presentation
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .vpn, planRefreshHandler: { currentPlanDetails in
            XCTAssertNil(currentPlanDetails)
            expectation3.fulfill()
        }, extendSubscriptionHandler: {
            expectation2.fulfill()
        })
        var planPresentations: [[PlanPresentation]] = []
        out.fetchPlans(backendFetch: false) { result in
            switch result {
            case .failure: XCTFail()
            case let .success((plans, _)):
                planPresentations = plans
                expectation1.fulfill()
            }
        }

        // THEN: we should show the price from user's subscription
        XCTAssertEqual(planPresentations.count, 1)
        XCTAssertEqual(planPresentations.first!.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        XCTAssertEqual(planPresentations.first?.first?.isCurrentlyProcessed, false)
        
        // THEN: we start to process Plus plan
        out.unfinishedPurchasePlan = InAppPurchasePlan(protonName: "vpnplus", listOfIAPIdentifiers: ["ios_vpnplus_12_usd_non_renewing"])
        waitForExpectations(timeout: timeout)
    }
    
    /* Extend subscription tests */
    
    func testCurrentPlan_CurrentMode_FetchCurrentPlans_ExtendSubscription() async {
        // GIVEN: user has has current subscription
        storeKitManager.canExtendSubscriptionStub.fixture = true
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan])
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        
        // WHEN: we compute plan presentation
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show current plan with ExtendSubscription button
        XCTAssertEqual(planPresentations.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withExtendSubscriptionButton(let plan) = out.footerType {
            XCTAssertEqual(planPresentations.first?.first?.storeKitProductId, plan.storeKitProductId)
        } else {
            XCTFail()
        }
    }
    
    func testCurrentPlan_UpdateMode_FetchCurrentPlans_ExtendSubscription() async {
        // GIVEN: user has has no subscription
        storeKitManager.canExtendSubscriptionStub.fixture = true
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan])
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        servicePlan.availablePlansDetailsStub.fixture = [PresentedPriceTestingHelper.plusPlan, PresentedPriceTestingHelper.basicPlan]
        let out = PaymentsUIViewModel(mode: .update, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        
        // WHEN: we compute plan presentation
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        XCTAssertEqual(planPresentations.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withExtendSubscriptionButton(let plan) = out.footerType {
            XCTAssertEqual(planPresentations.first?.first?.storeKitProductId, plan.storeKitProductId)
        } else {
            XCTFail()
        }
    }
    
    func testCurrentPlan_FetchCurrentPlans_No_Available_Plans() async {
        // GIVEN: user has has current subscription
        storeKitManager.canExtendSubscriptionStub.fixture = true
        servicePlan.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [PresentedPriceTestingHelper.plusPlan])
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = [PresentedPriceTestingHelper.basicIAP, PresentedPriceTestingHelper.plusIAP]
        let out = PaymentsUIViewModel(mode: .current, storeKitManager: storeKitManager, servicePlan: servicePlan, shownPlanNames: ["vpnplus", "vpnbasic", "free"], clientApp: .mail, planRefreshHandler: { _ in XCTFail() }, extendSubscriptionHandler: { XCTFail() })
        
        // WHEN: we compute plan presentation
        let planPresentations: [[PlanPresentation]] = await withCheckedContinuation { continuation in
            out.fetchPlans(backendFetch: false) { result in
                switch result {
                case .failure: XCTFail()
                case let .success((plans, _)):
                    continuation.resume(returning: plans)
                }
            }
        }
        
        // THEN: we should show current plan with ExtendSubscription button
        XCTAssertEqual(planPresentations.count, 1)
        switch planPresentations.first?.first?.planPresentationType {
        case .current(let currentPlanPresentationType):
            switch currentPlanPresentationType {
            case .details(let details):
                XCTAssertEqual(details.name, "Plus")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
        if case .withoutPlansToBuy = out.footerType { } else { XCTFail() }
    }

}
