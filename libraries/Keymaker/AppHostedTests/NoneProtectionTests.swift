//
//  NoneProtectionTests.swift
//  ProtonCore-Keymaker-Tests - Created on 4/05/2022.
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

@testable import ProtonCoreKeymaker

class NoneProtectionTests: XCTestCase {
    let keychain = KeychainWrapper(service: "ch.protonmail", accessGroup: "xxxxxxx.ch.protonmail.PMKeymaker")
    let mainKey = NoneProtection.generateRandomValue(length: 32)

    override func setUp() {
        super.setUp()
        let ret = self.keychain.removeEverything()
        XCTAssertTrue(ret)
    }
    func testStaticEnum() {
       XCTAssertTrue( NoneProtection.keychainLabel == "\(NoneProtection.self)")
    }

    func testLockUnlock() throws {
        let noneProtechion = NoneProtection(keychain: keychain)
        XCTAssertNotNil(noneProtechion)
        try noneProtechion.lock(value: mainKey)

        let byte = noneProtechion.getCypherBits()
        XCTAssertNotNil(byte)
        XCTAssertTrue(byte!.count == 32)
        let clear = try noneProtechion.unlock(cypherBits: byte!)
        XCTAssertEqual(clear, mainKey)
    }
}
