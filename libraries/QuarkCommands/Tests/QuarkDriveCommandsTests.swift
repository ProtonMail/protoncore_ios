//
//  QuarkDriveCommandsTests.swift
//  ProtonCore-QuarkCommands-Tests - Created on 03/20/2024.
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

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
#if canImport(ProtonCoreTestingToolkitUnitTestsDoh)
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreQuarkCommands

final class QuarkDriveCommandsTests: XCTestCase {

    var dohMock: DohMock!

    override func setUp() {
        super.setUp()
        dohMock = DohMock()

        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
        }

        stub(condition: isHost("test.quark.commands.url")) { request in
            #if SPM
            let bundle = Bundle.module
            #else
            let bundle = Bundle(for: type(of: self))
            #endif
            let url = bundle.url(forResource: "DrivePopulate", withExtension: "html")!
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)

        }
        // mock url
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }
    }

    func testDrivePopuleQuarkCommand() {
        // mock response
        let quarkCommand = Quark().baseUrl(dohMock)

        let user = User(name: "quarkcommand@test.quark.commands.url", password: "123456789")
        do {
            // Act
            let (_, response) = try quarkCommand.drivePopulateUser(user: user, scenario: 4, hasPhotos: false, withDevice: false)

            // Assert
            XCTAssertEqual(response.url?.absoluteString, "https://test.quark.commands.url/quark/raw::drive:populate?-u=quarkcommand@test.quark.commands.url&-p=123456789&-S=4")
        } catch {
            XCTFail("drivePopulateUser method threw an unexpected error: \(error)")
        }
    } 

    func testDrivePopuleQuarkCommandWithPhotosAndDevice() {
        let quarkCommand = Quark().baseUrl(dohMock)

        let user = User(name: "quarkcommand@test.quark.commands.url", password: "123456789")

        do {
            // Act
            let (_, response) = try quarkCommand.drivePopulateUser(user: user, scenario: 4, hasPhotos: true, withDevice: true)

            // Assert
            XCTAssertEqual(response.url?.absoluteString, "https://test.quark.commands.url/quark/raw::drive:populate?-u=quarkcommand@test.quark.commands.url&-p=123456789&-S=4&--photo=true&--device=true")
        } catch {
            XCTFail("drivePopulateUser method threw an unexpected error: \(error)")
        }
    }
}
