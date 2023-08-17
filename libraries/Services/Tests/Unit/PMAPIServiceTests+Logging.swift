//
//  PMAPIServiceTests+Logging.swift
//  ProtonCore-Services-Tests - Created on 22/06/23.
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
import ProtonCoreFoundations
import ProtonCoreNetworking
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreObservability
import ProtonCoreUtilities
import ProtonCoreDoh

@testable import ProtonCoreServices

@available(iOS 13.0.0, *)
final class PMAPIServiceLoggingTests: XCTestCase {
    
    var dohMock: DohMock!
    var doh: DoHInterface!
    var cacheToClearMock: URLCacheMock!
    var sessionMock: SessionMock!
    var sessionFactoryMock: SessionFactoryMock!
    var trustKitProviderMock: TrustKitProviderMock!
    var apiServiceDelegateMock: APIServiceDelegateMock!
    var authDelegateMock: AuthDelegateMock!
    var loggingDelegateMock: APIServiceLoggingDelegateMock!
    
    func testService(challenge: PMChallenge) -> (PMAPIService, ChallengeProperties) {
        let challengeParameterProvider = ChallengeParametersProvider.forAPIService(clientApp: .other(named: "core"), challenge: challenge)
        let service = PMAPIService.createAPIService(doh: doh,
                                                    sessionUID: "test_session_uid",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: challengeParameterProvider)
        service.loggingDelegate = loggingDelegateMock
        service.authDelegate = authDelegateMock
        let challengeProperties = ChallengeProperties(challenges: challengeParameterProvider.provideParametersForSessionFetching(),
                                                      productPrefix: challengeParameterProvider.prefix)
        return (service, challengeProperties)
    }
    
    override func setUp() {
        super.setUp()
        dohMock = DohMock()
        doh = dohMock
        cacheToClearMock = URLCacheMock()
        let sessionMockInstance = SessionMock()
        sessionMock = sessionMockInstance
        sessionFactoryMock = SessionFactoryMock()
        trustKitProviderMock = TrustKitProviderMock()
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "test.host.url" }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, _ in return sessionMockInstance }
        apiServiceDelegateMock = APIServiceDelegateMock()
        authDelegateMock = AuthDelegateMock()
        loggingDelegateMock = APIServiceLoggingDelegateMock()
    }
    
    // MARK: - Access token refresh logging
    
    func testAccessTokenRefreshLogging_NoAuthDelegate() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        service.authDelegate = nil
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .noAuthDelegate = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
    }
    
    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .noAccessTokenToBeRefreshed = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
    }
    
    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        let currentCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in currentCredentials }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidSucceedStub.wasCalledExactlyOnce)
        guard case .freshAccessTokenAlreadyAvailable = loggingDelegateMock.accessTokenRefreshDidSucceedStub.lastArguments?.third
        else { XCTFail(); return }
    }
    
    func testTokenRefreshCallSuccess() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let response = RefreshResponse(accessToken: "test access token new", tokenType: "test token type",
                                           scopes: ["full"], refreshToken: "test refresh token new")
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
            completion(task, .success(response))
        }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidSucceedStub.wasCalledExactlyOnce)
        guard case .accessTokenRefreshed = loggingDelegateMock.accessTokenRefreshDidSucceedStub.lastArguments?.third
        else { XCTFail(); return }
    }

    private func ensureLogoutHappensForAuthenticatedSession(for code: Int) async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .refreshFailedWithLogout = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
    }

    func testTokenRefreshCallWhenHttpError422_AuthenticatedSession() async {
        await ensureLogoutHappensForAuthenticatedSession(for: 422)
    }

    func testTokenRefreshCallWhenHttpError400_AuthenticatedSession() async {
        await ensureLogoutHappensForAuthenticatedSession(for: 400)
    }
    
    private func ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for code: Int) async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: code))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") {
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
            } else { XCTFail(); return }
        }

        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .unauthSessionInvalidatedAndRefetched = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
    }

    func testTokenRefreshCallWhenHttpError422_UnauthenticatedSession_AcquireSessionSuccess() async {
        await ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for: 422)
    }

    func testTokenRefreshCallWhenHttpError400_UnauthenticatedSession_AcquireSessionSuccess() async {
        await ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for: 400)
    }

    func testTokenRefreshCallWhenHttpError500_AuthenticatedSession() async {
        let code = 500
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: code, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: code))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .refreshFailedWithAuthError(.networkingError(let responseError)) = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }

    func testTokenRefreshCallWhenHttpError500_UnauthenticatedSession() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token",
                     refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidStartStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        guard case .refreshFailedWithAuthError(.networkingError(let responseError)) = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_AuthenticatedSession() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", userName: "jdoe", userID: "34r3", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad,
                                      localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                // There is contract with backend that this API call can't return 401. If 401 is mocked here then our code deadlocks itself.
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 404))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else {
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
        }

        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(loggingDelegateMock.accessTokenRefreshDidStartStub.callCounter, 2)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidSucceedStub.wasCalledExactlyOnce)
        guard case .localCacheBadRefreshRetried = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
        guard case .accessTokenRefreshed = loggingDelegateMock.accessTokenRefreshDidSucceedStub.lastArguments?.third
        else { XCTFail(); return }
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_UnauthenticatedSession() async {
        // GIVEN
        let (service, challengeProperties) = testService(challenge: PMChallenge())

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                // There is contract with backend that this API call can't return 401. If 401 is mocked here then our code deadlocks itself.
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 404))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else {
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
        }
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(loggingDelegateMock.accessTokenRefreshDidStartStub.callCounter, 2)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidFailStub.wasCalledExactlyOnce)
        XCTAssertTrue(loggingDelegateMock.accessTokenRefreshDidSucceedStub.wasCalledExactlyOnce)
        guard case .localCacheBadRefreshRetried = loggingDelegateMock.accessTokenRefreshDidFailStub.lastArguments?.third
        else { XCTFail(); return }
        guard case .accessTokenRefreshed = loggingDelegateMock.accessTokenRefreshDidSucceedStub.lastArguments?.third
        else { XCTFail(); return }
    }
}

#endif
