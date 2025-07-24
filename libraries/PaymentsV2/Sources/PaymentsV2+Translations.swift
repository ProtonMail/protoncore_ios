//
//  PaymentsV2+Translations.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

public enum PaymentsV2Localizer: String, TranslationsExposing {

    public static var bundle: Bundle {
        return Bundle.module
    }

    public static var prefixForMissingValue: String = ""

    case APIs_malformed_url_request
    case Plans_Manager_impossible_to_get_user_uuid
    case Plans_Manager_impossible_to_match_plan
    case Plans_Manager_impossible_to_restore_transactions
    case Plans_Manager_Transaction_cancelled_by_user
    case Plans_Manager_Transaction_unknown_error
    case Plans_Manager_pending_transaction_received
    case PlansComposer_unable_to_fetch_currentSub
    case Remote_manager_error
    case SK_Receipt_impossible_to_get_receipt
    case Transaction_Handler_plan_not_found
    case Transaction_Handler_repeated_purchase
    case Transaction_Handler_receipt_update_failed

    public var l10n: String {
        switch self {
        case .APIs_malformed_url_request:
            return localized(key: self.rawValue, comment: "Malformed or incorrect URL error message")
        case .Plans_Manager_impossible_to_get_user_uuid:
            return localized(key: self.rawValue, comment: "Proton Plan - impossible to get user's UUID")
        case .Plans_Manager_impossible_to_match_plan:
            return localized(key: self.rawValue, comment: "Proton Plan not found in Apple Store plans")
        case .Plans_Manager_impossible_to_restore_transactions:
            return localized(key: self.rawValue, comment: "Proton Plan - Impossible to restore transactions")
        case .Plans_Manager_Transaction_cancelled_by_user:
            return localized(key: self.rawValue, comment: "Proton Plan - transaction cancelled by the user")
        case .Plans_Manager_Transaction_unknown_error:
            return localized(key: self.rawValue, comment: "Proton Plan - unknown transaction error")
        case .Plans_Manager_pending_transaction_received:
            return localized(key: self.rawValue, comment: "Proton Plan - unexpected pending transaction")
        case .PlansComposer_unable_to_fetch_currentSub:
            return localized(key: self.rawValue, comment: "Plans manager get current sub fail")
        case .Remote_manager_error:
            return localized(key: self.rawValue, comment: "Remote data deconding error")
        case .SK_Receipt_impossible_to_get_receipt:
            return localized(key: self.rawValue, comment: "StoreKitManager get receipt fail")
        case .Transaction_Handler_plan_not_found:
            return localized(key: self.rawValue, comment: "TransactionHandler - impossible to find plan's name")
        case .Transaction_Handler_repeated_purchase:
            return localized(key: self.rawValue, comment: "TransactionHandler - repeated purchase, or renewal attempted")
        case .Transaction_Handler_receipt_update_failed:
            return localized(key: self.rawValue, comment: "TransactionHandler - receipt refresh failed")
        }
    }
}
