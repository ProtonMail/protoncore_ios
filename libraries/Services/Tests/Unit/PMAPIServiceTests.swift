//
//  PMAPIServiceTests.swift
//  ProtonCore-Services-Tests - Created on 20/12/22.
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
import ProtonCore_Doh
import ProtonCore_Networking

@testable import ProtonCore_Services

final class PMAPIServiceTests: XCTestCase {
    
    var doh: DoHInterface!
    var sessionUID: String!
    var sessionFactoryMock: SessionFactoryMock!
    var cacheToClearMock: URLCacheMock!
    var trustKitProviderMock: TrustKitProviderMock!
    
    override func setUp() {
        super.setUp()
        doh = DohMock()
        sessionUID = "testCreateAPIService"
        sessionFactoryMock = SessionFactoryMock()
        let sessionMockInstance = SessionMock()
        sessionFactoryMock.createSessionInstanceStub.bodyIs { _, _ in return sessionMockInstance }
        cacheToClearMock = URLCacheMock()
        trustKitProviderMock = TrustKitProviderMock()
    }
    
    override func tearDown() {
        super.tearDown()
        doh = nil
        sessionUID = nil
        sessionFactoryMock = nil
        cacheToClearMock = nil
        trustKitProviderMock = nil
    }
    
    func testCreateAPIService_doh_sessionUID() {
        let apiServiceDef = PMAPIService.createAPIService(doh: doh,
                                                          sessionUID: sessionUID,
                                                          challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiServiceDef.sessionUID, sessionUID)
        
        let apiService = PMAPIService.createAPIService(doh: doh, sessionUID: sessionUID, sessionFactory: sessionFactoryMock, cacheToClear: cacheToClearMock, trustKitProvider: trustKitProviderMock, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiService.sessionUID, sessionUID)
    }
    
    func testCreateAPIServiceWithoutSession_doh_sessionUID() {
        let apiServiceDef = PMAPIService.createAPIServiceWithoutSession(doh: doh,
                                                                        challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiServiceDef.sessionUID, "")
        
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: doh, sessionFactory: sessionFactoryMock, cacheToClear: cacheToClearMock, trustKitProvider: trustKitProviderMock, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiService.sessionUID, "")
    }
    
    func testCreateAPIService_environment_sessionUID() {
        let apiServiceDef = PMAPIService.createAPIService(environment: .black, sessionUID: sessionUID,
                                                          challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiServiceDef.sessionUID, sessionUID)
        
        let apiService = PMAPIService.createAPIService(environment: .black, sessionUID: sessionUID, sessionFactory: sessionFactoryMock, cacheToClear: cacheToClearMock, trustKitProvider: trustKitProviderMock, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiService.sessionUID, sessionUID)
    }
    
    func testCreateAPIServiceWithoutSession_environment_sessionUID() {
        let apiServiceDef = PMAPIService.createAPIServiceWithoutSession(environment: .black,
                                                                        challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiServiceDef.sessionUID, "")
        
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: .black, sessionFactory: sessionFactoryMock, cacheToClear: cacheToClearMock, trustKitProvider: trustKitProviderMock, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core")))
        XCTAssertEqual(apiService.sessionUID, "")
    }
}
