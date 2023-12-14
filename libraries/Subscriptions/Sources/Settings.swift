//
//  Settings.swift
//  ProtonCore-Subscriptions - Created on 03.10.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation
import StoreKit
import ProtonCoreFeatureSwitch
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreUtilities

private class Handler {}

/// Describes the possible management actions that can be done with a user subscription (or lack thereof)
public enum SubscriptionCTA: TranslationsExposing {
    public var l10n: String {
        assertionFailure("You're not supposed to localize this enum directly. Please use the title, description, buttonText properties instead.")
        return ""
    }

    public static var bundle: Bundle {
#if SPM
        return Bundle.module
#else
        return Bundle(path: Bundle(for: Handler.self).path(forResource: "Translations-Subscriptions", ofType: "bundle")!)!
#endif
    }

    public static var prefixForMissingValue: String = ""

    /// the user can upgrade to a paid subscription
    case upgrade
    /// the user can cancel the current IAP subscription
    case manageSubscription
    /// the user can't manage the current subscription as it's not IAP
    case cannotManageSubscription

    /// A suitable display string for the Settings item's title
    public var title: String {
        switch self {
        case .upgrade: return localized(key: "pmsettings-settings-system-settings-upgrade-subscription-title", comment: "Title for setting item to upgrade subscription")
        case .manageSubscription:
            return localized(key: "pmsettings-settings-system-settings-manage-subscription-title", comment: "Title for setting item to manage subscriptions")
        case .cannotManageSubscription:
            return localized(key: "pmsettings-settings-system-settings-cannot-manage-subscription-title", comment: "Title for setting item that explains subscriptions can't be managed from mobile")
        }
    }

    /// A suitable display string for the Settings item's description
    public var description: String {
        switch self {
        case .upgrade: return localized(key: "pmsettings-settings-system-settings-upgrade-subscription-description", comment: "Title for setting item to upgrade subscription")
        case .manageSubscription:
            return localized(key: "pmsettings-settings-system-settings-manage-subscription-description", comment: "description for setting item to manage subscription")
        case .cannotManageSubscription:
            return localized(key: "pmsettings-settings-system-settings-cannot-manage-subscription-description", comment: "description for setting item that explains subscriptions can't be managed from mobile")
        }
    }

    /// A suitable display string for the Settings item's link or button
    public var buttonText: String {
        switch self {
        case .upgrade: return localized(key: "pmsettings-settings-system-settings-upgrade-subscription-button", comment: "Title for setting item to manage subscriptions")
        case .manageSubscription:
            return localized(key: "pmsettings-settings-system-settings-manage-subscription-button", comment: "Description for setting item to manage subscriptions")
        case .cannotManageSubscription:
            return "" // N/A
        }
    }

    /// A closure that will invoke the appropriate action, if any
    public var action: ((PaymentsUI) -> Void) {
        switch self {
        case .upgrade: return upgradeSubscription
        case .manageSubscription: return manageSubscriptions
        case .cannotManageSubscription: return { _ in }
        }
    }

    private func manageSubscriptions(paymentWrapper: (PaymentsUI)) {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else {
            return
        }

        if #available(iOS 15.0, *) {
            if let currentScene = UIApplication.shared.windows.first?.windowScene {
                Task {
                    try? await AppStore.showManageSubscriptions(in: currentScene)
                }
            }
        } else {
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    private func upgradeSubscription(paymentWrapper: (PaymentsUI)) {
        paymentWrapper.showUpgradePlan(presentationType: .modal, backendFetch: true) { _ in }
    }
}

/// Provides descriptions and actions for implementing subscription management in the settings section
public class SubscriptionSettingsProvider {
    public static func appropriateCTA(for subscription: CurrentPlan.Subscription) -> SubscriptionCTA {
        guard let paymentMethod = subscription.external else {
            return .upgrade
        }
        guard paymentMethod == .apple else { return .cannotManageSubscription }
        return .manageSubscription
    }
}
