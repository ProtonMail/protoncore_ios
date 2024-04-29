//
//  TwoFATests.swift
//  ProtonCore-Services-Tests - Created on 29/04/24.
//
//  Copyright (c) 2024 Proton Technologies AG
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

import Foundation
import XCTest
@testable import ProtonCoreAuthentication
import ProtonCoreServices

class TwoFATests: XCTestCase {

    var jsonDecoder: JSONDecoder!

#if SPM
let bundle = Bundle.module
#else
let bundle = Bundle(for: type(of: self))
#endif

    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder.decapitalisingFirstLetter
    }

    override func tearDown() {
        jsonDecoder = nil
        super.tearDown()
    }

    func testParseAuthRouteResponseWithNoTwoFA() {

        guard let url = bundle.url(forResource: "No2FA", withExtension: "json"),
        let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to read contents of fixture file")
            return
        }

        do {
            let response = try jsonDecoder.decode(AuthService.AuthRouteResponse.self, from: data)

            XCTAssertEqual(response._2FA.enabled, .off)
            XCTAssertNil(response._2FA.FIDO2!.authenticationOptions)
            XCTAssert(response._2FA.FIDO2!.registeredKeys.isEmpty)
        } catch {
            XCTFail("Error decoding data: \(error)")
        }

    }

    func testParseAuthRouteResponseWithTwoFACode() {
        guard let url = bundle.url(forResource: "2FAOnly", withExtension: "json"),
        let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to read contents of fixture file")
            return
        }

        do {
            let response = try jsonDecoder.decode(AuthService.AuthRouteResponse.self, from: data)

            XCTAssertEqual(response._2FA.enabled, [.totp])
            XCTAssertNil(response._2FA.FIDO2!.authenticationOptions)
            XCTAssert(response._2FA.FIDO2!.registeredKeys.isEmpty)
        } catch {
            XCTFail("Error decoding data: \(error)")
        }

    }

    func testParseAuthRouteResponseWithTwoFACodeAndFIDO2() {

        guard let url = bundle.url(forResource: "2FAandFIDO2", withExtension: "json"),
        let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to read contents of fixture file")
            return
        }

        do {
            let response = try jsonDecoder.decode(AuthService.AuthRouteResponse.self, from: data)

            XCTAssertEqual(response._2FA.enabled, [.totp, .webAuthn])
            XCTAssertEqual(response._2FA.FIDO2!.authenticationOptions!.publicKey.timeout, 600_000)
            XCTAssert(response._2FA.FIDO2!.authenticationOptions!.publicKey.challenge.starts(with: Data([139, 123, 9])))
            XCTAssertEqual(response._2FA.FIDO2!.authenticationOptions!.publicKey.userVerification, "discouraged")
            XCTAssertEqual(response._2FA.FIDO2!.authenticationOptions!.publicKey.rpId, "proton.black")
            XCTAssert(response._2FA.FIDO2!.authenticationOptions!.publicKey.allowCredentials[0].id.starts(with: Data([214, 89, 242])))
            XCTAssertEqual(response._2FA.FIDO2!.authenticationOptions!.publicKey.allowCredentials[0].type, "public-key")
            XCTAssertEqual(response._2FA.FIDO2!.registeredKeys[0].attestationFormat, "packed")
            XCTAssert(response._2FA.FIDO2!.registeredKeys[0].credentialID.starts(with: Data([214, 89, 242])))
            XCTAssertEqual(response._2FA.FIDO2!.registeredKeys[0].name, "Yubi")

        } catch {
            XCTFail("Error decoding data: \(error)")
        }

    }
}
