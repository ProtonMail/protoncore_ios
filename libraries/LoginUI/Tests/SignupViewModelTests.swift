//
//  SignupViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 09.04.21.
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

import ProtonCore_Authentication
import ProtonCore_Challenge
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_LoginUI

class SignupViewModelTests: XCTestCase {

    var viewModel: SignupViewModel!
    var signupServiceMock: SignupServiceMock!
    var loginMock: LoginMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        signupServiceMock = SignupServiceMock()
        loginMock = LoginMock()
        let api = PMAPIService(doh: DohMock())
        let authDelegate = AuthHelper()
        let serviceDelegate = AnonymousServiceManager()
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        viewModel = SignupViewModel(apiService: api, signupService: signupServiceMock, loginService: loginMock, challenge: PMChallenge(), humanVerificationVersion: .v3)
    }

    func testIsUserNameValid() throws {
        XCTAssertEqual(viewModel.isUserNameValid(name: ""), false)
        XCTAssertEqual(viewModel.isUserNameValid(name: "wwewwqqw"), true)
        XCTAssertEqual(viewModel.isUserNameValid(name: "12345_adad"), true)
    }

    func testIsEmailValid() {
        XCTAssertEqual(viewModel.isEmailValid(email: ""), false)
        XCTAssertEqual(viewModel.isEmailValid(email: "123"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: "1111@"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: "sadsds@kjdk"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: "aaa.ch"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: ".ch"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: "jahja/aa"), false)
        XCTAssertEqual(viewModel.isEmailValid(email: ".test@test.ch"), false)
    }

    func testUpdateAvailableDomainWhenSingleDomain() {
        loginMock.updateAvailableDomainStub.bodyIs { _, _, result in
            result(["test"])
        }
        loginMock.updateAvailableDomainStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.updateAvailableDomain { result in
            XCTAssertEqual(result, ["test"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testUpdateAvailableDomainWhenMultipleDomains() {
        loginMock.updateAvailableDomainStub.bodyIs { _, _, result in
            result(["test", "test2", "test3"])
        }
        loginMock.updateAvailableDomainStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.updateAvailableDomain { result in
            XCTAssertEqual(result, ["test", "test2", "test3"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCheckUsernameWithoutDomainSuccess() {
        loginMock.checkAvailabilityForUsernameAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForUsernameAccountStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.checkUsernameAccount(username: "test") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCheckUsernameWithDomainSuccess() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.checkInternalAccount(username: "test") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRequestValidationTokenSuccess() {
        signupServiceMock.requestValidationTokenResult = .success(())
        let expect = expectation(description: "expectation1")
        viewModel.requestValidationToken(email: "test@test.ch") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRequestValidationTokenError() {
        signupServiceMock.requestValidationTokenResult = .failure(.validationTokenRequest)
        let expect = expectation(description: "expectation1")
        viewModel.requestValidationToken(email: "test@test.ch") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .validationTokenRequest)
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
