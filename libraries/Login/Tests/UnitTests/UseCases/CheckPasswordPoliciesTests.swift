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
        return PasswordPolicy.atLeastOneNumberMock
    }

    private func atLeastOneSpecialCharacterPolicy() -> PasswordPolicy {
        return PasswordPolicy.atLeastOneSpecialCharacterMock
    }

    private func atLeastOneUpperCaseAndOneLowercasePolicy() -> PasswordPolicy {
        return PasswordPolicy.atLeastOneUpperCaseAndOneLowercaseMock
    }

    private func disallowCommonPasswordsPolicy() -> PasswordPolicy {
        return PasswordPolicy.disallowCommonPasswordsMock
    }
}
#endif

