//
//  PasswordPolicyViewModel.swift
//  ProtonCore-LoginUI - Created on 06/05/2025.
//
//  Copyright (c) 2025 Proton AG
//
//  This file is part of ProtonCore.
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

#if os(iOS)

import ProtonCoreUIFoundations
import ProtonCoreLogin
import ProtonCoreLog
import SwiftUI

extension PasswordPolicyView {
    @MainActor
    public class ViewModel: ObservableObject {
        // Error message for the first unsatisfied exceptional policy (if any, nil otherwise)
        @Published var exceptionalErrorMessage: String?

        // List of requirement messages with Booleans indicating if satisfied or not
        @Published var requirementsList: [BulletedListItem]

        // The names of the exceptional policies that are shown separate from standard password policies.
        private static let exceptionalPolicyNames = [
            PasswordPolicy.disallowCommonPasswordsPolicyName,
            PasswordPolicy.disallowSequencesPolicyName
        ]

        private var passwordPolicies: [(PasswordPolicy, Bool)] = []

        public init(passwordPolicies: [(PasswordPolicy, Bool)]) {
            exceptionalErrorMessage = nil
            requirementsList = []

            self.passwordPolicies = passwordPolicies

            constructStrings()
        }

        func constructStrings() {
            let unsatisfiedExceptionalPolicies = passwordPolicies.filter { (policy, valid) in
                Self.exceptionalPolicyNames.contains(policy.policyName) && !valid
            }

            exceptionalErrorMessage = unsatisfiedExceptionalPolicies.first?.0.errorMessage

            // Filter out only the "exceptional" policies-- the policies which are displayed in
            // red above the list of standard policies.
            let standardPolicies = passwordPolicies.filter { (policy, _) in
                !Self.exceptionalPolicyNames.contains(policy.policyName)
            }

            // Construct the list of requirements for the standard policies.
            for standardPolicy in standardPolicies {
                let listItem = BulletedListItem(text: standardPolicy.0.requirementMessage,
                                                struck: standardPolicy.1)
                requirementsList.append(listItem)
            }
        }
    }

    public struct BulletedListItem: Identifiable, Hashable {
        public let id = UUID()
        let text: String
        let struck: Bool
    }
}

#endif

