//
//  GenerateDeviceSecretTests.swift
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
@testable import ProtonCoreLogin

final class GenerateDeviceSecretTests: XCTestCase {

    var sut: GenerateDeviceSecret!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = GenerateDeviceSecret()
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
    }

    func testGenerateDeviceSecretIs32Bytes() throws {
        let deviceSecret = try sut.invoke()
        let deviceSecretData = Data(base64Encoded: deviceSecret)
        XCTAssertEqual(deviceSecretData?.count, 32)
    }
}
#endif
