//
//  InfoEndpointTests.swift
//  ProtonCore-Authentication-Tests - Created on 14/12/2022.
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
import ProtonCoreFeatureSwitch
#if canImport(ProtonCoreTestingToolkitUnitTestsFeatureSwitch)
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
#endif
@testable import ProtonCoreAuthentication

final class InfoEndpointTests: XCTestCase {

    var cut: AuthService.InfoEndpoint!

    override func setUp() {
        super.setUp()
        cut = AuthService.InfoEndpoint(username: "dummy")
    }

    func testParameterGeneration() {
        XCTAssertEqual(["Username": "dummy"], cut.calculatedParameters as! [String: String])
    }

    func testParameterGeneration_sso() {
        // Given
        cut = AuthService.InfoEndpoint(username: "dummy", intent: .sso)

        // Then
        XCTAssertEqual(["Username": "dummy", "Intent": "SSO"], cut.calculatedParameters as! [String: String])
    }

    func testParameterGeneration_auto() {
        // Given
        cut = AuthService.InfoEndpoint(username: "dummy", intent: .auto)

        // Then
        XCTAssertEqual(["Username": "dummy", "Intent": "Auto"], cut.calculatedParameters as! [String: String])
    }

    func testParameterGeneration_proton() {
        // Given
        cut = AuthService.InfoEndpoint(username: "dummy", intent: .proton)

        // Then
        XCTAssertEqual(["Username": "dummy", "Intent": "Proton"], cut.calculatedParameters as! [String: String])
    }

    func testPath() {
        XCTAssertEqual("/auth/info", cut.path)
    }

    func testMethod() {
        XCTAssertEqual(.post, cut.method)
    }

    func testIsAuth() {
        XCTAssertFalse(cut.isAuth)
    }

    func testHeaderWithFeatureSwitch() {
        XCTAssertEqual(["X-Accept-ExtAcc": true], cut.header as! [String: Bool])
    }
}
