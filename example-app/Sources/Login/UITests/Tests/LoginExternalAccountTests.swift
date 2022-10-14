//
//  LoginExternalAccountTests.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands

class LoginExternalAccountUnavailableTests: LoginBaseTestCase {
    
    let mainRobot = LoginSampleAppRobot()
    lazy var quarkCommands = QuarkCommands(doh: doh)
    
    override func setUp() {
        beforeSetUp(launchArguments: ["UITests_MockExternalAccountsUnavailableInAuth"])
        
        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    func testExternalAccountUnavailablePopupIsClosable() {
        let randomEmail = "\(StringUtils.randomAlphanumericString(length: 8))@proton.uitests"
        let randomPassword = StringUtils.randomAlphanumericString(length: 8)
        quarkCommands.createUser(externalEmail: randomEmail, password: randomPassword)
        
        mainRobot
            .showLogin()
            .fillUsername(username: randomEmail)
            .fillpassword(password: randomPassword)
            .signIn(robot: ExternalAccountsNotSupportedDialogRobot.self)
            .verify.externalAccountsNotSupportedDialog()
            .tapClose(to: LoginRobot.self)
            .closeLoginScreen(to: LoginSampleAppRobot.self)
            .verify.buttonLogoutIsNotVisible()
    }
    
    func testExternalAccountUnavailablePopupOpensLearnMorePage() {
        let randomEmail = "\(StringUtils.randomAlphanumericString(length: 8))@proton.uitests"
        let randomPassword = StringUtils.randomAlphanumericString(length: 8)
        quarkCommands.createUser(externalEmail: randomEmail, password: randomPassword)
        
        mainRobot
            .showLogin()
            .fillUsername(username: randomEmail)
            .fillpassword(password: randomPassword)
            .signIn(robot: ExternalAccountsNotSupportedDialogRobot.self)
            .verify.externalAccountsNotSupportedDialog()
            .verify.isInsideTheApplication()
            .tapLearnMore(to: SafariRobot.self)
            .verify.isOutsideOfApplication()
    }
}
