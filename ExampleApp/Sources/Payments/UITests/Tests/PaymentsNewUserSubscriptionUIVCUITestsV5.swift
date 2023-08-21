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
    
    lazy var quarkCommands = QuarkCommands(doh: doh)
    let mainRobot = PaymentsSampleAppRobot()
    
    override func setUp() {
        super.setUp()
        quarkCommands.unban()
        quarkCommands.disableJail()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    /// Test current plans
    func testCurrentFreePlan() {
        let randomUsername = StringUtils.randomAlphanumericString()
        quarkCommands.createUser(username: randomUsername, password: ObfuscatedConstants.password, protonPlanName: "free")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: randomUsername)
            .insertPassword(password: ObfuscatedConstants.password)
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
    
    func testUpdatePlusPlanSuccess() {
           let randomUsername = StringUtils.randomAlphanumericString()
           quarkCommands.createUser(username: randomUsername, password: ObfuscatedConstants.password, protonPlanName: "free")
           
           mainRobot
               .showPaymentsUI()
               .verify.newUserSubscriptionUIScreenIsShown()
               .insertUsername(name: randomUsername)
               .insertPassword(password: ObfuscatedConstants.password)
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
       
       func testUpdatePlusPlanSuccessAppTermination() {
           let randomUsername = StringUtils.randomAlphanumericString()
           quarkCommands.createUser(username: randomUsername, password: ObfuscatedConstants.password, protonPlanName: "free")
           
           mainRobot
               .showPaymentsUI()
               .verify.newUserSubscriptionUIScreenIsShown()
               .insertUsername(name: randomUsername)
               .insertPassword(password: ObfuscatedConstants.password)
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
    
    func testUpdatePlusPlanSuccessExtendSubscriptionSuccess() {
        let randomUsername = StringUtils.randomAlphanumericString()
        quarkCommands.createUser(username: randomUsername, password: ObfuscatedConstants.password, protonPlanName: "free")
           
        mainRobot
           .showPaymentsUI()
           .verify.newUserSubscriptionUIScreenIsShown()
           .insertUsername(name: randomUsername)
           .insertPassword(password: ObfuscatedConstants.password)
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
    
    func testUpdatePlusPlanSuccessExtendSubscriptionSuccessAppTermination() {
        let randomUsername = StringUtils.randomAlphanumericString()
        quarkCommands.createUser(username: randomUsername, password: ObfuscatedConstants.password, protonPlanName: "free")
           
        mainRobot
           .showPaymentsUI()
           .verify.newUserSubscriptionUIScreenIsShown()
           .insertUsername(name: randomUsername)
           .insertPassword(password: ObfuscatedConstants.password)
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
           .insertUsername(name: randomUsername)
           .insertPassword(password: ObfuscatedConstants.password)
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
