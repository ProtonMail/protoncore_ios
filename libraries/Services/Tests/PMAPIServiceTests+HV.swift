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
import ProtonCore_Doh
import ProtonCore_TestingToolkit
import ProtonCore_Utilities
@testable import ProtonCore_Authentication
@testable import ProtonCore_Services
@testable import ProtonCore_Networking

@available(iOS 13.0.0, *)
final class PMAPIServiceHVTests: XCTestCase {
    
    struct EmptyTestResponse: APIDecodableResponse, Equatable {}
    
    struct DataTestResponse: APIDecodableResponse, Equatable { let string: String; let number: Int }
    
    let humanVerificationResponse: HTTPURLResponse = .init(statusCode: 444)
    let humanVerificationResponseJSON: JSONDictionary = [
        "Code": 9001,
        "Error": "human verification in tests",
        "Details": [
            "HumanVerificationToken": "test human verification token",
            "Title": "test human verification title",
            "HumanVerificationMethods": ["test_human_verification_method"]
        ]
    ]
    lazy var humanVerificationResponseData: Data = try! JSONSerialization.data(withJSONObject: humanVerificationResponseJSON)
    lazy var humanVerificationSessionError: SessionResponseError = .responseBodyIsNotADecodableObject(body: humanVerificationResponseData, response: humanVerificationResponse)
    
    let someOtherErrorResponse: HTTPURLResponse = .init(statusCode: 400)
    let someOtherErrorResponseJSON: JSONDictionary = ["Code": 1234, "Error": "some other error in tests"]
    lazy var someOtherErrorResponseData: Data = try! JSONSerialization.data(withJSONObject: someOtherErrorResponseJSON)
    lazy var someOtherSessionError: SessionResponseError = .responseBodyIsNotADecodableObject(body: someOtherErrorResponseData, response: someOtherErrorResponse)
    
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
    
    func testHumanVerificationIsLaunchedForJSONResponse_HVClose() async throws {
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
        sessionMock.requestJSONStub.bodyIs { _, _, completion in
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .success(self.humanVerificationResponseJSON))
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
                            jsonCompletion: { task, result in continuation.resume(returning: (task, result)) })
        }
        
        // THEN
        XCTAssertTrue(humanDelegateMock.onHumanVerifyStub.wasCalledExactlyOnce)
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value.responseCode, 9001)
        XCTAssertEqual(value.error, "human verification in tests")
    }
    
    func testHumanVerificationIsLaunchedForJSONResponse_HVError() async throws {
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
        sessionMock.requestJSONStub.bodyIs { _, _, completion in
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .success(self.humanVerificationResponseJSON))
        }
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
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value.responseCode, 1234)
        XCTAssertEqual(value.userFacingMessage, "Test error")
    }
    
    func testHumanVerificationIsLaunchedForJSONResponse_ErrorInRetriedRequest() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .success(self.humanVerificationResponseJSON))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .success(self.someOtherErrorResponseJSON))
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
        let error = try XCTUnwrap(result.1.error)
        XCTAssertEqual(error.code, 1234)
        XCTAssertEqual(error.localizedDescription, "some other error in tests")
    }
    
    func testHumanVerificationIsLaunchedForJSONResponse_HVSuccess() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .success(self.humanVerificationResponseJSON))
            case 1: completion(URLSessionDataTaskMock(response: self.successfulResponse), .success(self.successfulResponseJSON))
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
                       try JSONSerialization.data(withJSONObject: self.successfulResponseJSON))
    }
    
    // MARK: - Codable empty response tests
    
    func testHumanVerificationIsLaunchedForCodableEmptyResponse_HVClose() async throws {
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
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
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
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 9001, userFacingMessage: "human verification in tests", underlyingError: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableEmptyResponse_HVError() async throws {
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
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
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
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 1234, userFacingMessage: "test error", underlyingError: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableEmptyResponse_ErrorInRetriedRequest() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .failure(self.someOtherSessionError))
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
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 400, responseCode: 1234, userFacingMessage: "some other error in tests",
                                            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: someOtherErrorResponseData, response: nil).underlyingError))
    }
    
    func testHumanVerificationIsLaunchedForCodableEmptyResponse_HVSuccess() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(try! JSONDecoder.decapitalisingFirstLetter.decode(EmptyTestResponse.self, from: self.successfulResponseData))
            )
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
                            decodableCompletion: { (task, result: Result<EmptyTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        _ = try XCTUnwrap(result.1.value)
    }
    
    // MARK: - Codable data response tests
    
    func testHumanVerificationIsLaunchedForCodableDataResponse_HVClose() async throws {
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
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
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
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 9001, userFacingMessage: "human verification in tests", underlyingError: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableDataResponse_HVError() async throws {
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
            completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
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
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 444, responseCode: 1234, userFacingMessage: "test error", underlyingError: nil))
    }
    
    func testHumanVerificationIsLaunchedForCodableDataResponse_ErrorInRetriedRequest() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
            case 1: completion(URLSessionDataTaskMock(response: self.someOtherErrorResponse), .failure(self.someOtherSessionError))
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
                            decodableCompletion: { (task, result: Result<DataTestResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let value = try XCTUnwrap(result.1.error as? ResponseError)
        XCTAssertEqual(value, ResponseError(httpCode: 400, responseCode: 1234, userFacingMessage: "some other error in tests",
                                            underlyingError: SessionResponseError.responseBodyIsNotADecodableObject(body: someOtherErrorResponseData, response: nil).underlyingError))
    }
    
    func testHumanVerificationIsLaunchedForCodableDataResponse_HVSuccess() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(try! JSONDecoder.decapitalisingFirstLetter.decode(DataTestResponse.self, from: self.successfulResponseData))
            )
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
    
    func testHumanVerificationIsLaunchedForPOSTAuth_HVSuccess() async throws {
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
            case 0: completion(URLSessionDataTaskMock(response: self.humanVerificationResponse), .failure(self.humanVerificationSessionError))
            case 1: completion(
                URLSessionDataTaskMock(response: self.successfulResponse),
                .success(AuthService.AuthRouteResponse(accessToken: "test access token",
                                                       expiresIn: 1000,
                                                       tokenType: "test token type",
                                                       refreshToken: "test refresh tokeb",
                                                       scope: "test scope",
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
        humanDelegateMock.onHumanVerifyStub.bodyIs { _, _, _, completion in
            completion(.verification(header: [:], verificationCodeBlock: { isSuccessful, responseError, blockFinish in blockFinish?() }))
        }
        
        let authCredential = AuthCredential.dummy.updated(sessionID: "test sessionID", accessToken: "test accessToken", refreshToken: "test refreshToken", expiration: .distantFuture, userName: "test userName", userID: "test userID")
        
        // WHEN
        let result = await withCheckedContinuation { continuation in
            service.request(method: .get, path: "unit/tests", parameters: nil, headers: nil,
                            authenticated: false, autoRetry: true, customAuthCredential: authCredential,
                            nonDefaultTimeout: nil, retryPolicy: .userInitiated,
                            decodableCompletion: { (task, result: Result<AuthService.AuthRouteResponse, APIService.APIError>) in
                continuation.resume(returning: (task, result))
            })
        }
        
        // THEN
        let response = try XCTUnwrap(result.1.value)
        XCTAssertEqual(response.accessToken, "test access token")
        XCTAssertEqual(response.expiresIn, 1000)
        XCTAssertEqual(response.tokenType, "test token type")
        XCTAssertEqual(response.refreshToken, "test refresh tokeb")
        XCTAssertEqual(response.scope, "test scope")
        XCTAssertEqual(response.UID, "test uid")
        XCTAssertEqual(response.userID, "test user id")
        XCTAssertEqual(response.eventID, "test event id")
        XCTAssertEqual(response.serverProof, "test server proof")
        XCTAssertEqual(response.passwordMode, .one)
        XCTAssertEqual(response._2FA.enabled, .off)    
    }
}
