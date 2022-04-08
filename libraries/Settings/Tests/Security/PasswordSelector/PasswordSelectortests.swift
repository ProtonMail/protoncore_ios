//
//  PasswordSelectortests.swift
//  ProtonCore-Settings - Created on 02.10.2020.
//
//  Copyright (c) 2022 Proton Technologies AG
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

import XCTest
@testable import ProtonCore_Settings

final class PasswordSelectorTests: XCTestCase {
    func tests_onInit_ThereIsNoConfirmationPassword_NorInitialProposal() {
        let sut = makeSUT()

        XCTAssertNil(sut.initialPasswordProposal)
        XCTAssertNil(sut.confirmationPassword)
    }

    func test_setInitialPassword_savesInitialPasswordProposal() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")

        XCTAssertEqual(sut.initialPasswordProposal, "1234")
    }

    func test_setInitialPasswordTwice_overwritesInitialPasswordProposalValue() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setInitialPassword(to: "5678")

        XCTAssertEqual(sut.initialPasswordProposal, "5678")
    }

    func test_setConfirmationPassword_setsConfirmationPasswordProposalOnValidSameInitialPasswordProposal() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setConfirmationPassword(to: "1234")

        XCTAssertEqual(sut.confirmationPassword, "1234")
    }

    func test_setConfirmationPassword_doesNotSetPasswordIfPasswordProposalIsNotSet() throws {
        let sut = makeSUT()

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "1234"))
    }

    func test_onSetAgainInitialPasswordProposalConfirmationPasswordIsNil() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setConfirmationPassword(to: "1234")

        try sut.setInitialPassword(to: "1234")
        XCTAssertNil(sut.confirmationPassword)
    }

    func test_onSetAgainWrongInitialPasswordProposal_initialPasswordProposalIsNil() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setConfirmationPassword(to: "1234")

        XCTAssertThrowsError(try sut.setInitialPassword(to: "abc"))
        XCTAssertNil(sut.initialPasswordProposal)
    }

    func test_onSetAgainWrongConfirmationPassword_initialPasswordProposalDoesNotChange() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setConfirmationPassword(to: "1234")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "abc"))
        XCTAssertEqual(sut.initialPasswordProposal, "1234")
    }

    func test_onSetAgainWrongConfirmationPassword_previouslyValidConfirmationPasswordIsDeleted() throws {
        let sut = makeSUT()

        try sut.setInitialPassword(to: "1234")
        try sut.setConfirmationPassword(to: "1234")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "abc"))
        XCTAssertNil(sut.confirmationPassword)
    }

    func test_setInitialPasswordOnlyAcceptsSecurityPasswordPolicyDefinedValues() throws {
        let sut = makeSUT()

        XCTAssertThrowsError(try sut.setInitialPassword(to: "-1234"))
        XCTAssertNil(sut.initialPasswordProposal, "Do not accept negative numbers")

        XCTAssertThrowsError(try sut.setInitialPassword(to: "1234.0"))
        XCTAssertNil(sut.initialPasswordProposal, "Do not accept non integer numbers")

        XCTAssertThrowsError(try sut.setInitialPassword(to: "-1234.0"))
        XCTAssertNil(sut.initialPasswordProposal, "Do not accept negative numbers or non-integer")

        XCTAssertThrowsError(try sut.setInitialPassword(to: "a234"))
        XCTAssertNil(sut.initialPasswordProposal, "Do not accept letters")

        XCTAssertThrowsError(try sut.setInitialPassword(to: "😡234"))
        XCTAssertNil(sut.initialPasswordProposal, "Do not accept emoji")
    }

    func test_setConfirmationPasswordOnlyAcceptsTheSameValueAsTheInitialPasswordProposal() throws {
        let sut = makeSUT()
        let validPassword = "1234"
        try sut.setInitialPassword(to: validPassword)

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "-1234"))
        XCTAssertNil(sut.confirmationPassword, "Do not accept negative numbers")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "1234.0"))
        XCTAssertNil(sut.confirmationPassword, "Do not accept non integer numbers")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "-1234.0"))
        XCTAssertNil(sut.confirmationPassword, "Do not accept negative numbers or non-integer")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "a234"))
        XCTAssertNil(sut.confirmationPassword, "Do not accept letters")

        XCTAssertThrowsError(try sut.setConfirmationPassword(to: "😡234"))
        XCTAssertNil(sut.confirmationPassword, "Do not accept emoji")

        try sut.setConfirmationPassword(to: validPassword)
        XCTAssertEqual(sut.initialPasswordProposal, sut.confirmationPassword)
    }

    // MARK: - Helpers

    private func makeSUT() -> SecurityPasswordSelector {
        return SecurityPasswordSelector()
    }
}
