//
//  EmailVerificationViewModelTests.swift
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
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_LoginUI

class EmailVerificationViewModelTests: XCTestCase {

    var viewModel: EmailVerificationViewModel!
    var signupMock: SigupMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        let api = PMAPIService(doh: DohMock())
        let authDelegate = AuthHelper()
        let serviceDelegate = AnonymousServiceManager()
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        signupMock = SigupMock()
        viewModel = EmailVerificationViewModel(apiService: api, signupService: signupMock)
    }

    func testValidCodeFormat() throws {
        XCTAssertEqual(viewModel.isValidCodeFormat(code: ""), false)
        XCTAssertEqual(viewModel.isValidCodeFormat(code: "123"), false)
        XCTAssertEqual(viewModel.isValidCodeFormat(code: "12345"), false)
        XCTAssertEqual(viewModel.isValidCodeFormat(code: "1234567"), false)
        XCTAssertEqual(viewModel.isValidCodeFormat(code: "123456"), true)
    }
    
    func testRequestValidationTokenSuccess() throws {
        signupMock.requestValidationTokenResult = .success(())
        let expect = expectation(description: "expectation1")
        viewModel.email = "test@test.ch"
        viewModel.requestValidationToken { result in
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

    func testRequestValidationTokenError() throws {
        signupMock.requestValidationTokenResult = .failure(.validationTokenRequest)
        let expect = expectation(description: "expectation1")
        viewModel.email = "test@test.ch"
        viewModel.requestValidationToken { result in
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
    
    func testCheckValidationTokenSuccess() throws {
        signupMock.checkValidationTokenResult = .success(())
        let expect = expectation(description: "expectation1")
        viewModel.checkValidationToken(email: "test@test.ch", token: "123456") { result in
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

    func testCheckValidationTokenError() throws {
        signupMock.checkValidationTokenResult = .failure(.validationToken)
        let expect = expectation(description: "expectation1")
        viewModel.checkValidationToken(email: "test@test.ch", token: "123456") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .validationToken)
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetResendMessageSuccess() {
        viewModel.email = "test@test.ch"
        XCTAssertNotNil(viewModel.getResendMessage())
    }

    func testGetResendMessageError() {
        viewModel.email = nil
        XCTAssertNil(viewModel.getResendMessage())
    }
}
