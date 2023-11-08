//
//  CreateExternalUserEndpointTests.swift
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
import ProtonCoreNetworking
@testable import ProtonCoreAuthentication

private func areEqual(_ lhs: [AnyHashable: Any], _ rhs: [AnyHashable: Any]) -> Bool {
    (lhs as NSDictionary).isEqual(to: rhs)
}

final class CreateExternalUserEndpointTests: XCTestCase {

    func testCreateExternalUserEndpointContainsHVEmailHeadersIfAvailable() {
        let parameters = ExternalUserParameters(
            email: "email@tests.unit",
            modulusID: "test modulus",
            salt: "test salt",
            verifer: "test verifier",
            verifyToken: "test token",
            tokenType: VerifyMethod.PredefinedMethod.email.rawValue,
            productPrefix: "tests"
        )
        let endpoint = AuthService.CreateExternalUserEndpoint(externalUserParameters: parameters)
        XCTAssertTrue(
            areEqual(
                endpoint.header,
                ["x-pm-human-verification-token-type": "email",
                 "x-pm-human-verification-token": "email@tests.unit:test token"]
            )
        )
    }

    func testCreateExternalUserEndpointContainsHVNonEmailHeadersIfAvailable() {
        let parameters = ExternalUserParameters(
            email: "email@tests.unit",
            modulusID: "test modulus",
            salt: "test salt",
            verifer: "test verifier",
            verifyToken: "test token",
            tokenType: VerifyMethod.PredefinedMethod.captcha.rawValue,
            productPrefix: "tests"
        )
        let endpoint = AuthService.CreateExternalUserEndpoint(externalUserParameters: parameters)
        XCTAssertTrue(
            areEqual(
                endpoint.header,
                ["x-pm-human-verification-token-type": "captcha",
                 "x-pm-human-verification-token": "test token"]
            )
        )
    }

    func testCreateExternalUserEndpointHasNoHVHeadersIfHVTokenNotAvailable() {
        let parameters = ExternalUserParameters(
            email: "email@tests.unit",
            modulusID: "test modulus",
            salt: "test salt",
            verifer: "test verifier",
            verifyToken: nil,
            tokenType: VerifyMethod.PredefinedMethod.captcha.rawValue,
            productPrefix: "tests"
        )
        let endpoint = AuthService.CreateExternalUserEndpoint(externalUserParameters: parameters)
        XCTAssertTrue(areEqual(endpoint.header, [:]))
    }

    func testCreateExternalUserEndpointHasNoHVHeadersIfHVTypeNotAvailable() {
        let parameters = ExternalUserParameters(
            email: "email@tests.unit",
            modulusID: "test modulus",
            salt: "test salt",
            verifer: "test verifier",
            verifyToken: nil,
            tokenType: nil,
            productPrefix: "tests"
        )
        let endpoint = AuthService.CreateExternalUserEndpoint(externalUserParameters: parameters)
        XCTAssertTrue(areEqual(endpoint.header, [:]))
    }

}
