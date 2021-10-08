//
//  SignupServiceTests.swift
//  ProtonCore-Login-Tests - Created on 05.04.21.
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
@testable import ProtonCore_Login

class SignupServiceTests: XCTestCase {

    let timeout = 1.0

    // MARK: **** Validation tests ****

    func testValidationTokenRequestSuccess() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockValidationTokenOK()
        let expect = expectation(description: "expectation1")
        service.requestValidationToken(email: "test@test.ch") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testValidationTokenRequestError() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockValidationTokenError()
        let expect = expectation(description: "expectation1")
        service.requestValidationToken(email: "test@test.ch") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                break
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testValidationTokenCheckOK() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockValidationTokenCheckOK()
        let expect = expectation(description: "expectation1")
        service.checkValidationToken(email: "test@test.ch", token: "000000") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testValidationTokenCheckInvalidVerificationCode() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockValidationTokenCheckError12087()
        let expect = expectation(description: "expectation1")
        service.checkValidationToken(email: "test@test.ch", token: "000001") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .invalidVerificationCode(let message) = error else {
                    XCTFail("the error should be SignupError.invalidVerificationCode")
                    return
                }
                XCTAssertEqual(message, "Invalid verification code")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testValidationTokenCheckEmailAddressAlreadyUsed() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockValidationTokenCheckError2500()
        let expect = expectation(description: "expectation1")
        service.checkValidationToken(email: "test2@test2.ch", token: "000000") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .emailAddressAlreadyUsed = error else {
                    XCTFail("the error should be SignupError.emailAddressAlreadyUsed")
                    return
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: **** Create user tests ****

    func testCreateNewUserOk() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateUserOK()
        let expect = expectation(description: "expectation1")
        try? service.createNewUser(userName: "abc", password: "abc", deviceToken: "1234") { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUserModulusError() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockModulusError()
        let expect = expectation(description: "expectation1")
        try? service.createNewUser(userName: "abc", password: "abc", deviceToken: "1234") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUserUsersError() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockCreateUserError()
        let expect = expectation(description: "expectation1")
        try? service.createNewUser(userName: "abc", password: "abc", deviceToken: "1234") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUserUsernameAlreadyTaken() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockCreateUserError12081()
        let expect = expectation(description: "expectation1")
        try? service.createNewUser(userName: "abc", password: "abc", deviceToken: "1234") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message) = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
                XCTAssertEqual(message, "Username already taken or not allowed")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewUserInvalidInput() {
        let service = SignupService(api: apiService, challenge: PMChallenge())
        
        mockCreateUserError2001()
        let expect = expectation(description: "expectation1")
        try? service.createNewUser(userName: "abc", password: "abc", deviceToken: "1234") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message) = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
                XCTAssertEqual(message, "Invalid input")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: **** Create external user tests ****

    func testCreateNewExternalUserOk() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateExternalUserOK()
        let expect = expectation(description: "expectation1")
        try? service.createNewExternalUser(email: "test@test.ch", password: "1", deviceToken: "1234", verifyToken: "1234", completion: { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserError() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateExternalUserError()
        let expect = expectation(description: "expectation1")
        try? service.createNewExternalUser(email: "test@test.ch", password: "1", deviceToken: "1234", verifyToken: "1234", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
            }
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserEmailAddressAlreadyUsed() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateExternalUserError2500()
        let expect = expectation(description: "expectation1")
        try? service.createNewExternalUser(email: "test@test.ch", password: "1", deviceToken: "1234", verifyToken: "1234", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message) = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
                XCTAssertEqual(message, "Email address already used")
            }
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserInvalidInput() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateExternalUserError2001()
        let expect = expectation(description: "expectation1")
        try? service.createNewExternalUser(email: "test@test.ch", password: "1", deviceToken: "1234", verifyToken: "1234", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message) = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
                XCTAssertEqual(message, "Invalid input")
            }
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewExternalUserInvalidVerificationCode() {
        let service = SignupService(api: apiService, challenge: PMChallenge())

        mockCreateExternalUserError12087()
        let expect = expectation(description: "expectation1")
        try? service.createNewExternalUser(email: "test@test.ch", password: "1", deviceToken: "1234", verifyToken: "1234", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message) = error else {
                    XCTFail("the error should be SignupError.generic")
                    return
                }
                XCTAssertEqual(message, "Invalid verification code")
            }
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
