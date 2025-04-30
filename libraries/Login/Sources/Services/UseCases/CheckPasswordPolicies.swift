//
//  CheckPasswordPolicies.swift
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

import Foundation

import ProtonCoreLog

public struct CheckPasswordPolicies {

    public init() {}

    // Returns an array of tuples, (PasswordPolicy, Bool) in the same order as input
    // `passwordPolicies`, excluding any disabled or optional policies.
    // The boolean is true if the supplied `password` respects a given policy,
    // false otherwise.
    public func invoke(
        passwordPolicies: [PasswordPolicy],
        password: String
    ) -> [(PasswordPolicy, Bool)] {
        guard !passwordPolicies.isEmpty else { return [] }

        var result: [(PasswordPolicy, Bool)] = []
        for passwordPolicy in passwordPolicies {
            if passwordPolicy.state == .enabled {
                result.append((passwordPolicy, password.matches(passwordPolicy.regex)))
            }
        }

        return result
    }
}

extension String {
    func matches(_ pattern: String) -> Bool {
        do {
            let regex = try Regex(pattern)
            return self.firstMatch(of: regex) != nil
        } catch {
            PMLog.debug("Invalid regex pattern: \(error)")
            return false
        }
    }
}
