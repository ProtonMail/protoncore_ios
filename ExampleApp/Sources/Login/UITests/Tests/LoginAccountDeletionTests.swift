//
//  LoginAccountDeletionTests.swift
//  SampleAppUITests
//
//  Created by Greg on 29.07.22.
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

class LoginAccountDeletionTests: ProtonCoreBaseTestCase {

    let entryRobot = CoreExampleMainRobot()

    enum AlternaviteRouting: String {
        case off = "Off"
        case on = "On"
        case force = "Force"
    }

    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-LoginAccountDeletion-UITests")
        super.setUp()
    }

    func testLoginWithAccountDeletionCheck() {
        entryRobot.tap(.login, to: LoginSampleAppRobot.self)
            .changeEnvironmentToProd()
            .showLogin()
            .fillUsername(username: ObfuscatedConstants.liveTestUserUsername)
            .fillpassword(password: ObfuscatedConstants.liveTestUserPassword)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonDeleAccountVisible()
            .showDeleteAccount()
            .verifyDeleteAccount.deleteAccountShown()
    }

    func testLoginWithAccountDeletionAlternativeRoutingCheck() {
        entryRobot.changeAlternativeRoutingSwitch(name: AlternaviteRouting.force.rawValue)
            .tap(.login, to: LoginSampleAppRobot.self)
            .changeEnvironmentToProd()
            .showLogin()
            .fillUsername(username: ObfuscatedConstants.liveTestUserUsername)
            .fillpassword(password: ObfuscatedConstants.liveTestUserPassword)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonDeleAccountVisible()
            .showDeleteAccount()
            .verifyDeleteAccount.deleteAccountShown()
    }
}
