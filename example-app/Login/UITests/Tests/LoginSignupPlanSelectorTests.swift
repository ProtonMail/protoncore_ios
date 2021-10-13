//
//  LoginSignupPlanSelectorTests.swift
//  SampleAppUITests
//
//  Created by Greg on 28.06.21.
//

import XCTest
import ProtonCore_TestingToolkit

class LoginSignupPlanSelectorTests: LoginBaseTestCase {

    let mainRobot = LoginSampleAppRobot()
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

    /// Free internal account creation, only works on a real device
    
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
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .proceed(to: LoginSampleAppRobot.self)
            .backgroundApp(robot: LoginSampleAppRobot.self)
            .activateApp(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .proceed(to: LoginSampleAppRobot.self)
            .terminateApp(robot: LoginSampleAppRobot.self)
            .activateApp(robot: CoreExampleMainRobot.self)
            .tap(.login, to: LoginSampleAppRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showLogin()
            .fillUsername(username: name)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
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
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: AccountSummaryRobot.self, password: paymentPassword)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .backgroundApp(robot: LoginSampleAppRobot.self)
            .activateAppWithSiri(robot: LoginSampleAppRobot.self)
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
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .proceed(to: LoginSampleAppRobot.self)
            .backgroundApp(robot: LoginSampleAppRobot.self)
            .activateApp(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
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
            .verifyPayment(robot: LoginSampleAppRobot.self, password: paymentPassword)
            .backgroundApp(robot: LoginSampleAppRobot.self)
            .activateAppWithSiri(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
}

extension LoginSignupPlanSelectorTests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
        
    private var randomEmail: String {
        return "\(randomName)@test.a"
    }
}
