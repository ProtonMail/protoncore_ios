//
//  BioProtectionTests.swift
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

@testable import ProtonCore_Keymaker

#if !targetEnvironment(simulator)
class BioProtectionTests: XCTestCase {
    
    let keychain = Keychain(service: "ch.protonmail", accessGroup: "2SB5Z68H26.ch.protonmail.PMKeymaker")
    let mainKey = NoneProtection.generateRandomValue(length: 32)
    
    override func setUp() {
        super.setUp()
        let ret = self.keychain.removeEverything()
        XCTAssertTrue(ret)
    }
    
    func testStaticEnum() {
       XCTAssertTrue( BioProtection.keychainLabel == "\(BioProtection.self)")
    }
    
    func testLockUnlock() throws {
        let bioProtechion = BioProtection(keychain: keychain)
        XCTAssertNotNil(bioProtechion)
        try bioProtechion.lock(value: mainKey)
        
        let byte = bioProtechion.getCypherBits()
        XCTAssertNotNil(byte)
        let clear = try bioProtechion.unlock(cypherBits: byte!)
        XCTAssertEqual(clear, mainKey)
    }
}
#endif
