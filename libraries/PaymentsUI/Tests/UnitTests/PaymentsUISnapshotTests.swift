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

#if os(iOS)

import UIKit
import XCTest
import ProtonCoreDataModel
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants
import SnapshotTesting
import ProtonCoreUIFoundations
@testable import ProtonCorePayments
@testable import ProtonCorePaymentsUI

@available(iOS 13, *)
extension UITraitCollection {
    func updated(to style: UIUserInterfaceStyle) -> UITraitCollection {
        UITraitCollection(traitsFrom: [self, UITraitCollection.init(userInterfaceStyle: style)])
    }
}

@available(iOS 13, *)
final class PaymentsUISnapshotTests: XCTestCase {
    
    let subscriptionStartDate = Date(timeIntervalSince1970: 4818489600)
    let existingPaymentsMethods = [PaymentMethod(type: "test method")]
    
    let reRecordEverything = false
    
    var storeKitManager: StoreKitManagerMock!
    var servicePlan: ServicePlanDataServiceMock!

    let perceptualPrecision: Float = 0.98
    
    override func setUp() {
        super.setUp()
        storeKitManager = StoreKitManagerMock()
        servicePlan = ServicePlanDataServiceMock()
    }
    
    override func tearDown() {
        servicePlan = nil
        storeKitManager = nil
        super.tearDown()
    }
    
    enum MockData {
        
        enum Plans: CaseIterable, Equatable {
            
            case mail2022
            case vpn2022
            case drive2022
            case bundle2022
            case pass2023
            
            case free
            
            // these plans are unavailable for purchase on iOS, but users can have them if they subscribed through web
            
            case mailpro2022
            case bundlepro2022
            case enterprise2022
            case visionary2022

            // this is a unknown test plan that we use only for verifying our code works even if some new plan is introduced on the backend

            case unknownTestPlan
            case imaginaryOffer
            
            static var allPlans: [Plan] { allCases.map(\.plan) }
            
            static var mailPaidPlans: [Plan] { [Plans.bundle2022, .mail2022].map(\.plan) }
            static var mailPaidPlanAndImaginaryOffer: [Plan] { [Plans.imaginaryOffer, .mail2022].map(\.plan) }
            static var vpnPaidPlans: [Plan] { [Plans.bundle2022, .vpn2022].map(\.plan) }
            static var drivePaidPlans: [Plan] { [Plans.bundle2022, .drive2022].map(\.plan) }
            static var calendarPaidPlans: [Plan] { [Plans.bundle2022, .mail2022].map(\.plan) }
            static var passPaidPlans: [Plan] { [Plans.bundle2022, .pass2023].map(\.plan) }
            
            var plan: Plan {
                switch self {
                case .free:
                    return Plan.empty.updated(
                        name: "free",
                        maxAddresses: 1,
                        maxMembers: 1,
                        maxDomains: 0,
                        maxSpace: 524288000,
                        type: 0,
                        title: "Proton Free",
                        maxVPN: 1,
                        maxTier: 0,
                        features: 0,
                        maxCalendars: 1,
                        state: 1
                    )
                    
                case .mail2022:
                    return Plan.empty.updated(
                        name: "mail2022",
                        maxAddresses: 10,
                        maxMembers: 1,
                        pricing: ["1": 499, "12": 4788, "24": 8376],
                        maxDomains: 1,
                        maxSpace: 16106127360,
                        type: 1,
                        title: "Mail Plus",
                        maxVPN: 0,
                        maxTier: 0,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                    
                case .vpn2022:
                    return Plan.empty.updated(
                        name: "vpn2022",
                        maxAddresses: 0,
                        maxMembers: 0,
                        pricing: ["1": 999, "12": 7188, "15": 14985, "24": 11976, "30": 29970],
                        maxDomains: 0,
                        maxSpace: 0,
                        type: 1,
                        title: "VPN Plus",
                        maxVPN: 10,
                        maxTier: 2,
                        features: 0,
                        maxCalendars: 0,
                        state: 1,
                        cycle: 12
                    )
                    
                case .drive2022:
                    return Plan.empty.updated(
                        name: "drive2022",
                        maxAddresses: 0,
                        maxMembers: 0,
                        pricing: ["1": 499, "12": 4788, "24": 8376],
                        maxDomains: 0,
                        maxSpace: 214748364800,
                        type: 1,
                        title: "Drive Plus",
                        maxVPN: 0,
                        maxTier: 0,
                        features: 0,
                        maxCalendars: 0,
                        state: 1,
                        cycle: 12
                    )

                case .pass2023:
                    return Plan.empty.updated(
                        name: "pass2023",
                        maxAddresses: 0,
                        maxMembers: 0,
                        pricing: ["1": 499, "12": 4788, "24": 8376],
                        maxDomains: 0,
                        maxSpace: 214748364800,
                        type: 1,
                        title: "Pass Plus",
                        maxVPN: 0,
                        maxTier: 0,
                        features: 0,
                        maxCalendars: 0,
                        state: 1,
                        cycle: 12
                    )
                    
                case .bundle2022:
                    return Plan.empty.updated(
                        name: "bundle2022",
                        maxAddresses: 15,
                        maxMembers: 1,
                        pricing: ["1": 1199, "12": 11988, "24": 19176],
                        maxDomains: 3,
                        maxSpace: 536870912000,
                        type: 1,
                        title: "Proton Unlimited",
                        maxVPN: 10,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                    
                case .mailpro2022:
                    return Plan.empty.updated(
                        name: "mailpro2022",
                        maxAddresses: 10,
                        maxMembers: 1,
                        pricing: ["1": 799, "12": 8388, "24": 15576],
                        maxDomains: 3,
                        maxSpace: 16106127360,
                        type: 1,
                        title: "Mail Essentials",
                        maxVPN: 0,
                        maxTier: 0,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                    
                case .bundlepro2022:
                    return Plan.empty.updated(
                        name: "bundlepro2022",
                        maxAddresses: 15,
                        maxMembers: 1,
                        pricing: ["1": 1299, "12": 13188, "24": 23976],
                        maxDomains: 10,
                        maxSpace: 536870912000,
                        type: 1,
                        title: "Business",
                        maxVPN: 10,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                    
                case .enterprise2022:
                    return Plan.empty.updated(
                        name: "enterprise2022",
                        maxAddresses: 15,
                        maxMembers: 1,
                        pricing: ["1": 1599, "12": 16788, "24": 31176],
                        maxDomains: 10,
                        maxSpace: 1099511627776,
                        type: 1,
                        title: "Enterprise",
                        maxVPN: 10,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                    
                case .visionary2022:
                    return Plan.empty.updated(
                        name: "visionary2022",
                        maxAddresses: 100,
                        maxMembers: 6,
                        pricing: ["1": 2999, "12": 28788, "24": 47976],
                        maxDomains: 10,
                        maxSpace: 3298534883328,
                        type: 1,
                        title: "Visionary",
                        maxVPN: 60,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 120,
                        state: 1,
                        cycle: 12
                    )
                case .unknownTestPlan:
                    return Plan.empty.updated(
                        name: "unknown_plan_for_tests",
                        maxAddresses: 2,
                        maxMembers: 1,
                        pricing: ["1": 99999, "12": 999999, "15": 9999999, "24": 99999999, "30": 999999999],
                        maxDomains: 1,
                        maxSpace: 1024,
                        type: 1,
                        title: "Unknown Plan for Tests",
                        maxVPN: 2,
                        maxTier: 1,
                        features: 1,
                        maxCalendars: 2,
                        state: 1,
                        cycle: 12
                    )
                case .imaginaryOffer:
                    return Plan.empty.updated(
                        name: "bundle2022",
                        maxAddresses: 15,
                        maxMembers: 1,
                        pricing: ["1": 1199 / 2, "12": 11988 / 2, "24": 19176 / 2],
                        defaultPricing: ["1": 1199, "12": 11988, "24": 19176],
                        vendors: Plan.Vendors(apple: Plan.Vendor(plans: ["12": "iosimaginary_bundle2022_offer_12_usd_non_renewing"])),
                        maxDomains: 3,
                        maxSpace: 536870912000,
                        type: 1,
                        title: "Proton Unlimited",
                        maxVPN: 10,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 20,
                        state: 1,
                        cycle: 12
                    )
                }
            }
        }

        static var customPlansDescription: CustomPlansDescription = [
            "free": (
                purchasable: PurchasablePlanDescription(
                    name: "Free purchasable custom name", description: "Free purchasable custom description", details: [
                        (IconProvider.arrowUp, "Free purchasable custom arrow up"),
                        (IconProvider.arrowDown, "Free purchasable custom arrow down"),
                        (IconProvider.arrowLeft, "Free purchasable custom arrow left"),
                        (IconProvider.arrowRight, "Free purchasable custom arrow right")
                    ], isPreferred: false
                ),
                current: CurrentPlanDescription(
                    name: "Free current custom name", shouldShowUsedSpace: true, details: [
                        (IconProvider.arrowUp, "Free current custom arrow up"),
                        (IconProvider.arrowDown, "Free current custom arrow down"),
                        (IconProvider.arrowLeft, "Free current custom arrow left"),
                        (IconProvider.arrowRight, "Free current custom arrow right")
                    ]
                )
            ),
            "pass2023": (
                purchasable: PurchasablePlanDescription(
                    name: "Pass Plus purchasable custom name", description: "Pass Plus purchasable custom descriptipn", details: [
                        (IconProvider.arrowUp, "Pass Plus purchasable custom arrow up"),
                        (IconProvider.arrowDown, "Pass Plus purchasable custom arrow down"),
                        (IconProvider.arrowLeft, "Pass Plus purchasable custom arrow left"),
                        (IconProvider.arrowRight, "Pass Plus purchasable custom arrow right")
                    ], isPreferred: true
                ),
                current: CurrentPlanDescription(
                    name: "Pass Plus current custom name", shouldShowUsedSpace: false, details: [
                        (IconProvider.arrowUp, "Pass Plus current custom arrow up"),
                        (IconProvider.arrowDown, "Pass Plus current custom arrow down"),
                        (IconProvider.arrowLeft, "Pass Plus current custom arrow left"),
                        (IconProvider.arrowRight, "Pass Plus current custom arrow right")
                    ]
                )
            ),
            "bundle2022": (
                purchasable: PurchasablePlanDescription(
                    name: "Proton Unlimited purchasable custom name", description: "Proton Unlimited purchasable custom descriptipn", details: [
                        (IconProvider.arrowUp, "Proton Unlimited purchasable custom arrow up"),
                        (IconProvider.arrowDown, "Proton Unlimited purchasable custom arrow down"),
                        (IconProvider.arrowLeft, "Proton Unlimited purchasable custom arrow left"),
                        (IconProvider.arrowRight, "Proton Unlimited purchasable custom arrow right")
                    ], isPreferred: true
                ),
                current: CurrentPlanDescription(
                    name: "Proton Unlimited current custom name", shouldShowUsedSpace: false, details: [
                        (IconProvider.arrowUp, "Proton Unlimited current custom arrow up"),
                        (IconProvider.arrowDown, "Proton Unlimited current custom arrow down"),
                        (IconProvider.arrowLeft, "Proton Unlimited current custom arrow left"),
                        (IconProvider.arrowRight, "Proton Unlimited current custom arrow right")
                    ]
                )
            )
        ]
    }
    
    // swiftlint:disable function_parameter_count
    @MainActor
    private func snapshotSubscriptionScreen(mode: PaymentsUIMode,
                                            currentSubscriptionPlan: Plan?,
                                            paymentMethods: [PaymentMethod],
                                            name: String,
                                            clientApp: ClientApp,
                                            customPlansDescription: CustomPlansDescription = [:],
                                            modalPresentation: Bool = false,
                                            record: Bool,
                                            file: StaticString = #filePath,
                                            line: UInt = #line) async {
        let shownPlanNames: Set<String>
        let iapIdentifiers: Set<String>
        let paidPlans: [Plan]
        switch clientApp {
        case .mail:
            shownPlanNames = ObfuscatedConstants.mailShownPlanNames
            iapIdentifiers = ObfuscatedConstants.mailIAPIdentifiers
            paidPlans = MockData.Plans.mailPaidPlans
        case .vpn:
            shownPlanNames = ObfuscatedConstants.vpnShownPlanNames
            iapIdentifiers = ObfuscatedConstants.vpnIAPIdentifiers
            paidPlans = MockData.Plans.vpnPaidPlans
        case .drive:
            shownPlanNames = ObfuscatedConstants.driveShownPlanNames
            iapIdentifiers = ObfuscatedConstants.driveIAPIdentifiers
            paidPlans = MockData.Plans.drivePaidPlans
        case .calendar:
            shownPlanNames = ObfuscatedConstants.calendarShownPlanNames
            iapIdentifiers = ObfuscatedConstants.calendarIAPIdentifiers
            paidPlans = MockData.Plans.calendarPaidPlans
        case .pass:
            shownPlanNames = ObfuscatedConstants.passShownPlanNames
            iapIdentifiers = ObfuscatedConstants.passIAPIdentifiers
            paidPlans = MockData.Plans.passPaidPlans
        case .other("imaginaryOffer"):
            shownPlanNames = ObfuscatedConstants.mailShownPlanNames
            var identifiers = ObfuscatedConstants.mailIAPIdentifiers
            identifiers.insert("iosimaginary_bundle2022_offer_12_usd_non_renewing")
            iapIdentifiers = identifiers
            paidPlans = MockData.Plans.mailPaidPlanAndImaginaryOffer
        case .other:
            fatalError("misconfiguration")
        }
        
        servicePlan.paymentMethodsStub.fixture = paymentMethods
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = iapIdentifiers
        storeKitManager.priceLabelForProductStub.bodyIs { _, iapIdentifier in
            if iapIdentifier == MockData.Plans.imaginaryOffer.plan.vendors?.apple.plans.values.first {
                guard let price = MockData.Plans.imaginaryOffer.plan.pricing(for: InAppPurchasePlan.defaultCycle) else { return nil }
                return (NSDecimalNumber(value: Double(price) / 100.0), Locale.autoupdatingCurrent)
            }
            guard let iap = InAppPurchasePlan(storeKitProductId: iapIdentifier),
                  let plan = MockData.Plans.allPlans.first(where: { $0.name == iap.protonName }),
                  let price = plan.pricing(for: iap.period) else { return nil }
            return (NSDecimalNumber(value: Double(price) / 100.0), Locale.autoupdatingCurrent)
        }
        servicePlan.defaultPlanDetailsStub.fixture = MockData.Plans.free.plan
        servicePlan.availablePlansDetailsStub.fixture = paidPlans
        servicePlan.plansStub.fixture = (currentSubscriptionPlan.map { [$0] } ?? []) + paidPlans + [MockData.Plans.free.plan]
        servicePlan.detailsOfPlanCorrespondingToIAPStub.bodyIs { _, iap in MockData.Plans.allPlans.first { $0.name == iap.protonName } }
        servicePlan.currentSubscriptionStub.fixture = currentSubscriptionPlan.map {
            Subscription.dummy.updated(
                start: subscriptionStartDate,
                end: $0.cycle.flatMap {
                    Calendar.autoupdatingCurrent.date(byAdding: .month, value: $0, to: subscriptionStartDate)
                },
                planDetails: [$0],
                cycle: $0.cycle,
                amount: $0.cycle.map(String.init).flatMap($0.pricing(for:)),
                currency: Locale.autoupdatingCurrent.currencyCode
            )
        }
        servicePlan.currentSubscriptionStub.fixture?.organization = currentSubscriptionPlan.map {
            Organization.dummy.updated(
                maxDomains: $0.maxDomains, maxAddresses: $0.maxAddresses, maxSpace: $0.maxSpace,
                maxMembers: $0.maxMembers, maxVPN: $0.maxVPN, maxCalendars: $0.maxCalendars,
                usedDomains: 1, usedAddresses: 1, usedSpace: 1, usedMembers: 1, usedCalendars: 1
            )
        }
        let maxSpace = Double(max(currentSubscriptionPlan?.maxSpace ?? 0, MockData.Plans.free.plan.maxSpace))
        servicePlan.userStub.fixture = User.dummy.updated(usedSpace: maxSpace * 0.6, maxSpace: maxSpace)
        storeKitManager.canExtendSubscriptionStub.fixture = true
        
        let model = PaymentsUIViewModel(mode: mode,
                                        storeKitManager: storeKitManager,
                                        servicePlan: servicePlan,
                                        shownPlanNames: shownPlanNames,
                                        clientApp: clientApp,
                                        customPlansDescription: customPlansDescription,
                                        planRefreshHandler: { _ in XCTFail() },
                                        extendSubscriptionHandler: { XCTFail() })
        
        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.model = model
        _ = await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            model.fetchPlans(backendFetch: false) { _ in
                model.plans.flatMap { $0 }.forEach { $0.isExpanded = true }
                continuation.resume()
            }
        }
        
        let imageSize: CGSize
        switch mode {
        case .signup,
            _ where currentSubscriptionPlan == nil:
            imageSize = CGSize(width: 320, height: 1500)
        case .update, .current:
            imageSize = CGSize(width: 320, height: 750)
        }
        
        let traits: UITraitCollection = .iPhoneSe(.portrait)
        
        paymentsUIViewController.modalPresentation = modalPresentation
        let viewController: UIViewController
        if paymentsUIViewController.modalPresentation {
            viewController = LoginNavigationViewController(rootViewController: paymentsUIViewController)
        } else {
            viewController = paymentsUIViewController
        }
        
        assertSnapshot(matching: viewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .light)),
                                  perceptualPrecision: perceptualPrecision,
                                  size: imageSize),
                       record: reRecordEverything || record,
                       file: file,
                       testName: "\(name)-Light",
                       line: line)
        
        assertSnapshot(matching: viewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .dark)),
                                  perceptualPrecision: perceptualPrecision,
                                  size: imageSize),
                       record: reRecordEverything || record,
                       file: file,
                       testName: "\(name)-Dark",
                       line: line)
    }
    
    // MARK: - Test current subscription screen
    
    private func snapshotCurrentSubscriptionScreen(currentSubscriptionPlan: Plan?,
                                                   paymentMethods: [PaymentMethod],
                                                   name: String = #function,
                                                   clientApp: ClientApp,
                                                   customPlansDescription: CustomPlansDescription = [:],
                                                   modalPresentation: Bool = false,
                                                   record: Bool = false,
                                                   file: StaticString = #filePath,
                                                   line: UInt = #line) async {
        await snapshotSubscriptionScreen(mode: .current,
                                         currentSubscriptionPlan: currentSubscriptionPlan,
                                         paymentMethods: paymentMethods,
                                         name: name,
                                         clientApp: clientApp,
                                         customPlansDescription: customPlansDescription,
                                         modalPresentation: modalPresentation,
                                         record: record,
                                         file: file,
                                         line: line)
    }

    // free
    
    func testCurrentSubscription_Free_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_Free_InVPN() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentSubscription_Free_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }
    
    func testCurrentSubscription_Free_ImaginaryOffer() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .other(named: "imaginaryOffer")
        )
    }
    
    // mail2022
    
    func testCurrentSubscription_Mail2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Mail2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Mail2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // vpn2022
    
    func testCurrentSubscription_VPN2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testCurrentSubscription_VPN2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }
    
    func testCurrentSubscription_VPN2022_15() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testCurrentSubscription_VPN2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testCurrentSubscription_VPN2022_30() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    // bundle2022 in mail
    
    func testCurrentSubscription_Bundle2022_1_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Bundle2022_12_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Bundle2022_24_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    // bundle2022 in pass

    func testCurrentSubscription_Bundle2022_1_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentSubscription_Bundle2022_12_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testCurrentSubscription_Bundle2022_24_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }
    
    // drive2022
    
    func testCurrentSubscription_Drive2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }
    
    func testCurrentSubscription_Drive2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .drive
        )
    }
    
    func testCurrentSubscription_Drive2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }

    // pass2023

    func testCurrentSubscription_Pass2023_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentSubscription_Pass2023_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentSubscription_Pass2023_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }
    
    // mailpro2022
    
    func testCurrentSubscription_MailPro2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_MailPro2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_MailPro2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // bundlepro2022
    
    func testCurrentSubscription_BundlePro2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_BundlePro2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_BundlePro2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // enterprise2022
    
    func testCurrentSubscription_Enterprise2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Enterprise2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Enterprise2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Free_ModalPresentation() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail,
            modalPresentation: true
        )
    }
    
    // visionary2022
    
    func testCurrentSubscription_Visionary2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Visionary2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Visionary2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    // unknownTestPlan

    func testCurrentSubscription_Unknown_Plan_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_Unknown_Plan_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_Unknown_Plan_15() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_Unknown_Plan_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_Unknown_Plan_30() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentSubscription_CustomPresentation() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass,
            customPlansDescription: MockData.customPlansDescription
        )
    }
    
    // MARK: - Test upgrade subscription screen
    
    private func snapshotUpdateSubscriptionScreen(currentSubscriptionPlan: Plan?,
                                                  paymentMethods: [PaymentMethod],
                                                  name: String = #function,
                                                  clientApp: ClientApp,
                                                  customPlansDescription: CustomPlansDescription = [:],
                                                  modalPresentation: Bool = false,
                                                  record: Bool = false) async {
        await snapshotSubscriptionScreen(mode: .update,
                                         currentSubscriptionPlan: currentSubscriptionPlan,
                                         paymentMethods: paymentMethods,
                                         name: name,
                                         clientApp: clientApp,
                                         customPlansDescription: customPlansDescription,
                                         modalPresentation: modalPresentation,
                                         record: record)
    }

    // free
    
    func testUpdateSubscription_Free_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Free_InVPN() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }

    func testUpdateSubscription_Free_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .pass
        )
    }
    
    func testUpdateSubscription_Free_ImaginaryOffer() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .other(named: "imaginaryOffer")
        )
    }
    
    // mail2022
    
    func testUpdateSubscription_Mail_2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Mail2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Mail2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // vpn2022
    
    func testUpdateSubscription_VPN2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testUpdateSubscription_VPN2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }
    
    func testUpdateSubscription_VPN2022_15() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testUpdateSubscription_VPN2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    func testUpdateSubscription_VPN2022_30() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }
    
    // bundle2022
    
    func testUpdateSubscription_Bundle2022_1_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Bundle2022_12_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Bundle2022_24_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Bundle2022_1_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateSubscription_Bundle2022_12_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testUpdateSubscription_Bundle2022_24_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    // pass2023

    func testUpdateSubscription_Pass2023_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateSubscription_Pass2023_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testUpdateSubscription_Pass2023_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }
    
    // drive2022
    
    func testUpdateSubscription_Drive2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }
    
    func testUpdateSubscription_Drive2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .drive
        )
    }
    
    func testUpdateSubscription_Drive2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }
    
    // mailpro2022
    
    func testUpdateSubscription_MailPro2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_MailPro2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_MailPro2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // bundlepro2022
    
    func testUpdateSubscription_BundlePro2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_BundlePro2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_BundlePro2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // enterprise2022
    
    func testUpdateSubscription_Enterprise2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Enterprise2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Enterprise2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    // visionary2022
    
    func testUpdateSubscription_Visionary2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Visionary2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Visionary2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    // unknownTestPlan

    func testUpdateSubscription_Unknown_Plan_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Unknown_Plan_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Unknown_Plan_15() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Unknown_Plan_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateSubscription_Unknown_Plan_30() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.unknownTestPlan.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Free_ModalPresentation() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .mail,
            modalPresentation: true
        )
    }

    func testUpdateSubscription_Free_CustomDescription() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .pass,
            customPlansDescription: MockData.customPlansDescription,
            modalPresentation: true
        )
    }
    
    // MARK: - Test signup subscription screen
    
    private func snapshotSignupSubscriptionScreen(name: String = #function,
                                                  clientApp: ClientApp,
                                                  customPlansDescription: CustomPlansDescription = [:],
                                                  record: Bool = false) async {
        await snapshotSubscriptionScreen(mode: .signup,
                                         currentSubscriptionPlan: nil,
                                         paymentMethods: .empty,
                                         name: name,
                                         clientApp: clientApp,
                                         customPlansDescription: customPlansDescription,
                                         record: record)
    }
    
    func testSignupSubscription_Mail() async {
        await snapshotSignupSubscriptionScreen(clientApp: .mail)
    }
    
    func testSignupSubscription_VPN() async {
        await snapshotSignupSubscriptionScreen(clientApp: .vpn)
    }
    
    func testSignupSubscription_Drive() async {
        await snapshotSignupSubscriptionScreen(clientApp: .drive)
    }
    
    func testSignupSubscription_Calendar() async {
        await snapshotSignupSubscriptionScreen(clientApp: .calendar)
    }

    func testSignupSubscription_Pass() async {
        await snapshotSignupSubscriptionScreen(clientApp: .pass)
    }
    
    func testSignupSubscription_Free_ImaginaryOffer() async {
        await snapshotSignupSubscriptionScreen(
            clientApp: .other(named: "imaginaryOffer")
        )
    }

    func testSignupSubscription_CustomDescription() async {
        await snapshotSignupSubscriptionScreen(clientApp: .pass, customPlansDescription: MockData.customPlansDescription)
    }
}

#endif
