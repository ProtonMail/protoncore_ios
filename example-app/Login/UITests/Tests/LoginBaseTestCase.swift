//
//  LoginBaseTestCase.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest
import ProtonCore_Log
import ProtonCore_TestingToolkit

class LoginBaseTestCase: ProtonCoreBaseTestCase {
    
    let testData = TestData()
    
    override var host: String { super.host ?? ObfuscatedConstants.blackDefaultHost }
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: LoginSampleAppRobot!
        
    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-Login-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.login, to: LoginSampleAppRobot.self)
    }
}
