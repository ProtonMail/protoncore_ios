//
//  LoginMockingSetupTests.swift
//  Example-UnitTests-V5 - Created on 18/7/22.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
@testable import Example_iOS_Mail_V5_AppStoreIAP

class LoginMockingSetupTests: XCTestCase {

    override func tearDown() {
        LoginMockingSetup.stop()
    }

    func testCorrectStubbing() {
        LoginMockingSetup.start(hostUrl: "http://example.com", shouldMockHumanVerification: true)

        let data = try! Data(contentsOf: URL(string: "http://example.com/users")!)
        let string = String(data: data, encoding: .utf8)

        XCTAssertEqual("""
{\n    \"Error\": \"Human verification required\",\n    \"Code\": 9001,\n    \"Details\": {\n        \"HumanVerificationMethods\": [\"captcha\",\"sms\",\"email\",\"payment\",\"invite\", \"coupon\"],\n        \"HumanVerificationToken\": \"signup\"\n    },\n    \"ErrorDescription\": \"signup\"\n}\n
""", string)

    }

}
