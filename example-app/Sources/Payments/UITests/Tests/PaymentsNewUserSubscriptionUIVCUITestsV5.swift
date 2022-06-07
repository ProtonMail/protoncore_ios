//
//  PaymentsNewUserSubscriptionUIVCUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands
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
    
    func testCurrentPlusPlan() {
        let user = testData.mailPlusUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .mailPlus)
            .planButtonDoesNotExist(plan: .mailPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .mailPlus)
    }
    
    func testCurrentProPlan() {
        let user = testData.mailProUser

        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .pro)
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
    // Commenting out until the mailPlusVpnPlusWithCouponUser user will be seeded
//    func testCurrentMailPlusVpnPlusWithCouponPlan() {
//        let user = testData.mailPlusVpnPlusWithCouponUser
//
//        mainRobot
//            .showPaymentsUI()
//            .verify.newUserSubscriptionUIScreenIsShown()
//            .insertUsername(name: user.username)
//            .insertPassword(password: user.password)
//            .loginButtonTap()
//            .modalVCSwitchTap()
//            .showCurrentPlanButtonTap()
//            .wait(timeInterval: 2)
//            .selectPlanCell(plan: .mailPlus)
//            .planButtonDoesNotExist(plan: .mailPlus)
//            .verifyNumberOfCells(number: 1)
//            .verifyPlanV5(plan: .mailPlus)
//    }
    
    func testCurrentMailProVpnFreePlan() {
        let user = testData.mailprovpnfreeUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .pro)
    }
    
    func testCurrentMailPlusVpnFreePlan() {
        let user = testData.mailplusvpnfreeUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .mailPlus)
            .planButtonDoesNotExist(plan: .mailPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .mailPlus)
    }
    
    // Commenting out until the orgSubUser user will be seeded
//    func testCurrentOrgMemberPlan() {
//        let user = testData.orgSubUser
//
//        mainRobot
//            .showPaymentsUI()
//            .verify.newUserSubscriptionUIScreenIsShown()
//            .insertUsername(name: user.email)
//            .insertPassword(password: user.password)
//            .loginButtonTap()
//            .modalVCSwitchTap()
//            .showCurrentPlanButtonTap()
//            .wait(timeInterval: 2)
//            .selectCurrentPlanCell(plan: .none)
//            .verifyNumberOfCells(number: 1)
//    }

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
    
    func testUpdatePlusPlan() {
        let user = testData.mailPlusUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .mailPlus)
            .planButtonDoesNotExist(plan: .mailPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .mailPlus)
    }
    
    func testUpdateProPlan() {
        let user = testData.mailProUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectCurrentPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlanV5(plan: .pro)
    }
    
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
