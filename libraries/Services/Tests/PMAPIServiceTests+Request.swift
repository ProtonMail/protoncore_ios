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
import ProtonCore_CoreTranslation
import ProtonCore_TestingToolkit
import ProtonCore_Utilities

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
    
    override func setUp() {
        super.setUp()
        dohMock = DohMock()
        dohMock.statusStub.fixture = .on
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "test.host.url" }
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, executor, completion in
            executor.execute { completion(false) }
        }
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in false }
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
    
    // MARK: - Part 0 - deprecated API
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedRequestMethods_Variant1() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: false,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, completion: optionalContinuation(continuation))
        }
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedRequestMethods_Variant2() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false,
                            autoRetry: false, customAuthCredential: nil, completion: optionalContinuation(continuation))
        }
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedRequestMethods_Variant3() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false,
                            nonDefaultTimeout: nil, completion: optionalContinuation(continuation))
        }
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedDownloadMethod() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.downloadStub.bodyIs { _, _, _, completion in
            completion(nil, nil, nil)
        }
        
        let result = await withCheckedContinuation { continuation in
            service.download(byUrl: "", destinationDirectoryURL: URL(fileURLWithPath: "/"), headers: nil, authenticated: false, customAuthCredential: nil) { _ in } completion: { continuation.resume(returning: ($0, $1, $2)) }
        }
        
        XCTAssertNil(result.0)
        XCTAssertNil(result.1)
        XCTAssertNil(result.2)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant1() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadJSONStub.bodyIs { _, _, _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.upload(byPath: "unit/tests", parameters: [:], keyPackets: Data(), dataPacket: Data(), signature: nil, headers: nil,
                           authenticated: false, customAuthCredential: nil, nonDefaultTimeout: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant2() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadJSONStub.bodyIs { _, _, _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.upload(byPath: "unit/tests", parameters: [:], keyPackets: Data(), dataPacket: Data(), signature: nil, headers: nil,
                           authenticated: false, customAuthCredential: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant3() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadFromFileJSONStub.bodyIs { _, _, _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.uploadFromFile(byPath: "unit/tests", parameters: [:], keyPackets: Data(), dataPacketSourceFileURL: URL(fileURLWithPath: "/"), signature: nil,
                                   headers: nil, authenticated: false, customAuthCredential: nil, nonDefaultTimeout: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant4() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadFromFileJSONStub.bodyIs { _, _, _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.uploadFromFile(byPath: "unit/tests", parameters: [:], keyPackets: Data(), dataPacketSourceFileURL: URL(fileURLWithPath: "/"), signature: nil,
                                   headers: nil, authenticated: false, customAuthCredential: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant5() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadWithFilesJSONStub.bodyIs { _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.upload(byPath: "unit/tests", parameters: nil, files: [:], headers: nil, authenticated: false, customAuthCredential: nil,
                           uploadProgress: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    @available(*, deprecated, message: "testing deprecated api")
    func testDeprecatedUploadMethods_Variant6() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        
        sessionMock.uploadWithFilesJSONStub.bodyIs { _, _, _, completion, _ in
            completion(nil, .success(["Code": 1000]))
        }
        
        let result = await withCheckedContinuation { continuation in
            service.upload(byPath: "unit/tests", parameters: nil, files: [:], headers: nil, authenticated: false, customAuthCredential: nil,
                           nonDefaultTimeout: nil, uploadProgress: nil, completion: optionalContinuation(continuation))
        }
        
        XCTAssertNil(result.task)
        XCTAssertEqual(try result.response?.serializedToData(), try ["Code": 1000].serializedToData())
        XCTAssertNil(result.error)
    }
    
    // MARK: - Part 1 — logic before network operation
    /*
     
     new added what to test:
     
     -- if authenticated is false
     
     [+] with/withou customAuthCredential no fatching happend
     
     */
    func testNoFetchingWhenAuthenticatedIsFalseWithCustomAuthCredential() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: authCredential, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    func testNoFetchingWhenAuthenticatedIsFalseWithOutCustomAuthCredential() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    /*
     
     What to test:
     
     [+] if customAuthCredential, no fetching happens
     [+] if customAuthCredential, request is created with access token from customAuthCredential
     
     [+] if no customAuthCredential, fetching happens
     [+] if no customAuthCredential, authenticated and fetching fails, operation fails
     [+] if no customAuthCredential, not authenticated and fetching fails, request is created without access token
     
     [+] if no customAuthCredential, authenticated and fetching succeeds, request is created with fetched access token
     [+] if no customAuthCredential, not authenticated and fetching succeeds, request is created with fetched access token
     
     [+] if request creation throws, the operation fails
     
    */
    
    func testNoFetchingWhenCustomAuthCredentials() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: authCredential, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNil(result.task)
        XCTAssertTrue(try XCTUnwrap(result.response).isEmpty)
        XCTAssertNil(result.error)
    }
    
    func testRequestContainsCustomAuthAccessTokenWhenCustomAuthCredentials() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: authCredential, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
        XCTAssertEqual(request.value(key: "Authorization"), "Bearer test accessToken")
    }
    
    func testFetchingHappensWhenNoCustomAuthCredentials() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
    }
    
    func testOperationFailsIfAuthenticatedAndFetchingFails() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(sessionMock.generateStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error, PMAPIService.AuthCredentialFetchingResult.notFound.toNSError)
    }
    
    func testIfNotAuthenticatedAndFetchingFailsRequestWithoutAccessTokenIsCreated() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
        XCTAssertNil(request.value(key: "Authorization"))
    }
    
    func testIfAuthenticatedAndFetchingFailsRequestWithoutAccessTokenIsCreated() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result.error?.localizedDescription, "Empty token")
    }
    
    func testIfAuthenticatedAndFetchingSucceedsRequestWithAccessTokenIsCreated() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
        XCTAssertEqual(request.value(key: "Authorization"), "Bearer test accessToken")
    }
    
    func testIfNotAuthenticatedAndFetchingSucceedsRequestWithAccessTokenIsCreated() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        let request = try XCTUnwrap(sessionMock.requestJSONStub.lastArguments?.first)
        XCTAssertEqual(request.value(key: "Authorization"), nil)
    }
    
    func testIfRequestCreationFailsOperationFails() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        
        enum TestError: Error { case testError }
        sessionMock.generateStub.bodyIs { _, _, _, _, _, _ in throw TestError.testError }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertTrue(sessionMock.requestJSONStub.wasNotCalled)
        XCTAssertEqual(result.error, TestError.testError as NSError)
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
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        
        enum TestError: Error { case testError }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(SessionResponseError.networkingEngineError(underlyingError: TestError.testError as NSError))) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onUpdateStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.onLogoutStub.wasNotCalled)
        XCTAssertEqual(result.error, TestError.testError as NSError)
    }
    
    func testServerTimeIsUpdatedAccordingToResponse() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.serviceDelegate = apiServiceDelegateMock
        
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        let task = URLSessionDataTaskMock()
        task.responseStub.fixture = HTTPURLResponse(url: URL(string: "https://unit.test")!, statusCode: 0, httpVersion: nil,
                                                    headerFields: ["Date": "Fri, 13 May 2022 09:42:00 +02:00"])
        let date = DateParser.parse(time: "Fri, 13 May 2022 09:42:00 +02:00").map { Int64($0.timeIntervalSince1970) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(task, .success([:])) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(apiServiceDelegateMock.onUpdateStub.wasCalledExactlyOnce)
        XCTAssertEqual(apiServiceDelegateMock.onUpdateStub.lastArguments?.value, date)
    }
    
    func testTLSErrorIsPassedToDoHIfFailsTLS() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        sessionMock.failsTLSStub.bodyIs { _, _ in "test TLS error description" }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
        XCTAssertTrue(sessionMock.failsTLSStub.wasCalledExactlyOnce)
        XCTAssertIdentical(sessionMock.failsTLSStub.lastArguments?.value, sessionMock.requestJSONStub.lastArguments?.first)
        let error = try XCTUnwrap(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.capturedArguments.last?.a5)
        XCTAssertEqual(error.messageForTheUser, "test TLS error description")
    }
    
    func testErrorIsPassedToHandleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        enum TestError: Error, Equatable { case testError }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: TestError.testError as NSError))) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(sessionMock.requestJSONStub.wasCalledExactlyOnce)
        let error = try XCTUnwrap(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.capturedArguments.last?.a5)
        XCTAssertEqual(error as? TestError, TestError.testError)
    }
    
    func testNoAuthenticatedRequestIsRestartedIfDoHSaysSo() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
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
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
        XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
    }
    
    func testAuthenticatedRequestIsRestartedIfDoHSaysSo() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
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
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.getTokenAuthCredentialStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
        XCTAssertEqual(dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.callCounter, 2)
    }
    
    func testAPIMightBeBlockedIsReturnedIfNoRetryAndDoHError() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.serviceDelegate = apiServiceDelegateMock
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success([:])) }
        
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in true }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
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
    
    // MARK: - Part 3 — credential refreshing logic
    
    /*
     
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen.
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen. if it fails, operation fail
     [+] if authenticated and authCounter and credentials and there is an error with code 401, refresh credentials call happen. if it succeeds, operation is retried with
     [+] if no authenticated and there is an error with code 401, refresh credentials call doesn't happen
     [+] if no authCounter and there is an error with code 401, refresh credentials call doesn't happen
     
     */
    
    func testIfAuthenticatedAndAuthCounterAndCredentialsAnd401ThenRefreshCallHappens() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }
        
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.emptyAuthResponse)) }
        
        // WHEN
        _ = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
    }
    
    func testIfRefreshCallHappensAndFailsThenOperationFails() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }
        
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.failure(.emptyAuthResponse)) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertEqual(result.error?.code, AuthErrors.emptyAuthResponse.codeInNetworking)
    }
    
    func testIfRefreshCallHappensAndSucceedsThenOperationIsRetried() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
            } else {
                completion(nil, .success(["Code": 1000]))
            }
        }
        
        let refreshedCredentials = Credential.dummy.updated(
            UID: "test sessionID", accessToken: "test accessToken refreshed", refreshToken: "test refreshToken refreshed", expiration: .distantFuture, scope: ["full"]
        )
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.success(refreshedCredentials)) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertEqual(sessionMock.requestJSONStub.callCounter, 2)
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(result.response?["Code"] as? Int, 1000)
    }
    
    func testIfNotAuthenticatedAnd401ThenRefreshCallDoesNotHappens() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: false, autoRetry: true,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertEqual(result.error, NSError(domain: NSURLErrorDomain, code: 401))
    }
    
    func testIfNoAutoRetryAnd401ThenRefreshCallDoesNotHappens() async throws {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in authCredential }
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401)))) }
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil, authenticated: true, autoRetry: false,
                            customAuthCredential: nil, nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasNotCalled)
        XCTAssertEqual(result.error, NSError(domain: NSURLErrorDomain, code: 401))
    }
    
    // MARK: - Part 4 — concurrent tests with token in-memory persistance
    
    func testOnlyOneRefreshHappensEvenIfMultipleRequestsGet401() async {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let auth: Atomic<AuthCredential> = .init(.dummy.updated(
            sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old",
            expiration: .distantFuture, userName: "test userName", userID: "test userID")
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
        authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
            auth.mutate { $0 = AuthCredential(credentials) }
        }
        let refreshedCredentials = Credential.dummy.updated(
            UID: "test sessionID", accessToken: "test accessToken refreshed", refreshToken: "test refreshToken refreshed", expiration: .distantFuture, scope: ["full"]
        )
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.success(refreshedCredentials)) }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if request.value(key: "Authorization") == "Bearer test accessToken old" {
                completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
            } else {
                completion(nil, .success(["Code": 1000]))
            }
        }
        
        // WHEN
        let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true, customAuthCredential: nil,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
        XCTAssertEqual(results.count, Int(numberOfRequests))
    }
    
    func testOnlyOneRefreshHappensEvenIfMultipleRequestsGet401AndAuthIsUpdatedInPlace() async {
        // GIVEN
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        let auth: Atomic<AuthCredential> = .init(.dummy.updated(
            sessionID: "test sessionID", accessToken: "test accessToken old", refreshToken: "test refreshToken old",
            expiration: .distantFuture, userName: "test userName", userID: "test userID")
        )
        authDelegateMock.getTokenAuthCredentialStub.bodyIs { _, _ in auth.value }
        authDelegateMock.onUpdateStub.bodyIs { _, credentials, _ in
            auth.mutate {
                $0.udpate(sessionID: credentials.UID, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, expiration: credentials.expiration)
            }
        }
        let refreshedCredentials = Credential.dummy.updated(
            UID: "test sessionID", accessToken: "test accessToken refreshed", refreshToken: "test refreshToken refreshed", expiration: .distantFuture, scope: ["full"]
        )
        authDelegateMock.onRefreshStub.bodyIs { _, _, _, completion in completion(.success(refreshedCredentials)) }
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy) }
        sessionMock.requestJSONStub.bodyIs { counter, request, completion in
            if request.value(key: "Authorization") == "Bearer test accessToken old" {
                completion(nil, .failure(.networkingEngineError(underlyingError: NSError(domain: NSURLErrorDomain, code: 401))))
            } else {
                completion(nil, .success(["Code": 1000]))
            }
        }
        
        // WHEN
        let results = await performConcurrentlySettingExpectations(amount: numberOfRequests) { index, continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: true, autoRetry: true, customAuthCredential: nil,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated, jsonCompletion: optionalContinuation(continuation))
        }
        
        // THEN
        XCTAssertTrue(authDelegateMock.onRefreshStub.wasCalledExactlyOnce)
        XCTAssertEqual(authDelegateMock.getTokenAuthCredentialStub.callCounter, numberOfRequests * 2)
        XCTAssertTrue(authDelegateMock.getTokenCredentialStub.wasNotCalled)
        XCTAssertEqual(sessionMock.requestJSONStub.callCounter, numberOfRequests * 2)
        XCTAssertEqual(results.count, Int(numberOfRequests))
    }

}
