//
//  PlanViewModel.swift
//  ProtonCore-PaymentsUIV2 - Created on 7/11/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

import Combine
import Foundation
import ProtonCoreDoh
import ProtonCorePaymentsV2
import ProtonCoreUIFoundations
import StoreKit

/// Represents a purchasable plan or free instance
@MainActor
public class PlanViewModel: ObservableObject, Identifiable {

    private struct Constants {
        static func footerText(renew: Int) -> String {

            let expirationText = PaymentsUIV2Localizer.Current_plan_exipiration.l10n
            let renewalText = PaymentsUIV2Localizer.Current_plan_renewal.l10n

            return renew == 0 ? expirationText : renewalText
        }
    }

    /// user visible description
    @Published var description: String
    /// user visible plan title
    @Published var title: String
    /// internal plan name
    @Published var name: String?
    /// List of progress bar entitlements
    @Published var progressEntitlements: [ProgressEntitlement]
    /// List of string entitlements offered
    @Published var descriptionEntitlements: [DescriptionEntitlement]
    /// pre-formatted price
    @Published var formattedPrice: String
    /// formatted cycle
    @Published var formattedPeriod: String
    /// length of subscription cycle
    @Published var subscriptionPeriod: BillingCycle

    @Published var isExpanded = false

    public var isCurrentPlan: Bool

    private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    public var showProgressEntitlements: Bool {
        !progressEntitlements.isEmpty
    }

    public var renewFooter: AttributedString?
    public var isFreePlan: Bool

    /// plan Decorations
    private let decorations: [Decoration]

    /// the StoreKit product to purchase
    private let product: (any ProductProtocol)?

    /// Initializer that takes an `AvailablePlan` (as returned from the API), one of its `PlanInstance`s,
    /// and the StoreKit product with matching identifier.
    /// The plan description is taken from the `AvailablePlan`. The duration and identifier com from the `PlanInstance`,
    /// and the localized price and the purchase action are derived from the `Product`

    private let paymentsAPI: PaymentsAPIs
    private let remoteManager: RemoteManager
    private var plansManager: ProtonPlansManagerProviding?

    public init(doh: DoHInterface & ServerConfig,
                remoteManager: RemoteManager,
                composedPlan: ComposedPlan,
                plansManager: ProtonPlansManagerProviding? = nil) {

        self.paymentsAPI = PaymentsAPIs(doh: doh)
        self.remoteManager = remoteManager
        if let pManager = plansManager {
            self.plansManager = pManager
        } else {
            self.plansManager = ProtonPlansManager(doh: doh,
                                                   remoteManager: remoteManager)
        }

        let progressEntitlements = composedPlan.plan.entitlements.compactMap {
            switch $0 {
            case let .progress(entitlement):
                entitlement
            default: nil
            }
        }

        self.descriptionEntitlements = composedPlan.plan.entitlements.compactMap {
            switch $0 {
            case let .description(entitlement):
                entitlement
            default: nil
            }
        }

        self.description = composedPlan.plan.description
        self.title = composedPlan.plan.title
        self.isFreePlan = false
        self.name = composedPlan.plan.name
        self.progressEntitlements = progressEntitlements
        self.formattedPrice = composedPlan.product.displayPrice
        self.formattedPeriod = composedPlan.instance.description
        self.subscriptionPeriod = BillingCycle(rawValue: composedPlan.instance.cycle) ?? .all
        self.decorations = composedPlan.plan.decorations
        self.product = composedPlan.product
        self.isCurrentPlan = false

        if let transactionState = plansManager?.transactionProgress {
            self.transactionState = transactionState
        }
    }

    public init(doh: DoHInterface & ServerConfig,
                remoteManager: RemoteManager,
                currentPlan: CurrentSubscriptionResponse) {

        self.paymentsAPI = PaymentsAPIs(doh: doh)
        self.remoteManager = remoteManager

        let progressEntitlements = currentPlan.entitlements.compactMap {
            switch $0 {
            case let .progress(entitlement):
                entitlement
            default: nil
            }
        }

        self.descriptionEntitlements = currentPlan.entitlements.compactMap {
            switch $0 {
            case let .description(entitlement):
                entitlement
            default: nil
            }
        }

        self.description = currentPlan.description
        self.title = currentPlan.title
        self.name = currentPlan.name ?? PaymentsUIV2Localizer.Current_free_plan_name.l10n
        self.isFreePlan = currentPlan.name == nil
        self.progressEntitlements = progressEntitlements
        self.formattedPrice = Formatter.formatCurrency(amount: currentPlan.amount, currency: currentPlan.currency)
        self.formattedPeriod = currentPlan.cycleDescription ?? ""
        self.subscriptionPeriod = BillingCycle(rawValue: currentPlan.cycle ?? 0) ?? .all
        self.decorations = currentPlan.decorations
        self.isCurrentPlan = true
        self.product = nil
        if let endPeriod = currentPlan.periodEnd {
            let texts = [TextStyle(text: Constants.footerText(renew: currentPlan.renew ?? 0), font: .callout, color: ColorProvider.Shade80),
                         TextStyle(text: Formatter.formatDate(Double(endPeriod), formatType: .MMddYYYY), font: .headline, color: ColorProvider.TextNorm)]
            createFooterText(texts: texts)
        }

        if let transactionState = plansManager?.transactionProgress {
            self.transactionState = transactionState
        }
    }

    // MARK: Public methods
    public func downloaderForEntitlement(_ entitlement: DescriptionEntitlement) -> AssetDownloader {
        return AssetDownloader(url: try? paymentsAPI.url(for: .icon(name: entitlement.iconName)).url)
    }

    public func decorationsDownloaders() -> [AssetDownloader]? {
        return decorations.compactMap {
            switch $0 {
            case .starred(let decoration):
                AssetDownloader(url: try? paymentsAPI.url(for: .icon(name: decoration.iconName)).url)
            default:
                nil
            }
        }
    }

    public func purchasePlan() async {
        guard let product = product as? Product, let name = name, let plansManager = plansManager else {
            return
        }

        transactionState.send(.generatingReceipt)

        do {
            _ = try await plansManager.purchase(product, planName: name, planCycle: subscriptionPeriod.rawValue)
        } catch {
            debugPrint(error)
        }
    }

    // MARK: Private methods
    private func createFooterText(texts: [TextStyle]) {
        renewFooter = TextStylizer.composeText(texts: texts)
    }
}

extension PlanViewModel: @preconcurrency Equatable {
    public static func == (lhs: PlanViewModel, rhs: PlanViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.description == rhs.description
    }
}

extension PlanViewModel: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
