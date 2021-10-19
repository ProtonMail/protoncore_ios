//
//  PaymentsNewUserSubscriptionUIVCUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import XCTest
import ProtonCore_TestingToolkit

class PaymentsNewUserSubscriptionUIVCUITests: PaymentsBaseTestCase {
    
    lazy var quarkCommands = QuarkCommands(doh: doh)
    let mainRobot = PaymentsSampleAppRobot()
    let password = "a"
    
    override func setUp() {
        super.setUp()
        
        quarkCommands.unban()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    /// Update to plus plan
    
    func testUpdatePlusPlanSuccess() {
        let user = testData.mailFreeUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .plus)
            .verifyNumberOfCells(number: 2)
            .planButtonTap(plan: .plus)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .wait(timeInterval: 5)
            .selectPlanCell(plan: .plus)
            .planButtonDoesNotExist(plan: .plus)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlan(plan: .plus)
    }
    
    func testUpdatePlusPlanSuccessAppTermination() {
        let user = testData.mailFreeUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .selectPlanCell(plan: .plus)
            .verifyNumberOfCells(number: 2)
            .planButtonTap(plan: .plus)
            .verifyPayment(robot: PaymentsUIRobot.self, password: nil)
            .terminateApp(robot: PaymentsSampleAppRobot.self)
            .activateApp(robot: PaymentsSampleAppRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 5)
            .selectPlanCell(plan: .plus)
            .planButtonDoesNotExist(plan: .plus)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlan(plan: .plus)
    }
    
    /// Test current plans
    
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonDoesNotExist(plan: .mailPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .mailPlus)
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
            .selectPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .pro)
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
    
    func testCurrentMailPlusVpnPlusWithCouponPlan() {
        let user = testData.mailPlusVpnPlusWithCouponUser
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: user.username)
            .insertPassword(password: user.password)
            .loginButtonTap()
            .modalVCSwitchTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .mailPlusVpnPlus)
            .planButtonDoesNotExist(plan: .mailPlusVpnPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .mailPlusVpnPlus)
    }
    
    // TODO update after CP-2792
//    func testCurrentVpnPlusPlan() {
//        let user = testData.vpnPlusUser
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
//            .selectPlanCell(plan: .free)
//            .planButtonDoesNotExist(plan: .free)
//            .verifyNumberOfCells(number: 1)
//            .verifyPlan(plan: .free)
//    }
//
//    func testCurrentVpnBasicPlan() {
//        let user = testData.vpnBasicUser
//
//        mainRobot
//            .showPaymentsUI()
//            .verify.newUserSubscriptionUIScreenIsShown()
//            .insertUsername(name: user.username)
//            .insertPassword(password: user.password)
//            .loginButtonTap()
//            .showCurrentPlanButtonTap()
//            .wait(timeInterval: 2)
//            .selectPlanCell(plan: .free)
//            .planButtonDoesNotExist(plan: .free)
//            .verifyNumberOfCells(number: 1)
//            .verifyPlan(plan: .free)
//    }
    
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonDoesNotExist(plan: .mailPlus)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .mailPlus)
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
            .selectPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .pro)
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
            .selectPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .visionary)
    }
    
    // TODO update after CP-2792
//    func testUpdateVpnPlusPlan() {
//        let user = testData.vpnPlusUser
//
//        mainRobot
//            .showPaymentsUI()
//            .verify.newUserSubscriptionUIScreenIsShown()
//            .insertUsername(name: user.username)
//            .insertPassword(password: user.password)
//            .loginButtonTap()
//            .showUpdatePlansButtonTap()
//            .wait(timeInterval: 2)
//            .selectPlanCell(plan: .free)
//            .planButtonDoesNotExist(plan: .free)
//            .verifyNumberOfCells(number: 1)
//            .verifyPlan(plan: .free)
//    }
//
//    func testUpdateVpnBasicPlan() {
//        let user = testData.vpnBasicUser
//
//        mainRobot
//            .showPaymentsUI()
//            .verify.newUserSubscriptionUIScreenIsShown()
//            .insertUsername(name: user.username)
//            .insertPassword(password: user.password)
//            .loginButtonTap()
//            .showUpdatePlansButtonTap()
//            .wait(timeInterval: 2)
//            .selectPlanCell(plan: .free)
//            .planButtonDoesNotExist(plan: .free)
//            .verifyNumberOfCells(number: 1)
//            .verifyPlan(plan: .free)
//    }
}

extension PaymentsNewUserSubscriptionUIVCUITests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
