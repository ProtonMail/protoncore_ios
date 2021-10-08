//
//  PaymentsSignupPlanSelectorTests.swift
//  PaymentsSignupPlanSelectorTests
//
//  Created by Kristina Jureviciute on 2021-10-07.
//

import XCTest
import ProtonCore_TestingToolkit

class PaymentsSignupPlanSelectorTests: BaseTestCase {

    let mainRobot = MainRobot()
    let completeRobot = CompleteRobot()
    
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    let password = ObfuscatedConstants.password
    let paymentPassword = ObfuscatedConstants.sandboxPaymentAccountPassword
    
    override func setUp() {
        super.setUp()
        mainRobot
            .changeEnvironmentToPaymentsBlack()
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
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
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
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateAppWithSiri(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
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
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToPaymentsBlack()
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
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
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
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
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
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToPaymentsBlack()
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
            .selectPlanCell(plan: .free)
            .planButtonDoesNotExist(plan: .free)
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
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
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupWhithFreePlanWithAppInBackground() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateAppWithSiri(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan external account creation
    
    func testSignupNewExtAccountWhithPlusPlanSuccess() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
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
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .plus)
            .planButtonTap(plan: .plus)
            .verifyPaymentIfNeeded(password: paymentPassword)
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
}

extension PaymentsSignupPlanSelectorTests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
        
    private var randomEmail: String {
        return "\(randomName)@test.a"
    }
}
