//
//  GetPasswordPolicies.swift
//  ProtonCore-Login - Created on 29.04.25.
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

import ProtonCoreServices

/// Calls PasswordPolicies request and returns the password policies for the user
public struct GetPasswordPolicies {
    let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func invoke() async throws -> [PasswordPolicy] {
        let passwordPolicyRequest = PasswordPolicyRequest()
        let (_, result): (_, PasswordPolicyResponse) = try await apiService.perform(request: passwordPolicyRequest)

        return result.passwordPolicies
    }
}
