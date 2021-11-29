//
//  DeviceServiceTests.swift
//  ProtonCore-Login-Tests - Created on 08.04.21.
//
//  Copyright (c) 2019 Proton Technologies AG
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

// swiftlint:disable xctfail_message

import XCTest

import ProtonCore_TestingToolkit
@testable import ProtonCore_Login

@available(macOS 10.15, iOS 11.0, *)
class DeviceServiceTests: XCTestCase {

    enum GenericError: LocalizedError {
        case error(description: String)
        var errorDescription: String? {
            switch self {
            case .error(let description):
                return description
            }
        }
    }
    
    func createDevice(isSupported: Bool, data: Data? = nil, error: Error? = nil) -> DeviceService {
        let deviceMock = DCDeviceMock(isSupported: isSupported, data: data, error: error)
        return DeviceService(device: deviceMock)
    }

    func testGenerateTokenUnsuported() {
        let service = createDevice(isSupported: false)
        let expect = expectation(description: "expectation1")
        service.generateToken { result in
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "test")
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGenerateTokenDeviceTokenError() {
        let service = createDevice(isSupported: true, data: nil, error: nil)
        let expect = expectation(description: "expectation1")
        service.generateToken { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, SignupError.deviceTokenError)
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGenerateTokenGenericError() {
        let error = GenericError.error(description: "Test error")
        let service = createDevice(isSupported: true, data: nil, error: error)
        let expect = expectation(description: "expectation1")
        service.generateToken { result in
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "test")
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGenerateTokenSuccess() {
        let service = createDevice(isSupported: true, data: Data(base64Encoded: "test"), error: nil)
        let expect = expectation(description: "expectation1")
        service.generateToken { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, "test")
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

}
