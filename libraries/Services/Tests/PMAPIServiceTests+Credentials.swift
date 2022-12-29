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
import ProtonCore_Networking
import ProtonCore_TestingToolkit
import ProtonCore_Utilities
import ProtonCore_Doh

@testable import ProtonCore_Services

@available(iOS 13.0.0, *)
final class PMAPIServiceCredentialsTests: XCTestCase {
    
    let numberOfRequests: UInt = 50
    
    var dohMock: DohMock!
    var doh: DoHInterface!
    var sessionUID: String!
    var cacheToClearMock: URLCacheMock!
    var sessionMock: SessionMock!
    var sessionFactoryMock: SessionFactoryMock!
    var trustKitProviderMock: TrustKitProviderMock!
    var apiServiceDelegateMock: APIServiceDelegateMock!
    var authDelegateMock: AuthDelegateMock!
    
    override func setUp() {
        super.setUp()
        dohMock = DohMock()
        doh = dohMock
        sessionUID = "PMAPIServiceTests_testAdditionalHeaders"
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
        _ = PMAPIService.createAPIService(doh: doh,
                         sessionUID: sessionUID,
                         sessionFactory: sessionFactoryMock,
                         cacheToClear: cacheToClearMock,
                         trustKitProvider: trustKitProviderMock)
        XCTAssertEqual(result, hostUrl)
    }
    
    func testPMAPIServiceInitializer_ShouldSetSessionChallange() {
        trustKitProviderMock.noTrustKitStub.fixture = false
        trustKitProviderMock.trustKitStub.fixture = TrustKit(configuration: [:])
        var noTrustKit: Bool?
        var trustKit: TrustKit?
        sessionMock.setChallengeStub.bodyIs { _, noTrustKitParameter, trustKitParameter in
            noTrustKit = noTrustKitParameter
            trustKit = trustKitParameter
        }
        _ = PMAPIService.createAPIService(doh: doh,
                         sessionUID: sessionUID,
                         sessionFactory: sessionFactoryMock,
                         cacheToClear: cacheToClearMock,
                         trustKitProvider: trustKitProviderMock)
        XCTAssertFalse(noTrustKit!)
        XCTAssertNotNil(trustKit)
    }
    
    func testAdditionalHeaders_ShouldBeAddedToSessionRequest() async {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result, .wrongConfigurationNoDelegate)
    }
    
    func testTokenFetchFailsWhenNoTokenAvailable() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result, .notFound)
    }
    
    func testTokenFetchReturnsTokenWhenAvailable() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .found(let fetchedCredentials) = result else { XCTFail(); return }
        XCTAssertEqual(Credential(fetchedCredentials), Credential(freshCredentials))
    }
    
    // MARK: - Fetch token stress tests
    
    func testTokenFetchFailsWhenNoAuthDelegate_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                sessionUID: "test_session_uid",
                                sessionFactory: sessionFactoryMock,
                                cacheToClear: cacheToClearMock,
                                trustKitProvider: trustKitProviderMock)
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0 == .wrongConfigurationNoDelegate })
    }
    
    func testTokenFetchFailsWhenNoTokenAvailable_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredentials(completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.capturedArguments.allSatisfy { $0.value == "test_session_uid" })
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0 == .notFound })
    }
    
    func testTokenFetchReturnsTokenWhenAvailable_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .found(let fetchedCredentials) = $0 else { return false }
            return Credential(freshCredentials) == Credential(fetchedCredentials)
        })
    }
    
    // MARK: - Refresh token logic tests
    
    func testTokenRefreshFailsWhenNoAuthDelegate() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .wrongConfigurationNoDelegate = result else { XCTFail(); return }
    }
    
    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let fetchedCredentials) = result else { XCTFail(); return }
        XCTAssertEqual(Credential(currentCredentials), Credential(fetchedCredentials))
    }
    
    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.notImplementedYet(""))) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .noCredentialsToBeRefreshed = result else { XCTFail(); return }
    }
    
    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.notImplementedYet(""))) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshingError(underlyingError: .notImplementedYet("")) = result else { XCTFail(); return }
    }
    
    func testTokenRefreshCallSuccess() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let freshCredential = Credential.dummy
            .updated(UID: "test_user_session", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        authDelegateMock.onRefreshStub.bodyIs { _, sessionId, _, completion in
            // run on a different queue to simulate network call queue change
            DispatchQueue.global(qos: .userInitiated).async { completion(.success(freshCredential)) }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.first, freshCredential)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }
    
    func testTokenRefreshCallWhenHttpError422() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 422, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        guard case .logout(let capturedError) = result else { XCTFail(); return }
        XCTAssertEqual(capturedError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallWhenHttpError400() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 400, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        guard case .logout(let capturedError) = result else { XCTFail(); return }
        XCTAssertEqual(capturedError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallWhenHttpError500() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 500, responseCode: nil, userFacingMessage: nil, underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        guard case .refreshingError(let capturedError) = result else { XCTFail(); return }
        guard case .networkingError(let responseError) = capturedError else { XCTFail(); return }
        XCTAssertEqual(responseError.underlyingError, underlyingError)
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let freshCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 401, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { counter, _, _, completion in
            if counter == 1 {
                DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
            } else {
                DispatchQueue.global(qos: .userInitiated).async { completion(.success(freshCredential)) }
            }
        }

        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        guard case .refreshed(let returnedCredentials) = result else { XCTFail(); return }
        // scope is dropped when transforming from Credential to AuthCredentials
        XCTAssertEqual(Credential(returnedCredentials), freshCredential.updated(scopes: []))
    }
    
    // MARK: - Refresh token stress tests
    
    func testTokenRefreshFailsWhenNoAuthDelegate_StressTests() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .wrongConfigurationNoDelegate = $0 { return true } else { return false }
        })
    }
    
    func testTokenRefreshDoesNotRefreshIfCurrentCredentialsAreDifferentThan401Credentials_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
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
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(Credential(credentials), returnedCredentials.transform { $0?.updated(scopes: []) })
            return true
        })
    }
    
    func testTokenRefreshCallsDoesNotRefreshIfThereAreNoCurrentCredentials_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in nil }
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.notImplementedYet(""))) }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .noCredentialsToBeRefreshed = $0 { return true } else { return false }
        })
    }
    
    func testTokenRefreshCallsRefreshingIfCurrentCredentialsAreTheSameAs401Credentials_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        // WHEN
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.notImplementedYet(""))) }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            if case .refreshingError(.notImplementedYet("")) = $0 { return true } else { return false }
        })
    }
     
    func testTokenRefreshCallSuccess_StressTests() async {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token new", refreshToken: "test refresh token new", scopes: ["full"])
        authDelegateMock.onRefreshStub.bodyIs { _, sessionId, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(.success(newCredential)) }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onUpdateStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onUpdateStub.capturedArguments.allSatisfy { $0.first == newCredential })
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshed(let credentials) = $0 else { return false }
            XCTAssertEqual(Credential(credentials), newCredential.updated(scopes: []))
            return true
        })
    }
    
    func testTokenRefreshCallWhenHttpError422_StressTests() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 422, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }

    func testTokenRefreshCallWhenHttpError400_StressTests() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 400, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, numberOfRequests)
        XCTAssertEqual(authDelegateMock.onLogoutStub.callCounter, numberOfRequests)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .logout(let responseError) = $0 else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }
    
    func testTokenRefreshCallWhenHttpError500_StressTests() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let underlyingError = NSError(domain: NSURLErrorDomain, code: 500, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 500, responseCode: nil, userFacingMessage: nil, underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in
            DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, numberOfRequests)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, Int(numberOfRequests))
        XCTAssertTrue(fetchResults.allSatisfy {
            guard case .refreshingError(let authError) = $0 else { return false }
            guard case .networkingError(let responseError) = authError else { return false }
            XCTAssertEqual(responseError.underlyingError, underlyingError)
            return true
        })
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError_StressTests() async throws {
        // GIVEN
        let service = PMAPIService.createAPIService(doh: doh,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let rottenCredentials = AuthCredential(Credential.dummy
            .updated(UID: "test_session_uid", accessToken: "test access token old", refreshToken: "test refresh token old", scopes: ["full"])
        )
        
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, sessionId in rottenCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token refreshed", refreshToken: "test refresh token refreshed", scopes: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 401, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { counter, _, _, completion in
            if counter == 1 {
                DispatchQueue.global(qos: .userInitiated).async { completion(.failure(error)) }
            } else {
                DispatchQueue.global(qos: .userInitiated).async { completion(.success(newCredential)) }
            }
        }

        // WHEN
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.refreshAuthCredential(credentialsCausing401: rottenCredentials, completion: continuation.resume(returning:))
        }

        // THEN
        // are in incrementing by one because the local cache bad error retries the refresh token fetching
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests + 1)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, numberOfRequests + 1)
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
