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
#if canImport(ProtonCoreTestingToolkitUnitTestsFeatureSwitch)
import ProtonCoreTestingToolkitUnitTestsFeatureSwitch
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreAuthentication
import ProtonCoreUtilities
import ProtonCoreNetworking
import ProtonCoreFeatureSwitch

class AuthEndpointTests: XCTestCase {

    let headerExternal = "X-Accept-ExtAcc"
    let parametersUsername = "Username"
    let parametersEphemeral = "ClientEphemeral"
    let parametersProof = "ClientProof"
    let parametersSrp = "SRPSession"
    let parametersChallenge = "Payload"

    let username = "username"
    let prefix = "core"
    let ephemeralData = "ephemeral".utf8!
    let proofData = "proof".utf8!
    let srpSession = "srpSession"

    private let ephemeral = Data(capacity: 1)
    private let proof = Data(capacity: 1)

    func testAuthEndpoint_request_header_internel_noChallenge() {
        withFeatureSwitches([]) {
            let authEndpoint = AuthService.AuthEndpoint(data: .left(.init(username: username,
                                                                          ephemeral: ephemeralData,
                                                                          proof: proofData,
                                                                          srpSession: srpSession,
                                                                          challenge: nil)))
            XCTAssertEqual(authEndpoint.method, .post)
            XCTAssertEqual(authEndpoint.path, "/auth/v4")
            XCTAssertEqual(authEndpoint.method, .post)
            XCTAssertEqual(authEndpoint.header as? [String: Bool], ["X-Accept-ExtAcc": true])
            XCTAssertEqual(authEndpoint.parameters?[parametersUsername] as? String, username)
            XCTAssertEqual(authEndpoint.parameters?[parametersEphemeral] as? String, ephemeralData.base64EncodedString())
            XCTAssertEqual(authEndpoint.parameters?[parametersProof] as? String, proofData.base64EncodedString())
            XCTAssertEqual(authEndpoint.parameters?[parametersSrp] as? String, srpSession)
            XCTAssertNil(authEndpoint.parameters?[parametersChallenge])
            XCTAssertEqual(authEndpoint.isAuth, false)
        }
    }

    func testAuthEndpoint_request_header_external() {
        let authEndpoint = AuthService.AuthEndpoint(data: .left(.init(username: username,
                                                                      ephemeral: Data(),
                                                                      proof: Data(),
                                                                      srpSession: srpSession,
                                                                      challenge: nil)))

        XCTAssertEqual(authEndpoint.header[headerExternal] as? Bool, true)
    }

    func testAuthEndpointAllFingerprint() {
        let allDict = try! JSONSerialization.jsonObject(with: FingerprintMocks.allFignerprints.utf8!,
                                                        options: []) as! [[String: Any]]
        let cut = AuthService.AuthEndpoint(data: .left(.init(username: username,
                                                             ephemeral: ephemeralData,
                                                             proof: proofData,
                                                             srpSession: srpSession,
                                                             challenge: ChallengeProperties.init(challenges: allDict,
                                                                                                 productPrefix: prefix))))
        XCTAssertEqual(cut.path, "/auth/v4")
        XCTAssertFalse(cut.isAuth)
        XCTAssertEqual(cut.method, .post)
        XCTAssertNotNil(cut.challengeProperties)
        let dict = cut.calculatedParameters
        XCTAssertNotNil(dict)
        let payload = dict![parametersChallenge] as! [String: [String: Any]]
        XCTAssertTrue(payload.count == 2)
        for (k, v) in payload {
            XCTAssertTrue(k.contains("core-ios-v4-challenge"))
            XCTAssertTrue(v.count == 19)
        }
        XCTAssertEqual(dict![parametersUsername] as! String, username)
        XCTAssertEqual(dict![parametersEphemeral] as! String, ephemeralData.base64EncodedString())
        XCTAssertEqual(dict![parametersProof] as! String, proofData.base64EncodedString())
        XCTAssertEqual(dict![parametersSrp] as! String, srpSession)
    }

    func testAuthEndpointDeviceFingerprint() {
        let deviceDict = try! JSONSerialization.jsonObject(with: FingerprintMocks.deviceFignerprints.utf8!,
                                                           options: []) as! [[String: Any]]
        let cut = AuthService.AuthEndpoint(data: .left(.init(username: username,
                                                             ephemeral: ephemeralData,
                                                             proof: proofData,
                                                             srpSession: srpSession,
                                                             challenge: ChallengeProperties.init(challenges: deviceDict,
                                                                                                 productPrefix: prefix))))
        XCTAssertEqual(cut.path, "/auth/v4")
        XCTAssertFalse(cut.isAuth)
        XCTAssertEqual(cut.method, .post)
        XCTAssertNotNil(cut.challengeProperties)
        let dict = cut.calculatedParameters
        XCTAssertNotNil(dict)
        let payload = dict![parametersChallenge] as! [String: [String: Any]]
        XCTAssertTrue(payload.count == 2)
        for (k, v) in payload {
            XCTAssertTrue(k.contains("core-ios-v4-challenge"))
            XCTAssertTrue(v.count == 13)
        }
        XCTAssertEqual(dict![parametersUsername] as! String, username)
        XCTAssertEqual(dict![parametersEphemeral] as! String, ephemeralData.base64EncodedString())
        XCTAssertEqual(dict![parametersProof] as! String, proofData.base64EncodedString())
        XCTAssertEqual(dict![parametersSrp] as! String, srpSession)
    }

    func test_endpoint_withoutSSOResponseToken() {
        // Given
        let sut = AuthService.AuthEndpoint(data: .left(.init(username: "username", ephemeral: ephemeral, proof: proof, srpSession: "srpSession", challenge: nil)))

        // Then
        XCTAssertEqual(sut.parameters as? [String: String], [
            "Username": "username",
            "ClientEphemeral": ephemeral.base64EncodedString(),
            "ClientProof": proof.base64EncodedString(),
            "SRPSession": "srpSession"]
        )
    }

    func test_endpoint_withSSOResponseToken() {
        // Given
        let sut = AuthService.AuthEndpoint(data: .right(.init(ssoResponseToken: "ssoResponseToken")))

        // Then
        XCTAssertEqual(sut.parameters as? [String: String], [
            "SSOResponseToken": "ssoResponseToken"]
        )
    }
}
