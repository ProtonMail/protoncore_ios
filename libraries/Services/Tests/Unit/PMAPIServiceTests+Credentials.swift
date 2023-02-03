//
//  PMAPIServiceTests+Credentials.swift
//  ProtonCore-Services-Tests - Created on 16/02/22.
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
import ProtonCore_Networking
import ProtonCore_TestingToolkit
import ProtonCore_Utilities
import ProtonCore_Doh

@testable import ProtonCore_Services

@available(iOS 13.0.0, *)
final class PMAPIServiceCredentialsTests: XCTestCase {
    
    let numberOfRequests: UInt = 50

    let challengeParameterProvider = ChallengeParametersProvider.forAPIService(clientApp: .other(named: "core"))
    var challengeProperties: ChallengeProperties { ChallengeProperties(challenges: challengeParameterProvider.provideParameters(),
                                                                       productPrefix: challengeParameterProvider.prefix) }
    
    var dohMock: DohMock!
    var doh: DoHInterface!
    var cacheToClearMock: URLCacheMock!
    var sessionMock: SessionMock!
    var sessionFactoryMock: SessionFactoryMock!
    var trustKitProviderMock: TrustKitProviderMock!
    var apiServiceDelegateMock: APIServiceDelegateMock!
    var authDelegateMock: AuthDelegateMock!
    var testService: PMAPIService {
        PMAPIService.createAPIService(doh: doh,
                                      sessionUID: "test_session_uid",
                                      sessionFactory: sessionFactoryMock,
                                      cacheToClear: cacheToClearMock,
                                      trustKitProvider: trustKitProviderMock,
                                      challengeParametersProvider: challengeParameterProvider)
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
    }

    func testPMAPIServiceInitializer_ShouldCreateSessionWithProperURL() {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        var result: String?
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            result = url
            return sessionMockInstance
        }
        _ = testService
        XCTAssertEqual(result, hostUrl)
    }
    
    func testPMAPIServiceInitializer_ShouldSetSessionChallenge() {
        trustKitProviderMock.noTrustKitStub.fixture = false
        trustKitProviderMock.trustKitStub.fixture = TrustKit(configuration: [:])
        var noTrustKit: Bool?
        var trustKit: TrustKit?
        sessionMock.setChallengeStub.bodyIs { _, noTrustKitParameter, trustKitParameter in
            noTrustKit = noTrustKitParameter
            trustKit = trustKitParameter
        }
        _ = testService
        XCTAssertFalse(noTrustKit!)
        XCTAssertNotNil(trustKit)
    }
    
    func testAdditionalHeaders_ShouldBeAddedToSessionRequest() async {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, requestParameter, completion in
            request = requestParameter
            completion(nil, .success([:]))
        }
        await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: false, customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { _, _ in
                continuation.resume()
            }
        }
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "unit testing")
    }
    
    func testAdditionalHeaders_ShouldBeAppendedToPerRequestHeaders() async {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, requestParameter, completion in
            request = requestParameter
            completion(nil, .success([:]))
        }
        await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: ["x-pm-individual-header": "individual"], authenticated: false, autoRetry: false, customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { _, _ in
                continuation.resume()
            }
        }
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "unit testing")
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-individual-header"], "individual")
    }
    
    func testAdditionalHeaders_ShouldNotOverridePerRequestHeaders() async {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = testService
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, requestParameter, completion in
            request = requestParameter
            completion(nil, .success([:]))
        }
        await withCheckedContinuation { continuation in
            service.request(method: .get, path: "/unit/tests", parameters: nil, headers: ["x-pm-unit-tests": "bla bla"], authenticated: false, autoRetry: false, customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .background) { _, _ in
                continuation.resume()
            }
        }
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "bla bla")
    }
    
    // MARK: - Fetch token logic tests
    
    func testTokenFetchFailsWhenNoAuthDelegate() async {
        // GIVEN
        let service = testService
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result, .wrongConfigurationNoDelegate)
    }
    
    func testTokenFetchFailsWhenNoTokenAvailable() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result, .notFound)
    }
    
    func testTokenFetchReturnsTokenWhenAvailable() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let freshCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in freshCredentials }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .found(let fetchedCredentials) = result else { XCTFail(); return }
        XCTAssertEqual(Credential(fetchedCredentials), Credential(freshCredentials))
    }
    
    // MARK: - Fetch token stress tests
    
    func testTokenFetchFailsWhenNoAuthDelegate_StressTests() async {
        // GIVEN
        let service = testService
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0 == .wrongConfigurationNoDelegate })
    }
    
    func testTokenFetchFailsWhenNoTokenAvailable_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0 == .notFound })
    }
    
    func testTokenFetchReturnsTokenWhenAvailable_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let freshCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in freshCredentials }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .found(let fetchedCredentials) = $0 else { return false }
            return Credential(freshCredentials) == Credential(fetchedCredentials)
        })
    }

    // MARK: - acquire session logic tests

    private func assertThatNoAuthDelegateMethodWasCalled() {
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
    }

    func testSessionAcquiringFailsWhenNoDelegate() async {
        // GIVEN
        let service = testService

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.acquireSession(deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        assertThatNoAuthDelegateMethodWasCalled()

        guard case .wrongConfigurationNoDelegate = result else { XCTFail(); return }
        XCTAssertEqual(service.sessionUID, "test_session_uid")
    }

    func testSessionAcquiringSuccess() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
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
        let result = await withCheckedContinuation { continuation in
            service.acquireSession(deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        guard case .acquired(let credentials) = result else { XCTFail(); return }

        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasNotCalled)

        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.a2, "test_session_uid")
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments.map { AuthCredential($0.a1).description }, credentials.description)
        XCTAssertEqual(service.sessionUID, "new test session uid")
    }

    private func ensureSessionAcquiringErrorsOut(for code: Int) async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, _, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: code))
            completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.acquireSession(deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        guard case .acquiringError = result else { XCTFail(); return }
        assertThatNoAuthDelegateMethodWasCalled()
        XCTAssertEqual(service.sessionUID, "test_session_uid")
    }

    func testSessionAcquiringWhenHttpError500() async {
        await ensureSessionAcquiringErrorsOut(for: 500)
    }

    func testSessionAcquiringWhenHttpError401() async {
        await ensureSessionAcquiringErrorsOut(for: 401)
    }

    func testSessionAcquiringWhenHttpError400() async {
        await ensureSessionAcquiringErrorsOut(for: 400)
    }

    func testSessionAcquiringWhenHttpError422() async {
        await ensureSessionAcquiringErrorsOut(for: 422)
    }

    // MARK: - Refresh token logic tests

    func testTokenRefreshFailsWhenNoAuthDelegate() async {
        // GIVEN
        let service = testService

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        assertThatNoAuthDelegateMethodWasCalled()
        guard case .wrongConfigurationNoDelegate = result else { XCTFail(); return }
    }

    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )

        let currentCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in currentCredentials }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let fetchedCredentials) = result else { XCTFail(); return }
        XCTAssertEqual(Credential(currentCredentials), Credential(fetchedCredentials))
    }

    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .noCredentialsToBeRefreshed = result else { XCTFail(); return }
    }

    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token",
                     refreshToken: "test refresh token", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        let error = SessionResponseError.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
            completion(task, .failure(error))
        }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshingError(let authError) = result else { XCTFail(); return }
        XCTAssertTrue(error.underlyingError == authError.underlyingError)
    }

    func testTokenRefreshCallSuccess() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let freshCredential = Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new",
                     refreshToken: "test refresh token new", scopes: ["full"])
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
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first, freshCredential)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }

    private func ensureLogoutHappensForAuthenticatedSession(for code: Int) async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        guard case .logout(let capturedError) = result else { XCTFail(); return }
        XCTAssertEqual(capturedError.underlyingError, underlyingError)
    }

    func testTokenRefreshCallWhenHttpError422_AuthenticatedSession() async {
        await ensureLogoutHappensForAuthenticatedSession(for: 422)
    }

    func testTokenRefreshCallWhenHttpError400_AuthenticatedSession() async {
        await ensureLogoutHappensForAuthenticatedSession(for: 400)
    }

    private func ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for code: Int) async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
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
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(onRefreshCounter.value == 1)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        guard case .refreshed(let credentials) = result else { XCTFail(); return }
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.UID, credentials.sessionID)
        XCTAssertEqual(credentials.sessionID, "new test session uid")
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.second, "test_session_uid")
    }

    func testTokenRefreshCallWhenHttpError422_UnauthenticatedSession_AcquireSessionSuccess() async {
        await ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for: 422)
    }

    func testTokenRefreshCallWhenHttpError400_UnauthenticatedSession_AcquireSessionSuccess() async {
        await ensureTokenRefreshForSuccessfulSessionAcquisitionForUnauthenticatedSession(for: 400)
    }

    private func ensureTokenRefreshForFailingSessionAcquisitionForUnauthenticatedSession(for code: Int) async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: code))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
                completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
            } else { XCTFail(); return }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(onRefreshCounter.value == 1)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.lastArguments?.value, "test_session_uid")
        guard case .refreshingError(underlyingError: .networkingError(let responseError)) = result else { XCTFail(); return }
        XCTAssertEqual(responseError.httpCode, 401)
    }

    func testTokenRefreshCallWhenHttpError422_UnauthenticatedSession_AcquireSessionFail() async {
        await ensureTokenRefreshForFailingSessionAcquisitionForUnauthenticatedSession(for: 422)
    }

    func testTokenRefreshCallWhenHttpError400_UnauthenticatedSession_AcquireSessionFail() async {
        await ensureTokenRefreshForFailingSessionAcquisitionForUnauthenticatedSession(for: 400)
    }

    func testTokenRefreshCallWhenHttpError500_AuthenticatedSession() async {
        let code = 500
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        guard case .refreshingError(let capturedError) = result else { XCTFail(); return }
        guard case .networkingError(let responseError) = capturedError else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }

    func testTokenRefreshCallWhenHttpError500_UnauthenticatedSession() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token",
                     refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        guard case .refreshingError(let capturedError) = result else { XCTFail(); return }
        guard case .networkingError(let responseError) = capturedError else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_AuthenticatedSession() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let freshCredential = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad,
                                      localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
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
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_UnauthenticatedSession() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let freshCredential = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
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
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }

    // MARK: - Refresh token stress tests

    func testTokenRefreshFailsWhenNoAuthDelegate_StressTests() async throws {
        // GIVEN
        let service = testService

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        assertThatNoAuthDelegateMethodWasCalled()
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .wrongConfigurationNoDelegate = $0 { return true } else { return false }
        })
    }

    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )

        let currentCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in currentCredentials }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(credentials.description, currentCredentials.description)
            return true
        })
    }

    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .noCredentialsToBeRefreshed = $0 { return true } else { return false }
        })
    }

    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )

        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        let error = SessionResponseError.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 501))
            completion(task, .failure(error))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard error.underlyingError == authError.underlyingError else { return false }
            return true
        })
    }

    func testTokenRefreshCallSuccess_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let freshCredential = Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.first?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.dropFirst().allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onUpdateStub.capturedArguments.allSatisfy { $0.first == freshCredential })
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(Credential(credentials), freshCredential.updated(scopes: []))
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError422_AuthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 422))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError422_UnauthenticatedSession_AcquireSessionSuccess_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 422))
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.first?.value == "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.dropFirst().allSatisfy { $0.value == "new test session uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(onRefreshCounter.value, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.first?.value == "test_session_uid")
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.dropFirst().allSatisfy { $0.value == "new test session uid" })
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.UID, credentials.sessionID)
            XCTAssertEqual(credentials.sessionID, "new test session uid")
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError422_UnauthenticatedSession_AcquireSessionFail_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        let onRefreshCounter: Atomic<UInt> = .init(0) // only tracking refresh calls
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") {
                onRefreshCounter.mutate {
                    $0 += 1
                }
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 422))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
                completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
            } else { XCTFail(); return }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(onRefreshCounter.value, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(underlyingError: .networkingError(let responseError)) = $0 else { return false }
            XCTAssertEqual(responseError.httpCode, 401)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError400_AuthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError400_UnauthenticatedSession_AcquireSessionSuccess_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
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
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") {
                let data =
                """
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.first?.value == "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.dropFirst().allSatisfy { $0.value == "new test session uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(onRefreshCounter.value, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.first?.value == "test_session_uid")
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.dropFirst().allSatisfy { $0.value == "new test session uid" })
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.UID, credentials.sessionID)
            XCTAssertEqual(credentials.sessionID, "new test session uid")
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError400_UnauthenticatedSession_AcquireSessionFail_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
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
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else if let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/sessions") {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
                completion(task, .failure(.responseBodyIsNotADecodableObject(body: nil, response: nil)))
            } else { XCTFail(); return }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(onRefreshCounter.value, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.eraseUnauthSessionCredentialsStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.eraseUnauthSessionCredentialsStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(underlyingError: .networkingError(let responseError)) = $0 else { return false }
            XCTAssertEqual(responseError.httpCode, 401)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError500_AuthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token",
                     userName: "test username", userID: "test user ID", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard case .networkingError(let responseError) = authError else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError500_UnauthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard case .networkingError(let responseError) = authError else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_AuthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy.updated(UID: "test_session_uid",
                                                                        accessToken: "test access token old",
                                                                        refreshToken: "test refresh token old",
                                                                        scopes: ["full"]))
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        let freshCredential = Credential.dummy.updated(UID: "test_session_uid",
                                                       accessToken: "test access token new",
                                                       refreshToken: "test refresh token new",
                                                       scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests + 1)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests + 1)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let capturedCredentials) = $0 else { return false }
            XCTAssertEqual(Credential(capturedCredentials), freshCredential.updated(scopes: []))
            return true
        })
    }

    func testTokenRefreshCallRestartOnBadLocalCacheError_UnauthenticatedSession_StressTests() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock

        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }

        let freshCredential = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: false, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests + 1)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests + 1)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let capturedCredentials) = $0 else { return false }
            XCTAssertEqual(Credential(capturedCredentials), freshCredential.updated(scopes: []))
            return true
        })
    }
    
    // MARK: - Legacy path: Refresh token logic tests
    
    func testTokenRefreshFailsWhenNoAuthDelegate_LegacyPath() async {
        // GIVEN
        let service = testService
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .wrongConfigurationNoDelegate = result else { XCTFail(); return }
    }
    
    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        let currentCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in currentCredentials }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let fetchedCredentials) = result else { XCTFail(); return }
        XCTAssertEqual(Credential(currentCredentials), Credential(fetchedCredentials))
    }
    
    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .noCredentialsToBeRefreshed = result else { XCTFail(); return }
    }
    
    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        let error = SessionResponseError.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
            completion(task, .failure(error))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshingError(let authError) = result else { XCTFail(); return }
        XCTAssertTrue(error.underlyingError == authError.underlyingError)
    }
    
    func testTokenRefreshCallSuccess_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy.updated(UID: "test_session_uid",
                                                                        accessToken: "test access token old",
                                                                        refreshToken: "test refresh token old",
                                                                        scopes: ["full"]))
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        let freshCredential = Credential.dummy.updated(UID: "test_session_uid",
                                                       accessToken: "test access token new",
                                                       refreshToken: "test refresh token new",
                                                       scopes: ["full"])
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
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first.accessToken, freshCredential.accessToken)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }
    
    func testTokenRefreshCallWhenHttpError422_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 422))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        guard case .logout(let capturedError) = result else { XCTFail(); return }
        XCTAssertEqual(capturedError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallWhenHttpError400_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        guard case .logout(let capturedError) = result else { XCTFail(); return }
        XCTAssertEqual(capturedError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallWhenHttpError500_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestDecodableStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        guard case .refreshingError(let capturedError) = result else { XCTFail(); return }
        guard case .networkingError(let responseError) = capturedError else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let freshCredential = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs {count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
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
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }
    
    // MARK: - Legacy path: Refresh token stress tests
    
    func testTokenRefreshFailsWhenNoAuthDelegate_StressTests_LegacyPath() async throws {
        // GIVEN
        let service = testService
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .wrongConfigurationNoDelegate = $0 { return true } else { return false }
        })
    }
    
    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials_StressTests_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        let returnedCredentials: Atomic<Credential?> = .init(Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token refreshed", refreshToken: "test refresh token refreshed", scopes: ["full"]))
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in
            returnedCredentials.value.map { AuthCredential($0) }
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials, _ in
            returnedCredentials.mutate { $0 = newCredentials }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(Credential(credentials), returnedCredentials.transform { $0?.updated(scopes: []) })
            return true
        })
    }
    
    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials_StressTests_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)))
        }
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .noCredentialsToBeRefreshed = $0 { return true } else { return false }
        })
    }
    
    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials_StressTests_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters,
                                                         urlString: path, method: method,
                                                         timeout: timeout!, retryPolicy: retryPolicy) }
        let error = SessionResponseError.networkingEngineError(underlyingError: AuthErrors.notImplementedYet("").underlyingError)
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
            completion(task, .failure(error))
        }
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard error.underlyingError == authError.underlyingError else { return false }
            return true
        })
    }
     
    func testTokenRefreshCallSuccess_StressTests_LegacyPath() async {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        let newCredential = Credential.dummy.updated(UID: "test_session_uid",
                                                     accessToken: "test access token new",
                                                     refreshToken: "test refresh token new", scopes: ["full"])
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
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onUpdateStub.capturedArguments.allSatisfy {
            $0.first.accessToken == newCredential.accessToken
        })
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(Credential(credentials), newCredential.updated(scopes: []))
            return true
        })
    }
    
    func testTokenRefreshCallWhenHttpError422_StressTests_LegacyPath() async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 422))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError400_StressTests_LegacyPath() async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials,
                                          withoutSupportForUnauthenticatedSessions: true,
                                          deviceFingerprints: self.challengeProperties,
                                          completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }
    
    func testTokenRefreshCallWhenHttpError500_StressTests_LegacyPath() async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 500))
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard case .networkingError(let responseError) = authError else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError_StressTests_LegacyPath() async throws {
        // GIVEN
        let service = testService
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token refreshed", refreshToken: "test refresh token refreshed", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad,
                                      localizedDescription: "test description")
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { count, request, decoder, completion in
            guard let url = request.request?.url, url.absoluteString.hasSuffix("/auth/v4/refresh") else { XCTFail(); return }
            if count == 1 {
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 401))
                completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
            } else {
                let data =
                """
                {
                    "AccessToken": "test access token refreshed",
                    "RefreshToken": "test refresh token refreshed",
                    "TokenType": "test refresh token refreshed",
                    "Scopes": ["full"],
                }
                """.utf8!
                let response = try! decoder!.decode(RefreshResponse.self, from: data)
                let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 200))
                completion(task, .success(response))
            }
        }
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, withoutSupportForUnauthenticatedSessions: true, deviceFingerprints: self.challengeProperties, completion: continuation.resume(returning:))
        }

        // THEN
        // are in incrementing by one because the local cache bad error retries the refresh token fetching
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests + 1)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestDecodableStub.callCounter, numberOfRequests + 1)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let capturedCredentials) = $0 else { return false }
            XCTAssertEqual(Credential(capturedCredentials), newCredential.updated(scopes: []))
            return true
        })
    }
}
