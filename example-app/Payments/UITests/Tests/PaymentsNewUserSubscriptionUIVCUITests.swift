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
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "free")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
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
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "free")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
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
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "mailPlus")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .plus)
            .planButtonDoesNotExist(plan: .plus)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .plus)
    }
    
    func testCurrentProPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "pro")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .pro)
    }
    
    func testCurrentVisionaryPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "visionary")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .visionary)
    }
    
    func testCurrentVpnPlusPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "vpnPlus")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }
    
    func testCurrentVpnBasicPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "vpnBasic")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showCurrentPlanButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }
    
    /// Test update plans
    
    func testUpdatePlusPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "mailPlus")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .plus)
            .planButtonDoesNotExist(plan: .plus)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .plus)
    }
    
    func testUpdateProPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "pro")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .pro)
            .planButtonDoesNotExist(plan: .pro)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .pro)
    }
    
    func testUpdateVisionaryPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "visionary")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .visionary)
            .planButtonDoesNotExist(plan: .visionary)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .visionary)
    }
    
    func testUpdateVpnPlusPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "vpnPlus")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }
    
    func testUpdateVpnBasicPlan() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password, protonPlanName: "vpnBasic")
        
        mainRobot
            .showPaymentsUI()
            .verify.newUserSubscriptionUIScreenIsShown()
            .insertUsername(name: name)
            .insertPassword(password: password)
            .loginButtonTap()
            .showUpdatePlansButtonTap()
            .wait(timeInterval: 2)
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .verifyNumberOfCells(number: 1)
            .verifyPlan(plan: .free)
    }

}

extension PaymentsNewUserSubscriptionUIVCUITests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
