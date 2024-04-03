//
//  PMResponseCodeHandlerTests.swift
//  ProtonCore-Services-Tests - Created on 15/03/23.
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
import ProtonCoreNetworking
import ProtonCoreUtilities
@testable import ProtonCoreServices

final class PMResponseCodeHandlerTests: XCTestCase {
    var sut: ProtonMailResponseCodeHandler!
    var hvCalled = false
    var dvCalled = false
    var missingScopesCalled = false
    var forceUpgradeCalled = false
    let dict: JSONDictionary = [:]
    let responseError = ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: nil, underlyingError: nil)

    var missingScopesError: ResponseError {
        .init(
            httpCode: 403,
            responseCode: 403,
            userFacingMessage: "Error: Missing Scopes",
            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: underlyingErrorData!, response: nil) as NSError
        )
    }
    var underlyingErrorData: Data? {
        let dict = ["Details": ["MissingScopes": ["password"]]]
        let encoder = JSONEncoder()
        return try? encoder.encode(dict)
    }

    override func setUp() {
        super.setUp()
        sut = ProtonMailResponseCodeHandler()
        hvCalled = false
        missingScopesCalled = false
        forceUpgradeCalled = false
    }

    // MARK: - Human verification

    func test_handler_callsHVWhenHVRequired_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(dict), errorCode: APIErrorCode.humanVerificationRequired, completion: .left({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forRightResponseLeftCompletion() {
        handleResponse(response: .right(responseError), errorCode: APIErrorCode.humanVerificationRequired, completion: .left({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forLeftResponseRightCompletion() {
        handleResponse(response: .left(dict), errorCode: APIErrorCode.humanVerificationRequired, completion: .right({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseError), errorCode: APIErrorCode.humanVerificationRequired, completion: .right({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    // MARK: - Bad app version

    func test_handler_callsForceUpdadeWhenBadAppVersion_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(dict), errorCode: APIErrorCode.badAppVersion, completion: .left({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    func test_handler_callsForceUpdadeWhenBadAppVersion_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseError), errorCode: APIErrorCode.badAppVersion, completion: .right({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    // MARK: - Bad API version

    func test_handler_callsForceUpdadeWhenBadApiVersion_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(dict), errorCode: APIErrorCode.badApiVersion, completion: .left({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    func test_handler_callsForceUpdadeWhenBadApiVersion_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseError), errorCode: APIErrorCode.badApiVersion, completion: .right({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    // MARK: - Missing scopes error

    func test_handler_doesNotCallMissingScopesHandlerWhenMissingScopesError_forLeftResponse() {
        handleResponse(response: .left(dict), errorCode: 403, completion: .left({ _, _ in }))
        XCTAssertFalse(missingScopesCalled)
    }

    func test_handler_callsMissingScopesHandlerWhenMissingScopesError_forRightResponse() {
        handleResponse(response: .right(missingScopesError), errorCode: 403, completion: .left({ _, _ in }))
        XCTAssertTrue(missingScopesCalled)
    }

    // MARK: - Other error

    func test_handler_callsForceUpdadeWhenOtherError_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(dict), errorCode: APIErrorCode.HTTP504, completion: .left({ _, _ in }))
        XCTAssertFalse(hvCalled)
        XCTAssertFalse(forceUpgradeCalled)
    }

    func test_handler_callsForceUpdadeWhenOtherError_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseError), errorCode: APIErrorCode.HTTP504, completion: .right({ _, _ in }))
        XCTAssertFalse(hvCalled)
        XCTAssertFalse(forceUpgradeCalled)
    }

    private func handleResponse(response: Either<JSONDictionary, ResponseError>,
                                errorCode: Int,
                                completion: PMAPIService.APIResponseCompletion<PMAPIService.DummyAPIDecodableResponseOnlyForSatisfyingGenericsResolving>) {
        let credential: AuthCredential = .init(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        let responseHandlerData: PMResponseHandlerData = .init(
            method: .get,
            path: "",
            authenticated: true,
            authRetry: true,
            authRetryRemains: 0,
            customAuthCredential: credential,
            retryPolicy: .background,
            onDataTaskCreated: { _ in }
        )

        sut.handleProtonResponseCode(
            responseHandlerData: responseHandlerData,
            response: response,
            responseCode: errorCode,
            completion: completion,
            humanVerificationHandler: { _, _, _ in
                hvCalled = true
            },
            deviceVerificationHandler: { _, _, _ in
                dvCalled = true
            },
            missingScopesHandler: { _, _, _  in
                missingScopesCalled = true
            },
            forceUpgradeHandler: { _ in
                forceUpgradeCalled = true
            }
        )
    }
}
