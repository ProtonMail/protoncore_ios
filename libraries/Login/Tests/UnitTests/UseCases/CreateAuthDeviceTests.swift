//
//  CreateAuthDeviceTests.swift
//  ProtonCore-Login-Tests - Created on 27.11.2024.
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

final class CreateAuthDeviceTests: XCTestCase {

    var sut: CreateAuthDevice!
    var apiService: APIServiceMock!
    var deviceSecretRepository: DeviceSecretRepositoryProtocolMock!

    var userId: String = "123456789"

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIServiceMock()
        deviceSecretRepository = DeviceSecretRepositoryProtocolMock()
        sut = CreateAuthDevice(
            userId: userId,
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
        apiService = nil
    }

    func testCreateAuthDeviceSuccess() async throws {

        let createDeviceDataRes = try loadMockJSON(filename: "CreateAuthDeviceOK")
        let createDeviceRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(CreateAuthDeviceResponse.self, from: createDeviceDataRes)

        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices") {
                completion(nil, .success(createDeviceRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        try await sut.invoke()
        let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId)
        XCTAssertNotNil(deviceSecret)

        XCTAssertEqual(deviceSecret?.userId, userId)
        XCTAssertNotNil(deviceSecret?.deviceId)
        XCTAssertNotNil(deviceSecret?.token)
        XCTAssertNotNil(deviceSecret?.secret)
    }

    private func loadMockJSON(filename: String) throws -> Data {
        let url = Bundle.module.url(forResource: filename, withExtension: "json")!
        return try Data(contentsOf: url)
    }
}
#endif
