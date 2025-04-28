//
//  PasswordPolicy.swift
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation

/// `PasswordPolicy` object is the data model for the various password policies
/// that can be applied to an org (or globally).
public struct PasswordPolicy: Codable, Equatable {

    public var policyName: String
    public var state: State
    public var requirementMessage: String
    public var errorMessage: String
    public var regex: String

    public enum State: Int, Codable, Equatable {
        case enabled = 0
        case disabled = 1
        case optional = 2
    }

    public init(policyName: String,
                state: State,
                requirementMessage: String,
                errorMessage: String,
                regex: String) {
        self.policyName = policyName
        self.state = state
        self.requirementMessage = requirementMessage
        self.errorMessage = errorMessage
        self.regex = regex
    }
}

#if DEBUG
public extension PasswordPolicy {
    static var mock: PasswordPolicy {
        return .init(policyName: "AtLeastOneUpperCaseAndOneLowercase",
                     state: .optional,
                     requirementMessage: "At least 1 uppercase and 1 lowercase letter",
                     errorMessage: "Password must contain at least 1 uppercase and 1 lowercase letter",
                     regex: "/(?=.*[a-z])(?=.*[A-Z])/")
    }
}
#endif

