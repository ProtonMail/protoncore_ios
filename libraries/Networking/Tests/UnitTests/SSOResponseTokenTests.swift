//
//  SSOResponseTokenTests.swift
//  ProtonCore-Networking-iOS-Unit-Tests - Created on 19.06.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
@testable import ProtonCoreNetworking

final class SSOResponseTokenTests: XCTestCase {
    var sut: SSOResponseToken!
    
    func test_init() {
        sut = .init(token: "token", uid: "uid")
        XCTAssertEqual(sut.token, "token")
        XCTAssertEqual(sut.uid, "uid")
    }
}
