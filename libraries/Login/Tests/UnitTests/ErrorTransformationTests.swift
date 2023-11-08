//
//  ErrorTransformationTests.swift
//  ProtonCore-Login-Unit-Tests - Created on 28/05/2021.
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

import XCTest

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCryptoGoInterface
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreServices
@testable import ProtonCoreLogin

final class ErrorTransformationTests: XCTestCase {

    final class TestError: NSError {
        init(message: String, code: Int) { super.init(domain: "SessionTests", code: code, userInfo: [NSLocalizedDescriptionKey: message]) }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    let apiBlockedError = ResponseError(
        httpCode: nil, responseCode: nil, userFacingMessage: nil,
        underlyingError: NSError.protonMailError(
            APIErrorCode.potentiallyBlocked, localizedDescription: LSTranslation._loginservice_api_might_be_blocked_message.l10n
        )
    )

    let testError = TestError(message: "test message", code: 0)

    func testAuthErrorToLoginErrorTransformation() {
        XCTAssertEqual(
            AuthErrors.apiMightBeBlocked(message: "test message", originalError: apiBlockedError).asLoginError(),
            LoginError.apiMightBeBlocked(message: "test message", originalError: apiBlockedError)
        )

        let testGenericResponseError = ResponseError(httpCode: 412, responseCode: 123_456, userFacingMessage: "test response error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(testGenericResponseError).asLoginError(),
            LoginError.generic(message: "test response error", code: 123_456, originalError: testGenericResponseError)
        )

        let invalidAccessTokenError = ResponseError(httpCode: 401, responseCode: 123_456, userFacingMessage: "test access token error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(invalidAccessTokenError).asLoginError(),
            LoginError.invalidAccessToken(message: "test access token error")
        )

        let invalid2FAOrCredentialsError = ResponseError(httpCode: 402, responseCode: 8002, userFacingMessage: "test 2fa or credentials error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(invalid2FAOrCredentialsError).asLoginError(),
            LoginError.invalidCredentials(message: "test 2fa or credentials error")
        )
        XCTAssertEqual(
            AuthErrors.networkingError(invalid2FAOrCredentialsError).asLoginError(in2FAContext: true),
            LoginError.invalid2FACode(message: "test 2fa or credentials error")
        )

        func verifyIsGeneric(_ authError: AuthErrors, originalError: Error? = nil) {
            XCTAssertEqual(
                authError.asLoginError(),
                LoginError.generic(message: authError.localizedDescription, code: authError.codeInNetworking, originalError: originalError ?? authError)
            )
        }

        verifyIsGeneric(.emptyAuthInfoResponse)
        verifyIsGeneric(.emptyAuthResponse)
        verifyIsGeneric(.emptyServerSrpAuth)
        verifyIsGeneric(.emptyClientSrpAuth)
        verifyIsGeneric(.emptyUserInfoResponse)
        verifyIsGeneric(.wrongServerProof)
        verifyIsGeneric(.addressKeySetupError(testError), originalError: testError)
        verifyIsGeneric(.parsingError(testError), originalError: testError)
        verifyIsGeneric(.notImplementedYet("test message"))
    }

    func testAuthErrorToAvailabilityErrorTransformation() {

        XCTAssertEqual(
            AuthErrors.apiMightBeBlocked(message: "test message", originalError: apiBlockedError).asAvailabilityError(),
            AvailabilityError.apiMightBeBlocked(message: "test message", originalError: apiBlockedError)
        )

        let testGenericResponseError = ResponseError(httpCode: 412, responseCode: 123_456, userFacingMessage: "test response error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(testGenericResponseError).asAvailabilityError(),
            AvailabilityError.generic(message: "test response error", code: 123_456, originalError: testGenericResponseError)
        )

        let notAvailableError = ResponseError(httpCode: 401, responseCode: 2500, userFacingMessage: "test not available error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(notAvailableError).asAvailabilityError(),
            AvailabilityError.notAvailable(message: "test not available error")
        )

        func verifyIsGeneric(_ authError: AuthErrors, originalError: Error? = nil) {
            XCTAssertEqual(
                authError.asAvailabilityError(),
                AvailabilityError.generic(message: authError.localizedDescription, code: authError.codeInNetworking, originalError: originalError ?? authError)
            )
        }

        verifyIsGeneric(.emptyAuthInfoResponse)
        verifyIsGeneric(.emptyAuthResponse)
        verifyIsGeneric(.emptyServerSrpAuth)
        verifyIsGeneric(.emptyClientSrpAuth)
        verifyIsGeneric(.emptyUserInfoResponse)
        verifyIsGeneric(.wrongServerProof)
        verifyIsGeneric(.addressKeySetupError(testError), originalError: testError)
        verifyIsGeneric(.parsingError(testError), originalError: testError)
        verifyIsGeneric(.notImplementedYet("test message"))

    }

    func testAuthErrorToSetUsernameErrorTransformation() {

        XCTAssertEqual(
            AuthErrors.apiMightBeBlocked(message: "test message", originalError: apiBlockedError).asSetUsernameError(),
            SetUsernameError.apiMightBeBlocked(message: "test message", originalError: apiBlockedError)
        )

        let testGenericResponseError = ResponseError(httpCode: 412, responseCode: 123_456, userFacingMessage: "test response error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(testGenericResponseError).asSetUsernameError(),
            SetUsernameError.generic(message: "test response error", code: 123_456, originalError: testGenericResponseError)
        )

        let alreadySetError = ResponseError(httpCode: 401, responseCode: 2011, userFacingMessage: "test already set error", underlyingError: nil)
        XCTAssertEqual(
            AuthErrors.networkingError(alreadySetError).asSetUsernameError(),
            SetUsernameError.alreadySet(message: "test already set error")
        )

        func verifyIsGeneric(_ authError: AuthErrors, originalError: Error? = nil) {
            XCTAssertEqual(
                authError.asSetUsernameError(),
                SetUsernameError.generic(message: authError.localizedDescription, code: authError.codeInNetworking, originalError: originalError ?? authError)
            )
        }

        verifyIsGeneric(.emptyAuthInfoResponse)
        verifyIsGeneric(.emptyAuthResponse)
        verifyIsGeneric(.emptyServerSrpAuth)
        verifyIsGeneric(.emptyClientSrpAuth)
        verifyIsGeneric(.emptyUserInfoResponse)
        verifyIsGeneric(.wrongServerProof)
        verifyIsGeneric(.addressKeySetupError(testError), originalError: testError)
        verifyIsGeneric(.parsingError(testError), originalError: testError)
        verifyIsGeneric(.notImplementedYet("test message"))

    }

    func testAuthErrorToCreateAddressKeysErrorTransformation() {

        XCTAssertEqual(
            AuthErrors.apiMightBeBlocked(message: "test message", originalError: apiBlockedError).asCreateAddressKeysError(),
            CreateAddressKeysError.apiMightBeBlocked(message: "test message", originalError: apiBlockedError)
        )

        func verifyIsGeneric(_ authError: AuthErrors, originalError: Error? = nil) {
            XCTAssertEqual(
                authError.asCreateAddressKeysError(),
                CreateAddressKeysError.generic(message: authError.localizedDescription, code: authError.codeInNetworking, originalError: originalError ?? authError)
            )
        }

        verifyIsGeneric(.emptyAuthInfoResponse)
        verifyIsGeneric(.emptyAuthResponse)
        verifyIsGeneric(.emptyServerSrpAuth)
        verifyIsGeneric(.emptyClientSrpAuth)
        verifyIsGeneric(.emptyUserInfoResponse)
        verifyIsGeneric(.wrongServerProof)
        verifyIsGeneric(.addressKeySetupError(testError), originalError: testError)
        verifyIsGeneric(.parsingError(testError), originalError: testError)
        verifyIsGeneric(.notImplementedYet("test message"))

    }
}
