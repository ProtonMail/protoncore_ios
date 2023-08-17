//
//  RandomPinProtectionTests.swift
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

class RandomPinProtectionTests: XCTestCase {

    let keychain = KeychainWrapper(service: "ch.protonmail", accessGroup: "xxxxxxx.ch.protonmail.PMKeymaker")
    let mainKey = RandomPinProtection.generateRandomValue(length: 32)
    let pinCode = "123"
    
    override func setUp() {
        super.setUp()
        let ret = self.keychain.removeEverything()
        XCTAssertTrue(ret)
    }
    func testStaticEnum() {
       XCTAssertTrue( RandomPinProtection.keychainLabel == "\(RandomPinProtection.self)")
    }
    
    func testLockUnlockV1() throws {
        let randomProtechion = RandomPinProtection(pin: pinCode, keychain: keychain)
        XCTAssertNotNil(randomProtechion)
        try randomProtechion.lock(value: mainKey)
        
        let byte = randomProtechion.getCypherBits()
        XCTAssertNotNil(byte)
        let clear = try randomProtechion.unlock(cypherBits: byte!)
        XCTAssertEqual(clear, mainKey)
    }
    
    // TODO: this is testing the lagcy encrypt data. but right now we lost the logic to creat the lagcy data. need wait to fix this
    //    func testLockUnlockV0() throws {
    //        let randomProtechion = RandomPinProtection(pin: pinCode, keychain: keychain, version: .lagcy)
    //        XCTAssertNotNil(randomProtechion)
    //        try randomProtechion.lock(value: mainKey)
    //
    //        let byte = randomProtechion.getCypherBits()
    //        XCTAssertNotNil(byte)
    //        let clear = try randomProtechion.unlock(cypherBits: byte!)
    //        XCTAssertEqual(clear, mainKey)
    //    }

}
