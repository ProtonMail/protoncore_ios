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
    @TrimmedRegex public var regex: String

    public enum State: Int, Codable, Equatable {
        case disabled = 0
        case enabled = 1
        case optional = 2
    }
}

/// Disallow Common Passwords
public extension PasswordPolicy {
    static let disallowCommonPasswordsPolicyName = "DisallowCommonPasswords"
    static let disallowSequencesPolicyName = "DisallowSequences"
}

@propertyWrapper
public struct TrimmedRegex: Codable, Equatable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.wrappedValue = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public static func == (lhs: TrimmedRegex, rhs: TrimmedRegex) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

#if DEBUG
public extension PasswordPolicy {
    static var atLeastXCharactersMock: PasswordPolicy {
        return .init(policyName: "AtLeastXCharacters",
                     state: .enabled,
                     requirementMessage: "At least 8 characters",
                     errorMessage: "Password must contain at least 8 characters",
                     regex: "/.{8,}/")
    }

    static var atLeastOneNumberMock: PasswordPolicy {
        return .init(policyName: "AtLeastOneNumber",
                     state: .enabled,
                     requirementMessage: "Numbers",
                     errorMessage: "Password must contain at least 1 number",
                     regex: "/[0-9]/")
    }

    static var atLeastOneSpecialCharacterMock: PasswordPolicy {
        return .init(policyName: "AtLeastOneSpecialCharacter",
                     state: .enabled,
                     requirementMessage: "Symbols (!&*)",
                     errorMessage: "Password must contain at least 1 special character (!&*)",
                     regex: "/[\\*\\.\\!\\@\\$\\%\\^\\&\\#'\\\"\\`\\(\\)\\{\\}\\[\\]\\:\\;\\<\\>\\,\\.\\?\\/\\~\\_\\+\\-\\=\\|\\\\]/")
    }

    static var atLeastOneUpperCaseAndOneLowercaseMock: PasswordPolicy {
        return .init(policyName: "AtLeastOneUpperCaseAndOneLowercase",
                     state: .enabled,
                     requirementMessage: "At least 1 uppercase and 1 lowercase letter",
                     errorMessage: "Password must contain at least 1 uppercase and 1 lowercase letter",
                     regex: "/(?=.*[a-z])(?=.*[A-Z])/")
    }

    static var disallowCommonPasswordsMock: PasswordPolicy {
        return .init(policyName: "DisallowCommonPasswords",
                     state: .enabled,
                     requirementMessage: "Something not too common",
                     errorMessage: "Password shouldn't be too common or too predictable",
                     regex: "/^(?:(?!proton|protonmail|protonvpn|protondrive|protonpass|123456|password|12345678|qwerty|123456789|12345|1234|111111|1234567|dragon|123123|baseball|abc123|football|monkey|letmein|696969|shadow|master|666666|qwertyuiop|123321|mustang|1234567890|michael|654321|pussy|superman|1qaz2wsx|7777777|fuckyou|121212|000000|qazwsx|123qwe|killer|trustno1|jordan|jennifer|zxcvbnm|asdfgh|hunter|buster|soccer|harley|batman|andrew|tigger|sunshine|iloveyou|fuckme|2000|charlie|robert|thomas|hockey|ranger|daniel|starwars|klaster|112233|george|asshole|computer|michelle|jessica|pepper|1111|zxcvbn|555555|11111111|131313|freedom|777777|pass|fuck|maggie|159753|aaaaaa|ginger|princess|joshua|cheese|amanda|summer|love|ashley|6969|nicole|chelsea|biteme|matthew|access|yankees|987654321|dallas|austin|thunder|taylor|matrix).)*$/")
    }

    static var disallowSequencesMock: PasswordPolicy {
        return .init(policyName: "DisallowSequences",
                     state: .enabled,
                     requirementMessage: "No sequences (not 123 or abc)",
                     errorMessage: "Password must not contain a sequence (not 123 or abc)",
                     regex: "/^(?:(?!(.)\\1{2}|012|123|234|345|456|567|678|789|890|210|321|432|543|654|765|876|987|098|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz).)*$/")
    }
}
#endif
