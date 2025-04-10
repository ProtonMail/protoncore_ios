//
//  PaymentsUIV2+Translations.swift
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
import ProtonCoreUtilities

private class Handler {}

public enum PaymentsUIV2Localizer: String, TranslationsExposing {

    public static var bundle: Bundle {
        return Bundle.module
    }

    public static var prefixForMissingValue: String = ""

    case All_cycle
    case Available_plans_section_title
    case Available_subscriptions_view_subtitle
    case Available_subscriptions_view_title
    case Current_free_plan_name
    case Current_plan_exipiration
    case Current_plan_renewal
    case Error_view_button_title
    case Error_view_message
    case Error_view_title
    case Loading_plans_message
    case Monthly_cycle
    case No_available_plan_message
    case No_available_plan_title
    case No_filtered_plan_message
    case No_filtered_plan_title
    case Plans_footer_disclaimer
    case Purchase_button_title
    case Select_plan_nav_title
    case Subscriptions_nav_title
    case Transaction_cancelled_by_user
    case Transaction_process_error
    case Transaction_state_payment_account_update_complete
    case Transaction_state_payment_account_update_progress
    case Transaction_state_payment_confirmation_complete
    case Transaction_state_payment_confirmation_progress
    case Transaction_state_view_subtitle
    case Transaction_state_view_title
    case Yearly_cycle

    public var l10n: String {
        switch self {
        case .All_cycle:
            return localized(key: self.rawValue, comment: "All billing cycles")
        case .Available_plans_section_title:
            return localized(key: self.rawValue, comment: "Available plans section title")
        case .Available_subscriptions_view_subtitle:
            return localized(key: self.rawValue, comment: "Available subscriptions view header title")
        case .Available_subscriptions_view_title:
            return localized(key: self.rawValue, comment: "Available subscriptions view header title")
        case .Current_free_plan_name:
            return localized(key: self.rawValue, comment: "Current plan name")
        case .Current_plan_exipiration:
            return localized(key: self.rawValue, comment: "Current plan expiration prefix")
        case .Current_plan_renewal:
            return localized(key: self.rawValue, comment: "Current plan renewal prefix")
        case .Error_view_button_title:
            return localized(key: self.rawValue, comment: "Payments error view button title")
        case .Error_view_message:
            return localized(key: self.rawValue, comment: "Payments error view message")
        case .Error_view_title:
            return localized(key: self.rawValue, comment: "Payments error view title")
        case .Loading_plans_message:
            return localized(key: self.rawValue, comment: "Loading screen message")
        case .Monthly_cycle:
            return localized(key: self.rawValue, comment: "Monthly billing cycles")
        case .No_available_plan_message:
            return localized(key: self.rawValue, comment: "No available plans view message")
        case .No_available_plan_title:
            return localized(key: self.rawValue, comment: "No available plans view title")
        case .No_filtered_plan_message:
            return localized(key: self.rawValue, comment: "Filtered plans empty message")
        case .No_filtered_plan_title:
            return localized(key: self.rawValue, comment: "Filtered plans empty title")
        case .Plans_footer_disclaimer:
            return localized(key: self.rawValue, comment: "Plans footer disclaimer")
        case .Purchase_button_title:
            return localized(key: self.rawValue, comment: "Purchase button title")
        case .Select_plan_nav_title:
            return localized(key: self.rawValue, comment: "Select plan navigation title")
        case .Subscriptions_nav_title:
            return localized(key: self.rawValue, comment: "Available sub navigation title")
        case .Transaction_cancelled_by_user:
            return localized(key: self.rawValue, comment: "Transaction cancelled by user")
        case .Transaction_process_error:
            return localized(key: self.rawValue, comment: "Transaction process error")
        case .Transaction_state_payment_account_update_complete:
            return localized(key: self.rawValue, comment: "Transaction account update state complete")
        case .Transaction_state_payment_account_update_progress:
            return localized(key: self.rawValue, comment: "Transaction account update state progress")
        case .Transaction_state_payment_confirmation_complete:
            return localized(key: self.rawValue, comment: "Transaction confirmation state complete")
        case .Transaction_state_payment_confirmation_progress:
            return localized(key: self.rawValue, comment: "Transaction confirmation state progress")
        case .Transaction_state_view_subtitle:
            return localized(key: self.rawValue, comment: "Transaction progress view subtitle")
        case .Transaction_state_view_title:
            return localized(key: self.rawValue, comment: "Transaction progress view title")
        case .Yearly_cycle:
            return localized(key: self.rawValue, comment: "Yearly billing cycles")
        }
    }

}
