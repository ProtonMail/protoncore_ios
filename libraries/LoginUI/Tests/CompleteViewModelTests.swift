//
//  CompleteViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 08.04.21.
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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

import ProtonCore_TestingToolkit
import ProtonCore_Log
import ProtonCore_Login
import ProtonCore_Services
@testable import ProtonCore_LoginUI

class CompleteViewModelTests: XCTestCase {
    var authInfoRequestData: [String: Any]?
    var server: SrpServer?

    // MARK: Creare new internal user
    
    func testCreateNewUserSuccess() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUserOK()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                PMLog.debug("\(error)")
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUserInvalidLoginCredentials() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUserInvalidLoginCredentials()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCreateNewUserNonExistingUser() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUserNonExistingUser()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewUser(userName: "wrong user", password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUser2FAError() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUser2FAError()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidState:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: Creare new external user
    
    func testCreateNewExternalUserSuccess() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUserOK()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewExternalUser(email: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserInvalidLoginCredentials() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUserInvalidLoginCredentials()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewExternalUser(email: "wrong@user", password: "wrong", verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserNonExistingUser() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUserNonExistingUser()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewExternalUser(email: LoginTestUser.defaultUser.username, password: "wrong", verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUser2FAError() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUser2FAError()

        let expect = expectation(description: "expectation1")
        try? viewModel.createNewExternalUser(email: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidState:
                        break // all OK
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
