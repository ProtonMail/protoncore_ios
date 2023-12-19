//
//  LoginExternalAccountsUpdateRequiredUITests.swift
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

class LoginExternalAccountsUpdateRequiredUITests: LoginBaseTestCase {

    let mainRobot = LoginSampleAppRobot()
    lazy var quarkCommands = Quark().baseUrl(doh)

    override func setUp() {
        beforeSetUp(launchArguments: ["UITests_MockExternalAccountsUpdateRequiredInAuth"])

        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }

    func testExternalAccountsUpdateRequiredPopupIsClosable() throws {
        let user = User(email: randomEmail, name: randomName, password: randomPassword, isExternal: true)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showLogin()
            .fillUsername(username: user.email)
            .fillpassword(password: user.password)
            .signIn(robot: ExternalAccountsNotSupportedDialogRobot.self)
            .verify.externalAccountsUpdateRequireddDialog()
            .tapClose(to: LoginRobot.self)
            .closeLoginScreen(to: LoginSampleAppRobot.self)
            .verify.buttonLogoutIsNotVisible()
    }

    func testExternalAccountsUpdateRequiredPopupOpensLearnMorePage() throws {
        let user = User(email: randomEmail, name: randomName, password: randomPassword, isExternal: true)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showLogin()
            .fillUsername(username: user.email)
            .fillpassword(password: user.password)
            .signIn(robot: ExternalAccountsNotSupportedDialogRobot.self)
            .verify.externalAccountsUpdateRequireddDialog()
            .verify.isInsideTheApplication()
            .tapLearnMore(to: SafariRobot.self)
            .verify.isOutsideOfApplication()
    }
}
