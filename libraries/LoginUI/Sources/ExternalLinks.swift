//
//  ExternalLinks.swift
//  ProtonCore-Login - Created on 15.12.2020.
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

import Foundation
import ProtonCoreDataModel

public final class ExternalLinks {
    let clientApp: ClientApp

    public init(clientApp: ClientApp) {
        self.clientApp = clientApp
    }

    public var passwordReset: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://account.protonvpn.com/reset-password?ref=ios")!
        default:
            return URL(string: "https://account.proton.me/reset-password")!
        }
    }

    public var accountSetup: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://account.protonvpn.com?ref=ios")!
        default:
            return URL(string: "https://account.proton.me/")!
        }
    }

    public var termsAndConditions: URL {
        switch clientApp {
        case .wallet:
            return URL(string: "https://proton.me/legal/wallet/terms")!
        default:
            return URL(string: "https://proton.me/legal/terms-ios")!
        }
    }

    public var privacyPolicy: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://protonvpn.com/privacy-policy?ref=ios")!
        case .meet:
            return URL(string: "https://proton.me/meet/privacy-policy?ref=ios")!
        default:
            return URL(string: "https://proton.me/wallet/privacy-policy")!
        }
    }

    public var support: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://protonvpn.com/support?ref=ios")!
        default:
            return URL(string: "https://proton.me/support/contact")!
        }
    }

    public var commonLoginProblems: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://protonvpn.com/support/login-problems?ref=ios")!
        default:
            return URL(string: "https://proton.me/support/common-login-problems")!
        }
    }

    public var forgottenUsername: URL {
        switch clientApp {
        case .vpn:
            return URL(string: "https://account.protonvpn.com/forgot-username?ref=ios")!
        default:
            return URL(string: "https://account.proton.me/forgot-username")!
        }
    }

    public var learnMoreAboutExternalAccountsNotSupported: URL {
        URL(string: "https://proton.me/support/external-accounts")!
    }

    public var certifiedNoLogsVPN: URL {
        URL(string: "https://protonvpn.com/blog/no-logs-audit?ref=ios")!
    }
}

#endif
