//
//  PMAPIServiceTests.swift
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

@testable import ProtonCore_Services

@available(iOS 13.0.0, *)
final class PMAPIServiceTests: XCTestCase {
    
    var dohMock: DohMock! = nil
    var sessionUID: String! = nil
    var cacheToClearMock: URLCacheMock! = nil
    var sessionMock: SessionMock! = nil
    var sessionFactoryMock: SessionFactoryMock! = nil
    var trustKitProviderMock: TrustKitProviderMock! = nil
    var apiServiceDelegateMock: APIServiceDelegateMock! = nil
    var authDelegateMock: AuthDelegateMock! = nil
    
    override func setUp() {
        super.setUp()
        dohMock = DohMock()
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
        _ = PMAPIService(doh: dohMock,
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
        _ = PMAPIService(doh: dohMock,
                         sessionUID: sessionUID,
                         sessionFactory: sessionFactoryMock,
                         cacheToClear: cacheToClearMock,
                         trustKitProvider: trustKitProviderMock)
        XCTAssertFalse(noTrustKit!)
        XCTAssertNotNil(trustKit)
    }
    
    func testAdditionalHeaders_ShouldBeAddedToSessionRequest() {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0)
        }
        sessionMock.requestStub.bodyIs { _, requestParameter, _ in
            request = requestParameter
        }
        service.request(method: .get, path: "/unit/tests", parameters: nil, headers: nil, authenticated: false, nonDefaultTimeout: nil, completion: nil)
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "unit testing")
    }
    
    func testAdditionalHeaders_ShouldBeAppendedToPerRequestHeaders() {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0)
        }
        sessionMock.requestStub.bodyIs { _, requestParameter, _ in
            request = requestParameter
        }
        service.request(method: .get, path: "/unit/tests", parameters: nil, headers: ["x-pm-individual-header": "individual"], authenticated: false, nonDefaultTimeout: nil, completion: nil)
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "unit testing")
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-individual-header"], "individual")
    }
    
    func testAdditionalHeaders_ShouldNotOverridePerRequestHeaders() {
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["x-pm-unit-tests": "unit testing"]
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: sessionUID,
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.serviceDelegate = apiServiceDelegateMock
        var request: SessionRequest?
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout ?? 0.0)
        }
        sessionMock.requestStub.bodyIs { _, requestParameter, _ in
            request = requestParameter
        }
        service.request(method: .get, path: "/unit/tests", parameters: nil, headers: ["x-pm-unit-tests": "bla bla"], authenticated: false, nonDefaultTimeout: nil, completion: nil)
        request?.updateHeader()
        XCTAssertEqual(request!.request!.allHTTPHeaderFields!["x-pm-unit-tests"], "bla bla")
    }
    
    // MARK: - Refresh token logic tests
    
    func testTokenRefreshFailsWhenNoAuthDelegate() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        // WHEN
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertNil(accessToken)
        XCTAssertNil(sessionId)
        let error = try XCTUnwrap(maybeError)
        XCTAssertEqual(error.domain, "AuthDelegate is required")
    }
    
    func testTokenRefreshFailsWhenNoTokenAvailable() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        // WHEN
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in nil }
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertNil(accessToken)
        XCTAssertNil(sessionId)
        let error = try XCTUnwrap(maybeError)
        XCTAssertEqual(error.domain, "Empty token")
    }
    
    func testTokenRefreshReturnsTokenWhenAvailable() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let freshCredentials = Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        authDelegateMock.getTokenStub.bodyIs { _, _ in AuthCredential(freshCredentials) }

        // WHEN
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertEqual(accessToken, "test access token")
        XCTAssertEqual(sessionId, "test_session_uid")
        XCTAssertEqual(maybeError, nil)
    }
    
    func testTokenRefreshCallSuccess() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let expiredCredentials = AuthCredential.dummy
        
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in expiredCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        authDelegateMock.onRefreshStub.bodyIs { _, sessionId, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, nil) }
        }

        // WHEN
        expiredCredentials.expire()
        
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.value, newCredential)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(accessToken, "test access token")
        XCTAssertEqual(sessionId, "test_session_uid")
        XCTAssertEqual(maybeError, nil)
    }
    
    func testTokenRefreshCallWhenHttpError422() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let expiredCredentials = AuthCredential.dummy
        authDelegateMock.getTokenStub.bodyIs { _, _ in expiredCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 422, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
        }

        // WHEN
        expiredCredentials.expire()
        
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        XCTAssertEqual(accessToken, nil)
        XCTAssertEqual(sessionId, "test_session_uid")
        let capturedError = try XCTUnwrap(maybeError)
        XCTAssertEqual(capturedError, underlyingError)
    }
    
    func testTokenRefreshCallWhenHttpError400() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let expiredCredentials = AuthCredential.dummy
        authDelegateMock.getTokenStub.bodyIs { _, _ in expiredCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 400, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
        }

        // WHEN
        expiredCredentials.expire()
        
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        XCTAssertEqual(accessToken, nil)
        XCTAssertEqual(sessionId, "test_session_uid")
        let capturedError = try XCTUnwrap(maybeError)
        XCTAssertEqual(capturedError, underlyingError)
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let expiredCredentials = AuthCredential.dummy
        authDelegateMock.getTokenStub.bodyIs { _, _ in expiredCredentials }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 401, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { counter, _, completion in
            if counter == 1 {
                DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
            } else {
                DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, nil) }
            }
        }

        // WHEN
        expiredCredentials.expire()
        
        let (accessToken, sessionId, maybeError) = await withCheckedContinuation { continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, 2)
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(accessToken, "test access token")
        XCTAssertEqual(sessionId, "test_session_uid")
        XCTAssertNil(maybeError)
    }
    
    // MARK: - Refresh token stress tests
    
    let numberOfRequests = 50
    
    func testTokenRefreshFailsWhenNoAuthDelegate_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == nil })
        XCTAssertTrue(fetchResults.allSatisfy { $0.1 == nil })
        XCTAssertTrue(fetchResults.allSatisfy { $0.2?.domain == "AuthDelegate is required" })
    }
    
    func testTokenRefreshFailsWhenNoTokenAvailable_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        // WHEN
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in nil }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == nil })
        XCTAssertTrue(fetchResults.allSatisfy { $0.1 == nil })
        XCTAssertTrue(fetchResults.allSatisfy { $0.2?.domain == "Empty token" })
    }
    
    func testTokenRefreshReturnsTokenWhenAvailable_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let returnedCredentials: Atomic<Credential?> = .init(Credential.dummy.updated(UID: "test_session_uid", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"]))
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in
            returnedCredentials.value.map { AuthCredential($0) }
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = newCredentials }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == "test access token" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.1 == "test_session_uid" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.2 == nil })
    }
    
    func testTokenRefreshCallSuccess_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let returnedCredentials: Atomic<AuthCredential?> = .init(.dummy)
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in
            returnedCredentials.value
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = AuthCredential(newCredentials) }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        authDelegateMock.onRefreshStub.bodyIs { _, sessionId, completion in
            // run on a different queue to simulate network call
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, nil) }
        }

        // WHEN
        returnedCredentials.mutate { $0?.expire() }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests))
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onUpdateStub.lastArguments?.value, newCredential)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == "test access token" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.1 == "test_session_uid" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.2 == nil })
    }
    
    func testTokenRefreshCallWhenHttpError422_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let returnedCredentials: Atomic<AuthCredential?> = .init(.dummy)
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in
            returnedCredentials.value
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = AuthCredential(newCredentials) }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 422, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, completion in
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
        }

        // WHEN
        returnedCredentials.mutate { $0?.expire() }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests))
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, 1)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        XCTAssertEqual(fetchResults.count, numberOfRequests)
        XCTAssertEqual(fetchResults.first?.1, "test_session_uid")
        XCTAssertEqual(fetchResults.first?.2, underlyingError)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == nil })
        XCTAssertTrue(fetchResults.dropFirst().allSatisfy { $0.1 == nil })
        XCTAssertTrue(fetchResults.dropFirst().allSatisfy { $0.2?.domain == "Empty token" })
    }

    func testTokenRefreshCallWhenHttpError400_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        let returnedCredentials: Atomic<AuthCredential?> = .init(.dummy)
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in
            returnedCredentials.value
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = AuthCredential(newCredentials) }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }
        
        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 400, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { _, _, completion in
            DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
        }

        // WHEN
        returnedCredentials.mutate { $0?.expire() }
        
        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }
        
        // THEN
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests))
        XCTAssertEqual(authDelegateMock.getTokenStub.lastArguments?.value, "test_session_uid")
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, 1)
        XCTAssertEqual(authDelegateMock.onRefreshStub.lastArguments?.first, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.onLogoutStub.lastArguments?.value, "test_session_uid")
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertEqual(fetchResults.count, numberOfRequests)
        XCTAssertEqual(fetchResults.first?.1, "test_session_uid")
        XCTAssertEqual(fetchResults.first?.2, underlyingError)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == nil })
        XCTAssertTrue(fetchResults.dropFirst().allSatisfy { $0.1 == nil })
        XCTAssertTrue(fetchResults.dropFirst().allSatisfy { $0.2?.domain == "Empty token" })
    }
    
    func testTokenRefreshCallRestartOnBadLocalCacheError_StressTests() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test_session_uid",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock

        let returnedCredentials: Atomic<AuthCredential?> = .init(.dummy)
        authDelegateMock.getTokenStub.bodyIs { _, sessionId in
            returnedCredentials.value
        }
        authDelegateMock.onUpdateStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = AuthCredential(newCredentials) }
        }
        authDelegateMock.onLogoutStub.bodyIs { _, newCredentials in
            returnedCredentials.mutate { $0 = nil }
        }

        let newCredential = Credential.dummy.updated(UID: "test_user_session", accessToken: "test access token", refreshToken: "test refresh token", expiration: .distantFuture, scope: ["full"])
        let underlyingError = NSError(domain: "unit tests", code: APIErrorCode.AuthErrorCode.localCacheBad, localizedDescription: "test description")
        let error = AuthErrors.networkingError(.init(httpCode: 401, responseCode: 1000, userFacingMessage: "test message", underlyingError: underlyingError))
        authDelegateMock.onRefreshStub.bodyIs { counter, _, completion in
            if counter == 1 {
                DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, error) }
            } else {
                DispatchQueue.global(qos: .userInitiated).async { completion(newCredential, nil) }
            }
        }

        // WHEN
        returnedCredentials.mutate { $0?.expire() }

        let fetchResults = await performConcurrentlySettingExpectations(amount: numberOfRequests) { _, continuation in
            service.fetchAuthCredential { accessToken, sessionId, maybeError in
                continuation.resume(returning: (accessToken, sessionId, maybeError))
            }
        }

        // THEN
        // are in incrementing by one because the local cache bad error retries the refresh token fetching
        XCTAssertEqual(authDelegateMock.getTokenStub.callCounter, UInt(numberOfRequests + 1))
        XCTAssertEqual(authDelegateMock.onRefreshStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertTrue(fetchResults.allSatisfy { $0.0 == "test access token" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.1 == "test_session_uid" })
        XCTAssertTrue(fetchResults.allSatisfy { $0.2 == nil })
    }
}
