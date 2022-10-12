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
import ProtonCore_CoreTranslation_V5
import ProtonCore_DataModel
import ProtonCore_Services
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import SnapshotTesting
@testable import ProtonCore_Payments
@testable import ProtonCore_PaymentsUI

@available(iOS 13, *)
extension UITraitCollection {
    func updated(to style: UIUserInterfaceStyle) -> UITraitCollection {
        UITraitCollection(traitsFrom: [self, UITraitCollection.init(userInterfaceStyle: style)])
    }
}

@available(iOS 13, *)
final class PaymentsUISnapshotTests: XCTestCase {
    
    let subscriptionStartDate = Date(timeIntervalSince1970: 64776719700)
    let existingPaymentsMethods = [PaymentMethod(type: "test method")]
    
    let reRecordEverything = false
    
    var storeKitManager: StoreKitManagerMock!
    var servicePlan: ServicePlanDataServiceMock!
    
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
            
            case free
            
            // these plans are unavailable for purchase on iOS, but users can have them if they subscribed through web
            
            case mailpro2022
            case bundlepro2022
            case enterprise2022
            case visionary2022
            
            static var allPlans: [Plan] { allCases.map(\.plan) }
            
            static var mailPaidPlans: [Plan] { [Plans.mail2022, .bundle2022].map(\.plan) }
            static var vpnPaidPlans: [Plan] { [Plans.vpn2022, .bundle2022].map(\.plan) }
            static var drivePaidPlans: [Plan] { [Plans.drive2022, .bundle2022].map(\.plan) }
            static var calendarPaidPlans: [Plan] { [Plans.mail2022, .bundle2022].map(\.plan) }
            
            var plan: Plan {
                switch self {
                case .free:
                    return Plan.empty.updated(
                        name: "free",
                        maxAddresses: 1,
                        maxMembers: 1,
                        maxDomains: 0,
                        maxSpace: 524288000,
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
                        title: "Drive Plus",
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
                        title: "Visionary",
                        maxVPN: 60,
                        maxTier: 2,
                        features: 1,
                        maxCalendars: 120,
                        state: 1,
                        cycle: 12
                    )
                }
            }
        }
    }
    
    // swiftlint:disable function_parameter_count
    @MainActor
    private func snapshotSubscriptionScreen(mode: PaymentsUIMode,
                                            currentSubscriptionPlan: Plan?,
                                            paymentMethods: [PaymentMethod],
                                            name: String,
                                            clientApp: ClientApp,
                                            record: Bool) async {
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
        case .other:
            fatalError("misconfiguration")
        }
        
        servicePlan.paymentMethodsStub.fixture = paymentMethods
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = iapIdentifiers
        storeKitManager.priceLabelForProductStub.bodyIs { _, iapIdentifier in
            guard let iap = InAppPurchasePlan(storeKitProductId: iapIdentifier),
                  let plan = MockData.Plans.allPlans.first(where: { $0.name == iap.protonName }),
                  let price = plan.pricing(for: iap.period) else { return nil }
            return (NSDecimalNumber(value: Double(price) / 100.0), Locale.autoupdatingCurrent)
        }
        servicePlan.defaultPlanDetailsStub.fixture = MockData.Plans.free.plan
        servicePlan.availablePlansDetailsStub.fixture = paidPlans
        servicePlan.plansStub.fixture = (currentSubscriptionPlan.map { [$0] } ?? []) + paidPlans + [MockData.Plans.free.plan]
        servicePlan.detailsOfServicePlanStub.bodyIs { _, name in MockData.Plans.allPlans.first { $0.name == name } }
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
                                        planRefreshHandler: { _ in XCTFail() },
                                        extendSubscriptionHandler: { XCTFail() })
        
        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI-V5",
                                                                controllerType: PaymentsUIViewController.self)
        paymentsUIViewController.model = model
        _ = await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            model.fetchPlans(backendFetch: false) { _ in
                model.plans.flatMap { $0 }.forEach { $0.isExpanded = true }
                paymentsUIViewController.reloadData()
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
        
        assertSnapshot(matching: paymentsUIViewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .light)), size: imageSize),
                       record: reRecordEverything || record,
                       testName: "\(name)-Light")
        
        assertSnapshot(matching: paymentsUIViewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .dark)), size: imageSize),
                       record: reRecordEverything || record,
                       testName: "\(name)-Dark")
    }
    
    // MARK: - Test current subscription screen
    
    private func snapshotCurrentSubscriptionScreen(currentSubscriptionPlan: Plan?,
                                                   paymentMethods: [PaymentMethod],
                                                   name: String = #function,
                                                   clientApp: ClientApp,
                                                   record: Bool = false) async {
        await snapshotSubscriptionScreen(mode: .current,
                                         currentSubscriptionPlan: currentSubscriptionPlan,
                                         paymentMethods: paymentMethods,
                                         name: name,
                                         clientApp: clientApp,
                                         record: record)
    }
    
    func testCurrentSubscription_Free() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
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
    
    // bundle2022
    
    func testCurrentSubscription_Bundle2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Bundle2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testCurrentSubscription_Bundle2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
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
    
    // MARK: - Test upgrade subscription screen
    
    private func snapshotUpdateSubscriptionScreen(currentSubscriptionPlan: Plan?,
                                                  paymentMethods: [PaymentMethod],
                                                  name: String = #function,
                                                  clientApp: ClientApp,
                                                  record: Bool = false) async {
        await snapshotSubscriptionScreen(mode: .update,
                                         currentSubscriptionPlan: currentSubscriptionPlan,
                                         paymentMethods: paymentMethods,
                                         name: name,
                                         clientApp: clientApp,
                                         record: record)
    }
    
    func testUpdateSubscription_Free() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .mail
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
    
    func testUpdateSubscription_Bundle2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Bundle2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }
    
    func testUpdateSubscription_Bundle2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
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
    
    // MARK: - Test signup subscription screen
    
    private func snapshotSignupSubscriptionScreen(name: String = #function,
                                                  clientApp: ClientApp,
                                                  record: Bool = false) async {
        await snapshotSubscriptionScreen(mode: .signup,
                                         currentSubscriptionPlan: nil,
                                         paymentMethods: .empty,
                                         name: name,
                                         clientApp: clientApp,
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
}
