//
//  PMAPIServiceTests+MissingScopes.swift
//  ProtonCore-Services-Tests - Created on 16.05.2023.
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
final class PMAPIServiceMissingScopesTests: XCTestCase {
    var dohMock: DoHInterface!
    var cacheToClearMock: URLCacheMock!
    var sessionMock: SessionMock!
    var sessionFactoryMock: SessionFactoryMock!
    var trustKitProviderMock: TrustKitProviderMock!
    var missingScopesDelegateMock: MissingScopesDelegateMock!
    var authInfo: AuthInfoResponse!
    var responseHandlerData: PMResponseHandlerData!
    
    override func setUp() {
        super.setUp()
        setupMocks()
    }
    
    private func setupMocks() {
        let dohMock = DohMock()
        dohMock.statusStub.fixture = .on
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "test.host.url" }
        dohMock.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeededWithSessionIdStub.bodyIs { _, _, _, _, _, _, executor, completion in
            executor.execute { completion(false) }
        }
        dohMock.errorIndicatesDoHSolvableProblemStub.bodyIs { _, _ in false }
        self.dohMock = dohMock
        cacheToClearMock = URLCacheMock()
        let sessionMockInstance = SessionMock()
        sessionMock = sessionMockInstance
        sessionFactoryMock = SessionFactoryMock()
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, _ in return sessionMockInstance }
        
        trustKitProviderMock = TrustKitProviderMock()
        missingScopesDelegateMock = MissingScopesDelegateMock()
        authInfo = .init(
            modulus: "",
            serverEphemeral: "",
            version: 1,
            salt: "",
            srpSession: ""
        )
        responseHandlerData = .init(
            method: .put,
            path: "path",
            authenticated: true,
            authRetry: true,
            authRetryRemains: 1,
            retryPolicy: .background,
            onDataTaskCreated: { _ in }
        )
    }
    
    func testMissingScopesHandlerOnClosedWithErrorCallsCompletion() {
        // Given
        let expectationOnClosedWithError = XCTestExpectation(description: "on .closedWithError")
        missingScopesDelegateMock.onMissingScopesHandlingStub.bodyIs { _, _, _, completion in
            completion(.closedWithError(code: 1, description: ""))
        }
        let completion: PMAPIService.APIResponseCompletion<PMAPIService.DummyAPIDecodableResponseOnlyForSatisfyingGenericsResolving> = .right { _, _ in
            expectationOnClosedWithError.fulfill()
        }
        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.missingScopesDelegate = missingScopesDelegateMock
        
        // When
        service.missingScopesHandler(
            username: "username",
            responseHandler: responseHandlerData,
            completion: completion
        )
        
        // Then
        wait(for: [expectationOnClosedWithError], timeout: 0.1)
    }
    
    func testMissingScopesHandlerOnUnlockRestartRequest() {
        // Given
        let expectationOnUnlock = XCTestExpectation(description: "on .unlock")
        missingScopesDelegateMock.onMissingScopesHandlingStub.bodyIs { _, _, _, completion in
            completion(.unlocked)
        }

        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
        }
        sessionMock.requestDecodableStub.bodyIs { _, request, decoder, _, completion in
            let task = URLSessionDataTaskMock(response: HTTPURLResponse(statusCode: 400))
            let underlyingError = NSError(domain: "unit tests", code: 4242, localizedDescription: "test description")
            completion(task, .failure(.networkingEngineError(underlyingError: underlyingError)))
        }

        let completion: PMAPIService.APIResponseCompletion<PMAPIService.DummyAPIDecodableResponseOnlyForSatisfyingGenericsResolving> = .right { _, _ in
            expectationOnUnlock.fulfill()
        }

        let service = PMAPIService.createAPIService(doh: dohMock,
                                                    sessionUID: "test sessionUID",
                                                    sessionFactory: sessionFactoryMock,
                                                    cacheToClear: cacheToClearMock,
                                                    trustKitProvider: trustKitProviderMock,
                                                    challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        service.missingScopesDelegate = missingScopesDelegateMock
        
        // When
        service.missingScopesHandler(
            username: "username",
            responseHandler: responseHandlerData,
            completion: completion
        )
        
        // Then
        wait(for: [expectationOnUnlock], timeout: 0.1)
    }
}

#endif
