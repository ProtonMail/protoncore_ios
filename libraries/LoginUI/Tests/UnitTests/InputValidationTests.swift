//
//  InputValidationTests.swift
//  ProtonCore-Login-Tests - Created on 04/11/2020.
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

// swiftlint:disable xctfail_message

#if os(iOS)

import XCTest

import ProtonCoreChallenge
import ProtonCoreLogin
import ProtonCoreNetworking
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants
@testable import ProtonCoreLoginUI

class InputValidationTests: XCTestCase {    
    let data = CreateAddressData(email: "test@spam.la", credential: AuthCredential(LoginTestUser.credential), user: LoginTestUser.user, mailboxPassword: "123", passwordMode: .one)

    func testEmptyLoginPassword() {
        let vm = LoginViewModel(api: APIServiceMock(), login: LoginMock(), challenge: PMChallenge(), clientApp: .other(named: "core"))
        switch vm.validate(password: "") {
        case .failure(.emptyPassword):
            break
        default:
            XCTFail()
        }
    }

    func testValidLoginPassword() {
        let vm = LoginViewModel(api: APIServiceMock(), login: LoginMock(), challenge: PMChallenge(), clientApp: .other(named: "core"))
        switch vm.validate(password: "abc") {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func testValidLoginUsername() {
        let vm = LoginViewModel(api: APIServiceMock(), login: LoginMock(), challenge: PMChallenge(), clientApp: .other(named: "core"))
        switch vm.validate(username: "abc") {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func testEmptyLoginUsername() {
        let vm = LoginViewModel(api: APIServiceMock(), login: LoginMock(), challenge: PMChallenge(), clientApp: .other(named: "core"))
        switch vm.validate(username: "") {
        case .failure(.emptyUsername):
            break
        default:
            XCTFail()
        }
    }

    func testValidUsername() {
        let vm = CreateAddressViewModel(data: data, login: LoginMock(), defaultUsername: nil)
        switch vm.validate(username: "abc") {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func testEmptyUsername() {
        let vm = CreateAddressViewModel(data: data, login: LoginMock(), defaultUsername: nil)
        switch vm.validate(username: "") {
        case .failure(.emptyUsername):
            break
        default:
            XCTFail()
        }
    }
}

#endif

// swiftlint:enable xctfail_message
