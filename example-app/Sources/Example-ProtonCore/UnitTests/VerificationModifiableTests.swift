//
//  VerificationModifiableTests.swift
//  Example-UnitTests-V5 - Created on 19/7/22.
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
import ProtonCore_Environment
@testable import Example_iOS_Mail_V5_AppStoreIAP

class VerificationModifiableTests: XCTestCase {

    func testVerificationHostOverrideForMail() {
        let mailConfig = Environment.mailProd.dohModifiable.replacingHumanVerificationV3Host(with: "lalalalala")

        XCTAssertEqual("lalalalala", mailConfig.humanVerificationV3Host)
    }

    // the implementation lives in the default protocol implementation, so it doesn't hurt to verify
    func testVerificationHostOverrideForVPN() {
        let vpnConfig = Environment.mailProd.dohModifiable.replacingHumanVerificationV3Host(with: "lololololo")

        XCTAssertEqual("lololololo", vpnConfig.humanVerificationV3Host)
    }
}
