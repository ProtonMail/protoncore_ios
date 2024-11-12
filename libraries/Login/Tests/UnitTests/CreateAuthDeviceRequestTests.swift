//
//  CreateAuthDeviceRequestTests.swift
//  ProtonCore-Login-Tests - Created on 30.09.2024.
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
@testable import ProtonCoreLogin

final class CreateAuthDeviceRequestTests: XCTestCase {

    var apiService: APIServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIServiceMock()
    }

    override func tearDown() {
        super.tearDown()
        apiService = nil
    }

    let deviceName = "MyPhone 5"
    let activationToken = "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----"

    var createDeviceResponse: String {
        return """
            {
                "Code": 1000,
                "AuthDevice": {
                    "ID": "r5H2qGDRiUQ4-7gm...5YLf215MEgZCdzOtLW5psxgB8oNc=",
                    "DeviceToken": "wfih0367aa7dc0359bf5c42d15a93e6c",
                    "ActivationAddressID": "-Bpgivr5H2qGDRiUQ4-7gm5...oFRykab4Z23EGEW1ka3GtQPF9xwx9-VUA==",
                    "State": 2,
                    "Name": "\(deviceName)",
                    "LocalizedClientName": "Proton Account for Web",
                    "Platform": "Web",
                    "CreateTime": 1715720090,
                    "ActivateTime": 1715720090,
                    "RejectTime": 1715720090,
                    "ActivationToken": "\(activationToken)",
                    "LastActivityTime": 1715720090
                }
            }
        """
    }

    func testCreateAuthDeviceResponse() async throws {
        let createDeviceDataRes = self.createDeviceResponse.data(using: String.Encoding.utf8)!
        let createDeviceRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(CreateAuthDeviceResponse.self, from: createDeviceDataRes)

        let sut = CreateAuthDeviceRequest(name: deviceName, activationToken: activationToken)

        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices") {
                completion(nil, .success(createDeviceRes.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices") {
                completion(nil, .success(createDeviceRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let (_, response) = await apiService.perform(request: sut, response: createDeviceRes)

        XCTAssertEqual(response.responseCode, 1000)
        XCTAssertNil(response.error)

        if let authDevice = response.authDevice {
            XCTAssertEqual(authDevice.name, self.deviceName)
            XCTAssertEqual(authDevice.activationToken, self.activationToken)
        } else {
            XCTFail("AuthDevice not found")
        }
    }
}

#endif
