//
//  LoginSignupPlanSelectorTests.swift
//  SampleAppUITests
//
//  Created by Greg on 28.06.21.
//

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands
import Alamofire

class LoginSignupPlanSelectorTests: LoginBaseTestCase {

    lazy var quarkCommands = QuarkCommands(doh: doh)
    let mainRobot = LoginSampleAppRobot()
    let completeRobot = CompleteRobot()
    
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    let password = ObfuscatedConstants.password
    let paymentPassword = ObfuscatedConstants.sandboxPaymentAccountPassword
    let existingEmail = "\(ObfuscatedConstants.externalUserUsername)@me.com"
    let existingEmailPassword = ObfuscatedConstants.externalUserPassword
    
    override func setUp() {
        super.setUp()
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
    
    func testSignupWithExtAccountFreePlanWithAppInBackground() {
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

extension LoginSignupPlanSelectorTests {
    
    /// Free external account creation with HV v3
    func testSignupNewExtAccountWithFreeHV3PlanSuccess() {
        mainRobot
            .changeEnvironmentToFosseyBlack()
            .hv3Tap()
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTapToOwnershipHV()
            .verify.humanVerificationScreenIsShown()
            .performOwnershipEmailVerificationV3(code: ObfuscatedConstants.emailVerificationCode, to: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .free)
            .freePlanV3ButtonTap()
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupNewExtAccountWithFreeHV3PlanResendEmailSuccess() {
        let email = randomEmail
        mainRobot
            .changeEnvironmentToFosseyBlack()
            .hv3Tap()
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: email)
            .nextButtonTapToOwnershipHV()
            .verify.humanVerificationScreenIsShown()
            .didntReceiveCodeButton()
            .requestNewCodeButton(to: SignupHumanVerificationV3Robot.self)
            .resendDialogDisplay(email: email)
            .verify.humanVerificationScreenIsShown()
            .performOwnershipEmailVerificationV3(code: ObfuscatedConstants.emailVerificationCode, to: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .free)
            .freePlanV3ButtonTap()
            .proceed(email: randomEmail, code: ObfuscatedConstants.emailVerificationCode, to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupNewExtAccountWithPlusHV3PlanSuccess() {
        mainRobot
            .changeEnvironmentToFosseyBlack()
            .hv3Tap()
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTapToOwnershipHV()
            .verify.humanVerificationScreenIsShown()
            .performOwnershipEmailVerificationV3(code: ObfuscatedConstants.emailVerificationCode, to: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PaymentsUIRobot.self)
            .verify.paymentsUIScreenIsShown()
            .selectPlanCell(plan: .free)
            .selectPlanCell(plan: .mailPlus)
            .planButtonTap(plan: .mailPlus)
            .verifyPayment(robot: AccountSummaryRobot.self, password: paymentPassword)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testSignupExistingExtAccountHV3() {
        mainRobot
            .changeEnvironmentToFosseyBlack()
            .hv3Tap()
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: existingEmail)
            .nextButtonTapToOwnershipHV()
            .verify.humanVerificationScreenIsShown()
            .performOwnershipEmailVerificationV3(code: ObfuscatedConstants.emailVerificationCode, to: LoginRobot.self)
            .verify.loginScreenIsShown()
            .verify.emailAlreadyExists()
            .verify.checkEmail(email: existingEmail)
            .insertPassword(password: existingEmailPassword)
            .signInButtonTapAfterEmailError(to: CreateProtonmailRobot.self)
            .createPMAddressIsShown()
    }
    
    func testSignupNewExtAccountEditEmailHV3() {
        mainRobot
            .changeEnvironmentToFosseyBlack()
            .hv3Tap()
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTapToOwnershipHV()
            .didntReceiveCodeButton()
            .editEmailAddressButton(to: SignupRobot.self)
            .verify.signupScreenIsShown()
    }
}
