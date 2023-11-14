//
//  AuthServiceTests.swift
//  ProtonCore-Authentication-Tests - Created on 19/06/2023.
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
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsObservability
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreAuthentication
@testable import ProtonCoreObservability

class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var api: APIServiceMock!
    var observabilityServiceMock: ObservabilityServiceMock!

    override func setUp() {
        super.setUp()
        api = .init()
        sut = .init(api: api)
        continueAfterFailure = false
        observabilityServiceMock = ObservabilityServiceMock()
        ObservabilityEnv.current.observabilityService = observabilityServiceMock
    }

    func test_ssoAuthentication_success_tracksSuccess() {
        // Given
        let expectation = XCTestExpectation()
        let ssoResponseToken = SSOResponseToken(token: "token", uid: "uid")
        let authRouteResponse = AuthService.AuthRouteResponse(accessToken: "", tokenType: "", refreshToken: "", scopes: .empty, UID: "", userID: "", eventID: "", serverProof: "", passwordMode: .one, _2FA: .init(enabled: .off))
        let expectedEvent: ObservabilityEvent = .ssoAuthWithTokenTotalEvent(status: .http2xx)
        api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(authRouteResponse))
        }

        // When
        sut.ssoAuthentication(ssoResponseToken: ssoResponseToken) { _ in
            XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_ssoAuthentication_fails_tracksFailure() {
        // Given
        let expectation = XCTestExpectation()
        let ssoResponseToken = SSOResponseToken(token: "token", uid: "uid")
        let expectedEvent: ObservabilityEvent = .ssoAuthWithTokenTotalEvent(status: .http5xx)
        api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(ResponseError(httpCode: 500, responseCode: 123, userFacingMessage: "error", underlyingError: nil) as NSError))
        }

        // When
        sut.ssoAuthentication(ssoResponseToken: ssoResponseToken) { _ in
            XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_ssoAuthentication_success() {
        // Given
        let expectation = XCTestExpectation(description: "success expected")
        let ssoResponseToken = SSOResponseToken(token: "token", uid: "uid")
        let authRouteResponse = AuthService.AuthRouteResponse(accessToken: "", tokenType: "", refreshToken: "", scopes: .empty, UID: "", userID: "", eventID: "", serverProof: "", passwordMode: .one, _2FA: .init(enabled: .off))

        api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(authRouteResponse))
        }

        // When
        sut.ssoAuthentication(ssoResponseToken: ssoResponseToken) { response in
            switch response {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func test_ssoAuthentication_fails() {
        // Given
        let expectation = XCTestExpectation(description: "failure expected")
        let ssoResponseToken = SSOResponseToken(token: "token", uid: "uid")
        api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        sut.ssoAuthentication(ssoResponseToken: ssoResponseToken) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure:
                break
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func test_info_withAutoIntent_trackSuccessful() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            let username = "username"
            let expectedEvent: ObservabilityEvent = .ssoObtainChallengeToken(status: .http2xx)
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(["SSOChallengeToken": "ssoChallengeToken"]))
            }
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: username, intent: .auto) { response in
                XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withSSOIntent_trackSuccessful() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            let username = "username"
            let response = SSOChallengeResponse(ssoChallengeToken: "ssoChallengeToken")
            let expectedEvent: ObservabilityEvent = .ssoObtainChallengeToken(status: .http2xx)
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(response))
            }
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: username, intent: .sso) { response in
                XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withSSOIntent_trackFails() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            let username = "username"
            let expectedEvent: ObservabilityEvent = .ssoObtainChallengeToken(status: .unknown)
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(.badResponse()))
            }
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: username, intent: .sso) { response in
                XCTAssertTrue(self.observabilityServiceMock.reportStub.lastArguments!.value.isSameAs(event: expectedEvent))
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withSSOIntent() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            let username = "username"
            let response = SSOChallengeResponse(ssoChallengeToken: "ssoChallengeToken")
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(response))
            }
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: username, intent: .sso) { response in
                switch response {
                case .success(.right(let response)):
                    XCTAssertEqual(response.ssoChallengeToken, "ssoChallengeToken")
                default:
                    XCTFail("SSOChallenge expected")
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withProtonIntent() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            let username = "username"
            let response = AuthInfoResponse(modulus: "modulus", serverEphemeral: "serverEphemeral", version: 1, salt: "salt", srpSession: "srpSession")
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(response))
            }

            // When
            sut.info(username: username, intent: .proton) { response in
                switch response {
                case .success(.left(let response)):
                    XCTAssertEqual(response.modulus, "modulus")
                    XCTAssertEqual(response.serverEphemeral, "serverEphemeral")
                    XCTAssertEqual(response.version, 1)
                    XCTAssertEqual(response.salt, "salt")
                    XCTAssertEqual(response.srpSession, "srpSession")
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withAutoIntent_ssoExpected() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with sso response expected")
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(["SSOChallengeToken": "ssoChallengeToken"]))
            }
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: "username", intent: .auto) { response in
                switch response {
                case .success(.right(let response)):
                    XCTAssertEqual(response.ssoChallengeToken, "ssoChallengeToken")
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withAutoIntent_AuthInfoExpected() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "success with auth info response expected")
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(
                    [
                        "Modulus": "modulus",
                        "ServerEphemeral": "serverEphemeral",
                        "Version": 1,
                        "Salt": "salt",
                        "SRPSession": "srpSession"
                    ]
                ))
            }
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: "username", intent: .auto) { response in
                switch response {
                case .success(.left(let response)):
                    XCTAssertEqual(response.modulus, "modulus")
                    XCTAssertEqual(response.serverEphemeral, "serverEphemeral")
                    XCTAssertEqual(response.version, 1)
                    XCTAssertEqual(response.salt, "salt")
                    XCTAssertEqual(response.srpSession, "srpSession")
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withAutoIntent_badJSONExpectsError() {
        withFeatureSwitches([.ssoSignIn]) {
            // Given
            let expectation = XCTestExpectation(description: "failure with response error expected")
            api.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .success(["NotExpected": "not expected"]))
            }
            api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
                completion(nil, .failure(BadPerformError()))
            }

            // When
            sut.info(username: "username", intent: .auto) { response in
                switch response {
                case .failure(let error):
                    XCTAssertEqual(error, ResponseError(httpCode: nil, responseCode: 2002, userFacingMessage: "Response is neither SSOChallenge, nor AuthInfoResponse", underlyingError: nil))
                default:
                    XCTFail()
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 0.1)
        }
    }

    func test_info_withoutIntent() {
        // Given
        let expectation = XCTestExpectation(description: "success with authInfo response expected")
        let username = "username"
        api.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(AuthInfoResponse()))
        }

        // When
        sut.info(username: username, intent: nil) { response in
            switch response {
            case .success(.left(let response)):
                XCTAssertNotNil(response)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    private class BadPerformError: NSError {
        override var localizedDescription: String {
            "JSON Decodable request expected"
        }
    }
}
