//
//  AssociateAuthDeviceTests.swift
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
import ProtonCoreNetworking
import ProtonCoreServices

final class AssociateAuthDeviceTests: XCTestCase, JSONMockLoader {

    var sut: AssociateAuthDevice!
    var apiService: APIServiceMock!
    var deviceSecretRepository: DeviceSecretRepositoryProtocolMock!

    var userId: String = "123456789"
    var deviceId: String = "12345678"

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiService = APIServiceMock()
        deviceSecretRepository = DeviceSecretRepositoryProtocolMock()
        sut = AssociateAuthDevice(
            apiService: apiService,
            deviceSecretRepository: deviceSecretRepository
        )
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
        deviceSecretRepository = nil
        apiService = nil
    }

    func testAssociateAuthDeviceSuccess() async throws {
        let associateDeviceDataRes = try loadMockJSON(filename: "AssociateAuthDeviceOK")
        let associateDeviceRes = try JSONDecoder.decapitalisingFirstLetter
            .decode(AssociateAuthDeviceResponse.self, from: associateDeviceDataRes)

        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(self.deviceId)/associate") {
                completion(nil, .success(associateDeviceRes))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let result = await sut.invoke(userId: userId, deviceId: deviceId, deviceToken: "token")
        XCTAssertEqual(result, .success("encrypted$secret"))
    }

    func testAssociateAuthDeviceNotFound() async throws {
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(self.deviceId)/associate") {
                let responseError = ResponseError(
                    httpCode: 422,
                    responseCode: APIErrorCode.authDeviceNotFound,
                    userFacingMessage: nil,
                    underlyingError: nil
                )
                completion(nil, .failure(responseError as NSError))
            } else if method == .delete && path.contains("/auth/v4/devices/\(self.deviceId)") {
                completion(nil, .success(DefaultResponse()))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let result = await sut.invoke(userId: userId, deviceId: deviceId, deviceToken: "token")
        XCTAssertEqual(result, .deviceNotFound)
    }

    func testAssociateAuthDeviceNotActive() async throws {
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(self.deviceId)/associate") {
                let responseError = ResponseError(
                    httpCode: 422,
                    responseCode: APIErrorCode.authDeviceNotActive,
                    userFacingMessage: nil,
                    underlyingError: nil
                )
                completion(nil, .failure(responseError as NSError))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let result = await sut.invoke(userId: userId, deviceId: deviceId, deviceToken: "token")
        XCTAssertEqual(result, .deviceNotActive)
    }

    func testAssociateAuthDeviceRejected() async throws {
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(self.deviceId)/associate") {
                let responseError = ResponseError(
                    httpCode: 422,
                    responseCode: APIErrorCode.authDeviceRejected,
                    userFacingMessage: nil,
                    underlyingError: nil
                )
                completion(nil, .failure(responseError as NSError))
            } else if method == .delete && path.contains("/auth/v4/devices/\(self.deviceId)") {
                completion(nil, .success(DefaultResponse()))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let result = await sut.invoke(userId: userId, deviceId: deviceId, deviceToken: "token")
        XCTAssertEqual(result, .deviceRejected)
    }

    func testAssociateAuthDeviceTokenInvalid() async throws {
        apiService.requestDecodableStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            if method == .post && path.contains("/auth/v4/devices/\(self.deviceId)/associate") {
                let responseError = ResponseError(
                    httpCode: 422,
                    responseCode: APIErrorCode.authDeviceTokenInvalid,
                    userFacingMessage: nil,
                    underlyingError: nil
                )
                completion(nil, .failure(responseError as NSError))
            } else {
                XCTFail()
                completion(nil, .success([:]))
            }
        }

        let result = await sut.invoke(userId: userId, deviceId: deviceId, deviceToken: "token")
        XCTAssertEqual(result, .deviceTokenInvalid)
    }
}
#endif
