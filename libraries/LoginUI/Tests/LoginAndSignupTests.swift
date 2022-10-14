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
@testable import ProtonCore_Networking
@testable import ProtonCore_LoginUI
import TrustKit

final class LoginAndSignupTests: XCTestCase {
    
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_RecommendedInitializer() throws {
        let trustKit = TrustKit()
        let out = LoginAndSignup(appName: "test app", clientApp: .other(named: "test client"), environment: .custom("test env"),
                                 trustKit: trustKit,
                                 apiServiceDelegate: APIServiceDelegateMock(), forceUpgradeDelegate: ForceUpgradeDelegateMock(),
                                 minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap(out.container.api.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer1() throws {
        let trustKit = TrustKit()
        let out = LoginAndSignup(appName: "test app", clientApp: .other(named: "test client"), doh: DohMock(),
                                 trustKit: trustKit,
                                 apiServiceDelegate: APIServiceDelegateMock(), forceUpgradeDelegate: ForceUpgradeDelegateMock(),
                                 humanVerificationVersion: .v3, minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap(out.container.api.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer2() throws {
        let trustKit = TrustKit()
        let out = LoginAndSignup(appName: "test app", clientApp: .other(named: "test client"), environment: .custom("test environment"),
                                 trustKit: trustKit,
                                 apiServiceDelegate: APIServiceDelegateMock(), forceUpgradeDelegate: ForceUpgradeDelegateMock(),
                                 humanVerificationVersion: .v3, minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap(out.container.api.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
    
    @available(*, deprecated)
    func testTrustKitInstanceGivenToLoginAndSignupIsPassedToSession_DeprecatedInitializer3() throws {
        let trustKit = TrustKit()
        let out = LoginAndSignup(appName: "test app", clientApp: .other(named: "test client"), doh: DohMock(),
                                 trustKit: trustKit,
                                 apiServiceDelegate: APIServiceDelegateMock(), forceUpgradeDelegate: ForceUpgradeDelegateMock(),
                                 minimumAccountType: .username, isCloseButtonAvailable: true,
                                 paymentsAvailability: .notAvailable, signupAvailability: .notAvailable)
        let session = try XCTUnwrap(out.container.api.getSession() as? AlamofireSession)
        XCTAssertTrue(session.sessionChallenge.trustKit === trustKit)
    }
}
