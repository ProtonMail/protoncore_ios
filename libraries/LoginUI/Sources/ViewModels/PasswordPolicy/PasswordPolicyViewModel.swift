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
import ProtonCoreNetworking
import ProtonCoreServices
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

        private var getPasswordPoliciesUseCase: GetPasswordPolicies?
        private var checkPasswordPoliciesUseCase: CheckPasswordPolicies = CheckPasswordPolicies()
        private var apiService: APIService?

        private var passwordPolicies: [PasswordPolicy] = []
        private var evaluatedPasswordPolicies: [(PasswordPolicy, Bool)]

        public init(apiService: APIService?) {
            exceptionalErrorMessage = nil
            requirementsList = []

            if let apiService = apiService {
                self.apiService = apiService
                getPasswordPoliciesUseCase = GetPasswordPolicies(apiService: apiService)
            }


            self.evaluatedPasswordPolicies = []
        }

        public func loadPasswordPolicies() {
            guard let getPasswordPoliciesUseCase = self.getPasswordPoliciesUseCase else {
                return
            }

            Task {
                do {
                    self.passwordPolicies = try await getPasswordPoliciesUseCase.invoke()
                } catch {
                    // Observability?
                }
            }
        }

        // Returns `true` if all requirements are satisfied, `false` otherwise.
        // Updates `exceptionalErrorMessage` and `requirementsList`.
        public func checkPassword(_ password: String) -> Bool {
            self.evaluatedPasswordPolicies = checkPasswordPoliciesUseCase.invoke(
                passwordPolicies: self.passwordPolicies,
                password: password
            )

            let unsatisfiedPolicies = self.evaluatedPasswordPolicies.filter { (policy, valid) in
                !valid
            }

            // Filter for only the invalid "exceptional" policies-- the policies which are displayed in
            // red above the list of standard policies.
            let unsatisfiedExceptionalPolicies = unsatisfiedPolicies.filter { (policy, valid) in
                Self.exceptionalPolicyNames.contains(policy.policyName) && !valid
            }

            exceptionalErrorMessage = unsatisfiedExceptionalPolicies.first?.0.errorMessage

            // Filter for the standard policies which will be displayed in a list containing both
            // satisfied and unsatisfied requirements.
            let standardPolicies = self.evaluatedPasswordPolicies.filter { (policy, _) in
                !Self.exceptionalPolicyNames.contains(policy.policyName)
            }

            var newRequirementsList = [BulletedListItem]()
            var requirementsSatisfied = true
            for standardPolicy in standardPolicies {
                let listItem = BulletedListItem(text: standardPolicy.0.requirementMessage,
                                                struck: standardPolicy.1)
                newRequirementsList.append(listItem)

                requirementsSatisfied = requirementsSatisfied && standardPolicy.1
            }
            requirementsList = newRequirementsList

            return requirementsSatisfied && (exceptionalErrorMessage == nil)
        }
    }

    public struct BulletedListItem: Identifiable, Hashable {
        public let id = UUID()
        let text: String
        let struck: Bool
    }
}

#endif

