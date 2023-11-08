//
//  LoginExternalAccountsAddressRequiredUITests.swift
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

class LoginExternalAccountsAddressRequiredUITests: LoginBaseTestCase {

    let mainRobot = LoginSampleAppRobot()
    lazy var quarkCommands = QuarkCommands(doh: doh)

    override func setUp() {
        beforeSetUp(launchArguments: ["UITests_MockExternalAccountsAddressRequiredInAuth"])

        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }

    func testExternalAccountsAddressRequiredPopupIsClosable() {
        let randomEmail = randomEmail
        let randomPassword = randomPassword
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

    func testExternalAccountsAddressRequiredPopupOpensLearnMorePage() {
        let randomEmail = randomEmail
        let randomPassword = randomPassword
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
