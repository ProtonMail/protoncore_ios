//
//  SettingsResponseTests.swift
//  ProtonCore-Services-Tests - Created on 03/05/24.
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
import ProtonCoreServices

class SettingsResponseTests: XCTestCase {

    var jsonDecoder: JSONDecoder!

#if SPM
    let bundle = Bundle.module
#else
    let bundle = Bundle(for: type(of: self))
#endif

    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder.decapitalisingFirstLetter
    }

    override func tearDown() {
        jsonDecoder = nil
        super.tearDown()
    }

    func testSettingsResponseWithTwoFACodeAndFIDO2() {
        guard let url = bundle.url(forResource: "Settings", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to read contents of fixture file")
            return
        }

        do {
            let response = try jsonDecoder.decode(SettingsResponse.self, from: data)

            XCTAssertEqual(response.userSettings._2FA.registeredKeys[0].attestationFormat, "packed")
            XCTAssert(response.userSettings._2FA.registeredKeys[0].credentialID.starts(with: Data([214, 89, 242])))
            XCTAssertEqual(response.userSettings._2FA.registeredKeys[0].name, "Yubi")

        } catch {
            XCTFail("Error decoding data: \(error)")
        }

    }
}
