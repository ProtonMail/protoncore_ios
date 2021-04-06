//
//  SignupViewModelTests.swift
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

import ProtonCore_Challenge
import ProtonCore_Services
@testable import ProtonCore_Login

class SignupViewModelTests: XCTestCase {

    var viewModel: SignupViewModel!
    var signupMock: SigupMock!
    var loginMock: LoginMock!
    var deviceMock: DeviceMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        signupMock = SigupMock()
        loginMock = LoginMock()
        deviceMock = DeviceMock()
        let api = PMAPIService(doh: LiveDoHMail.default, sessionUID: ObfuscatedConstants.testSessionId)
        let authDelegate = AuthManager()
        let serviceDelegate = AnonymousServiceManager()
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        viewModel = SignupViewModel(apiService: api, signupService: signupMock, loginService: loginMock, deviceService: deviceMock, challenge: PMChallenge())
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

    func testUpdateAvailableDomain() {
        let expect = expectation(description: "expectation1")
        viewModel.updateAvailableDomain { result in
            XCTAssertEqual(result, "")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGenerateDeviceTokenSucess() {
        deviceMock.generateTokenResult = .success("test")
        let expect = expectation(description: "expectation1")
        deviceMock.generateToken { result in
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

    func testGenerateDeviceTokenError() {
        deviceMock.generateTokenResult = .failure(.deviceTokenUnsuported)
        let expect = expectation(description: "expectation1")
        deviceMock.generateToken { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, SignupError.deviceTokenUnsuported)
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCheckUserNameSuccess() {
        let expect = expectation(description: "expectation1")
        viewModel.checkUserName(username: "test") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRequestValidationTokenSuccess() {
        signupMock.requestValidationTokenResult = .success(())
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
        signupMock.requestValidationTokenResult = .failure(.validationTokenRequest)
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
