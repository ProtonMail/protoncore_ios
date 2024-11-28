//
//  OrganizationRepositoryTests.swift
//  ProtonCore-Login-Tests - Created on 28.11.24.
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

import XCTest
@testable import ProtonCoreLogin
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

final class OrganizationRepositoryTests: XCTestCase, JSONMockLoader {

    var sut: OrganizationRepository!
    var apiService: APIServiceMock!

    override func setUpWithError() throws {
        apiService = APIServiceMock()
        sut = OrganizationRepository(apiService: apiService)


    }

    override func tearDownWithError() throws {
        apiService = nil
        sut = nil
    }

    func testGetOrganizationSuccess() async throws {
        let organizationsDataRes = try loadMockJSON(filename: "GetOrganizationsOK")
        let organizationsRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(OrganizationResponse.self, from: organizationsDataRes)

        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/core/v4/organizations") {
                completion(nil, .success(organizationsRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let organization = try await sut.getOrganization()

        XCTAssertEqual(organization.displayName, "My Org")
        XCTAssertEqual(organization.planName, "plus")
    }

    func testGetOrganizationSettingsSuccess() async throws {
        let organizationsDataRes = try loadMockJSON(filename: "GetOrganizationsSettingsOK")
        let organizationsRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(OrganizationSettingsResponse.self, from: organizationsDataRes)

        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/core/v4/organizations/settings") {
                completion(nil, .success(organizationsRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let organization = try await sut.getOrganizationSettings()

        XCTAssertEqual(organization.showName, true)
    }

}
