//
//  LoginAndSignupTests.swift
//  ProtonCore-Login-Tests - Created on 14.10.22.
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

import ProtonCore_TestingToolkit
import ProtonCore_Services
@testable import ProtonCore_Networking
@testable import ProtonCore_LoginUI
import TrustKit

final class LoginAndSignupTests: XCTestCase {

    var testService: PMAPIService {
        PMAPIService.createAPIServiceWithoutSession(environment: .custom("test env"), challengeParametersProvider: .empty)
    }
    
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_RecommendedInitializer() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: testService,
                                 minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }

    func testLoginModuleAsksForSessionIfFeatureFlagIsSet() throws {
        withFeatureSwitches([.unauthSession]) {
            let mockService = APIServiceMock()
            mockService.dohInterfaceStub.fixture = DohInterfaceMock()
            _ = LoginAndSignup(appName: "test app",
                               clientApp: .other(named: "core"),
                               apiService: mockService,
                               minimumAccountType: .username, isCloseButtonAvailable: true,
                               paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
            XCTAssertTrue(mockService.acquireSessionIfNeededStub.wasCalledExactlyOnce)
        }
    }

    func testLoginModuleDoesNotAsksForSessionIfFeatureFlagIsNotSet() throws {
        let mockService = APIServiceMock()
        mockService.dohInterfaceStub.fixture = DohInterfaceMock()
        _ = LoginAndSignup(appName: "test app",
                           clientApp: .other(named: "core"),
                           apiService: mockService,
                           minimumAccountType: .username, isCloseButtonAvailable: true,
                           paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        XCTAssertTrue(mockService.acquireSessionIfNeededStub.wasNotCalled)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer1() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(
            appName: "test app",
            clientApp: .other(named: "core"),
            apiService: testService,
            minimumAccountType: .username,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: .notAvailable
        )
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer2() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(
            appName: "test app",
            clientApp: .other(named: "core"),
            apiService: testService,
            minimumAccountType: .username,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: .notAvailable
        )
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer3() throws {
        let trustKit = TrustKit()
        PMAPIService.trustKit = trustKit
        let out = LoginAndSignup(appName: "test app",
                                 clientApp: .other(named: "core"),
                                 apiService: testService,
                                 minimumAccountType: .username,
                                 isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable,
                                 signupAvailability: .notAvailable)
        let session = try XCTUnwrap((out.container.api as? PMAPIService)?.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
}
