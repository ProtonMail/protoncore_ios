//
//  LoginTests.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands

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
