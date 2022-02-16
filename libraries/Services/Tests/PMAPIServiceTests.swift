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

@testable import ProtonCore_Services

final class PMAPIServiceTests: XCTestCase {
    
    var dohMock: DohMock! = nil
    var sessionUID: String! = nil
    var cacheToClearMock: URLCacheMock! = nil
    var sessionMock: SessionMock! = nil
    var sessionFactoryMock: SessionFactoryMock! = nil
    var trustKitProviderMock: TrustKitProviderMock! = nil
    var apiServiceDelegateMock: APIServiceDelegateMock! = nil
    
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
}
