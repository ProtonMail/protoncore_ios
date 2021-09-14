//
//  ExampleLocalMailAppUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import XCTest
import ProtonCore_TestingToolkit

class NewUserSubscriptionUIVCUITests: BaseTestCase {

    let quarkCommands = QuarkCommands(doh: OhmBlackDoHMail.default)
    let mainRobot = MainRobot()
    let password = "a"
    
    override func setUp() {
        super.setUp()

        quarkCommands.unban()
        mainRobot
            .changeEnvironmentToOhmBlack()
    }
    
    /// Update to plus plan
    
    func testUpdatePlusPlanSuccess() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password)
        
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
            .verifyPayment(password: nil)
            .wait(timeInterval: 5)
            .selectPlanCell(plan: .plus)
            .planButtonDoesNotExist(plan: .plus)
            .verifyNumberOfCells(number: 1)
            .verifyExpirationTime()
            .verifyPlan(plan: .plus)
    }
    
    func testUpdatePlusPlanSuccessAppTermination() {
        let name = randomName
        quarkCommands.createUser(username: name, password: password)
        
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
            .verifyPayment(password: nil)
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToOhmBlack()
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
        quarkCommands.createUser(username: name, password: password, plan: .mailPlus)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .pro)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .visionary)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .vpnPlus)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .vpnBasic)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .mailPlus)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .pro)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .visionary)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .vpnPlus)
        
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
        quarkCommands.createUser(username: name, password: password, plan: .vpnBasic)
        
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

extension NewUserSubscriptionUIVCUITests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
