//
//  SignupPlanSelectorTests.swift
//  SampleAppUITests
//
//  Created by Greg on 28.06.21.
//

import XCTest
import ProtonCore_TestingToolkit

class SignupPlanSelectorTests: BaseTestCase {

    let mainRobot = MainRobot()
    let completeRobot = CompleteRobot()
    
    let password = ObfuscatedConstants.password
    let paymentPassword = ObfuscatedConstants.sandboxPaymentAccountPassword
    
    override func setUp() {
        super.setUp()
        mainRobot
            .changeEnvironmentToBlack()
            .planSelectorSwitchTap()
    }

    func testSignupNewIntAccountWhithFreePlanSuccess() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: RecoveryRobot.self)
            .verify.recoveryScreenIsShown()
            .skipButtonTap()
            .verify.recoveryDialogDisplay()
            .skipButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectFreePlanCell()
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .logoutButtonTap()
    }
    
    func testSignupWhithFreePlanWithAppInBackground() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: RecoveryRobot.self)
            .verify.recoveryScreenIsShown()
            .skipButtonTap()
            .verify.recoveryDialogDisplay()
            .skipButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectFreePlanCell()
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupWhithFreePlanAndAppTermination() {
        let name = randomName
        let password = password
        
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: name)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: RecoveryRobot.self)
            .verify.recoveryScreenIsShown()
            .skipButtonTap()
            .verify.recoveryDialogDisplay()
            .skipButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectFreePlanCell()
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToBlack()
            .showLogin()
            .fillUsername(username: name)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupNewIntAccountWhithPlusPlanSuccess() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: RecoveryRobot.self)
            .verify.recoveryScreenIsShown()
            .skipButtonTap()
            .verify.recoveryDialogDisplay()
            .skipButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlusPlanCell()
            .plusPlanButtonTap()
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .logoutButtonTap()
    }
}

extension SignupPlanSelectorTests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
