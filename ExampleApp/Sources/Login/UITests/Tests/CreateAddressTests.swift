//
//  LoginTests.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import XCTest
import fusion
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsLogin
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands

class CreateAddressTests: LoginBaseTestCase {
    
    let mainRobot = LoginSampleAppRobot()
    var createAddressTestCases: CreateAddressTestCases!
    
    override func setUp() {
        super.setUp()
        createAddressTestCases = CreateAddressTestCases(doh: doh)
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showLogin()
    }
    
    func testShowCreateAddressSuccessfulCreation() {
        createAddressTestCases.testShowCreateAddressSuccessfulCreation(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testShowCreateAddressNewNameSuccessfulCreation() {
        createAddressTestCases.testShowCreateAddressNewNameSuccessfulCreation(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testShowCreateAddressCancelButton() {
        createAddressTestCases.testShowCreateAddressCancelButton()
    }
    
    func testShowCreateAddressBackButton() {
        createAddressTestCases.testShowCreateAddressBackButton()
    }
    
    func testShowCreateAddressInvalidCharacter() {
        createAddressTestCases.testShowCreateAddressInvalidCharacter()
    }
}
