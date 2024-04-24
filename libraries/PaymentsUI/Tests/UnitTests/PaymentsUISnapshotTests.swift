//
//  PaymentsUISnapshotTests.swift
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
import ProtonCoreFeatureFlags
import ProtonCoreServices
import ProtonCoreUtilities
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsPayments
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
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
    var plansDataSource: PlansDataSourceMock!

    let perceptualPrecision: Float = 0.98
    var featureFlagsRepository: FeatureFlagsRepositoryProtocol!

    override func setUp() {
        super.setUp()
        storeKitManager = StoreKitManagerMock()
        servicePlan = ServicePlanDataServiceMock()
        plansDataSource = PlansDataSourceMock()
        featureFlagsRepository = FeatureFlagsRepository.shared
    }

    override func tearDown() {
        servicePlan = nil
        storeKitManager = nil
        plansDataSource = nil
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
            case arbitraryOffer

            static var allPlans: [Plan] { allCases.map(\.plan) }

            static var mailPaidPlans: [Plan] { [Plans.bundle2022, .mail2022].map(\.plan) }
            static var mailPaidPlanAndArbitraryOffer: [Plan] { [Plans.arbitraryOffer, .mail2022].map(\.plan) }
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
                case .arbitraryOffer:
                    return Plan.empty.updated(
                        name: "bundle2022",
                        maxAddresses: 15,
                        maxMembers: 1,
                        pricing: ["1": 1199 / 2, "12": 11988 / 2, "24": 19176 / 2],
                        defaultPricing: ["1": 1199, "12": 11988, "24": 19176],
                        vendors: Plan.Vendors(apple: Plan.Vendor(plans: ["12": "iosarbitrary_bundle2022_offer_12_usd_non_renewing"])),
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

        static let availablePlansList = [AvailablePlans.AvailablePlan(ID: "app_bundle2022_12_usd_auto_renewing",
                                                                      type: 0,
                                                                      name: "Bundle2022", title: "Bundle Title", instances: [.init(cycle: 12, description: "description", periodEnd: 12, price: [.init(ID: "price", current: 1299, currency: "CHF")])], entitlements:
                                                                        [.description(.init(type: "description", iconName: "tick", text: "text", hint: "hint"))],
                                                                      decorations: [.starred(.init(type: "starred", iconName: "tick"))]
                                                                     )
        ]

        static let availablePlans: AvailablePlans = .init(plans: MockData.availablePlansList, defaultCycle: 12) // dynamic plan
        static let currentPlan: CurrentPlan = .init(subscriptions: [.init(title: "Current Subscription", // dynamic plan
                                                                          name: "planName",
                                                                          description: "Description",
                                                                          periodEnd: 1965360000,
                                                                          entitlements: [
                                                                            .description(.init(type: "description",
                                                                                               text: "text",
                                                                                               iconName: "tick",
                                                                                               hint: "hint")),

                                                                          ]
                                                                         )
        ])
        enum DynamicPlans {

            static let mailFree: CurrentPlan = .init(subscriptions: [
                .init(title: "Mail Free",
                      name: nil,
                      description: "Free encrypted email and calendar for everyone",
                      periodEnd: 1965360000,
                      entitlements: [.progress(.init(type: "progress",
                                                     text: "402 MB of 1 GB total storage",
                                                     min: 0, max: 10, current: 4)),
                                     .description(.description(text: "1 GB total storage", iconName: "disk")),
                                     .description(.description(text: "1 free email address", iconName: "mail")),
                                     .description(.description(text: "150 messages per day", iconName: "mail"))
                                    ])
            ])
            static let vpnFree: CurrentPlan = .init(subscriptions: [
                .init(title: "VPN Free",
                      name: nil,
                      description: "High-speed Swiss VPN that protects your privacy",
                      periodEnd: 1965360000,
                      entitlements: [.description(.description(text: "249 servers in 5 countries", iconName: "servers")),
                                     .description(.description(text: "No ads", iconName: "rocket")),
                                     .description(.description(text: "Unlimited volume/bandwidth", iconName: "infinite"))
                      ])
            ])
            static let passFree: CurrentPlan = .init(subscriptions: [
                .init(title: "Pass Free",
                      name: nil,
                      description: "Encrypted password manager that also protects your identity",
                      periodEnd: 1965360000,
                      entitlements: [.description(.description(text: "Unlimited logins and notes", iconName: "infinite")),
                                     .description(.description(text: "Unlimited devices", iconName: "infinite")),
                                     .description(.description(text: "10 hide-my-email aliases", iconName: "alias")),
                                     .description(.description(text: "Vault sharing (up to 3 people)", iconName: "vault"))
                      ])
            ])
            static let arbitraryFree: CurrentPlan = .init(subscriptions: [
                .init(title: "Blue Moon Free",
                      name: nil,
                      description: "Keep your satellites secure",
                      periodEnd: 1965360000,
                      entitlements: [.description(.description(text: "Aliases!", iconName: "alias")),
                                     .description(.description(text: "Arrows and Switches!", iconName: "arrows-switch"))
                      ])
            ])
            static var mail2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Mail Plus",
                      name: "mail2022",
                      description: "Encrypted email with premium features and free VPN",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .progress(.init(type: "progress", text: "1.2 GB of 15 GB", min: 0, max: 150, current: 12)),
                        .description(.description(text: "15 GB total storage", iconName: "disk")),
                        .description(.description(text: "10 email addresses", iconName: "email")),
                        .description(.description(text: "Unlimited messages", iconName: "infinite")),
                        .description(.description(text: "Support for 1 custom email domain", iconName: "globe")),
                        .description(.description(text: "25 Calendars", iconName: "calendar")),
                        .description(.description(text: "Calendar sharing", iconName: "calendar")),
                        .description(.description(text: "1 medium-speed VPN connection", iconName: "globe"))
                      ])
            ])
            static var vpn2022: CurrentPlan = .init(subscriptions: [
                .init(title: "VPN Plus",
                      name: "vpn2022",
                      description: "Encrypted email with premium features and free VPN",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "Highest VPN speed", iconName: "vpn")),
                        .description(.description(text: "Protect 10 devices at a time", iconName: "vpn")),
                        .description(.description(text: "Available on all platforms", iconName: "vpn")),
                        .description(.description(text: "Ad-blocker and malware protection", iconName: "vpn")),
                        .description(.description(text: "High-speed streaming", iconName: "vpn")),
                        .description(.description(text: "Priority support & live chat", iconName: "vpn")),
                        .description(.description(text: "Advanced VPN customizations", iconName: "vpn"))
                      ])
            ])
            static var bundle2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Proton Unlimited",
                      name: "bundle2022",
                      description: "Acces to all Proton apps and premium features",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .progress(.init(type: "progress", text: "1.2 GB of 500 GB", min: 0, max: 5000, current: 12)),
                        .description(.description(text: "500 GB total storage")),
                        .description(.description(text: "15 email addresses")),
                        .description(.description(text: "Unlimited messages")),
                        .description(.description(text: "Support for 3 custom email domains")),
                        .description(.description(text: "Unlimited folders, labels and filters")),
                        .description(.description(text: "Unlimited hide-my-email aliases"))
                      ])
            ])
            static var drive2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Drive Plus",
                      name: "drive2022",
                      description: "Secure your files with end-to-end encryption",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .progress(.init(type: "progress", text: "1.2 GB of 200 GB", min: 0, max: 2000, current: 12)),
                        .description(.description(text: "200 GB total storage")),
                        .description(.description(text: "End-to-end encryption")),
                        .description(.description(text: "Share with up to 10 others")),
                        .description(.description(text: "Version history"))
                      ])
            ])

            static var pass2023: CurrentPlan = .init(subscriptions: [
                .init(title: "Pass Plus",
                      name: "pass2022",
                      description: "Encrypted password manager that also protects your identity",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "Unlimited logins and notes")),
                        .description(.description(text: "Unlimited devices")),
                        .description(.description(text: "Unlimited hide-my-email aliases")),
                        .description(.description(text: "Integrated 2FA authenticator")),
                        .description(.description(text: "Organize items with multiple vaults")),
                        .description(.description(text: "Vault sharing (up to 10 people)"))
                      ])
            ])

            static var mailpro2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Mail Essentials",
                      name: "mailpro2022",
                      description: "Secure email and calendar for professionals and businesses.",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "10 email addresses per user", iconName: "email")),
                        .description(.description(text: "Unlimited folders, labels and filters", iconName: "infinite")),
                        .description(.description(text: "Support for 3 custom email domains", iconName: "globe")),
                        .description(.description(text: "Calendar sharing", iconName: "calendar")),
                        .description(.description(text: "Contact groups management", iconName: "calendar")),
                        .description(.description(text: "1 free VPN connection per user", iconName: "globe")),
                        .description(.description(text: "15 GB storage per user"))
                      ])
            ])

            static var bundlepro2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Business",
                      name: "bundlepro2022",
                      description: "Privacy and security suite for businesses, including all premium Proton services.",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "15 email addresses per user", iconName: "email")),
                        .description(.description(text: "Unlimited folders, labels and filters", iconName: "infinite")),
                        .description(.description(text: "Support for 10 custom email domains", iconName: "globe")),
                        .description(.description(text: "Calendar sharing", iconName: "calendar")),
                        .description(.description(text: "Contact groups management", iconName: "calendar")),
                        .description(.description(text: "10 VPN connections per user", iconName: "globe")),
                        .description(.description(text: "500 GB storage per user"))
                      ])
            ])
            static var enterprise2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Enterprise",
                      name: "enterprise2022",
                      description: "All premium Proton services with more storage for your business.",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "Everything business", iconName: "email")),
                        .description(.description(text: "Tailored to your needs", iconName: "infinite")),
                        .description(.description(text: "Dedicated account manager", iconName: "globe")),
                        .description(.description(text: "As much storage as needed", iconName: "calendar")),
                      ])
            ])
            static var visionary2022: CurrentPlan = .init(subscriptions: [
                .init(title: "Visionary",
                      name: "visionary2022",
                      description: "Our exclusive plan for early supporters.",
                      periodEnd: 1965360000,
                      renew: 0,
                      entitlements: [
                        .description(.description(text: "6 users", iconName: "email")),
                        .description(.description(text: "100 email addresses per user", iconName: "email")),
                        .description(.description(text: "Unlimited folders, labels and filters", iconName: "infinite")),
                        .description(.description(text: "Support for 10 custom email domains", iconName: "globe")),
                        .description(.description(text: "Calendar sharing", iconName: "calendar")),
                        .description(.description(text: "Contact groups management", iconName: "calendar")),
                        .description(.description(text: "10 VPN connections per user", iconName: "globe")),
                        .description(.description(text: "6 TB storage per user"))
                      ])
            ])

        }

        enum StorageSplit {

            static let mailFree: CurrentPlan = .init(subscriptions: [
                .init(title: "Mail Free",
                      name: nil,
                      description: "Free encrypted email and calendar for everyone",
                      periodEnd: 1965360000,
                      entitlements: [.progress(.init(type: "progress",
                                                     title: "Mail storage",
                                                     text: "402 MB of 500 MB",
                                                     min: 0, max: 5, current: 4)),
                                     .progress(.init(type: "progress",
                                                     title: "Drive storage",
                                                     text: "0.00 B of 2 GB",
                                                     min: 0, max: 2, current: 0)),
                                     .description(.description(text: "1 of 1 user", iconName: "user")),
                                     .description(.description(text: "1 of 1 address", iconName: "email")),
                                     .description(.description(text: "0 of 3 calendars", iconName: "calendar")),
                                     .description(.description(text: "Free VPN on a single device", iconName: "vpn")),
                                     .description(.description(text: "And the free features of all other Proton products!", iconName: "tick"))
                                    ])
            ])
            static let driveFree: CurrentPlan = .init(subscriptions: [
                .init(title: "Drive Free",
                      name: nil,
                      description: "Free encrypted storage for everyone",
                      periodEnd: 1965360000,
                      entitlements: [.progress(.init(type: "progress",
                                                     title: "Mail storage",
                                                     text: "402 MB of 500 MB",
                                                     min: 0, max: 5, current: 4)),
                                     .progress(.init(type: "progress",
                                                     title: "Drive storage",
                                                     text: "0.00 B of 2 GB",
                                                     min: 0, max: 2, current: 0)),
                                     .description(.description(text: "1 of 1 user", iconName: "user")),
                                     .description(.description(text: "1 of 1 address", iconName: "email")),
                                     .description(.description(text: "0 of 3 calendars", iconName: "calendar")),
                                     .description(.description(text: "Free VPN on a single device", iconName: "vpn")),
                                     .description(.description(text: "And the free features of all other Proton products!", iconName: "tick"))
                                    ])
            ])
            static let mailFreeDelinquent: CurrentPlan = .init(subscriptions: [
                .init(title: "Mail Free",
                      name: nil,
                      description: "Free encrypted email and calendar for everyone",
                      periodEnd: 1965360000,
                      entitlements: [.progress(.init(type: "progress",
                                                     title: "Mail storage",
                                                     text: "495 MB of 500 MB",
                                                     min: 0, max: 500, current: 495)),
                                     .progress(.init(type: "progress",
                                                     title: "Drive storage",
                                                     text: "0.00 B of 2 GB",
                                                     min: 0, max: 2, current: 0)),
                                     .description(.description(text: "1 of 1 user", iconName: "user")),
                                     .description(.description(text: "1 of 1 address", iconName: "email")),
                                     .description(.description(text: "0 of 3 calendars", iconName: "calendar")),
                                     .description(.description(text: "Free VPN on a single device", iconName: "vpn")),
                                     .description(.description(text: "And the free features of all other Proton products!", iconName: "tick"))
                                    ])
            ])
            static let driveFreeDelinquent: CurrentPlan = .init(subscriptions: [
                .init(title: "Drive Free",
                      name: nil,
                      description: "Free encrypted storage for everyone",
                      periodEnd: 1965360000,
                      entitlements: [.progress(.init(type: "progress",
                                                     title: "Mail storage",
                                                     text: "402 MB of 500 MB",
                                                     min: 0, max: 5, current: 4)),
                                     .progress(.init(type: "progress",
                                                     title: "Drive storage",
                                                     text: "1.98 GB of 2 GB",
                                                     min: 0, max: 200, current: 198)),
                                     .description(.description(text: "1 of 1 user", iconName: "user")),
                                     .description(.description(text: "1 of 1 address", iconName: "email")),
                                     .description(.description(text: "0 of 3 calendars", iconName: "calendar")),
                                     .description(.description(text: "Free VPN on a single device", iconName: "vpn")),
                                     .description(.description(text: "And the free features of all other Proton products!", iconName: "tick"))
                                    ])
            ])
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

    @MainActor
    // swiftlint:disable:next function_body_length
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
        case .other("arbitraryOffer"):
            shownPlanNames = ObfuscatedConstants.mailShownPlanNames
            var identifiers = ObfuscatedConstants.mailIAPIdentifiers
            identifiers.insert("iosimaginary_bundle2022_offer_12_usd_non_renewing")
            iapIdentifiers = identifiers
            paidPlans = MockData.Plans.mailPaidPlanAndArbitraryOffer
        case .other:
            fatalError("misconfiguration")
        }

        servicePlan.paymentMethodsStub.fixture = paymentMethods
        storeKitManager.inAppPurchaseIdentifiersStub.fixture = iapIdentifiers
        storeKitManager.priceLabelForProductStub.bodyIs { _, iapIdentifier in
            if iapIdentifier == MockData.Plans.arbitraryOffer.plan.vendors?.apple.plans.values.first {
                guard let price = MockData.Plans.arbitraryOffer.plan.pricing(for: InAppPurchasePlan.defaultCycle) else { return nil }
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
        let maxSpace = Int64(max(currentSubscriptionPlan?.maxSpace ?? 0, MockData.Plans.free.plan.maxSpace))
        servicePlan.userStub.fixture = User.dummy.updated(usedSpace: Int64(Double(maxSpace) * 0.6), maxSpace: maxSpace)
        storeKitManager.canExtendSubscriptionStub.fixture = true

        let viewModel = PaymentsUIViewModel(mode: mode,
                                            storeKitManager: storeKitManager,
                                            planService: .left(servicePlan),
                                            shownPlanNames: shownPlanNames,
                                            clientApp: clientApp,
                                            customPlansDescription: customPlansDescription,
                                            planRefreshHandler: { _ in XCTFail() },
                                            extendSubscriptionHandler: { XCTFail() })

        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.viewModel = viewModel

        _ = await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.fetchPlans(backendFetch: false) { _ in
                viewModel.plans.flatMap { $0 }.forEach { $0.isExpanded = true }
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

    @MainActor
    private func snapshotDynamicPlanSubscriptionScreen(mode: PaymentsUIMode,
                                                       currentPlan: CurrentPlan = MockData.currentPlan,
                                                       name: String,
                                                       clientApp: ClientApp,
                                                       modalPresentation: Bool = false,
                                                       record: Bool,
                                                       file: StaticString = #filePath,
                                                       line: UInt = #line) async {
        let availablePlans: AvailablePlans = MockData.availablePlans
        let shownPlanNames: Set<String> = planNamesFor(client: clientApp)

        //    plansDataSource.paymentMethodsStub.fixture = paymentMethods
        plansDataSource.availablePlansStub.fixture = availablePlans
        plansDataSource.currentPlanStub.fixture = currentPlan
        //    storeKitManager.inAppPurchaseIdentifiersStub.fixture = iapIdentifiers

        storeKitManager.priceLabelForProductStub.bodyIs { _, iapIdentifier in
            if iapIdentifier == MockData.Plans.arbitraryOffer.plan.vendors?.apple.plans.values.first {
                guard let price = MockData.Plans.arbitraryOffer.plan.pricing(for: InAppPurchasePlan.defaultCycle) else { return nil }
                return (NSDecimalNumber(value: Double(price) / 100.0), Locale.autoupdatingCurrent)
            }
            guard let iap = InAppPurchasePlan(storeKitProductId: iapIdentifier),
                  let plan = MockData.Plans.allPlans.first(where: { $0.name == iap.protonName }),
                  let price = plan.pricing(for: iap.period) else { return nil }
            return (NSDecimalNumber(value: Double(price) / 100.0), Locale.autoupdatingCurrent)
        }
        storeKitManager.canExtendSubscriptionStub.fixture = true

        let viewModel = PaymentsUIViewModel(mode: mode,
                                            storeKitManager: storeKitManager,
                                            planService: .right(plansDataSource),
                                            shownPlanNames: shownPlanNames,
                                            clientApp: clientApp,
                                            customPlansDescription: [:],
                                            planRefreshHandler: { _ in XCTFail() },
                                            extendSubscriptionHandler: { XCTFail() })
        viewModel.currentPlan = try! await .createCurrentPlan(from: currentPlan.subscriptions.first!, plansDataSource: plansDataSource)

        let paymentsUIViewController = UIStoryboard.instantiate(storyboardName: "PaymentsUI",
                                                                controllerType: PaymentsUIViewController.self,
                                                                inAppTheme: { .default })
        paymentsUIViewController.viewModel = viewModel

        let imageSize: CGSize
        switch mode {
        case .signup:
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

    private func planNamesFor(client: ClientApp) -> Set<String> {
        switch client {
        case .mail:
            return ObfuscatedConstants.mailShownPlanNames.union(["free"])
        case .vpn:
            return ObfuscatedConstants.vpnShownPlanNames
        case .drive:
            return ObfuscatedConstants.driveShownPlanNames
        case .calendar:
            return ObfuscatedConstants.calendarShownPlanNames
        case .pass:
            return ObfuscatedConstants.passShownPlanNames
        case .other("arbitraryOffer"):
            return ObfuscatedConstants.mailShownPlanNames
        case .other:
            fatalError("misconfiguration")
        }
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

    private func snapshotCurrentDynamicSubscriptionScreen(currentPlan: CurrentPlan,
                                                          name: String = #function,
                                                          clientApp: ClientApp,
                                                          modalPresentation: Bool = false,
                                                          record: Bool = false,
                                                          file: StaticString = #filePath,
                                                          line: UInt = #line) async {

        await snapshotDynamicPlanSubscriptionScreen(mode: .current,
                                                    currentPlan: currentPlan.updated(renew: 0),
                                                    name: name.appending("expiring"),
                                                    clientApp: clientApp,
                                                    modalPresentation: modalPresentation,
                                                    record: record,
                                                    file: file,
                                                    line: line)

        await snapshotDynamicPlanSubscriptionScreen(mode: .current,
                                                    currentPlan: currentPlan.updated(renew: 1),
                                                    name: name.appending("renewing"),
                                                    clientApp: clientApp,
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

    func testCurrentDynamicSubscription_Free_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailFree,
                clientApp: .mail
            )
        }
    }

    func testCurrentDynamicSubscription_Free_InMail_StorageSplit() async {
        await withFeatureFlags([.dynamicPlans, .splitStorage]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.StorageSplit.mailFree,
                clientApp: .mail
            )
        }
    }

    func testCurrentDynamicSubscription_Free_InMail_StorageSplit_Delinquent() async {
        await withFeatureFlags([.dynamicPlans, .splitStorage]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.StorageSplit.mailFreeDelinquent,
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Free_InVPN() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_Free_InVPN() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpnFree,
                clientApp: .vpn
            )
        }
    }

    func testCurrentSubscription_Free_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Free_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.passFree,
                clientApp: .pass
            )
        }
    }

    func testCurrentDynamicSubscription_Free_InDrive_StorageSplit() async {
        await withFeatureFlags([.dynamicPlans, .splitStorage]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.StorageSplit.driveFree,
                clientApp: .drive
            )
        }
    }

    func testCurrentDynamicSubscription_Free_InDrive_StorageSplit_Delinquent() async {
        await withFeatureFlags([.dynamicPlans, .splitStorage]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.StorageSplit.driveFreeDelinquent,
                clientApp: .drive
            )
        }
    }

    func testCurrentSubscription_Free_ArbitraryOffer() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .other(named: "arbitraryOffer")
        )
    }

    func testCurrentDynamicSubscription_Free_ArbitraryOffer() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.arbitraryFree,
                clientApp: .other(named: "arbitraryOffer")
            )
        }
    }

    // mail2022

    func testCurrentSubscription_Mail2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Mail2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 1, cycleDescription: "every month", currency: "EUR", amount: 499),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Mail2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Mail2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 12, cycleDescription: "every year",
                                                                    currency: "EUR", amount: 4788),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Mail2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Mail2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 24, cycleDescription: "every 2 years", currency: "EUR", amount: 8376),
                clientApp: .mail
            )
        }
    }

    // vpn2022

    func testCurrentSubscription_VPN2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_VPN2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every month", currency: "CHF", amount: 999),
                clientApp: .vpn
            )
        }
    }

    func testCurrentSubscription_VPN2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_VPN2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 12, cycleDescription: "every year", currency: "CHF", amount: 7188),
                clientApp: .vpn
            )
        }
    }

    func testCurrentSubscription_VPN2022_15() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_VPN2022_15() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 1.5 years", currency: "CHF", amount: 7485),
                clientApp: .vpn
            )
        }
    }

    func testCurrentSubscription_VPN2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_VPN2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 2 years", currency: "CHF", amount: 11976),
                clientApp: .vpn
            )
        }
    }

    func testCurrentSubscription_VPN2022_30() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testCurrentDynamicSubscription_VPN2022_30() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 2.5 years", currency: "CHF", amount: 14900),
                clientApp: .vpn
            )
        }
    }
    // bundle2022 in mail

    func testCurrentSubscription_Bundle2022_1_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_1_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 1, cycleDescription: "every month",
                                                                      currency: "USD", amount: 1299),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Bundle2022_12_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_12_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 12, cycleDescription: "every year",
                                                                      currency: "USD", amount: 11988),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Bundle2022_24_InMail() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_24_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                      currency: "USD", amount: 19176),
                clientApp: .mail
            )
        }
    }

    // bundle2022 in pass

    func testCurrentSubscription_Bundle2022_1_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_1_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 1, cycleDescription: "every month",
                                                                      currency: "USD", amount: 1299),
                clientApp: .pass
            )
        }
    }

    func testCurrentSubscription_Bundle2022_12_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_12_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 12, cycleDescription: "every year",
                                                                      currency: "USD", amount: 11988),
                clientApp: .pass
            )
        }
    }

    func testCurrentSubscription_Bundle2022_24_InPass() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Bundle2022_24_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                      currency: "USD", amount: 19176),
                clientApp: .pass
            )
        }
    }

    // drive2022

    func testCurrentSubscription_Drive2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }

    func testCurrentDynamicSubscription_Drive2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 1, cycleDescription: "every month",
                                                                     currency: "USD", amount: 499),
                clientApp: .drive
            )
        }
    }

    func testCurrentSubscription_Drive2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .drive
        )
    }

    func testCurrentDynamicSubscription_Drive2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 12, cycleDescription: "every year",
                                                                     currency: "USD", amount: 4788),
                clientApp: .drive
            )
        }
    }

    func testCurrentSubscription_Drive2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }

    func testCurrentDynamicSubscription_Drive2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                     currency: "USD", amount: 8376),
                clientApp: .drive
            )
        }
    }

    // pass2023

    func testCurrentSubscription_Pass2023_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Pass2023_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 1, cycleDescription: "every month",
                                                                    currency: "CHF", amount: 499),
                clientApp: .pass
            )
        }
    }

    func testCurrentSubscription_Pass2023_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Pass2023_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 12, cycleDescription: "every year",
                                                                    currency: "CHF", amount: 4788),
                clientApp: .pass
            )
        }
    }

    func testCurrentSubscription_Pass2023_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testCurrentDynamicSubscription_Pass2023_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 1, cycleDescription: "every 2 years",
                                                                    currency: "CHF", amount: 3588),
                clientApp: .pass
            )
        }
    }

    // mailpro2022

    func testCurrentSubscription_MailPro2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_MailPro2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                       currency: "CHF", amount: 799),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_MailPro2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_MailPro2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                       currency: "CHF", amount: 8388),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_MailPro2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_MailPro2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                       currency: "CHF", amount: 7788),
                clientApp: .mail
            )
        }
    }

    // bundlepro2022

    func testCurrentSubscription_BundlePro2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_BundlePro2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 1299),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_BundlePro2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_BundlePro2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 13188),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_BundlePro2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_BundlePro2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                         currency: "CHF", amount: 23976),
                clientApp: .mail
            )
        }
    }

    // enterprise2022

    func testCurrentSubscription_Enterprise2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Enterprise2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 1599),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Enterprise2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Enterprise2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 16788),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Enterprise2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Enterprise2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.enterprise2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                          currency: "CHF", amount: 31176),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Free_ModalPresentation() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail,
            modalPresentation: true
        )
    }

    func testCurrentDynamicSubscription_Free_ModalPresentation() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailFree,
                clientApp: .mail,
                modalPresentation: true
            )
        }
    }

    // visionary2022

    func testCurrentSubscription_Visionary2022_1() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Visionary2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 2999),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Visionary2022_12() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Visionary2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 28788),
                clientApp: .mail
            )
        }
    }

    func testCurrentSubscription_Visionary2022_24() async {
        await snapshotCurrentSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testCurrentDynamicSubscription_Visionary2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                         currency: "CHF", amount: 47976),
                clientApp: .mail
            )
        }
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

    // No sense speaking of unknown dynamic plans, or with custom descriptions, as all are created server side like that
    // So no snapshot tests for the equivalent to the above static plans

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

    private func snapshotUpdateDynamicSubscriptionScreen(currentPlan: CurrentPlan,
                                                         name: String = #function,
                                                         clientApp: ClientApp,

                                                         modalPresentation: Bool = false,
                                                         record: Bool = false,
                                                         file: StaticString = #filePath,
                                                         line: UInt = #line) async {
        await snapshotDynamicPlanSubscriptionScreen(mode: .update,
                                                    currentPlan: currentPlan,
                                                    name: name,
                                                    clientApp: clientApp,
                                                    modalPresentation: modalPresentation,
                                                    record: record,
                                                    file: file,
                                                    line: line)
    }

    // free

    func testUpdateSubscription_Free_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Free_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailFree,
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Free_InVPN() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_Free_InVPN() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpnFree,
                clientApp: .vpn
            )
        }
    }

    func testUpdateSubscription_Free_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Free_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.passFree,
                clientApp: .pass
            )
        }
    }

    func testUpdateSubscription_Free_ArbitraryOffer() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: nil,
            paymentMethods: .empty,
            clientApp: .other(named: "arbitraryOffer")
        )
    }

    func testUpdateDynamicSubscription_Free_ArbitraryOffer() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.arbitraryFree,
                clientApp: .other(named: "arbitraryOffer")
            )
        }
    }

    // mail2022

    func testUpdateSubscription_Mail_2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Mail2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 1, cycleDescription: "every month", currency: "EUR", amount: 499),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Mail2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan,
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Mail2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 12, cycleDescription: "every year", currency: "EUR", amount: 4788),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Mail2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mail2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Mail2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mail2022.updated(cycle: 24, cycleDescription: "every 2 years", currency: "EUR", amount: 8376),
                clientApp: .mail
            )
        }
    }

    // vpn2022

    func testUpdateSubscription_VPN2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_VPN2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every month", currency: "CHF", amount: 999),
                clientApp: .vpn
            )
        }
    }

    func testUpdateSubscription_VPN2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_VPN2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 12, cycleDescription: "every year", currency: "CHF", amount: 7188),
                clientApp: .vpn
            )
        }
    }

    func testUpdateSubscription_VPN2022_15() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 15),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_VPN2022_15() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 1.5 years", currency: "CHF", amount: 7485),
                clientApp: .vpn
            )
        }
    }

    func testUpdateSubscription_VPN2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_VPN2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 2 years", currency: "CHF", amount: 11976),
                clientApp: .vpn
            )
        }
    }

    func testUpdateSubscription_VPN2022_30() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.vpn2022.plan.updated(cycle: 30),
            paymentMethods: existingPaymentsMethods,
            clientApp: .vpn
        )
    }

    func testUpdateDynamicSubscription_VPN2022_30() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotCurrentDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.vpn2022.updated(cycle: 1, cycleDescription: "every 2.5 years", currency: "CHF", amount: 14900),
                clientApp: .vpn
            )
        }
    }

    // bundle2022

    func testUpdateSubscription_Bundle2022_1_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_1_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 1, cycleDescription: "every month",
                                                                      currency: "USD", amount: 1299),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Bundle2022_12_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_12_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 12, cycleDescription: "every year",
                                                                      currency: "USD", amount: 11988),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Bundle2022_24_InMail() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_24_InMail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                      currency: "USD", amount: 19176),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Bundle2022_1_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_1_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 1, cycleDescription: "every month",
                                                                      currency: "USD", amount: 1299),
                clientApp: .pass
            )
        }
    }

    func testUpdateSubscription_Bundle2022_12_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_12_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 12, cycleDescription: "every year",
                                                                      currency: "USD", amount: 11988),
                clientApp: .pass
            )
        }
    }

    func testUpdateSubscription_Bundle2022_24_InPass() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundle2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Bundle2022_24_InPass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundle2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                      currency: "USD", amount: 19176),
                clientApp: .pass
            )
        }
    }

    // pass2023

    func testUpdateSubscription_Pass2023_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Pass2023_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 1, cycleDescription: "every month",
                                                                    currency: "CHF", amount: 499),
                clientApp: .pass
            )
        }
    }

    func testUpdateSubscription_Pass2023_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Pass2023_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 12, cycleDescription: "every year",
                                                                    currency: "CHF", amount: 4788),
                clientApp: .pass
            )
        }
    }

    func testUpdateSubscription_Pass2023_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.pass2023.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .pass
        )
    }

    func testUpdateDynamicSubscription_Pass2023_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.pass2023.updated(cycle: 1, cycleDescription: "every 2 years",
                                                                    currency: "CHF", amount: 3588),
                clientApp: .pass
            )
        }
    }
    // drive2022

    func testUpdateSubscription_Drive2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }

    func testUpdateDynamicSubscription_Drive2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 1, cycleDescription: "every month",
                                                                     currency: "USD", amount: 499),
                clientApp: .drive
            )
        }
    }

    func testUpdateSubscription_Drive2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 12),
            paymentMethods: .empty,
            clientApp: .drive
        )
    }

    func testUpdateDynamicSubscription_Drive2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 12, cycleDescription: "every year",
                                                                     currency: "USD", amount: 4788),
                clientApp: .drive
            )
        }
    }

    func testUpdateSubscription_Drive2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.drive2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .drive
        )
    }

    func testUpdateDynamicSubscription_Drive2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.drive2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                     currency: "USD", amount: 8376),
                clientApp: .drive
            )
        }
    }
    // mailpro2022

    func testUpdateSubscription_MailPro2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_MailPro2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                       currency: "CHF", amount: 799),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_MailPro2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_MailPro2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                       currency: "CHF", amount: 8388),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_MailPro2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.mailpro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_MailPro2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.mailpro2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                       currency: "CHF", amount: 7788),
                clientApp: .mail
            )
        }
    }

    // bundlepro2022

    func testUpdateSubscription_BundlePro2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_BundlePro2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 1299),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_BundlePro2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_BundlePro2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 13188),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_BundlePro2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.bundlepro2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_BundlePro2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                         currency: "CHF", amount: 23976),
                clientApp: .mail
            )
        }
    }

    // enterprise2022
    func testUpdateSubscription_Enterprise2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Enterprise2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 1599),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Enterprise2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Enterprise2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.bundlepro2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 16788),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Enterprise2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.enterprise2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Enterprise2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.enterprise2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                          currency: "CHF", amount: 31176),
                clientApp: .mail
            )
        }
    }

    // visionary2022

    func testUpdateSubscription_Visionary2022_1() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 1),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Visionary2022_1() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 1, cycleDescription: "every month",
                                                                         currency: "CHF", amount: 2999),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Visionary2022_12() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 12),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Visionary2022_12() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 12, cycleDescription: "every year",
                                                                         currency: "CHF", amount: 28788),
                clientApp: .mail
            )
        }
    }

    func testUpdateSubscription_Visionary2022_24() async {
        await snapshotUpdateSubscriptionScreen(
            currentSubscriptionPlan: MockData.Plans.visionary2022.plan.updated(cycle: 24),
            paymentMethods: existingPaymentsMethods,
            clientApp: .mail
        )
    }

    func testUpdateDynamicSubscription_Visionary2022_24() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotUpdateDynamicSubscriptionScreen(
                currentPlan: MockData.DynamicPlans.visionary2022.updated(cycle: 24, cycleDescription: "every 2 years",
                                                                         currency: "CHF", amount: 47976),
                clientApp: .mail
            )
        }
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
        if try! await featureFlagsRepository.isEnabled(CoreFeatureFlagType.dynamicPlan) {
            await snapshotDynamicPlanSubscriptionScreen(mode: .signup,
                                                        currentPlan: MockData.DynamicPlans.mailFree,
                                                        name: name,
                                                        clientApp: clientApp,
                                                        record: record)
        } else {
            await snapshotSubscriptionScreen(mode: .signup,
                                             currentSubscriptionPlan: nil,
                                             paymentMethods: .empty,
                                             name: name,
                                             clientApp: clientApp,
                                             customPlansDescription: customPlansDescription,
                                             record: record)
        }
    }

    func testSignupSubscription_Mail() async {
        await snapshotSignupSubscriptionScreen(clientApp: .mail)
    }

    func testSignupDynamicSubscription_Mail() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(clientApp: .mail)
        }
    }

    func testSignupSubscription_VPN() async {
        await snapshotSignupSubscriptionScreen(clientApp: .vpn)
    }

    func testSignupDynamicSubscription_VPN() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(clientApp: .vpn)
        }
    }

    func testSignupSubscription_Drive() async {
        await snapshotSignupSubscriptionScreen(clientApp: .drive)
    }

    func testSignupDynamicSubscription_Drive() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(clientApp: .drive)
        }
    }

    func testSignupSubscription_Calendar() async {
        await snapshotSignupSubscriptionScreen(clientApp: .calendar)
    }

    func testSignupDynamicSubscription_Calendar() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(clientApp: .calendar)
        }
    }

    func testSignupSubscription_Pass() async {
        await snapshotSignupSubscriptionScreen(clientApp: .pass)
    }

    func testSignupDynamicSubscription_Pass() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(clientApp: .pass)
        }
    }

    func testSignupSubscription_Free_ArbitraryOffer() async {
        await snapshotSignupSubscriptionScreen(
            clientApp: .other(named: "arbitraryOffer")
        )
    }

    func testSignupDynamicSubscription_Free_ArbitraryOffer() async {
        await withFeatureFlags([.dynamicPlans]) {
            await snapshotSignupSubscriptionScreen(
                clientApp: .other(named: "arbitraryOffer")
            )
        }
    }

    func testSignupSubscription_CustomDescription() async {
        await snapshotSignupSubscriptionScreen(clientApp: .pass, customPlansDescription: MockData.customPlansDescription)
    }
}

extension CurrentPlan.Subscription.DescriptionEntitlement {
    static func description(text: String, iconName: String = "") -> Self {
        .init(type: "description", text: text, iconName: iconName)
    }
}

extension CurrentPlan {
    func updated(cycle: Int? = nil, cycleDescription: String? = nil, currency: String? = nil, amount: Int? = nil, renew: Int? = nil) -> CurrentPlan {
        Self(subscriptions: self.subscriptions.map { $0.updated(cycle: cycle,
                                                                cycleDescription: cycleDescription,
                                                                currency: currency,
                                                                amount: amount,
                                                                renew: renew)
        })
    }
}

extension CurrentPlan.Subscription {
    func updated(cycle: Int?, cycleDescription: String?, currency: String?, amount: Int?, renew: Int?) -> Self {
        Self(title: self.title,
             name: self.name,
             description: self.description,
             cycleDescription: cycleDescription ?? self.cycleDescription,
             cycle: cycle ?? self.cycle,
             currency: currency ?? self.currency,
             amount: amount ?? self.amount,
             periodEnd: self.periodEnd,
             renew: renew ?? self.renew,
             entitlements: self.entitlements)
    }
}

#endif
