//
//  CheckPasswordPoliciesTests.swift
//  ProtonCore-Login-Tests - Created on 29.04.2025.
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

#if os(iOS)
import XCTest
@testable import ProtonCoreLogin

final class CheckPasswordPoliciesTests: XCTestCase {

    var sut: CheckPasswordPolicies!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CheckPasswordPolicies()
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
    }

    func testCheckPasswordPolicyEmtpyList() throws {
        let password = "12345678"

        let result = sut.invoke(passwordPolicies: [], password: password)
        XCTAssertEqual(result.isEmpty, true)
    }

    func testCheckPasswordTooShort() throws {
        let password = "123"

        let result = sut.invoke(passwordPolicies: [atLeast8CharactersPolicy()], password: password)

        let errorMessage = result.first?.0.errorMessage
        let valid = result.first?.1 as? Bool

        XCTAssertEqual(errorMessage, "Password must contain at least 8 characters")
        XCTAssertEqual(valid, false)
    }

    func testIgnoresOptionalAndDisabledPolicies() throws {
        let password = "123abcXYZ"

        let result = sut.invoke(passwordPolicies: [optionalPolicy(),
                                                   disabledPolicy(),
                                                   optionalPolicy()],
                                password: password)

        XCTAssertEqual(result.isEmpty, true)
    }

    func testFailsSomeDefaultPolicies() throws {
        let password = "123abc"

        let result = sut.invoke(passwordPolicies: [atLeast8CharactersPolicy(),
                                                   atLeastOneNumberPolicy(),
                                                   atLeastOneSpecialCharacterPolicy(),
                                                   atLeastOneUpperCaseAndOneLowercasePolicy()
                                                  ],
                                password: password)

        let valid0 = result[0].1
        XCTAssertEqual(valid0, false)

        let valid1 = result[1].1
        XCTAssertEqual(valid1, true)

        let valid2 = result[2].1
        XCTAssertEqual(valid2, false)

        let valid3 = result[3].1
        XCTAssertEqual(valid3, false)
    }

    func testPassesAllDefaultPolicies() throws {
        let password = "123abc%$@BIGLETTERS"

        let result = sut.invoke(passwordPolicies: [atLeast8CharactersPolicy(),
                                                   atLeastOneNumberPolicy(),
                                                   atLeastOneSpecialCharacterPolicy(),
                                                   atLeastOneUpperCaseAndOneLowercasePolicy(),
                                                   disallowCommonPasswordsPolicy()
                                                  ],
                                password: password)

        let valid0 = result[0].1
        XCTAssertEqual(valid0, true)

        let valid1 = result[1].1
        XCTAssertEqual(valid1, true)

        let valid2 = result[2].1
        XCTAssertEqual(valid2, true)

        let valid3 = result[3].1
        XCTAssertEqual(valid3, true)

        let valid4 = result[4].1
        XCTAssertEqual(valid4, true)
    }

    func testContainsCommonPassword() throws {
        let password = "qwertyuiop"

        let result = sut.invoke(passwordPolicies: [disallowCommonPasswordsPolicy()],
                                password: password)

        let errorMessage = result.first?.0.errorMessage
        let valid = result.first?.1 as? Bool

        XCTAssertEqual(errorMessage, "Password shouldn't be too common or too predictable")
        XCTAssertEqual(valid, false)
    }

    private func atLeast8CharactersPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastXCharacters",
                                   state: .enabled,
                                   requirementMessage: "At least 8 characters",
                                   errorMessage: "Password must contain at least 8 characters",
                                   regex: "/.{8,}/")
    }

    private func disabledPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastXCharacters",
                                   state: .disabled,
                                   requirementMessage: "At least 8 characters",
                                   errorMessage: "Password must contain at least 8 characters",
                                   regex: "/.{8,}/")
    }

    private func optionalPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastXCharacters",
                                   state: .optional,
                                   requirementMessage: "At least 8 characters",
                                   errorMessage: "Password must contain at least 8 characters",
                                   regex: "/.{8,}/")
    }

    private func atLeastOneNumberPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastOneNumber",
                                   state: .enabled,
                                   requirementMessage: "Numbers",
                                   errorMessage: "Password must contain at least 1 number",
                                   regex: "/[0-9]/")
    }

    private func atLeastOneSpecialCharacterPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastOneSpecialCharacter",
                                   state: .enabled,
                                   requirementMessage: "Symbols (!&*)",
                                   errorMessage: "Password must contain at least 1 special character (!&*)",
                                   regex: "/[\\*\\.\\!\\@\\$\\%\\^\\&\\#'\\\"\\`\\(\\)\\{\\}\\[\\]\\:\\;\\<\\>\\,\\.\\?\\/\\~\\_\\+\\-\\=\\|\\\\]/")
    }

    private func atLeastOneUpperCaseAndOneLowercasePolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "AtLeastOneUpperCaseAndOneLowercase",
                                   state: .enabled,
                                   requirementMessage: "At least 1 uppercase and 1 lowercase letter",
                                   errorMessage: "Password must contain at least 1 uppercase and 1 lowercase letter",
                                   regex: "/(?=.*[a-z])(?=.*[A-Z])/")
    }

    private func disallowCommonPasswordsPolicy() -> PasswordPolicy {
        return PasswordPolicy.init(policyName: "DisallowCommonPasswords",
                                   state: .enabled,
                                   requirementMessage: "Something not too common",
                                   errorMessage: "Password shouldn't be too common or too predictable",
                                   regex: "/^(?:(?!proton|protonmail|protonvpn|protondrive|protonpass|123456|password|12345678|qwerty|123456789|12345|1234|111111|1234567|dragon|123123|baseball|abc123|football|monkey|letmein|696969|shadow|master|666666|qwertyuiop|123321|mustang|1234567890|michael|654321|pussy|superman|1qaz2wsx|7777777|fuckyou|121212|000000|qazwsx|123qwe|killer|trustno1|jordan|jennifer|zxcvbnm|asdfgh|hunter|buster|soccer|harley|batman|andrew|tigger|sunshine|iloveyou|fuckme|2000|charlie|robert|thomas|hockey|ranger|daniel|starwars|klaster|112233|george|asshole|computer|michelle|jessica|pepper|1111|zxcvbn|555555|11111111|131313|freedom|777777|pass|fuck|maggie|159753|aaaaaa|ginger|princess|joshua|cheese|amanda|summer|love|ashley|6969|nicole|chelsea|biteme|matthew|access|yankees|987654321|dallas|austin|thunder|taylor|matrix).)*$/")
    }
}
#endif

