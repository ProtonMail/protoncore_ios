//
//  PaymentsDoH.swift
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
import ProtonCoreDoh

public final class PaymentsDoH: DoH, ServerConfig {
    public let signupDomain: String
    public let captchaHost: String
    public let humanVerificationV3Host: String
    public let accountHost: String
    public let defaultHost: String
    public let apiHost: String
    public let defaultPath: String
    public let proxyToken: String?

    public init(signupDomain: String,
                captchaHost: String,
                humanVerificationV3Host: String,
                accountHost: String,
                defaultHost: String,
                apiHost: String,
                defaultPath: String,
                proxyToken: String?) {
        self.signupDomain = signupDomain
        self.captchaHost = captchaHost
        self.humanVerificationV3Host = humanVerificationV3Host
        self.accountHost = accountHost
        self.defaultHost = defaultHost
        self.apiHost = apiHost
        self.defaultPath = defaultPath
        self.proxyToken = proxyToken
    }

    public convenience init() {
        self.init(signupDomain: "proton.me",
                  captchaHost: "https://some.captcha.host",
                  humanVerificationV3Host: "https://verify.proton.me",
                  accountHost: "https://verify.proton.me",
                  defaultHost: "https://some.default.host",
                  apiHost: "payments-api.proton.me",
                  defaultPath: "/api",
                  proxyToken: nil)
    }
}
