//
//  AuthDeviceRequestTests.swift
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
import ProtonCoreServices
@testable import ProtonCoreLogin

final class AuthDeviceRequestTests: XCTestCase {

    var apiService: APIServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIServiceMock()
    }

    override func tearDown() {
        super.tearDown()
        apiService = nil
    }

    func testCreateAuthDeviceResponse() async throws {
        let deviceName = "MyPhone 5"
        let activationToken = "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----"

        let createDeviceDataRes = try loadMockJSON(filename: "CreateAuthDeviceOK")
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
            XCTAssertEqual(authDevice.name, deviceName)
            XCTAssertEqual(authDevice.activationToken, activationToken)
        } else {
            XCTFail("AuthDevice not found")
        }
    }

    func testGetAuthDevicesResponse() async throws {
        let clientName = "Proton Account for Web"

        let devicesDataRes = try loadMockJSON(filename: "GetAuthDevicesOK")
        let devicesRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(AuthDevicesResponse.self, from: devicesDataRes)

        let sut = AuthDevicesRequest()

        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/auth/v4/devices") {
                completion(nil, .success(devicesRes.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .get && path.contains("/auth/v4/devices") {
                completion(nil, .success(devicesRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let (_, response) = await apiService.perform(request: sut, response: devicesRes)

        XCTAssertEqual(response.responseCode, 1000)
        XCTAssertNil(response.error)

        XCTAssertEqual(response.authDevices.count, 2)
        XCTAssertEqual(response.authDevices.first?.localizedClientName, clientName)
    }

    func testActivateAuthDeviceResponse() async throws {

        let dataRes = try loadMockJSON(filename: "ActivateAuthDeviceOK")
        let res = try JSONDecoder.decapitalisingFirstLetter
            .decode(DefaultResponse.self, from: dataRes)

        let deviceID = "12345678"
        let sut = ActivateAuthDeviceRequest(deviceID: deviceID, encryptedSecret: "secret")

        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(deviceID)") {
                completion(nil, .success(res.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(deviceID)") {
                completion(nil, .success(res))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let (_, response) = await apiService.perform(request: sut, response: res)

        XCTAssertEqual(response.responseCode, 1000)
        XCTAssertNil(response.error)
    }

    private func loadMockJSON(filename: String) throws -> Data {
        let url = Bundle.module.url(forResource: filename, withExtension: "json")!
        return try Data(contentsOf: url)
    }
}

#endif
