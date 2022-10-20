//
//  EnvironmentTests.swift
//  ProtonCore-Environment-Tests - Created on 09/01/22.
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
//

import XCTest
@testable import ProtonCore_Environment

class EnvironmentTests: XCTestCase {
    
    func testPrebuildCount() {
       XCTAssertTrue(Environment.prebuild.count == 6)
    }
    
    func testEqualable() {
        XCTAssertTrue(Environment.vpnProd == .vpnProd)
        XCTAssertTrue(Environment.mailProd == .mailProd)
        XCTAssertTrue(Environment.black == .black)
        XCTAssertTrue(Environment.blackPayment == .blackPayment)
        XCTAssertFalse(Environment.custom("domain.com") == .custom("domain.net"))
        XCTAssertTrue(Environment.custom("domain.com") == .custom("domain.com"))
    }
    
    func testStatusUpdate() {
        var env: Environment = .mailProd
        XCTAssertTrue(env.doh.status == .off)
        env.updateDohStatus(to: .on)
        XCTAssertTrue(env.doh.status == .on)
        env.updateDohStatus(to: .forceAlternativeRouting)
        XCTAssertTrue(env.doh.status == .forceAlternativeRouting)
        env = .black
        XCTAssertTrue(env.doh.status == .off)
        env.updateDohStatus(to: .on)
        XCTAssertTrue(env.doh.status == .on)
        env.updateDohStatus(to: .forceAlternativeRouting)
        XCTAssertTrue(env.doh.status == .forceAlternativeRouting)
        env = .vpnProd
        XCTAssertTrue(env.doh.status == .off)
        env.updateDohStatus(to: .on)
        XCTAssertTrue(env.doh.status == .on)
        env.updateDohStatus(to: .forceAlternativeRouting)
        XCTAssertTrue(env.doh.status == .forceAlternativeRouting)
    }
    
    func testValueCheck() {
        var env: Environment = .mailProd
        XCTAssertTrue(env.doh.signupDomain == Environment.productionMail.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Environment.productionMail.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Environment.productionMail.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Environment.productionMail.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Environment.productionMail.captchaHost)
        
        env = .vpnProd
        XCTAssertTrue(env.doh.signupDomain == Environment.productionVPN.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Environment.productionVPN.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Environment.productionVPN.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Environment.productionVPN.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Environment.productionVPN.captchaHost)
        
        env = .black
        XCTAssertTrue(env.doh.signupDomain == Environment.blackServer.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Environment.blackServer.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Environment.blackServer.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Environment.blackServer.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Environment.blackServer.captchaHost)
    }
    
    func testModifiableCheck() {
        let env: Environment = .mailProd
        XCTAssertTrue(env.doh.signupDomain == Environment.productionMail.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Environment.productionMail.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Environment.productionMail.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Environment.productionMail.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Environment.productionMail.captchaHost)
        XCTAssertTrue(env.doh.humanVerificationV3Host == Environment.productionMail.humanVerificationV3Host)
        _ = env.dohModifiable.replacingHumanVerificationV3Host(with: "testdomain.com")
        XCTAssertTrue(env.doh.humanVerificationV3Host == "testdomain.com")
    }
}
