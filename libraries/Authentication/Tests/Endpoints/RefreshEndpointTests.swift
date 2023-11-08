//
//  RefreshEndpointTests.swift
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
import ProtonCoreNetworking
import ProtonCoreServices
@testable import ProtonCoreAuthentication

class RefreshEndpointTests: XCTestCase {

    let parametersResponseType = "ResponseType"
    let parametersGrantType = "GrantType"
    let parametersRefreshToken = "RefreshToken"
    let parametersRedirect = "RedirectURI"

    func testRefreshEndpoint_request() {
        let authCredential = AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        let refreshEndpoint = RefreshEndpoint(authCredential: authCredential)
        XCTAssertEqual(refreshEndpoint.method, .post)
        XCTAssertEqual(refreshEndpoint.path, "/auth/v4/refresh")
        XCTAssertEqual(refreshEndpoint.parameters?[parametersResponseType] as? String, "token")
        XCTAssertEqual(refreshEndpoint.parameters?[parametersGrantType] as? String, "refresh_token")
        XCTAssertEqual(refreshEndpoint.parameters?[parametersRefreshToken] as? String, "refreshToken")
        XCTAssertEqual(refreshEndpoint.parameters?[parametersRedirect] as? String, "http://protonmail.ch")
        XCTAssertEqual(refreshEndpoint.isAuth, true)
        XCTAssertEqual(refreshEndpoint.authCredential, authCredential)
    }
}
