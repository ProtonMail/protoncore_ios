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
       XCTAssertTrue(Environment.prebuild.count == 5)
    }
    
    func testEqualable() {
        XCTAssertTrue(Environment.blackFossey == .blackFossey)
        XCTAssertTrue(Environment.vpnProd == .vpnProd)
        XCTAssertTrue(Environment.prod == .prod)
        XCTAssertTrue(Environment.black == .black)
        XCTAssertTrue(Environment.blackPayment == .blackPayment)
        XCTAssertFalse(Environment.custom("domain.com") == .custom("domain.net"))
        XCTAssertTrue(Environment.custom("domain.com") == .custom("domain.com"))
    }
    
    func testStatusUpdate() {
        var env: Environment = .prod
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
        var env: Environment = .prod
        XCTAssertTrue(env.doh.signupDomain == Production.default.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Production.default.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Production.default.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Production.default.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Production.default.captchaHost)
        
        env = .vpnProd
        XCTAssertTrue(env.doh.signupDomain == ProductionVPN.default.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == ProductionVPN.default.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == ProductionVPN.default.defaultPath)
        XCTAssertTrue(env.doh.accountHost == ProductionVPN.default.accountHost)
        XCTAssertTrue(env.doh.captchaHost == ProductionVPN.default.captchaHost)
        
        env = .black
        XCTAssertTrue(env.doh.signupDomain == BlackServer.default.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == BlackServer.default.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == BlackServer.default.defaultPath)
        XCTAssertTrue(env.doh.accountHost == BlackServer.default.accountHost)
        XCTAssertTrue(env.doh.captchaHost == BlackServer.default.captchaHost)
    }
    
    func testModifiableCheck() {
        let env: Environment = .prod
        XCTAssertTrue(env.doh.signupDomain == Production.default.signupDomain)
        XCTAssertTrue(env.doh.defaultHost == Production.default.defaultHost)
        XCTAssertTrue(env.doh.defaultPath == Production.default.defaultPath)
        XCTAssertTrue(env.doh.accountHost == Production.default.accountHost)
        XCTAssertTrue(env.doh.captchaHost == Production.default.captchaHost)
        XCTAssertTrue(env.doh.humanVerificationV3Host == Production.default.humanVerificationV3Host)
        _ = env.dohModifiable.replacingHumanVerificationV3Host(with: "testdomain.com")
        XCTAssertTrue(env.doh.humanVerificationV3Host == "testdomain.com")
    }
}
