//
//  PMAPIServiceTests+CreateRequest.swift
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

final class PMAPIServiceCreateRequestTests: XCTestCase {
    
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
        apiServiceDelegateMock = APIServiceDelegateMock()
        authDelegateMock = AuthDelegateMock()
    }
    
    func testTimeoutTimeoutDohOFF() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.status = .off
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .post,
                                          parameters: nil,
                                          nonDefaultTimeout: 100,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 100)
        XCTAssertTrue( sessionTest.request?.method == .post)
        // don't konw if the -100 need to fail or pass
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .put,
                                          parameters: nil,
                                          nonDefaultTimeout: -100,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == -100)
        XCTAssertTrue( sessionTest.request?.method == .put)
    }
    
    func testCreateRequestTimeoutDohOn() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.statusStub.fixture = .on
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 30)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .post,
                                          parameters: nil,
                                          nonDefaultTimeout: 100,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 100)
        XCTAssertTrue( sessionTest.request?.method == .post)
        
        // don't konw if the -100 need to fail or pass
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .delete,
                                          parameters: nil,
                                          nonDefaultTimeout: -100,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == -100)
        XCTAssertTrue( sessionTest.request?.method == .delete)
    }
    
    func testCreateRequestAdditionalHeaders() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        apiServiceDelegateMock.additionalHeadersStub.fixture = ["a": "av", "b": "bc"]
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertTrue( sessionTest.hasHeader(key: "a"))
        XCTAssertTrue( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "c"))
    }
    
    func testCreateRequestCustomHeaders() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "c"))
        
        let testHeaders = ["a": "av", "b": "bc"]
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: testHeaders,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertTrue( sessionTest.hasHeader(key: "a"))
        XCTAssertTrue( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "c"))
    }
    
    func testCreateRequestAccessToken() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "c"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "this is a fake token")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "c"))
        XCTAssertTrue( sessionTest.hasHeader(key: "Authorization"))
    }
    
    func testCreateRequestUserID() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: "",
                                          accessToken: "this is a fake token")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertTrue( sessionTest.hasHeader(key: "Authorization"))
        
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: "this is a fake userid",
                                          accessToken: "this is a fake token")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertTrue( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertTrue( sessionTest.hasHeader(key: "Authorization"))
    }
    
    func testCreateRequestAppLocal() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.matches(key: "x-pm-locale", value: "en_US"))
        
        apiServiceDelegateMock.localeStub.fixture = "us"
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.matches(key: "x-pm-locale", value: "us"))
    }
    
    func testCreateRequestAppVersion() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.hasHeader(key: "x-pm-appversion"))
        
        let appVersion = "iOS_0.1.0"
        apiServiceDelegateMock.appVersionStub.fixture = appVersion
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.matches(key: "x-pm-appversion", value: appVersion))
        
        apiServiceDelegateMock.appVersionStub.fixture = ""
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        let testValue = sessionTest.value(key: "x-pm-appversion")
        XCTAssertNotNil(testValue)
        XCTAssertFalse(testValue!.isEmpty)
    }
    
    func testCreateRequestUserAgent() throws {
        let hostUrl = "proton.unittests"
        let sessionMockInstance = sessionMock!
        var sessionTest: SessionRequest!
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in hostUrl }
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, url in
            XCTAssertEqual(url, hostUrl)
            return sessionMockInstance
        }
        sessionMock.generateStub.bodyIs { _, method, path, parameters, timeout, retryPolicy in
            sessionTest = SessionFactory.instance.createSessionRequest(parameters: parameters, urlString: path, method: method, timeout: timeout!, retryPolicy: retryPolicy)
            return sessionTest
        }
        // build service
        let testService = PMAPIService.createAPIService(doh: dohMock,
                                       sessionUID: sessionUID,
                                       sessionFactory: sessionFactoryMock,
                                       cacheToClear: cacheToClearMock,
                                       trustKitProvider: trustKitProviderMock,
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        testService.serviceDelegate = apiServiceDelegateMock
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.hasHeader(key: "x-pm-appversion"))
        
        let agent = "iOS_Simulator_12_23_567890"
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        apiServiceDelegateMock.userAgentStub.fixture = ""
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        let userAgent = sessionTest.value(key: "User-Agent")
        XCTAssertNotNil(userAgent)
        XCTAssertFalse(userAgent!.isEmpty)
        
        apiServiceDelegateMock.userAgentStub.fixture = agent
        _ = try testService.createRequest(url: "proton.unittests/unit/tests",
                                          method: .get,
                                          parameters: nil,
                                          nonDefaultTimeout: nil,
                                          headers: nil,
                                          sessionUID: nil,
                                          accessToken: "")
        XCTAssertTrue( sessionTest.request?.timeoutInterval == 60)
        XCTAssertTrue( sessionTest.request?.url?.absoluteString == "proton.unittests/unit/tests")
        XCTAssertTrue( sessionTest.request?.method == .get)
        XCTAssertTrue( sessionTest.headerCounts() > 0)
        XCTAssertFalse( sessionTest.hasHeader(key: "a"))
        XCTAssertFalse( sessionTest.hasHeader(key: "b"))
        XCTAssertFalse( sessionTest.hasHeader(key: "x-pm-uid"))
        XCTAssertFalse( sessionTest.hasHeader(key: "Authorization"))
        XCTAssertTrue( sessionTest.matches(key: "User-Agent", value: agent))
    }
}
