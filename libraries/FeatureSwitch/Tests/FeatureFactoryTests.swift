//
//  FeatureFactoryTests.swift
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
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif

class FeatureFactoryMock: FeatureFactory {
    override init() { super.init() }
    
    @FuncStub(FeatureFactoryMock.isCoreInternal, initialReturn: .crash) public var isCoreInternalStub
    override func isCoreInternal() -> Bool { isCoreInternalStub() }
    
    @FuncStub(FeatureFactoryMock.isInternal, initialReturn: .crash) public var isInternalStub
    override func isInternal() -> Bool { isInternalStub() }
}

class FeatureFactoryTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        FeatureFactory.shared.clear()
    }
    
    func testFeatures() {
        var testfeatureOne = Feature.init(name: "testfeatureOne", isEnable: false, flags: [])
        XCTAssertFalse(FeatureFactory.shared.isEnabled(testfeatureOne))
        FeatureFactory.shared.enable(&testfeatureOne)
        XCTAssertTrue(FeatureFactory.shared.isEnabled(testfeatureOne))
        FeatureFactory.shared.disable(&testfeatureOne)
        XCTAssertFalse(FeatureFactory.shared.isEnabled(testfeatureOne))
        testfeatureOne.enable()
        XCTAssertTrue(testfeatureOne.isEnabled)
        testfeatureOne.disable()
        XCTAssertFalse(testfeatureOne.isEnabled)
        
        #if !SPM
        // TODO: enable back the test once you find a way to build with DEBUG_CORE_INTERNAL in tests
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: false, flags: [.availableCoreInternal])
        XCTAssertFalse(FeatureFactory.shared.isEnabled(testfeatureTwo))
        FeatureFactory.shared.enable(&testfeatureTwo)
        XCTAssertTrue(FeatureFactory.shared.isEnabled(testfeatureTwo))
        FeatureFactory.shared.disable(&testfeatureTwo)
        XCTAssertFalse(FeatureFactory.shared.isEnabled(testfeatureTwo))
        testfeatureTwo.enable()
        XCTAssertTrue(testfeatureTwo.isEnabled)
        testfeatureTwo.disable()
        XCTAssertFalse(testfeatureTwo.isEnabled)
        #endif
    }
    
    func testFeaturesDisibleCoreInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return false
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return false
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableCoreInternal])
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        
        var testfeatureOne = Feature.init(name: "testfeatureOne", isEnable: true, flags: [])
        XCTAssertTrue(sharedMock.isEnabled(testfeatureOne))
        sharedMock.disable(&testfeatureOne)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureOne))
        sharedMock.enable(&testfeatureOne)
        XCTAssertTrue(sharedMock.isEnabled(testfeatureOne))
    }
    
    func testFeaturesDisibleInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return false
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return false
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableInternal])
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        
        var testfeatureOne = Feature.init(name: "testfeatureOne", isEnable: true, flags: [])
        XCTAssertTrue(sharedMock.isEnabled(testfeatureOne))
        sharedMock.disable(&testfeatureOne)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureOne))
        sharedMock.enable(&testfeatureOne)
        XCTAssertTrue(sharedMock.isEnabled(testfeatureOne))
    }
    
    func testFeaturesEnableCoreInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return true
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return false
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableCoreInternal])
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
    }
    
    func testFeaturesEnableInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return false
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return true
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableInternal])
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
    }
    
    func testFeaturesDisibleCoreInternalEnableInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return false
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return true
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableInternal, .availableCoreInternal])
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
    }
    
    func testFeaturesEnalbeCoreInternalDisibleInternal() {
        let sharedMock = FeatureFactoryMock.init()
        sharedMock.isCoreInternalStub.bodyIs { _ in
            return true
        }
        sharedMock.isInternalStub.bodyIs { _ in
            return false
        }
        
        var testfeatureTwo = Feature.init(name: "testfeatureTwo", isEnable: true, flags: [.availableInternal, .availableCoreInternal])
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.disable(&testfeatureTwo)
        XCTAssertFalse(sharedMock.isEnabled(testfeatureTwo))
        sharedMock.enable(&testfeatureTwo)
        XCTAssertTrue(sharedMock.isEnabled(testfeatureTwo))
    }
}

