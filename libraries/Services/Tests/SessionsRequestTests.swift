//
//  SessionsRequestTests.swift
//  ProtonCore-Services-Tests - Created on 07/12/22.
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
import ProtonCore_Challenge
@testable import ProtonCore_Authentication
@testable import ProtonCore_Services
@testable import ProtonCore_Networking

final class SessionsRequestTests: XCTestCase {

    var dohMock: DoHInterface!
    var sessionUID: String!
    var cacheToClearMock: URLCacheMock!
    var sessionMock: SessionMock!
    var sessionFactoryMock: SessionFactoryMock!
    var trustKitProviderMock: TrustKitProviderMock!
    var apiServiceDelegateMock: APIServiceDelegateMock!
    var authDelegateMock: AuthDelegateMock!
    var service: PMAPIService!
    
    override func setUp() {
        super.setUp()
        setupMock()
        service = PMAPIService(doh: dohMock,
                                   sessionUID: "test sessionUID",
                                   sessionFactory: sessionFactoryMock,
                                   cacheToClear: cacheToClearMock,
                                   trustKitProvider: trustKitProviderMock)
        service.authDelegate = authDelegateMock
    }
    
    func setupMock() {
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
        sessionMock.generateStub.bodyIs { _, method, url, params, time, retryPolicy in
            SessionRequest(parameters: params, urlString: url, method: method, timeout: time ?? 1.0, retryPolicy: retryPolicy)
        }
    }
    
    let sessionsRequestSuccessResponse = """
    {
        "code": 1000,
        "accessToken": "testAccessToken",
        "refreshToken": "testRefreshToken",
        "tokenType": "Bearer",
        "scopes": [],
        "UID": "testUID",
    }
    """
    
    func test_perform_Sessions_Request_Success() {
        sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
            let decoderedJSON = self.sessionsRequestSuccessResponse.data(using: .utf8)
            do {
                let response: SessionsRequestResponse = try JSONDecoder().decode(SessionsRequestResponse.self, from: decoderedJSON!)
                completion(nil, .success(response))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        let expectation = self.expectation(description: "Success completion block performSessionsRequest")
        service.performSessionsRequest(challenge: nil)  { result in
            switch result {
            case .success(let credential):
                XCTAssertEqual(credential.UID, "testUID")
                XCTAssertEqual(credential.accessToken, "testAccessToken")
                XCTAssertEqual(credential.refreshToken, "testRefreshToken")
                XCTAssertEqual(credential.userName, "")
                XCTAssertEqual(credential.userID, "")
                XCTAssertEqual(credential.scopes, [])
            case .failure:
                XCTFail("Not expected error")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1.0) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func test_perform_Sessions_Request_Fail() {
        sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 404))
            completion(task, .failure(SessionResponseError.configurationError))
        }
        let expectation = self.expectation(description: "Success completion block performSessionsRequest")
        service.performSessionsRequest(challenge: nil) { result in
            switch result {
            case .success:
                XCTFail("Not expected success case")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, SessionResponseError.configurationError.localizedDescription)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1.0) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func test_perform_Sessions_Request_Success_with_challenge() {
        sessionMock.requestDecodableStub.bodyIs { counter, request, decoder, completion in
            let dict = request.parameters as? [String: Any]
            XCTAssertNotNil(dict)
            let payload = dict?["Payload"] as! [String: [String: Any]]
            XCTAssertTrue(payload.count == 2)
            for (k, v) in payload {
                XCTAssertTrue(k.contains("core-ios-v4-challenge"))
                XCTAssertTrue(v.count == 13)
            }
            let decoderedJSON = self.sessionsRequestSuccessResponse.data(using: .utf8)
            do {
                let response: SessionsRequestResponse = try JSONDecoder().decode(SessionsRequestResponse.self, from: decoderedJSON!)
                completion(nil, .success(response))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        let expectation = self.expectation(description: "Success completion block performSessionsRequest")
        let challenge = ChallengeProperties.init(challenges: PMChallenge.shared().export().deviceFingerprintDict(),
                                                 productPrefix: "core")
        service.performSessionsRequest(challenge: challenge)  { result in
            switch result {
            case .success(let credential):
                XCTAssertEqual(credential.UID, "testUID")
                XCTAssertEqual(credential.accessToken, "testAccessToken")
                XCTAssertEqual(credential.refreshToken, "testRefreshToken")
                XCTAssertEqual(credential.userName, "")
                XCTAssertEqual(credential.userID, "")
                XCTAssertEqual(credential.scope, [])
            case .failure:
                XCTFail("Not expected error")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1.0) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
