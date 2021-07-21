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
    
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    let password = ObfuscatedConstants.password
    let paymentPassword = ObfuscatedConstants.sandboxPaymentAccountPassword
    
    override func setUp() {
        super.setUp()
        mainRobot
            .changeEnvironmentToOhmBlack()
            .planSelectorSwitchTap()
    }

    /// Free internal account creation
    
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
    
    func testSignupNewIntFreePlanWithAppInBackground() {
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
    
    func testSignupNewIntFreePlanAndAppTermination() {
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
            .changeEnvironmentToOhmBlack()
            .showLogin()
            .fillUsername(username: name)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan internal account creation
    
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
    
    func testSignupNewIntAccountWhithPlusPlanSuccessAppInBackground() {
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
            .backgroundApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .logoutButtonTap()
    }
    
    func testSignupNewIntAccountWhithPlusPlanSuccessAppTermination() {
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
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToOhmBlack()
            .planSelectorSwitchTap()
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
            .freePlanButtonDoesNotExist()
            .selectPlusPlanCell()
            .plusPlanButtonTap()
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .logoutButtonTap()
    }
    
    /// Free external account creation
    
    func testSignupNewExtAccountWhithFreePlanSuccess() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
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
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectFreePlanCell()
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan external account creation
    
    func testSignupNewExtAccountWhithPlusPlanSuccess() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlusPlanCell()
            .plusPlanButtonTap()
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .logoutButtonTap()
    }

    func testSignupNewExtAccountWhithPlusPlanWithAppInBackground() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlusPlanCell()
            .plusPlanButtonTap()
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
}

extension SignupPlanSelectorTests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
        
    private var randomEmail: String {
        return "\(randomName)@test.a"
    }
}
