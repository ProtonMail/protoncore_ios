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
import ProtonCoreDoh
@testable import ProtonCoreEnvironment

class EnvironmentTests: XCTestCase {

    func testPrebuildCount() {
       XCTAssertTrue(Environment.prebuild.count == 7)
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
        Environment.prebuild.forEach { env in
            XCTAssertTrue(env.doh.status == .off)
            env.updateDohStatus(to: .on)
            XCTAssertTrue(env.doh.status == .on)
            env.updateDohStatus(to: .forceAlternativeRouting)
            XCTAssertTrue(env.doh.status == .forceAlternativeRouting)
        }
    }

    func testValueCheck() {
        [
            (Environment.mailProd, Environment.productionMail),
            (Environment.vpnProd, Environment.productionVPN),
            (Environment.driveProd, Environment.productionDrive),
            (Environment.calendarProd, Environment.productionCalendar),
            (Environment.passProd, Environment.productionPass),
            (Environment.black, Environment.blackServer),
            (Environment.blackPayment, Environment.blackPaymentsServer),
        ].forEach { (env: Environment, doh: DoH & ServerConfig) in
            XCTAssertTrue(env.doh.signupDomain == doh.signupDomain)
            XCTAssertTrue(env.doh.defaultHost == doh.defaultHost)
            XCTAssertTrue(env.doh.defaultPath == doh.defaultPath)
            XCTAssertTrue(env.doh.accountHost == doh.accountHost)
            XCTAssertTrue(env.doh.captchaHost == doh.captchaHost)
        }
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
