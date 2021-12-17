//
//  LoginSignupPlanSelectorTests.swift
//  SampleAppUITests
//
//  Created by Greg on 28.06.21.
//

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import Alamofire

class LoginSignupPlanSelectorTests: LoginBaseTestCase {

    lazy var quarkCommands = QuarkCommands(doh: doh)
    let mainRobot = LoginSampleAppRobot()
    let completeRobot = CompleteRobot()
    
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    let password = ObfuscatedConstants.password
    let paymentPassword = ObfuscatedConstants.sandboxPaymentAccountPassword
    
    override func setUp() {
        super.setUp()
        quarkCommands.unban()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .planSelectorSwitchTap()
    }

    /// Free internal account creation
    
    func testSignupNewIntAccountWithFreeHV3PlanSuccess() {
        mainRobot
            .hv3Tap()
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
            .freePlanV3ButtonTap()
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: AccountSummaryRobot.self)
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
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: LoginSampleAppRobot.self)
            .backgroundApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: AccountSummaryRobot.self)
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
            .selectPlanCell(plan: .free)
            .freePlanButtonTap()
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: LoginSampleAppRobot.self)
            .terminateApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: CoreExampleMainRobot.self)
            .tap(.login, to: LoginSampleAppRobot.self)
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
            .showLogin()
            .fillUsername(username: name)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan internal account creation
    
    func testSignupNewIntAccountWithPlusPlanSuccess() {
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
    
    func testSignupNewIntAccountWithPlusPlanSuccessAppInBackground() {
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
            .backgroundApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Free external account creation
    
    func testSignupNewExtAccountWithFreePlanSuccess() {
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
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupWithFreePlanWithAppInBackground() {
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
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: LoginSampleAppRobot.self)
            .backgroundApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    /// Plus plan external account creation
    
    func testSignupNewExtAccountWithPlusPlanSuccess() {
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

    func testSignupNewExtAccountWithPlusPlanWithAppInBackground() {
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
            .backgroundApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
}
