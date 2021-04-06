//
//  PasswordViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 09.04.21.
//
//  Copyright (c) 2019 Proton Technologies AG
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

// swiftlint:disable xctfail_message

import XCTest

@testable import ProtonCore_Login

class PasswordViewModelTests: XCTestCase {

    func testPasswordOK1() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "a", repeatParrword: "a")
        switch result {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }

    func testPasswordOK2() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "fhhjdhjdhjdhjhdjhddssaww@#$", repeatParrword: "fhhjdhjdhjdhjhdjhddssaww@#$")
        switch result {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }
    
    func testPasswordEmpty() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "", repeatParrword: "")
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .passwordEmpty)
        }
    }

    func testPasswordNotEqual1() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "aa", repeatParrword: "bb")
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .passwordNotEqual)
        }
    }

    func testPasswordNotEqual2() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "", repeatParrword: "bb")
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .passwordNotEqual)
        }
    }

    func testPasswordNotEqual3() throws {
        let viewModel = PasswordViewModel()
        let result = viewModel.passwordValidationResult(for: .notEmpty, password: "c", repeatParrword: "")
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .passwordNotEqual)
        }
    }
}
