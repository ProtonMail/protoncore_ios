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

import Foundation
import ProtonCorePaymentsV2
import StoreKit
import ProtonCoreUI
import Combine

public protocol PlanViewModelDelegate: AnyObject {
    func purchaseInProgress()
    func updatingAccount()
    func transactionCompleted()
}

/// Represents a purchasable plan or free instance
@MainActor
public class PlanViewModel: ObservableObject, Identifiable {

    private struct Constants {
        static func footerText(renew: Int) -> String {

            let expirationText = String(localized: "Current_plan_exipiration", bundle: .module)
            let renewalText = String(localized: "Current_plan_renewal", bundle: .module)
            
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

    public weak var delegate: PlanViewModelDelegate?

    public var showProgressEntitlements: Bool {
        !progressEntitlements.isEmpty
    }

    public var renewFooter: AttributedString?

    /// plan Decorations
    private let decorations: [Decoration]

    /// the StoreKit product to purchase
    private let product: (any ProductProtocol)?

    /// Initializer that takes an `AvailablePlan` (as returned from the API), one of its `PlanInstance`s,
    /// and the StoreKit product with matching identifier.
    /// The plan description is taken from the `AvailablePlan`. The duration and identifier com from the `PlanInstance`,
    /// and the localized price and the purchase action are derived from the `Product`

    private var cancellables = Set<AnyCancellable>()
    private let paymentsAPI: PaymentsAPIs
    private let remoteManager: RemoteManager
    private var subscriptionManager: ProtonPlansManagerProviding?

    public init(envURL: EnvURLType,
                remoteManager: RemoteManager,
                composedPlan: ComposedPlan,
                subscriptionManager: ProtonPlansManagerProviding? = nil) {

        self.paymentsAPI = PaymentsAPIs(envURL: envURL)
        self.remoteManager = remoteManager
        if let subManager = subscriptionManager {
            self.subscriptionManager = subManager
        } else {
            self.subscriptionManager = ProtonPlansManager(environment: envURL,
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
        self.name = composedPlan.plan.name
        self.progressEntitlements = progressEntitlements
        self.formattedPrice = composedPlan.product.displayPrice
        self.formattedPeriod = composedPlan.instance.description
        self.subscriptionPeriod = BillingCycle(rawValue: composedPlan.instance.cycle) ?? .all
        self.decorations = composedPlan.plan.decorations
        self.product = composedPlan.product
        self.isCurrentPlan = false
    }

    public init(envURL: EnvURLType,
                remoteManager: RemoteManager,
                currentPlan: CurrentSubscriptionResponse) {

        self.paymentsAPI = PaymentsAPIs(envURL: envURL)
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
        self.name = currentPlan.name ?? String(localized: "Current_free_plan_name", bundle: .module)
        self.progressEntitlements = progressEntitlements
        self.formattedPrice = ProtonCoreUI.Formatter.formatCurrency(amount: currentPlan.amount, currency: currentPlan.currency)
        self.formattedPeriod = currentPlan.cycleDescription ?? ""
        self.subscriptionPeriod = BillingCycle(rawValue: currentPlan.cycle ?? 0) ?? .all
        self.decorations = currentPlan.decorations
        self.isCurrentPlan = true
        self.product = nil
        if let endPeriod = currentPlan.periodEnd {
            let texts = [TextStyle(text: Constants.footerText(renew: currentPlan.renew ?? 0), font: .callout, color: Theme.color.shade80),
                         TextStyle(text: Formatter.formatDate(Double(endPeriod), formatType: .MMddYYYY), font: .headline, color: Theme.color.textNorm)]
            createFooterText(texts: texts)
        }
    }

    // MARK: Public methods
    public func iconURLforEntitlement(_ entitlement: DescriptionEntitlement) -> URL? {
        try? paymentsAPI.url(for: .icon(name: entitlement.iconName)).url
    }

    public func decorationsURLs() -> [URL]? {
        return decorations.compactMap {
            switch $0 {
            case .starred(let decoration):
                try? paymentsAPI.url(for: .icon(name: decoration.iconName)).url
            default:
                nil
            }
        }
    }

    public func purchasePlan() async {
        guard let product = product as? Product, let name = name, let subscriptionManager = subscriptionManager else {
            return
        }

        delegate?.purchaseInProgress()

        subscriptionManager.transactionStatePublisher.sink { [weak self] value in
            guard let self = self else { return }

            switch value {
            case .transactionCompleted:
                self.delegate?.transactionCompleted()
            case .createNewSubscription:
                self.delegate?.updatingAccount()
            default:
                break
            }
        }
        .store(in: &cancellables)

        do {
            try await subscriptionManager.purchase(product, planName: name, planCycle: subscriptionPeriod.rawValue)
        } catch {
            debugPrint(error)
        }
    }

    // MARK: Private methods
    private func createFooterText(texts: [TextStyle]) {
        renewFooter = TextStylizer.composeText(texts: texts)
    }
}

extension PlanViewModel: Equatable {
    public static func == (lhs: PlanViewModel, rhs: PlanViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.description == rhs.description
    }
}

extension PlanViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
