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
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
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
            .selectPlanCell(plan: .mailFree)
            .mailFreePlanButtonTap()
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
            .selectPlanCell(plan: .mailFree)
            .mailFreePlanButtonTap()
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
            .selectPlanCell(plan: .mailFree)
            .mailFreePlanButtonTap()
            .proceed(to: MainRobot.self)
            .terminateApp(robot: MainRobot.self)
            .activateApp(robot: MainRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showLogin()
            .fillUsername(username: name)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan internal account creation, only works on a real device
    
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: AccountSummaryRobot.self, password: paymentPassword)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: AccountSummaryRobot.self, password: paymentPassword)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateAppWithSiri(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
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
            .selectPlanCell(plan: .mailFree)
            .mailFreePlanButtonTap()
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
            .selectPlanCell(plan: .mailFree)
            .mailFreePlanButtonTap()
            .proceed(to: MainRobot.self)
            .backgroundApp(robot: MainRobot.self)
            .activateAppWithSiri(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan external account creation, only works on a real device
    
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: AccountSummaryRobot.self, password: paymentPassword)
            .startUsingAppTap(robot: MainRobot.self)
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: MainRobot.self, password: paymentPassword)
            .backgroundApp(robot: MainRobot.self)
            .activateAppWithSiri(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: MainRobot.self)
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
