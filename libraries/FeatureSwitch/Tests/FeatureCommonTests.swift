//
//  FeatureCommonTests.swift
//  ProtonCore-FeatureSwitch - Created on 9/20/22.
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

import XCTest
@testable import ProtonCoreFeatureSwitch

class FeatureCommonTests: XCTestCase {
    
    func testFileWithoutCommon() {
        let url = Bundle.main.url(forResource: "testFeature", withExtension: "json")
        XCTAssertNil(url)
        let url1 = Bundle.main.url(forResource: "testLocalFeature", withExtension: "json")
        XCTAssertNil(url1)
        let url2 = Bundle(for: type(of: self)).url(forResource: "testFeature", withExtension: "json")
        XCTAssertNil(url2)
    }
    
    func testFileWithCommon() {
        let url = FeatureCommon.bundle.url(forResource: "testFeature", withExtension: "json")
        XCTAssertNotNil(url)
        let bundle: Bundle
        #if SPM
        bundle = Bundle.module
        #else
        bundle = Bundle(for: type(of: self)) 
        #endif
        let url1 = bundle.url(forResource: "testLocalFeature", withExtension: "json")
        XCTAssertNotNil(url1)
        let url2 = FeatureCommon.bundle.url(forResource: "testRemoteFeature", withExtension: "json")
        XCTAssertNil(url2)
    }
}
