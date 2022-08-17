//
//  VerifiedMessageTests.swift
//  ProtonCore-Crypto-Tests - Created on 07/15/22.
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
@testable import ProtonCore_Crypto

class VerifiedMessageTests: CryptoTestBase {

    func testVerifiedString() {
        let check = "TestString"
        let vstring = VerifiedString.verified(check)
        XCTAssertEqual(check, vstring.content)
        let vstringError = VerifiedString.unverified(check, SignatureVerifyError.init(message: "error"))
        XCTAssertEqual(check, vstringError.content)
    }
    
    func testVerifiedData() {
        let check = random(length: 10)
        let vData = VerifiedData.verified(check)
        XCTAssertEqual(check, vData.content)
        let vDataError = VerifiedData.unverified(check, SignatureVerifyError.init(message: "error"))
        XCTAssertEqual(check, vDataError.content)
    }
}
