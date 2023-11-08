//
//  TrustKitConfigurationTests.swift
//  ProtonCore-Environment-Tests - Created on 09/01/22.
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
//

#if os(iOS)

import XCTest
@testable import ProtonCoreEnvironment

final class TrustKitConfigurationTests: XCTestCase {

    func testIgnorePinningForUserDefinedTrustAnchorsIsIgnored() {
        let configuration1 = TrustKitWrapper.configuration(hardfail: true, ignoreMacUserDefinedTrustAnchors: true)
        let configuration2 = TrustKitWrapper.configuration(hardfail: true, ignoreMacUserDefinedTrustAnchors: false)
        let configuration3 = TrustKitWrapper.configuration(hardfail: true)
        XCTAssertTrue(NSDictionary(dictionary: configuration1).isEqual(to: configuration2))
        XCTAssertTrue(NSDictionary(dictionary: configuration2).isEqual(to: configuration3))
    }
}

#endif
