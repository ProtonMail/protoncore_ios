//
//  PMAPIServiceTests+DV.swift
//  ProtonCore-Services-Tests - Created on 03/23/23.
//
//  Copyright (c) 2023 Proton Technologies AG
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

#if os(iOS)

import XCTest
import TrustKit
import ProtonCoreChallenge
import ProtonCoreDoh
#if canImport(ProtonCoreTestingToolkitUnitTestsNetworking)
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsObservability
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreUtilities
@testable import ProtonCoreAuthentication
@testable import ProtonCoreServices
@testable import ProtonCoreNetworking

@available(iOS 13.0.0, *)
final class PMAPIServiceDVTests: XCTestCase {

    struct EmptyTestResponse: APIDecodableResponse, Equatable {}

    struct DataTestResponse: APIDecodableResponse, Equatable { let string: String; let number: Int }

    let deviceVerificationResponse: HTTPURLResponse = .init(statusCode: 444)
    let deviceVerificationResponseJSON: JSONDictionary = [
        "Code": 9002,
        "Error": "device verification in required test",
        "Details": [
            "ChallengeType": 3,
            "ChallengePayload": "6Y6p+EtgXD079D1nKgp0J5pP6Q986C2/5stplwyQFpz6uoA5RnI1la9MY42EsBeN/L5zfpAN+dsUjHF4/6o5VxsHp5XEExgYsRK7H4XQ0PZ29dsbvAw3dAKxRUud+OB3"
        ]
    ]
    lazy var deviceVerificationResponseData: Data = try! JSONSerialization.data(withJSONObject: deviceVerificationResponseJSON)
    lazy var deviceVerificationSessionError: SessionResponseError = .responseBodyIsNotADecodableObject(body: deviceVerificationResponseData,
                                                                                                       response: deviceVerificationResponse)
    let someOtherErrorResponse: HTTPURLResponse = .init(statusCode: 400)
    let someOtherErrorResponseJSON: JSONDictionary = ["Code": 1234, "Error": "some other error in tests"]
    lazy var someOtherErrorResponseData: Data = try! JSONSerialization.data(withJSONObject: someOtherErrorResponseJSON)
    lazy var someOtherSessionError: SessionResponseError = .responseBodyIsNotADecodableObject(body: someOtherErrorResponseData,
                                                                                              response: someOtherErrorResponse)
    let successfulResponse: HTTPURLResponse = .init(statusCode: 200)
    let successfulResponseJSON: JSONDictionary = ["Code": 1000, "String": "some successful string", "Number": 42]
    lazy var successfulResponseData: Data = try! JSONSerialization.data(withJSONObject: successfulResponseJSON)

    var dohMock: DoHInterface! = nil
    var sessionUID: String! = nil
    var cacheToClearMock: URLCacheMock! = nil
    var sessionMock: SessionMock! = nil
    var sessionFactoryMock: SessionFactoryMock! = nil
    var trustKitProviderMock: TrustKitProviderMock! = nil
    var apiServiceDelegateMock: APIServiceDelegateMock! = nil
    var authDelegateMock: AuthDelegateMock! = nil
    var humanDelegateMock: HumanVerifyDelegateMock! = nil

    override func setUp() {
        super.setUp()
        let dohMock = DohMock()
        dohMock.statusStub.fixture = .on
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "test.host.url" }
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, executor, completion in
            executor.execute { completion(false) }
        }
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in false }
        self.dohMock = dohMock
        sessionUID = "PMAPIServiceTests_testAdditionalHeaders"
        cacheToClearMock = URLCacheMock()
        let sessionMockInstance = SessionMock()
        sessionMock = sessionMockInstance
        sessionFactoryMock = SessionFactoryMock()
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, _ in return sessionMockInstance }
        trustKitProviderMock = TrustKitProviderMock()
        apiServiceDelegateMock = APIServiceDelegateMock()
        authDelegateMock = AuthDelegateMock()
        humanDelegateMock = HumanVerifyDelegateMock()
    }

    // MARK: - JSON response tests

    func testDeviceVerificationIsLaunchedForJSONResponse_DV_Error() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, _, completion in
            completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .success(self.deviceVerificationResponseJSON))
        }
        humanDelegateMock.onDeviceVerifyStub.bodyIs { _, _ in
            ""
        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }

        // THEN
        XCTAssertTrue(humanDelegateMock.onDeviceVerifyStub.wasCalledExactlyOnce)
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value.responseCode, 9002)
        XCTAssertEqual(value.error, "device verification in required test")
    }

    func testDeviceVerificationIsLaunchedForJSONResponse_ErrorInRetriedRequest() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { counter, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .success(self.deviceVerificationResponseJSON))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .success(self.someOtherErrorResponseJSON))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }

        // THEN
        let error = try XCTUnwrap(result.1.error)
        XCTAssertEqual(error.code, 1234)
        XCTAssertEqual(error.localizedDescription, "some other error in tests")
    }

    func testDeviceVerificationIsLaunchedForJSONResponse_DVSuccessRetry() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { counter, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .success(self.deviceVerificationResponseJSON))
            case 1: completion(URLSessionDataTaskMock(response: self.successfulResponse), .success(self.successfulResponseJSON))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }

        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(try JSONSerialization.data(withJSONObject: value),
                       try JSONSerialization.data(withJSONObject: self.successfulResponseJSON))
    }

    // MARK: - Codable empty response tests

    func testDeviceVerificationIsLaunchedForCodableEmptyResponse_DV_Error() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, _, _, _, completion in
            completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
        }
        humanDelegateMock.onDeviceVerifyStub.bodyIs { _, _ in
            ""
        }

        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 9002, userFacingMessage: "device verification in required test", underlyingError: nil))
    }

    func testDeviceVerificationIsLaunchedForCodableEmptyResponse_ErrorInRetriedRequest() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .failure(self.someOtherSessionError))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 400, responseCode: 1234, userFacingMessage: "some other error in tests",
                                            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: someOtherErrorResponseData, response: nil).underlyingError))
    }

    func testDeviceVerificationIsLaunchedForCodableEmptyResponse_DVSuccessRetry() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(try! JSONDecoder.decapitalisingFirstLetter.decode(EmptyTestResponse.self, from: self.successfulResponseData))
            )
            default: XCTFail("Stub shouldn't be called more than twice")
            }

        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        // THEN
        _ = try XCTUnwrap(result.1.value)
    }

    func testDeviceVerificationIsLaunchedForCodableDataResponseError() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, _, _, _, completion in
            completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
        }
        humanDelegateMock.onDeviceVerifyStub.bodyIs { _, _ in
            ""
        }

        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 9002, userFacingMessage: "device verification in required test", underlyingError: nil))
    }

    func testDeviceVerificationIsLaunchedForCodableDataResponse_ErrorInRetriedRequest() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .failure(self.someOtherSessionError))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 400, responseCode: 1234, userFacingMessage: "some other error in tests",
                                            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: someOtherErrorResponseData, response: nil).underlyingError))
    }

    func testDeviceVerificationIsLaunchedForCodableDataResponse_HVSuccess() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(try! JSONDecoder.decapitalisingFirstLetter.decode(DataTestResponse.self, from: self.successfulResponseData))
            )
            default: XCTFail("Stub shouldn't be called more than twice")
            }

        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let response = try XCTUnwrap(result.1.value)
        XCTAssertEqual(response.string, "some successful string")
        XCTAssertEqual(response.number, 42)
    }

    // MARK: - POST /auth tests

    func testDeviceVerificationIsLaunchedForPOSTAuth_DVSuccess() async throws {
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, _, completion in
            switch counter {
            case 0: completion(URLSessionDataTaskMock(response: self.deviceVerificationResponse), .failure(self.deviceVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(AuthService.AuthRouteResponse(accessToken: "test access token",
                                                       tokenType: "test token type",
                                                       refreshToken: "test refresh tokeb",
                                                       scopes: ["test scope"],
                                                       UID: "test uid",
                                                       userID: "test user id",
                                                       eventID: "test event id",
                                                       serverProof: "test server proof",
                                                       passwordMode: .one,
                                                       _2FA: .init(enabled: .off)))
            )
            default: XCTFail("Stub shouldn't be called more than twice")
            }

        }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, authRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<AuthService.AuthRouteResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }

        // THEN
        let response = try XCTUnwrap(result.1.value)
        XCTAssertEqual(response.accessToken, "test access token")
        XCTAssertEqual(response.tokenType, "test token type")
        XCTAssertEqual(response.refreshToken, "test refresh tokeb")
        XCTAssertEqual(response.scopes, ["test scope"])
        XCTAssertEqual(response.UID, "test uid")
        XCTAssertEqual(response.userID, "test user id")
        XCTAssertEqual(response.eventID, "test event id")
        XCTAssertEqual(response.serverProof, "test server proof")
        XCTAssertEqual(response.passwordMode, .one)
        XCTAssertEqual(response._2FA.enabled, .off)
    }
}

#endif
