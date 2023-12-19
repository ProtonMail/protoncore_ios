//
//  PaymentsNewUserSubscriptionUIVCUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import XCTest
import fusion
import ProtonCoreTestingToolkit
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
import Alamofire

class PaymentsNewUserSubscriptionUIVCUITests: PaymentsBaseTestCase {

    lazy var quarkCommands = Quark().baseUrl(doh)
    let mainRobot = PaymentsSampleAppRobot()

    override func setUpWithError() throws {
        try super.setUpWithError()

        try quarkCommands.jailUnban()
        try quarkCommands.systemEnv(variable: "JAILS_ENABLED", value: "0")
    }

    override func setUp() {
        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }

    /// Test current plans
    func testCurrentFreePlan() throws {
        let user = User(name: StringUtils.randomAlphanumericString(), password: ObfuscatedConstants.password)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }

    func testCurrentVisionaryPlan() {
        let user = testData.visionaryUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .visionary)
    }

    func testCurrentVpnPlusPlan() {
        let user = testData.vpnPlusUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }

    func testCurrentVpnBasicPlan() {
        let user = testData.vpnBasicUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }

    /// Update to plus plan

    func testUpdatePlusPlanSuccess() throws {
        let user = User(name: StringUtils.randomAlphanumericString(), password: ObfuscatedConstants.password)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonTap(plan: .mail2022)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .wait(timeInterval: 5)
            .selectPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlan(plan: .mail2022)
    }

    func testUpdatePlusPlanSuccessAppTermination() throws {
        let user = User(name: StringUtils.randomAlphanumericString(), password: ObfuscatedConstants.password)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonTap(plan: .mail2022)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .terminateApp(app: app, robot: PaymentsSampleAppRobot.self)
            .activateApp(app: app, robot: CoreExampleMainRobot.self)
            .tap(.payments, to: PaymentsSampleAppRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: randomUsername)
            .insertPassword(password: ObfuscatedConstants.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlan(plan: .mail2022)
    }
    /// Test update plans

    func testUpdateVisionaryPlan() {
        let user = testData.visionaryUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .visionary)
    }

    func testUpdateVpnPlusPlan() {
        let user = testData.vpnPlusUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showUpdatePlansButtonTap()
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }

    func testUpdateVpnBasicPlan() {
        let user = testData.vpnBasicUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }
}
