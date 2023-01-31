//
//  PMAPIServiceTests+Request.swift
//  ProtonCore-Services-Tests - Created on 04/20/22.
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
import TrustKit
import ProtonCore_Foundations
import ProtonCore_CoreTranslation
import ProtonCore_TestingToolkit
import ProtonCore_Utilities
import ProtonCore_Doh
import ProtonCore_FeatureSwitch

@testable import ProtonCore_Services
@testable import ProtonCore_Networking

@available(iOS 13.0, *)
func optionalContinuation<T, E>(_ continuation: CheckedContinuation<T, E>) -> (T) -> Void {
    { continuation.resume(returning: $0) }
}

@available(iOS 13.0, *)
func optionalContinuation<T, R, E>(_ continuation: CheckedContinuation<(first: T, second: R), E>) -> (T, R) -> Void {
    { continuation.resume(returning: (first: $0, second: $1)) }
}

@available(iOS 13.0, *)
func optionalContinuation<T, R, S, E>(_ continuation: CheckedContinuation<(first: T, second: R, third: S), E>) -> (T, R, S) -> Void {
    { continuation.resume(returning: (first: $0, second: $1, third: $2)) }
}

@available(iOS 13.0, *)
func optionalContinuation(
    _ continuation: CheckedContinuation<(task: URLSessionDataTask?, response: [String: Any]?, error: NSError?), Never>
) -> (URLSessionDataTask?, [String: Any]?, NSError?) -> Void {
    { continuation.resume(returning: (task: $0, response: $1, error: $2)) }
}

@available(iOS 13.0, *)
func optionalContinuation(
    _ continuation: CheckedContinuation<(task: URLSessionDataTask?, response: [String: Any]?, error: NSError?), Never>
) -> API.JSONCompletion {
    { continuation.resume(returning: (task: $0, response: $1.value, error: $1.error)) }
}

@available(iOS 13.0.0, *)
final class PMAPIServiceRequestTests: XCTestCase {
    
    let numberOfRequests: UInt = 50
    
    var dohMock: DohMock! = nil
    var sessionUID: String! = nil
    var cacheToClearMock: URLCacheMock! = nil
    var sessionMock: SessionMock! = nil
    var sessionFactoryMock: SessionFactoryMock! = nil
    var trustKitProviderMock: TrustKitProviderMock! = nil
    var apiServiceDelegateMock: APIServiceDelegateMock! = nil
    var authDelegateMock: AuthDelegateMock! = nil

    var testService: PMAPIService {
        PMAPIService.createAPIService(doh: dohMock,
                                      sessionUID: "test sessionUID",
                                      sessionFactory: sessionFactoryMock,
                                      cacheToClear: cacheToClearMock,
                                      trustKitProvider: trustKitProviderMock,
                                      challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
    }
    
    override func setUp() {
        super.setUp()
        let mock = DohMock()
        dohMock = mock
        mock.statusStub.fixture = .on
        mock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "test.host.url" }
        mock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, executor, completion in
            executor.execute { completion(false) }
        }
        mock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in false }
        sessionUID = "PMAPIServiceTests_testAdditionalHeaders"
        cacheToClearMock = URLCacheMock()
        let sessionMockInstance = SessionMock()
        sessionMock = sessionMockInstance
        sessionFactoryMock = SessionFactoryMock()
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, _ in return sessionMockInstance }
        trustKitProviderMock = TrustKitProviderMock()
        apiServiceDelegateMock = APIServiceDelegateMock()
        authDelegateMock = AuthDelegateMock()
    }
    
    // MARK: - Error propagation
    
    func testRequestWithJSONPassesServerErrorCodeInsteadOfHttpCode() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            let service = testService
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
            }

            sessionMock.requestJSONStub.bodyIs { _, _, completion in
                completion(URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 404)), .success(["Code": 2222]))
            }

            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            _ = try XCTUnwrap(result.task)
            let error = try XCTUnwrap(result.error)
            XCTAssertEqual(error.code, 2222)
        }
    }
    
    func testRequestWithJSONPassesHttpErrorCode() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            let service = testService
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
            }

            sessionMock.requestJSONStub.bodyIs { _, _, completion in
                completion(URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 404)), .success([:]))
            }

            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            _ = try XCTUnwrap(result.task)
            let error = try XCTUnwrap(result.error)
            XCTAssertEqual(error.code, 404)
        }
    }
    
    // MARK: - Deprecated API
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedRequestMethods_Variant1() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            let service = testService
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: false,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, completion: optionalContinuation(continuation))
            }
            XCTAssertNil(result.task)
            XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
            XCTAssertNil(result.error)
        }
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedRequestMethods_Variant2() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            let service = testService
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false,
                                autoRetry: false, customAuthCredential: nil, completion: optionalContinuation(continuation))
            }
            XCTAssertNil(result.task)
            XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
            XCTAssertNil(result.error)
        }
    }

    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant6() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            let service = testService
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
            }

            sessionMock.uploadWithFilesJSONStub.bodyIs { _, _, _, completion, _ in
                completion(nil, .success(["Code": 1000]))
            }

            let result = await withCheckedContinuation { continuation in
                service.upload(byPath: "/unit/tests", parameters: nil, files: [:], headers: nil, authenticated: false, customAuthCredential: nil,
                               nonDefaultTimeout: nil, uploadProgress: nil, completion: optionalContinuation(continuation))
            }

            XCTAssertNil(result.task)
            XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
            XCTAssertNil(result.error)
        }
    }
    
    // MARK: - Part 1 — logic before network operation
    
    /*
     
     What to test:
     
     [+] if customAuthCredential, no fetching happens
     [+] if customAuthCredential, request is created with access token from customAuthCredential
     
    */
    
    private func noFetchingHappensWhenCustomAuthCredentials(authenticated: Bool) async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: authenticated, autoRetry: true,
                            customAuthCredential: authCredential, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }

    func testNoFetchingWhenAuthenticatedIsFalseWithCustomAuthCredential() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await noFetchingHappensWhenCustomAuthCredentials(authenticated: false)
        }
    }

    func testNoFetchingWhenAuthenticatedIsFalseWithCustomAuthCredential_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            try await noFetchingHappensWhenCustomAuthCredentials(authenticated: false)
        }
    }

    func testNoFetchingWhenCustomAuthCredentials() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await noFetchingHappensWhenCustomAuthCredentials(authenticated: true)
        }
    }

    func testNoFetchingWhenCustomAuthCredentials_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            try await noFetchingHappensWhenCustomAuthCredentials(authenticated: true)
        }
    }

    func testRequestContainsCustomAuthAccessTokenWhenCustomAuthCredentials() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true,
                                customAuthCredential: authCredential, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
            XCTAssertEqual(request.value(key: "Authorization"), "Bearer test accessToken")
        }
    }

    /*

     What to test:

     [+] if no customAuthCredential, fetching happens regardless of authenticated parameter value
     [+] if no customAuthCredential and authenticated is true and legacy path, fetching happens
     [+] if no customAuthCredential and authenticated is false and legacy path, fetching doesn't happen

    */

    private func ensureFetchingHappensWhenNoCustomAuthCredentials(authenticated: Bool) async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: authenticated, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test sessionUID")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }

    func testFetchingHappensWhenNoCustomAuthCredentialsForAuthenticatedFlagTrue() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await ensureFetchingHappensWhenNoCustomAuthCredentials(authenticated: true)
        }
    }

    func testFetchingHappensWhenNoCustomAuthCredentialsForAuthenticatedFlagFalse() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await ensureFetchingHappensWhenNoCustomAuthCredentials(authenticated: false)
        }
    }

    func testFetchingHappensWhenNoCustomAuthCredentialsForAuthenticatedFlagTrue_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            try await ensureFetchingHappensWhenNoCustomAuthCredentials(authenticated: true)
        }
    }

    func testNoFetchingHappensWhenNoCustomAuthCredentialsForAuthenticatedFlagFalse_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            XCTAssertNil(result.task)
            XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
            XCTAssertNil(result.error)
        }
    }

    /*

     What to test:

     [+] if no customAuthCredential, and fetching fails, request is created without access token, regardless of authenticated value
     [+] if no customAuthCredential, legacy path, authenticated and fetching fails, operation fails
     [+] if no customAuthCredential, legacy path, not authenticated and fetching fails, request is created without access token
     [+] if no customAuthCredential, legacy path, not authenticated and fetching succeeds, request is created without access token

    */

    private func ensureIfFetchingFailsRequestIsCreatedWithoutAccessToken(authenticated: Bool) async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: authenticated, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard let request = sessionMock.requestJSONStub.lastArguments?.first else { XCTFail(); return }
        XCTAssertFalse(request.hasHeader(key: "Authorization"))
        XCTAssertFalse(request.hasHeader(key: "x-pm-uid"))
    }

    func testIfAuthenticatedFetchingFailsCreatesRequestWithoutAccessToken() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensureIfFetchingFailsRequestIsCreatedWithoutAccessToken(authenticated: true)
        }
    }

    func testIfNotAuthenticatedFetchingFailsCreatesRequestWithoutAccessToken() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensureIfFetchingFailsRequestIsCreatedWithoutAccessToken(authenticated: false)
        }
    }
    
    func testIfAuthenticatedAndFetchingFailsOperationFails_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(sessionMock.generateStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            XCTAssertNotNil(result.error)
            XCTAssertEqual(result.error, PMAPIService.AuthCredentialFetchingResult.notFound.toNSError)
        }
    }
    
    func testIfNotAuthenticatedAndFetchingFailsRequestWithoutAccessTokenIsCreated_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
            XCTAssertFalse(request.hasHeader(key: "Authorization"))
            XCTAssertFalse(request.hasHeader(key: "x-pm-uid"))
        }
    }

    func testIfNotAuthenticatedAndFetchingSucceedsRequestWithoutAccessTokenIsCreated_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            // GIVEN
            let service = testService

            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
            XCTAssertFalse(request.hasHeader(key: "Authorization"))
            XCTAssertFalse(request.hasHeader(key: "x-pm-uid"))
        }
    }

    /*

     What to test:

     [+] if no customAuthCredential and fetching succeeds, request is created with fetched access token, regardless of authenticated value

     [+] if no customAuthCredential, legacy path, authenticated and fetching succeeds, request is created with fetched access token

     [+] if request creation throws, the operation fails

    */

    private func ensureIfFetchisSucceedsRequestWithAccessTokenIsCreated(authenticated: Bool) async throws {
        // GIVEN
        let service = testService

        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: authenticated, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
        XCTAssertEqual(request.value(key: "Authorization"), "Bearer test accessToken")
        XCTAssertEqual(request.value(key: "x-pm-uid"), "test sessionID")
    }

    func testIfAuthenticatedAndFetchingSucceedsRequestWithAccessTokenIsCreated() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await ensureIfFetchisSucceedsRequestWithAccessTokenIsCreated(authenticated: true)
        }
    }

    func testIfNotAuthenticatedAndFetchingSucceedsRequestWithAccessTokenIsCreated() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            try await ensureIfFetchisSucceedsRequestWithAccessTokenIsCreated(authenticated: false)
        }
    }
    
    func testIfAuthenticatedAndFetchingSucceedsRequestWithAccessTokenIsCreated_LegacyPath() async throws {
        try await withFeatureSwitches([]) {
            try await ensureIfFetchisSucceedsRequestWithAccessTokenIsCreated(authenticated: true)
        }
    }

    func testIfRequestCreationFailsOperationFails() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock

            enum TestError: Error { case testError }
            sessionMock.generateStub.bodyIs { _, _, _, _, _, _ in throw TestError.testError }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertEqual(result.error, TestError.testError as NSError)
        }
    }
    
    func testIfRequestCreationFailsOperationFails_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock

            enum TestError: Error { case testError }
            sessionMock.generateStub.bodyIs { _, _, _, _, _, _ in throw TestError.testError }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertEqual(result.error, TestError.testError as NSError)
        }
    }
    
    // MARK: - Part 2 — logic after network operation, around DoH
    
    /*
     
     What to test:
     
     [+] if network operation throws, the operation fails
     [+] server time is updated
     [+] if failsTLS, TLS error is passed to DoH
     [+] error is passed to handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded
     [+] if handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded returns shouldRetry, request is restarted
     [+] if handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded returns no shouldRetry and error is DoH, delegate is notified
     
    */
    
    func testOperationFailsIfNetworkOperationThrows() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }

            enum TestError: Error { case testError }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(SessionResponseError.networkingEngineError(underlyingError: TestError.testError as NSError))) }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
            XCTAssertEqual(result.error, TestError.testError as NSError)
        }
    }
    
    func testServerTimeIsUpdatedAccordingToResponse() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock

            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            let task = URLSessionDataTaskMock()
            task.responseStub.fixture = HTTPURLResponse(url: URL(string: "https://unit.test")!, statusCode: 0, httpVersion: nil,
                                                        headerFields: ["Date": "Fri, 13 May 2022 09:42:00 +02:00"])
            let date = DateParser.parse(time: "Fri, 13 May 2022 09:42:00 +02:00").map { Int64($0.timeIntervalSince1970) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(task, .success([:])) }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(apiServiceDelegateMock.onUpdateStub.wasCalledExactlyOnce)
            XCTAssertEqual(apiServiceDelegateMock.onUpdateStub.lastArguments?.value, date)
        }
    }
    
    func testTLSErrorIsPassedToDoHIfFailsTLS() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
            sessionMock.failsTLSStub.bodyIs { _, _ in "test TLS error description" }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
            XCTAssertTrue(sessionMock.failsTLSStub.wasCalledExactlyOnce)
            XCTAssertIdentical(sessionMock.failsTLSStub.lastArguments?.value, sessionMock.requestJSONStub.lastArguments?.first)
            let error = try XCTUnwrap(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.capturedArguments.last?.a5)
            XCTAssertEqual(error.messageForTheUser, "test TLS error description")
        }
    }
    
    func testErrorIsPassedToHandleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            enum TestError: Error, Equatable { case testError }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: TestError.testError as NSError))) }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
            let error = try XCTUnwrap(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.capturedArguments.last?.a5)
            XCTAssertEqual(error as? TestError, TestError.testError)
        }
    }

    func testNoAuthenticatedRequestIsRestartedIfDoHSaysSo() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, _, _, _, _, _, executor, completion in
                if counter == 1 {
                    executor.execute { completion(true) }
                } else {
                    executor.execute { completion(false) }
                }
            }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
            XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
        }
    }

    func testAuthenticatedRequestIsRestartedIfDoHSaysSo() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, _, _, _, _, _, executor, completion in
                if counter == 1 {
                    executor.execute { completion(true) }
                } else {
                    executor.execute { completion(false) }
                }
            }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
            XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
        }
    }
    
    func testNoAuthenticatedRequestIsRestartedIfDoHSaysSo_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, _, _, _, _, _, executor, completion in
                if counter == 1 {
                    executor.execute { completion(true) }
                } else {
                    executor.execute { completion(false) }
                }
            }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
            XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
        }
    }
    
    func testAuthenticatedRequestIsRestartedIfDoHSaysSo_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, _, _, _, _, _, executor, completion in
                if counter == 1 {
                    executor.execute { completion(true) }
                } else {
                    executor.execute { completion(false) }
                }
            }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
            XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
        }
    }
    
    func testAPIMightBeBlockedIsReturnedIfNoRetryAndDoHError() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in true }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            XCTAssertEqual((result.error! as NSError).code, APIErrorCode.potentiallyBlocked)
            XCTAssertEqual((result.error! as NSError).localizedDescription, CoreString._net_api_might_be_blocked_message)

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
            XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
            XCTAssertTrue(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.wasCalledExactlyOnce)
        }
    }

    func testAPIMightBeBlockedIsReturnedIfNoRetryAndDoHError_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }

            dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in true }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            XCTAssertEqual((result.error! as NSError).code, APIErrorCode.potentiallyBlocked)
            XCTAssertEqual((result.error! as NSError).localizedDescription, CoreString._net_api_might_be_blocked_message)

            // THEN
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
            XCTAssertTrue(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.wasCalledExactlyOnce)
        }
    }
    
    // MARK: - Part 3 — credential refreshing logic

    /*

     If we perform the call without the credentials and get 401 back, we need to:
        * acquire the session
        * if the session acquiring call fails, return error
        * if the session acquiring call succeeds, retry the original call
            * if the retry of the original call fails, regardless of the code (including 401), return error (do not retry again)

    */

    func test401WithoutCredentialsReturnsErrorIfSessionAcquisitionFails() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, request, completion in
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 401)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, _, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 400)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: response)))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.response)
            guard let responseError = result.error as? ResponseError else { XCTFail(); return }
            XCTAssertEqual(responseError.httpCode, 400)
        }
    }

    func test401WithoutCredentialsReturnsSuccessIfSessionAcquisitionSucceedsAndRetriedCallSucceeds() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if counter == 1 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else if counter == 2 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 200)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .success([:]))
                } else {
                    XCTFail(); return
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.response)
        }
    }

    func test401WithoutCredentialsReturnsErrorIfSessionAcquisitionSucceedsAndRetriedCallErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if counter == 1 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else if counter == 2 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else {
                    XCTFail(); return
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.response)
            guard let responseError = result.error as? ResponseError else { XCTFail(); return }
            XCTAssertEqual(responseError.httpCode, 401)
        }
    }

    /*

     If we perform the call with the credentials and get 401 back, we need to:
     * refresh the credentials
     * if the credentials refresh succeeds, retry the original call
        * if the retry of the original call fails, regardless of the code (including 401), return error (do not retry again)
     * if the credentials refresh fails with error OTHER THAN 400 or 422, return error
     * if the credentials refresh fails with error 400 or 422 AND credentials were for the authenticated session (user logged in), log the user out via AuthDelegate.onLogout method

     */

    func test401WithCredentialsReturnsSuccessIfRefreshCredentialsSucceedsAndRetryCallSucceeds() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            let oldCredentials = AuthCredential(Credential.dummy
                .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
            )
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if counter == 1 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else if counter == 2 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 200)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .success([:]))
                } else {
                    XCTFail(); return
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    let data =
                    """
                    {
                        "AccessToken": "test access token new",
                        "RefreshToken": "test refresh token new",
                        "TokenType": "test refresh token new",
                        "Scopes": ["full"],
                    }
                    """.utf8!
                    let response = try! decoder!.decode(RefreshResponse.self, from: data)
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                    completion(task, .success(response))
                } else { XCTFail(); return }
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.response)
        }
    }

    func test401WithCredentialsReturnsErrorIfRefreshCredentialsSucceedsAndRetryCallErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            let oldCredentials = AuthCredential(Credential.dummy
                .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
            )
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if counter == 1 || counter == 2 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else {
                    XCTFail(); return
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
                let data =
                """
                {
                    "AccessToken": "test access token new",
                    "RefreshToken": "test refresh token new",
                    "TokenType": "test refresh token new",
                    "Scopes": ["full"],
                }
                """.utf8!
                let response = try! decoder!.decode(RefreshResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.response)
            guard let responseError = result.error as? ResponseError else { XCTFail(); return }
            XCTAssertEqual(responseError.httpCode, 401)
        }
    }

    func test401WithCredentialsReturnsErrorIfRefreshCredentialsErrorsWithNonSpecialCode() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.serviceDelegate = apiServiceDelegateMock
            service.authDelegate = authDelegateMock

            let oldCredentials = AuthCredential(Credential.dummy
                .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
            )
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if counter == 1 {
                    guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                    let response = HTTPURLResponse(statusCode: 401)
                    let task = URLSessionDataTaskMock(response: response)
                    completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
                } else {
                    XCTFail(); return
                }
            }
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
                    completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                } else { XCTFail(); return }
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertNil(result.response)
            XCTAssertEqual(result.error?.code, 500)
            XCTAssertEqual(result.error?.localizedDescription, "test error message")
        }
    }

    private func ensure401WithCredentialsLogsUserOutIfAuthenticateSessionAndRefreshCredentialsErrors(httpCode: Int) async {
        // GIVEN
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        service.authDelegate = authDelegateMock

        let oldCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old",
                     userName: "test user name", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }

        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if counter == 1 {
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 401)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
            } else {
                XCTFail(); return
            }
        }
        
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: httpCode))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test sessionUID")
        XCTAssertNil(result.response)
        XCTAssertEqual(result.error?.code, 4242)
        XCTAssertEqual(result.error?.localizedDescription, "test error message")
    }

    func test401WithCredentialsLogsUserOutIfAuthenticateSessionAndRefreshCredentialsErrorsWith400() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsLogsUserOutIfAuthenticateSessionAndRefreshCredentialsErrors(httpCode: 400)
        }
    }

    func test401WithCredentialsLogsUserOutIfAuthenticateSessionAndRefreshCredentialsErrorsWith422() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsLogsUserOutIfAuthenticateSessionAndRefreshCredentialsErrors(httpCode: 422)
        }
    }

    /*

     * if the credentials refresh fails with error 400 or 422 AND credentials were for the unauthenticated session, erase the credentials and acquire new session
        * if the session acquiring call fails, return error
        * if the session acquiring call succeeds, retry the original call
            * if the retry of the original call fails, regardless of the code (including 401), return error (do not retry again)

     */

    private func ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallSucceeds(httpCode: Int) async {
        // GIVEN
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        service.authDelegate = authDelegateMock

        let oldCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: httpCode))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                return
            }
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
            let data = """
            {
                "AccessToken": "new test access token",
                "RefreshToken": "new test refresh token",
                "TokenType": "new test token type",
                "Scopes": ["scope1", "scope2"],
                "UID": "new test session uid"
            }
            """.utf8!
            let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
            completion(nil, .success(response))
        }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if counter == 1 {
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 401)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
            } else if counter == 2 {
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 200)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .success([:]))
            } else {
                XCTFail(); return
            }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(onRefreshCounter.value == 1)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.lastArguments?.value, "test sessionUID")
    }

    func test401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith400AndSessionAcquisitionSuccedAndRetryCallSucceeds() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallSucceeds(httpCode: 400)
        }
    }

    func test401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith422AndSessionAcquisitionSuccedAndRetryCallSucceeds() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallSucceeds(httpCode: 422)
        }
    }

    private func ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionErrors(httpCode: Int) async {
        // GIVEN
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        service.authDelegate = authDelegateMock

        let oldCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: httpCode))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                return
                
            }
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: httpCode))
            completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
        }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if counter == 1 {
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 401)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
            } else {
                XCTFail(); return
            }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertNil(result.response)
        XCTAssertEqual(result.error?.code, httpCode)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(onRefreshCounter.value == 1)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.lastArguments?.value, "test sessionUID")
    }

    func test401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith400AndSessionAcquisitionErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionErrors(httpCode: 400)
        }
    }

    func test401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith422AndSessionAcquisitionErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsSucceedsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionErrors(httpCode: 422)
        }
    }

    private func ensure401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallErrors(httpCode: Int) async {
        // GIVEN
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        service.authDelegate = authDelegateMock

        let oldCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test sessionUID", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in oldCredentials }
        
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: httpCode))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                return
            }
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
            let data = """
            {
                "AccessToken": "new test access token",
                "RefreshToken": "new test refresh token",
                "TokenType": "new test token type",
                "Scopes": ["scope1", "scope2"],
                "UID": "new test session uid"
            }
            """.utf8!
            let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
            completion(nil, .success(response))
        }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if counter == 1 || counter == 2 {
                guard request.urlString.hasSuffix("/unit/tests") else { XCTFail(); return }
                let response = HTTPURLResponse(statusCode: 401)
                let task = URLSessionDataTaskMock(response: response)
                completion(task, .failure(.responseBodyIsNotAJSONDictionary(body: nil, response: response)))
            } else {
                XCTFail(); return
            }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }

        // THEN
        XCTAssertNil(result.response)
        XCTAssertEqual(result.error?.bestShotAtReasonableErrorCode, 401)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(onRefreshCounter.value == 1)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.lastArguments?.value, "test sessionUID")
    }

    func test401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith400AndSessionAcquisitionSuccedAndRetryCallErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallErrors(httpCode: 400)
        }
    }

    func test401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsWith422AndSessionAcquisitionSuccedAndRetryCallErrors() async {
        await withFeatureSwitches([.unauthSession]) {
            await ensure401WithCredentialsErrorsIfUnauthenticateSessionAndRefreshCredentialsErrorsAndSessionAcquisitionSuccedAndRetryCallErrors(httpCode: 422)
        }
    }

    // MARK: - Part 3 — credential refreshing logic — legacy path
    
    /*
     
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen.
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen. if it fails, operation fail
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen. if it succeeds, operation is retried with
     [+] if no authenticated and there is an error with code 401, refresh credentials call doesn't happen
     [+] if no authCounter and there is an error with code 401, refresh credentials call doesn't happen
     
     */
    
    func testIfAuthenticatedAndAuthCounterAndCredentialsAnd401ThenRefreshCallHappens_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }

            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    onRefreshCounter.mutate {
                        $0 += 1
                    }
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
                    let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
                    completion(task, .failure(.networkingEngineError(underlyingError:underlyingError)))
                }
            }

            // WHEN
            _ = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(onRefreshCounter.value == 1)
        }
    }
    
    func testIfRefreshCallHappensAndFailsThenOperationFails_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }
           
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    onRefreshCounter.mutate {
                        $0 += 1
                    }
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
                    let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
                    completion(task, .failure(.networkingEngineError(underlyingError:underlyingError)))
                    return
                }
            }
            
            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertEqual(result.error?.code, 4242)
        }
    }
    
    func testIfRefreshCallHappensAndSucceedsThenOperationIsRetried_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, _, completion in
                if counter == 1 {
                    completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
                } else {
                    completion(nil, .success(["Code": 1000]))
                }
            }
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "test access token new",
                    "RefreshToken": "test refresh token new",
                    "TokenType": "test refresh token new",
                    "Scopes": ["full"],
                }
                """.utf8!
                let response = try! decoder!.decode(RefreshResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(result.response?["Code"] as? Int, 1000)
        }
    }
    
    func testIfNotAuthenticatedAnd401ThenRefreshCallDoesNotHappens_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertEqual(result.error, NSError(domain: NSURLErrorDomain, code: 401))
        }
    }
    
    func testIfNoAutoRetryAnd401ThenRefreshCallDoesNotHappens_LegacyPath() async throws {
        await withFeatureSwitches([]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", userName: "test userName", userID: "test userID")
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: false,
                                customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertEqual(result.error, NSError(domain: NSURLErrorDomain, code: 401))
        }
    }
    
    // MARK: - Part 4 — concurrent tests with token in-memory persistance
    
    func testOnlyOneRefreshHappensEvenIfMultipleRequestsGet401() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let auth: Atomic<AuthCredential> = .init(.dummy.updated(
                sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old", userName: "test userName", userID: "test userID")
            )
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
            authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
                auth.mutate { $0 = AuthCredential(credentials) }
            }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if request.value(key: "Authorization") == "Bearer test accessToken old" {
                    completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
                } else {
                    completion(nil, .success(["Code": 1000]))
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "test access token new",
                    "RefreshToken": "test refresh token new",
                    "TokenType": "test refresh token new",
                    "Scopes": ["full"],
                }
                """.utf8!
                let response = try! decoder!.decode(RefreshResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true, customAuthCredential: nil,
                                nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
            XCTAssertEqual(results.count, Int(numberOfRequests))
        }
    }
    
    func testOnlyOneRefreshHappensEvenIfMultipleRequestsGet401AndAuthIsUpdatedInPlace() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let auth: Atomic<AuthCredential> = .init(.dummy.updated(
                sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old", userName: "test userName", userID: "test userID")
            )
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
            authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
                auth.mutate {
                    $0.udpate(sessionID: credentials.UID, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken)
                }
            }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if request.value(key: "Authorization") == "Bearer test accessToken old" {
                    completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
                } else {
                    completion(nil, .success(["Code": 1000]))
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "test access token new",
                    "RefreshToken": "test refresh token new",
                    "TokenType": "test refresh token new",
                    "Scopes": ["full"],
                }
                """.utf8!
                let response = try! decoder!.decode(RefreshResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }

            // WHEN
            let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true, customAuthCredential: nil,
                                nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
            XCTAssertEqual(results.count, Int(numberOfRequests))
        }
    }

    func testOnlyOneSessionAcquisitionHappensEvenIfMultipleRequestsGet401() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let auth: Atomic<AuthCredential> = .init(.dummy.updated(
                sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old"
            ))
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
            authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
                auth.mutate { $0 = AuthCredential(credentials) }
            }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if request.value(key: "Authorization") == "Bearer test accessToken old" {
                    completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
                } else {
                    completion(nil, .success(["Code": 1000]))
                }
            }
            
            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    onRefreshCounter.mutate {
                        $0 += 1
                    }
                    let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
                    completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                    return
                }
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                completion(nil, .success(response))
            }

            // WHEN
            let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true, customAuthCredential: nil,
                                nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(onRefreshCounter.value == 1)
            XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.callCounter == 2)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
            XCTAssertEqual(results.count, Int(numberOfRequests))
            XCTAssertEqual(auth.value.sessionID, "new test session uid")
        }
    }

    func testOnlyOneSessionAcquisitionHappensEvenIfMultipleRequestsGet401AndAuthIsUpdatedInPlace() async {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            let auth: Atomic<AuthCredential> = .init(.dummy.updated(
                sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old"
            ))
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
            authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
                auth.mutate {
                    $0.udpate(sessionID: credentials.UID, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken)
                }
            }
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
            sessionMock.requestJSONStub.bodyIs { counter, request, completion in
                if request.value(key: "Authorization") == "Bearer test accessToken old" {
                    completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
                } else {
                    completion(nil, .success(["Code": 1000]))
                }
            }

            sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
                SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            }
            let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                    onRefreshCounter.mutate {
                        $0 += 1
                    }
                    let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test error message")
                    let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
                    completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
                    return
                }
                guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                completion(nil, .success(response))
            }

            // WHEN
            let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
                service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil,
                                authenticated: true, autoRetry: true, customAuthCredential: nil,
                                nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
            }

            // THEN
            XCTAssertTrue(onRefreshCounter.value == 1)
            XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
            XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.callCounter == 2)
            XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
            XCTAssertEqual(results.count, Int(numberOfRequests))
            XCTAssertEqual(auth.value.sessionID, "new test session uid")
        }
    }

    // MARK: - Part 5 — session acquisition

    func testSessionAcquireCallDoesNothingIfSessionIsAlreadyAvailable() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in
                AuthCredential(sessionID: "test", accessToken: "test", refreshToken: "test", userName: "test", userID: "test", privateKey: "test", passwordKeySalt: "test")
            }
            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionAlreadyPresent) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasNotCalled)
        }
    }

    func testSessionAcquireCallDoesNothingIfNoDelegate() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionUnavailableAndNotFetched) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasNotCalled)
        }
    }

    func testSessionAcquireCallSucceedsIfSessionAcquireCallSucceeds() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let task = URLSessionDataTaskMock(response: .init(statusCode: 200))
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionFetchedAndAvailable) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(service.sessionUID, "new test session uid")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
            XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.accessToken, "new test access token")
        }
    }

    func testSessionAcquireCallContainsFingerprintData() async throws {
        try await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let challengeProperties: ChallengeParametersProvider = .forAPIService(clientApp: .other(named: "core"))
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            var capturedRequest: SessionRequest?
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let task = URLSessionDataTaskMock(response: .init(statusCode: 200))
                capturedRequest = request
                let data = """
                {
                    "AccessToken": "new test access token",
                    "RefreshToken": "new test refresh token",
                    "TokenType": "new test token type",
                    "Scopes": ["scope1", "scope2"],
                    "UID": "new test session uid"
                }
                """.utf8!
                let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                completion(task, .success(response))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionFetchedAndAvailable) = result else { XCTFail(); return }
            let parameters = try XCTUnwrap(capturedRequest?.parameters as? [String: Any])
            let payload = try XCTUnwrap(parameters["Payload"] as? [String: Any])
            let challenge0 = try XCTUnwrap(payload["\(challengeProperties.prefix)-ios-v4-challenge-0"] as? [String: Any])
            let challenge1 = try XCTUnwrap(payload["\(challengeProperties.prefix)-ios-v4-challenge-1"] as? [String: Any])
            let challangeParameters0 = try XCTUnwrap(challengeProperties.provideParameters().first) as NSDictionary
            let challangeParameters1 = try XCTUnwrap(challengeProperties.provideParameters().last) as NSDictionary
            XCTAssertTrue(challangeParameters0.isEqual(to: challenge0))
            XCTAssertTrue(challangeParameters1.isEqual(to: challenge1))
        }
    }

    func testSessionAcquireCallFailsSilentlyIfSessionAcquireCallFailsWithHttpResponse() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let task = URLSessionDataTaskMock(response: .init(statusCode: 404))
                completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionUnavailableAndNotFetched) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(service.sessionUID, "test sessionUID")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        }
    }

    func testSessionAcquireCallFailsIfSessionAcquireCallFailsWithoutHttpResponseAndNoAR() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                let task = URLSessionDataTaskMock()
                completion(task, .failure(.networkingEngineError(underlyingError: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue))))
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .failure(let error) = result else { XCTFail(); return }
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.timedOut.rawValue)
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
            XCTAssertEqual(service.sessionUID, "test sessionUID")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        }
    }

    func testSessionAcquireCallSucceedsIfSessionAcquireCallFailsButARRetrySucceeds() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                switch counter {
                case 1:
                    let task = URLSessionDataTaskMock()
                    completion(task, .failure(.networkingEngineError(underlyingError: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue))))
                case 2:
                    let task = URLSessionDataTaskMock(response: .init(statusCode: 200))
                    let data = """
                    {
                        "AccessToken": "new test access token",
                        "RefreshToken": "new test refresh token",
                        "TokenType": "new test token type",
                        "Scopes": ["scope1", "scope2"],
                        "UID": "new test session uid"
                    }
                    """.utf8!
                    let response = try! decoder!.decode(SessionsRequestResponse.self, from: data)
                    completion(task, .success(response))
                default:
                    XCTFail()
                    completion(nil, .failure(.configurationError))
                }
            }
            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, host, requestHeaders, sessionId, response, error, callCompletionBlockUsing, completion in
                switch counter {
                case 1: completion(true)
                case 2: completion(false)
                default: XCTFail(); completion(false)
                }
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionFetchedAndAvailable) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
            XCTAssertEqual(service.sessionUID, "new test session uid")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
            XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.accessToken, "new test access token")
        }
    }

    func testSessionAcquireCallFailsSilentlyIfSessionAcquireCallFailsAndARRetryFailsWithResponse() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                switch counter {
                case 1:
                    let task = URLSessionDataTaskMock()
                    completion(task, .failure(.networkingEngineError(underlyingError: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue))))
                case 2:
                    let task = URLSessionDataTaskMock(response: .init(statusCode: 404))
                    completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
                default:
                    XCTFail()
                    completion(nil, .failure(.configurationError))
                }
            }
            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, host, requestHeaders, sessionId, response, error, callCompletionBlockUsing, completion in
                switch counter {
                case 1: completion(true)
                case 2: completion(false)
                default: XCTFail(); completion(false)
                }
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .success(.sessionUnavailableAndNotFetched) = result else { XCTFail(); return }
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
            XCTAssertEqual(service.sessionUID, "test sessionUID")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        }
    }

    func testSessionAcquireCallFailsIfSessionAcquireCallFailsAndARRetryFailsWithoutResponse() async throws {
        await withFeatureSwitches([.unauthSession]) {
            // GIVEN
            let service = testService
            service.authDelegate = authDelegateMock
            sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
                SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
            }
            sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
                guard request.urlString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
                switch counter {
                case 1:
                    let task = URLSessionDataTaskMock()
                    completion(task, .failure(.networkingEngineError(underlyingError: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue))))
                case 2:
                    let task = URLSessionDataTaskMock()
                    completion(task, .failure(.networkingEngineError(underlyingError: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue))))
                default:
                    XCTFail()
                    completion(nil, .failure(.configurationError))
                }
            }
            dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { counter, host, requestHeaders, sessionId, response, error, callCompletionBlockUsing, completion in
                switch counter {
                case 1: completion(true)
                case 2: completion(false)
                default: XCTFail(); completion(false)
                }
            }

            // WHEN
            let result = await withCheckedContinuation { continuation in
                service.acquireSessionIfNeeded(completion: continuation.resume(returning:))
            }

            // THEN
            guard case .failure(let error) = result else { XCTFail(); return }
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.timedOut.rawValue)
            XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
            XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
            XCTAssertEqual(service.sessionUID, "test sessionUID")
            XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        }
    }
}
