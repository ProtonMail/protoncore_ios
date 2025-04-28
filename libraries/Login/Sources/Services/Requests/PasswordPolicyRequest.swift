//
//  PasswordPolicyRequest.swift
//  ProtonCore-Login - Created on 28.04.25.
//
//  Copyright (c) 2025 Proton Technologies AG
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

import ProtonCoreNetworking

public final class PasswordPolicyResponse: Response, APIDecodableResponse, Encodable {
    var passwordPolicies: [PasswordPolicy]
}

public final class PasswordPolicyRequest: Request {
    public var path: String {
        return "/core/v4/password-policies"
    }

    public let isAuth: Bool = false

    public let method: HTTPMethod = .get
}
