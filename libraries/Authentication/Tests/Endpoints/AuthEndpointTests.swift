//
//  AuthEndpointTests.swift
//  ProtonCore-Authentication-Tests - Created on 13/12/2022.
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
@testable import ProtonCore_Authentication
import ProtonCore_FeatureSwitch

class AuthEndpointTests: XCTestCase {
    
    let headerExternal = "X-Accept-ExtAcc"
    let parametersUsername = "Username"
    let parametersEphemeral = "ClientEphemeral"
    let parametersProof = "ClientProof"
    let parametersSrp = "SRPSession"
    let parametersChallenge = "Payload"
    
    override func tearDown() {
        super.tearDown()
        FeatureFactory.shared.disable(&.externalSignupHeader)
    }
    
    func testAuthEndpoint_request_header_internel_noChallenge() {
        FeatureFactory.shared.disable(&.externalSignupHeader)
        let authEndpoint = AuthService.AuthEndpoint(username: "username", ephemeral: "ephemeral".data(using: .utf8)!, proof: "proof".data(using: .utf8)!, session: "mockSession", challenge: nil)
        XCTAssertEqual(authEndpoint.method, .post)
        XCTAssertEqual(authEndpoint.path, "/auth/v4")
        XCTAssertEqual(authEndpoint.method, .post)
        XCTAssertEqual(authEndpoint.header as? [String: Bool], [:])
        XCTAssertEqual(authEndpoint.parameters?[parametersUsername] as? String, "username")
        XCTAssertEqual(authEndpoint.parameters?[parametersEphemeral] as? String, "ephemeral".data(using: .utf8)!.base64EncodedString())
        XCTAssertEqual(authEndpoint.parameters?[parametersProof] as? String, "proof".data(using: .utf8)!.base64EncodedString())
        XCTAssertEqual(authEndpoint.parameters?[parametersSrp] as? String, "mockSession")
        XCTAssertNil(authEndpoint.parameters?[parametersChallenge])
        XCTAssertEqual(authEndpoint.isAuth, false)
    }
    
    func testAuthEndpoint_request_header_external() {
        FeatureFactory.shared.enable(&.externalSignupHeader)
        let authEndpoint = AuthService.AuthEndpoint(username: "username", ephemeral: Data(), proof: Data(), session: "mockSession", challenge: nil)
        XCTAssertEqual(authEndpoint.header[headerExternal] as? Bool, true)
    }
    
    func testAuthEndpoint_request_parameters_challenge() {
        let authEndpoint = AuthService.AuthEndpoint(username: "username", ephemeral: Data(), proof: Data(), session: "mockSession", challenge: ChallengeProperties(challengeData: ["data": "myData"], productPrefix: "prefix"))
        XCTAssertEqual(authEndpoint.parameters?[parametersChallenge] as? [String: [String: String]], ["prefix-ios-v4-challenge-0": ["data": "myData"]])
    }
}
