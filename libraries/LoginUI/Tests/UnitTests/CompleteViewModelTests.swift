//
//  CompleteViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 08.04.21.
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

import XCTest
import GoLibs

import ProtonCore_ObfuscatedConstants
import ProtonCore_TestingToolkit
import ProtonCore_Log
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_FeatureSwitch
@testable import ProtonCore_LoginUI

class CompleteViewModelTests: XCTestCase {
    var authInfoRequestData: [String: Any]?
    var server: SrpServer?
    
    // MARK: - Create new username user
    
    func test_createNewUsernameAccount_isSuccessful() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .username)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserOK()

        let expectation = expectation(description: "Success expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                PMLog.debug("\(error)")
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewUsernameAccount_withInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .username)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserInvalidLoginCredentials()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewUsernameAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .username)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserNonExistingUser()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewUser(userName: "wrong user", password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewUsernameAccount_with2FAError_failsWithInvalidStateError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .username)
        _ = (authDelegate, serviceDelegate)
        mockCreateUser2FAError()

        let expectation = expectation(description: "failure with invalidState error expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidState:
                        break
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: - Create new internal user
    
    func test_createNewInternalAccount_isSuccessful() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .internal)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserOK()

        let expectation = expectation(description: "Success expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                PMLog.debug("\(error)")
                XCTFail("Should succeed")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewInternalAccountInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .internal)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserInvalidLoginCredentials()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail(".failure expected")
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail("Should fail with .invalidCredentials error")
                    }
                } else {
                    XCTFail("LoginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewInternalAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .internal)
        _ = (authDelegate, serviceDelegate)
        mockCreateUserNonExistingUser()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewUser(userName: "wrong user", password: "wrong", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewInternalAccount_with2FAError_failsWithInvalidStateError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .internal)
        _ = (authDelegate, serviceDelegate)
        mockCreateUser2FAError()

        let expectation = expectation(description: "failure with invalidState error expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidState:
                        break
                    default:
                        XCTFail(".invalidState error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: - Create new external user
    
    func test_createNewExternalAccount_isSuccessful() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .external)
        _ = (authDelegate, serviceDelegate)
        mockCreateExternalUserOK()

        let expectation = expectation(description: "success expected")
        viewModel.createNewExternalAccount(email: LoginTestUser.defaultUser.username,
                                           password: LoginTestUser.defaultUser.password,
                                           verifyToken: "abc",
                                           tokenType: "test") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail(".success expected")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 130) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_withInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .external)
        _ = (authDelegate, serviceDelegate)
        mockCreateExternalUserInvalidLoginCredentials()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewExternalAccount(email: "wrong@user", password: "wrong", verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .external)
        _ = (authDelegate, serviceDelegate)
        mockCreateExternalUserNonExistingUser()

        let expectation = expectation(description: "failure with invalidCredentials error expected")
        viewModel.createNewExternalAccount(email: LoginTestUser.defaultUser.username, password: "wrong", verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidCredentials:
                        break
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_with2FAError_failsWithInvalidStateError() {
        let (viewModel, authDelegate, serviceDelegate) = createViewModel(doh: DohMock(), type: .external)
        _ = (authDelegate, serviceDelegate)
        mockCreateExternalUser2FAError()

        let expectation = expectation(description: "Failure with invalidState error expected")
        viewModel.createNewExternalAccount(email: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, verifyToken: "abc", tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if let loginError = error as? LoginError {
                    switch loginError {
                    case .invalidState:
                        break
                    default:
                        XCTFail(".invalidState error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
