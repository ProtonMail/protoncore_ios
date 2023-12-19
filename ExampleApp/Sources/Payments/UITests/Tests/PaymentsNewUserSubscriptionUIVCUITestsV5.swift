//
//  PaymentsNewUserSubscriptionUIVCUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import XCTest
import fusion
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsPaymentsUI
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
import Alamofire

class PaymentsNewUserSubscriptionUIVCUITests: PaymentsBaseTestCase {

    let mainRobot = PaymentsSampleAppRobot()
    lazy var quarkCommands = Quark().baseUrl(doh)

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
            .selectCurrentPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .free)
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
            .selectCurrentPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .visionary)
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
            .selectCurrentPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .free)
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
            .selectCurrentPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .free)
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
            .selectCurrentPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlanV5(plan: .mail2022)
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
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonSelected(plan: .mail2022)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlanV5(plan: .mail2022)
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
            .selectCurrentPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .visionary)
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
            .selectCurrentPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .free)
    }

    func testUpdateVpnBasicPlan() {
        let user = testData.vpnBasicUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .free)
    }

    func testUpdatePlusPlanSuccessExtendSubscriptionSuccess() throws {
        let user = User(name: StringUtils.randomAlphanumericString(), password: ObfuscatedConstants.password)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .extendSunscriptionSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonTap(plan: .mail2022)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .wait(timeInterval: 5)
            .selectCurrentPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlanV5(plan: .mail2022)
            .extendSubscriptionTap()
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .wait(timeInterval: 5)
            .selectCurrentPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyRenewTime()
    }

    func testUpdatePlusPlanSuccessExtendSubscriptionSuccessAppTermination() throws {
        let user = User(name: StringUtils.randomAlphanumericString(), password: ObfuscatedConstants.password)
        try quarkCommands.userCreate(user: user)

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .extendSunscriptionSwitchTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .mail2022)
            .planButtonTap(plan: .mail2022)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .wait(timeInterval: 5)
            .selectCurrentPlanCell(plan: .mail2022)
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlanV5(plan: .mail2022)
            .extendSubscriptionTap()
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .terminateApp(app: app, robot: PaymentsSampleAppRobot.self)
            .activateApp(app: app, robot: CoreExampleMainRobot.self)
            .tap(.payments, to: PaymentsSampleAppRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.name)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .extendSunscriptionSwitchTap()
            .showCurrentPlanButtonTap()
            .selectCurrentPlanCell(plan: .mail2022)
            .extendSubscriptionSelected()
            .planButtonDoesNotExist(plan: .mail2022)
            .wait(timeInterval: 2)
            .verifyNumberOfCells(number: 1)
            .verifyRenewTime()
    }
}
