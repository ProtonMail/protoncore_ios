//
//  SignupServiceTests.swift
//  ProtonCore-Login-Tests - Created on 05.04.21.
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
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#endif
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreLogin

class SignupServiceTests: XCTestCase {

    let timeout = 1.0

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    // MARK: **** Validation tests ****

    func testValidationTokenRequestSuccess() {
        let service = SignupService(api: apiService, clientApp: .mail)

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
        let service = SignupService(api: apiService, clientApp: .mail)

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
        let service = SignupService(api: apiService, clientApp: .mail)

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
        let service = SignupService(api: apiService, clientApp: .mail)

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
        let service = SignupService(api: apiService, clientApp: .mail)

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

    // MARK: **** Create username account tests ****

    func testCreateNewUsernameAccountOk() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateUsernameAccountOK()
        let expect = expectation(description: "expectation1")
        service.createNewUsernameAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil) { result in
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

    func testCreateNewUsernameAccountModulusError() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockModulusError()
        let expect = expectation(description: "expectation1")
        service.createNewUsernameAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil) { result in
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

    func testCreateNewUsernameAccountUsersError() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateUsernameAccountError()
        let expect = expectation(description: "expectation1")
        service.createNewUsernameAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil) { result in
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

    func testCreateNewUsernameAccountUsernameAlreadyTaken() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateUsernameAccountError12081()
        let expect = expectation(description: "expectation1")
        service.createNewUsernameAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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

    func testCreateNewUsernameAccountInvalidInput() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateUsernameAccountError2001()
        let expect = expectation(description: "expectation1")
        service.createNewUsernameAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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

    // MARK: **** Create internal account tests ****

    func testCreateNewInternalAccountOk() {
        let service = SignupService(api: apiService, clientApp: .mail)
        let domain = "proton.test"
        mockCreateInternalAccountOK(username: "abc", domain: domain)
        let expect = expectation(description: "expectation1")
        service.createNewInternalAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil, domain: domain) { result in
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

    func testCreateNewInternalAccountModulusError() {
        let service = SignupService(api: apiService, clientApp: .mail)
        let domain = "proton.test"
        mockModulusErrorWithParseDomain(username: "abc", domain: domain)
        let expect = expectation(description: "expectation1")
        service.createNewInternalAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil, domain: domain) { result in
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

        waitForExpectations(timeout: 10.0) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateNewInternalAccountUsersError() {
        let service = SignupService(api: apiService, clientApp: .mail)
        let domain = "proton.test"
        mockCreateInternalAccountError(username: "abc", domain: domain)
        let expect = expectation(description: "expectation1")
        service.createNewInternalAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil, domain: domain) { result in
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

    func testCreateNewInternalAccountUsernameAlreadyTaken() {
        let service = SignupService(api: apiService, clientApp: .mail)
        let domain = "proton.test"
        mockCreateInternalAccountError12081(username: "abc", domain: domain)
        let expect = expectation(description: "expectation1")
        service.createNewInternalAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil, domain: domain) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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

    func testCreateNewInternalAccountInvalidInput() {
        let service = SignupService(api: apiService, clientApp: .mail)
        let domain = "proton.test"
        mockCreateInternalAccountError2001(username: "abc", domain: domain)
        let expect = expectation(description: "expectation1")
        service.createNewInternalAccount(userName: "abc", password: "abc", email: nil, phoneNumber: nil, domain: domain) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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

    func testCreateNewExternalAccountOk() {
        let service = SignupService(api: apiService, clientApp: .mail)
        mockCreateExternalUserOK()
        let expect = expectation(description: "expectation1")
        service.createNewExternalAccount(email: "test@test.ch", password: "1", verifyToken: "1234", tokenType: "test", completion: { result in
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

    func testCreateNewExternalAccountError() {
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateExternalUserError()
        let expect = expectation(description: "expectation1")
        service.createNewExternalAccount(email: "test@test.ch", password: "1", verifyToken: "1234", tokenType: "test", completion: { result in
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
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateExternalUserError2500()
        let expect = expectation(description: "expectation1")
        service.createNewExternalAccount(email: "test@test.ch", password: "1", verifyToken: "1234", tokenType: "test", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateExternalUserError2001()
        let expect = expectation(description: "expectation1")
        service.createNewExternalAccount(email: "test@test.ch", password: "1", verifyToken: "1234", tokenType: "test", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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
        let service = SignupService(api: apiService, clientApp: .mail)

        mockCreateExternalUserError12087()
        let expect = expectation(description: "expectation1")
        service.createNewExternalAccount(email: "test@test.ch", password: "1", verifyToken: "1234", tokenType: "test", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard case .generic(let message, _, _) = error else {
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

    func testValidEmailSuccess() {
        let apiService = APIServiceMock()
        let service = SignupService(api: apiService, clientApp: .mail)

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/validate/email") {
                completion(nil, .success(["Code": 1000]))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expect = expectation(description: "expectation1")
        service.validateEmailServerSide(email: "test@test.ch", completion: { result in
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

    func testValidEmailInvalidInput() {
        let apiService = APIServiceMock()
        let service = SignupService(api: apiService, clientApp: .mail)
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/validate/email") {
                let error = """
                    {
                        "Code": 2050,
                        "Error": "Email address failed validation",
                        "ErrorDescription": "",
                        "Details": {
                            "[Email]": [
                                "Email address failed validation"]
                        }
                    }
                """
                let errorDict = try? JSONSerialization.jsonObject(with: error.data(using: .utf8)!, options: []) as? [String: Any]
                completion(nil, .success(errorDict!))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expect = expectation(description: "expectation1")
        service.validateEmailServerSide(email: "invalid email", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case .generic(let message, let code, _) = error {
                    XCTAssertEqual(message, "Email address failed validation")
                    XCTAssertEqual(code, 2050)
                } else {
                    XCTFail()
                }
                expect.fulfill()
            }
        })
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testValidPhoneNumberSuccess() {
        let apiService = APIServiceMock()
        let service = SignupService(api: apiService, clientApp: .mail)

        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/validate/phone") {
                completion(nil, .success(["Code": 1000]))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expect = expectation(description: "expectation1")
        service.validatePhoneNumberServerSide(number: "+4100000000", completion: { result in
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

    func testValidPhoneNumberInvalidInput() {
        let apiService = APIServiceMock()
        let service = SignupService(api: apiService, clientApp: .mail)
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/core/v4/validate/phone") {
                let error = """
                    {
                        "Code": 2058,
                        "Error": "Phone number failed validation",
                        "ErrorDescription": "",
                        "Details": {
                            "[Phone]": [
                                "Phone number failed validation"]
                        }
                    }
                """
                let errorDict = try? JSONSerialization.jsonObject(with: error.data(using: .utf8)!, options: []) as? [String: Any]
                completion(nil, .success(errorDict!))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let expect = expectation(description: "expectation1")

        service.validatePhoneNumberServerSide(number: "invalid number", completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case .generic(let message, let code, _) = error {
                    XCTAssertEqual(message, "Phone number failed validation")
                    XCTAssertEqual(code, 2058)
                } else {
                    XCTFail()
                }
                expect.fulfill()
            }
        })
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}

#endif

// swiftlint:enable xctfail_message
