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
        let viewModel = createViewModel(doh: DohMock(), type: .username)
        mockCreateUserOK()

        let expectation = expectation(description: "Success expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                PMLog.debug("\(error)")
                XCTFail()
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewUsernameAccount_withInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .username)
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
                        expectation.fulfill()
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewUsernameAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .username)
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
                        expectation.fulfill()
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewUsernameAccount_with2FAError_failsWithInvalidStateError() {
        let viewModel = createViewModel(doh: DohMock(), type: .username)
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
                        expectation.fulfill()
                    default:
                        XCTFail()
                    }
                } else {
                    XCTFail()
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: - Create new internal user
    
    func test_createNewInternalAccount_isSuccessful() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUserOK()

        let expectation = expectation(description: "Success expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                PMLog.debug("\(error)")
                XCTFail("Should succeed")
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewInternalAccount_withCapCDisabled_isFailing() {
        FeatureFactory.shared.disable(&.externalAccountConversion)
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
        mockCreateUserOK()

        let expectation = expectation(description: "Failure expected")
        viewModel.createNewUser(userName: LoginTestUser.defaultUser.username, password: LoginTestUser.defaultUser.password, email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail("result should be .failure")
            case .failure:
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewInternalAccountInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
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
                        expectation.fulfill()
                    default:
                        XCTFail("Should fail with .invalidCredentials error")
                    }
                } else {
                    XCTFail("LoginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewInternalAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
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
                        expectation.fulfill()
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewInternalAccount_with2FAError_failsWithInvalidStateError() {
        let viewModel = createViewModel(doh: DohMock(), type: .internal)
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
                        expectation.fulfill()
                    default:
                        XCTFail(".invalidState error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: - Create new external user
    
    func test_createNewExternalAccount_isSuccessful() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUserOK()

        let expectation = expectation(description: "success expected")
        viewModel.createNewExternalAccount(email: LoginTestUser.defaultUser.username,
                                           password: LoginTestUser.defaultUser.password,
                                           verifyToken: "abc",
                                           tokenType: "test") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail(".success expected")
            }
        }
        waitForExpectations(timeout: 130) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func test_createNewExternalAccount_withCapCDisabled_isFailing() {
        FeatureFactory.shared.disable(&.externalAccountConversion)
        let viewModel = createViewModel(doh: DohMock(), type: .external)
        mockCreateExternalUserOK()

        let expectation = expectation(description: "failure expected")
        viewModel.createNewExternalAccount(email: LoginTestUser.defaultUser.username,
                                           password: LoginTestUser.defaultUser.password,
                                           verifyToken: "abc",
                                           tokenType: "test") { result in
            switch result {
            case .success:
                XCTFail(".failure expected")
            case .failure:
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 130) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_withInvalidLoginCredentials_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
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
                        expectation.fulfill()
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_withNonExistingUser_failsWithInvalidCredentialsError() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
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
                        expectation.fulfill()
                    default:
                        XCTFail(".invalidCredentials error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func test_createNewExternalAccount_with2FAError_failsWithInvalidStateError() {
        let viewModel = createViewModel(doh: DohMock(), type: .external)
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
                        expectation.fulfill()
                    default:
                        XCTFail(".invalidState error expected")
                    }
                } else {
                    XCTFail("loginError should not be nil")
                }
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
