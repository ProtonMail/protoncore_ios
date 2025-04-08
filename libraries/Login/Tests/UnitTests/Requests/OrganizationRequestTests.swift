//
//  OrganizationRequestTests.swift
//  ProtonCore-Login-Tests - Created on 28.11.2024.
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

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreServices
@testable import ProtonCoreLogin

final class OrganizationRequestTests: XCTestCase, JSONMockLoader {

    var apiService: APIServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIServiceMock()
    }

    override func tearDownWithError() throws {
        super.tearDown()
        apiService = nil
    }

    func testGetOrganizationResponse() async throws {
        let organizationsDataRes = try loadMockJSON(filename: "GetOrganizationsOK")
        let organizationsRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(OrganizationResponse.self, from: organizationsDataRes)

        let sut = GetOrganizationRequest()

        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/core/v4/organizations") {
                completion(nil, .success(organizationsRes.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let (_, response) = await apiService.perform(request: sut, response: organizationsRes)

        XCTAssertEqual(response.responseCode, 1000)
        XCTAssertNil(response.error)
        XCTAssertEqual(response.organization.displayName, "My Org")
        XCTAssertEqual(response.organization.planName, "plus")
    }

    func testGetOrganizationSettingsResponse() async throws {
        let organizationsDataRes = try loadMockJSON(filename: "GetOrganizationsSettingsOK")
        let organizationsRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(OrganizationSettingsResponse.self, from: organizationsDataRes)

        let sut = GetOrganizationSettingsRequest()

        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/core/v4/organizations/settings") {
                completion(nil, .success(organizationsRes.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let (_, response) = await apiService.perform(request: sut, response: organizationsRes)

        XCTAssertEqual(response.responseCode, 1000)
        XCTAssertNil(response.error)
        XCTAssertTrue(response.showName)
    }
}

#endif
