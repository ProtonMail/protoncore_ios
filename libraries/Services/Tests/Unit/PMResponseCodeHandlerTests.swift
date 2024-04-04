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

    func responseErrorWithResponseCode(_ responseCode: Int?) -> ResponseError {
        ResponseError(httpCode: 403,
                      responseCode: responseCode,
                      userFacingMessage: "",
                      underlyingError: nil)
    }

    var missingScopesError: ResponseError {
        .init(
            httpCode: 403,
            responseCode: APIErrorCode.lockedScopeRequired,
            userFacingMessage: "Error: Missing Scopes",
            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: underlyingMissingScopesErrorData!, response: nil) as NSError
        )
    }
    var underlyingMissingScopesErrorData: Data? {
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
        handleResponse(response: .left(["Code" : APIErrorCode.humanVerificationRequired]),
                       completion: .left({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forRightResponseLeftCompletion() {
        handleResponse(response: .right(responseErrorWithResponseCode(APIErrorCode.humanVerificationRequired)),
                       completion: .left({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forLeftResponseRightCompletion() {
        handleResponse(response: .left(["Code" : APIErrorCode.humanVerificationRequired]),
                       completion: .right({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    func test_handler_callsHVWhenHVRequired_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseErrorWithResponseCode(APIErrorCode.humanVerificationRequired)),
                       completion: .right({ _, _ in }))
        XCTAssertTrue(hvCalled)
    }

    // MARK: - Bad app version

    func test_handler_callsForceUpgradeWhenBadAppVersion_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(["Code": APIErrorCode.badAppVersion]),
                       completion: .left({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    func test_handler_callsForceUpgradeWhenBadAppVersion_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseErrorWithResponseCode(APIErrorCode.badAppVersion)),
                       completion: .right({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    // MARK: - Bad API version

    func test_handler_callsForceUpgradeWhenBadApiVersion_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(["Code": APIErrorCode.badApiVersion]),
                           completion: .left({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    func test_handler_callsForceUpgradeWhenBadApiVersion_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseErrorWithResponseCode(APIErrorCode.badApiVersion)),
                       completion: .right({ _, _ in }))
        XCTAssertTrue(forceUpgradeCalled)
    }

    // MARK: - Missing scopes error

    func test_handler_doesNotCallMissingScopesHandlerWhenGenericError_forLeftResponse() {
            handleResponse(response: .right(responseError), completion: .left({ _, _ in }))
        XCTAssertFalse(missingScopesCalled)
    }

    func test_handler_doesNotCallMissingScopesHandlerWhenGenericError_forRightResponse() {
            handleResponse(response: .right(responseError), completion: .right({ _, _ in }))
        XCTAssertFalse(missingScopesCalled)
    }

    func test_handler_callsMissingScopesHandlerWhenMissingScopesError_forLeftCompletion() {
        handleResponse(response: .right(missingScopesError), completion: .left({ _, _ in }))
        XCTAssertTrue(missingScopesCalled)
    }

    func test_handler_callsMissingScopesHandlerWhenMissingScopesError_forRightCompletion() {
        handleResponse(response: .right(missingScopesError), completion: .right({ _, _ in }))
        XCTAssertTrue(missingScopesCalled)
    }

    // MARK: - Other error

    func test_handler_callsForceUpgradeWhenOtherError_forLeftResponseLeftCompletion() {
        handleResponse(response: .left(["Code": APIErrorCode.HTTP504]),
                       completion: .left({ _, _ in }))
        XCTAssertFalse(hvCalled)
        XCTAssertFalse(forceUpgradeCalled)
    }

    func test_handler_callsForceUpgradeWhenOtherError_forRightResponseRightCompletion() {
        handleResponse(response: .right(responseErrorWithResponseCode(APIErrorCode.HTTP504)),
                       completion: .right({ _, _ in }))
        XCTAssertFalse(hvCalled)
        XCTAssertFalse(forceUpgradeCalled)
    }

    private func handleResponse(response: Either<JSONDictionary, ResponseError>,
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
            responseCode: response.code ?? 0,
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
