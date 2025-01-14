//
//  Login+Translations.swift
//  ProtonCoreLogin - Created on 01/08/2023.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCoreUtilities

private class Handler {}

public enum LSTranslation: TranslationsExposing {

    public static var bundle: Bundle {
        return Bundle.module
    }

    public static var prefixForMissingValue: String = ""

    case _loginservice_api_might_be_blocked_message
    case _loginservice_error_generic
    case _loginservice_external_accounts_not_supported_popup_local_desc
    case _loginservice_external_accounts_address_required_popup_title
    case _sso_code_doesnt_match
    case _sso_invalid_code
    case _sso_device_secret_not_found

    case errorUpdatePasswordDefault

    public var l10n: String {
        switch self {
        case ._loginservice_api_might_be_blocked_message:
            return localized(key: "The Proton servers are unreachable. It might be caused by wrong network configuration, Proton servers not working or Proton servers being blocked", comment: "Message shown when we suspect that the Proton servers are blocked")
        case ._loginservice_error_generic:
            return localized(key: "An error has occured", comment: "Generic error message when no better error can be displayed")
        case ._loginservice_external_accounts_not_supported_popup_local_desc:
            return localized(key: "Get a Proton Mail address linked to this account in your Proton web settings.", comment: "External accounts not supported popup local desc")
        case ._loginservice_external_accounts_address_required_popup_title:
            return localized(key: "Proton address required", comment: "External accounts address required popup title")
        case ._sso_code_doesnt_match:
            return localized(key: "Code doesn't match", comment: "SSO error displayed when the confirmation code introduced (in device B) does not match with the one in the device A")
        case ._sso_invalid_code:
            return localized(key: "Code isn't valid", comment: "SSO error displayed when the confirmation code is invalid (e.g. wrong length)")
        case ._sso_device_secret_not_found:
            return localized(key: "Device secret not found", comment: "SSO error displayed when there was an error while validating the code")
        case .errorUpdatePasswordDefault:
            return localized(key: "Password update failed", comment: "Error message")
        }
    }
}
