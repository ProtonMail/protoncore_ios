//
//  EndSessionEndpointTests.swift
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

class EndSessionEndpointTests: XCTestCase {
    
    func testEndSessionEndpoint_request() {
        let endSessionEndpoint = AuthService.EndSessionEndpoint()
        XCTAssertEqual(endSessionEndpoint.method, .delete)
        XCTAssertEqual(endSessionEndpoint.path, "/auth/v4")
        XCTAssertEqual(endSessionEndpoint.method, .delete)
        XCTAssertNil(endSessionEndpoint.parameters)
        XCTAssertEqual(endSessionEndpoint.isAuth, true)
        XCTAssertNil(endSessionEndpoint.auth)
        XCTAssertNil(endSessionEndpoint.authCredential)
    }
}
