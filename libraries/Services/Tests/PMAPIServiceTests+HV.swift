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
import ProtonCore_TestingToolkit
import ProtonCore_Utilities

@testable import ProtonCore_Services
@testable import ProtonCore_Networking

@available(iOS 13.0.0, *)
final class PMAPIServiceHVTests: XCTestCase {
    
    var dohMock: DohMock! = nil
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
        humanDelegateMock = HumanVerifyDelegateMock()
    }
    
    struct TestResponse: APIDecodableResponse, Equatable {
        var code: Int?
        var error: String?
        var details: HumanVerificationDetails?
    }
    
    func testHumanVerificationIsLaunchedForJSONRequest_HVClose() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success(["Code": 9001])) }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.close)
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }
        
        // THEN
        XCTAssertTrue(humanDelegateMock.onHumanVerifyStub.wasCalledExactlyOnce)
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(try JSONSerialization.data(withJSONObject: value),
                       try JSONSerialization.data(withJSONObject: ["Code": 9001]))
    }
    
    func testHumanVerificationIsLaunchedForJSONRequest_HVError() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { _, _, completion in completion(nil, .success(["Code": 9001])) }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.closeWithError(code: 1234, description: "Test error"))
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(try value.serializedToData(), try ["Code": 1234, "Error": "Test error"].serializedToData())
    }
    
    func testHumanVerificationIsLaunchedForJSONRequest_HVSuccess() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestJSONStub.bodyIs { counter, _, completion in
            switch counter {
            case 0: completion(nil, .success(["Code": 9001]))
            case 1: completion(nil, .success(["Code": 1234]))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
        }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.verification(header: [:], verificationCodeBlock: { isSuccessful, responseError, blockFinish in blockFinish?() }))
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(try JSONSerialization.data(withJSONObject: value),
                       try JSONSerialization.data(withJSONObject: ["Code": 1234]))
    }
    
    func testHumanVerificationIsLaunchedForCodableRequest_HVClose() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, _, _, completion in
            completion(nil, .success(TestResponse(code: 9001, error: "hv", details: nil)))
        }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.close)
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<TestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(value, TestResponse(code: 9001, error: "hv", details: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableRequest_HVError() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, _, _, completion in
            completion(nil, .success(TestResponse(code: 9001, error: "hv", details: nil)))
        }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.closeWithError(code: 1234, description: "test error"))
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<TestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(value, TestResponse(code: 1234, error: "test error", details: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableRequest_HVSuccess() async throws {
        let service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
        service.humanDelegate = humanDelegateMock
        
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 30.0, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { counter, _, _, completion in
            switch counter {
            case 0: completion(nil, .success(TestResponse(code: 9001, error: "hv", details: nil)))
            case 1: completion(nil, .success(TestResponse(code: 1234, error: nil, details: nil)))
            default: XCTFail("Stub shouldn't be called more than twice")
            }
            
        }
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.verification(header: [:], verificationCodeBlock: { isSuccessful, responseError, blockFinish in blockFinish?() }))
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<TestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.value)
        XCTAssertEqual(value, TestResponse(code: 1234, error: nil, details: nil))
    }
}
