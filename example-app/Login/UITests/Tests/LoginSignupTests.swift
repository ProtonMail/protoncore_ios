//
//  LoginSignupTests.swift
//  SampleAppUITests
//
//  Created by Greg on 15.04.21.
//

import XCTest
import ProtonCore_TestingToolkit

class LoginSignupTests: LoginBaseTestCase {
    
    let mainRobot = LoginSampleAppRobot()

    let password = ObfuscatedConstants.password
    let shortPassword = ObfuscatedConstants.shortPassword
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    let emailVerificationWrongCode = ObfuscatedConstants.emailVerificationWrongCode
    let testEmail = ObfuscatedConstants.testEmail
    let testNumber = ObfuscatedConstants.testNumber
    let exampleCountry = "Swi"
    let exampleCode = "+41"
    let defaultCode = "XXXXXX"
    let existingName = ObfuscatedConstants.existingUsername
    let existingEmail = "\(ObfuscatedConstants.externalUserUsername)@me.com"
    let existingEmailPassword = ObfuscatedConstants.externalUserPassword

    override func setUp() {
        super.setUp()

        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    func testCloseButtonExists() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.closeButtonIsShown()
    }
    
    func testCloseButtonDoesntExist() {
        mainRobot
            .closeSwitchTap()
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.closeButtonIsNotShown()
    }
    
    func testBothAccountInt() {
        mainRobot
            .changeSignupMode(mode: .both(.internal))
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.otherAccountExtButtonIsShown()
    }
    
    func testBothAccountExt() {
        mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.otherAccountIntButtonIsShown()
    }
    
    func testIntAccountOnly() {
        mainRobot
            .changeSignupMode(mode: .internal)
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.otherAccountButtonIsNotShown()
    }
    
    func testExtAccountOnly() {
        mainRobot
            .changeSignupMode(mode: .external)
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.otherAccountButtonIsNotShown()
    }
    
    func testSwitchIntToLogin() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .signinButtonTap()
            .verify.loginScreenIsShown()
    }
    
    func testSwitchExtToLogin() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .signinButtonTap()
            .verify.loginScreenIsShown()
    }
    
    func testSignupNewIntAccountSuccess() {
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
            .skipButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: SignupHumanVerificationRobot.self)
            .verify.humanVerificationScreenIsShown()
            .humanVerificationCaptchaTap(to: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .logoutButtonTap()
    }
    
    func testSignupExistingIntAccount() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: existingName)
            .nextButtonTap(robot: SignupRobot.self)
            .verify.usernameAlreadyExists()
    }

    func testSignupNewExtAccountSuccess() {
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
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .logoutButtonTap()
    }
    
    func testSignupExistingExtAccount() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .otherAccountButtonTap()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: existingEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: LoginRobot.self)
            .verify.loginScreenIsShown()
            .verify.emailAlreadyExists()
            .verify.checkEmail(email: existingEmail)
            .insertPassword(password: existingEmailPassword)
            .signInButtonTapAfterEmailError(to: CreateProtonmailRobot.self)
            .createPMAddressIsShown()
    }

    func testPasswordVerificationEmpty() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordEmpty()
    }

    func testPasswordVerificationTooShort() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: shortPassword)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordTooShort()
    }
    
    func testPasswordVerificationRepeatPasswordEmpty() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordNotEqual()
    }
    
    func testPasswordVerificationPasswordEmpty() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordNotEqual()
    }
    
    func testPasswordsVerificationDoNotMatch() {
        mainRobot
            .showSignup()
            .verify.signupScreenIsShown()
            .insertName(name: randomName)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordScreenIsShown()
            .insertPassword(password: password)
            .insertRepeatPassword(password: password + password)
            .nextButtonTap(robot: PasswordRobot.self)
            .verify.passwordNotEqual()
    }
    
    func testRecoveryVerificationEmail() {
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
            .insertRecoveryEmail(email: testEmail)
            .verify.nextButtonIsEnabled()
    }
    
    func testRecoveryVerificationPhone() {
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
            .selectRecoveryMethod(method: .phone)
            .insertRecoveryNumber(number: testNumber)
            .verify.nextButtonIsEnabled()
            .nextButtonTap()
            .verify.phoneNumberInvalid()
    }
    
    func testRecoverySelectCountryAndCheckCode() {
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
            .selectRecoveryMethod(method: .phone)
            .selectCountrySelector()
            .verify.countrySelectorScreenIsShown()
            .insertCountryName(name: exampleCountry)
            .selectTopCountry()
            .verify.recoveryScreenIsShown()
            .verify.verifyCountryCode(code: exampleCode)
    }

    func testSignupNewIntAccountHVRequired() {
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
            .skipButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: SignupHumanVerificationRobot.self)
            .verify.humanVerificationScreenIsShown()
            .closeButton()
            .verify.recoveryScreenIsShown()
            .verify.humanVerificationRequired()
    }

    func testSignupNewIntStayInRecoveryMethod() {
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
            .recoveryMethodTap()
            .verify.recoveryScreenIsShown()
            .skipButtonTap()
            .verify.recoveryDialogDisplay()
            .recoveryMethodTap()
            .verify.recoveryScreenIsShown()
    }
    
    func testSignupNewExtSendCodeRequestNewCode() {
        let email = randomEmail
        mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: email)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .resendCodeButton()
            .verify.resendDialogDisplay(email: email)
            .newCodeButtonTap()
            .verify.resendEmailMessage(email: email)
            .verify.verifyVerificationCode(code: defaultCode)
    }
    
    func testSignupNewExtSendCodeCancel() {
        let email = randomEmail
        mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: email)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .resendCodeButton()
            .verify.resendDialogDisplay(email: email)
            .cancelButtonTap()
            .verify.emailVerificationScreenIsShown()
    }
    
    func testSignupNewExtWrongVerificationCodeResend() {
        let email = randomEmail
        mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
            .verify.signupScreenIsShown()
            .insertExternalEmail(name: email)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationWrongCode)
            .nextButtonTap(robot: EmailVerificationRobot.EmailVerificationDialogRobot.self)
            .verify.verificationDialogDisplay()
            .resendButtonTap()
            .verify.resendEmailMessage(email: email)
            .verify.verifyVerificationCode(code: defaultCode)
    }
    
    func testSignupNewExtWrongVerificationCodeChangeEmail() {
        let email = randomEmail
        mainRobot
            .changeSignupMode(mode: .both(.external))
            .showSignup()
            .verify.signupScreenIsShown()
            .verify.otherAccountIntButtonIsShown()
            .insertExternalEmail(name: email)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationWrongCode)
            .nextButtonTap(robot: EmailVerificationRobot.EmailVerificationDialogRobot.self)
            .verify.verificationDialogDisplay()
            .changeEmailButtonTap()
            .waitDisapper()
            .verify.signupScreenIsShown()
    }
    
    func testSignupNewIntTermsAndConditions() {
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
            .TCLinkTap()
            .verify.tcScreenIsShown()
            .swipeUpWebView()
            .backButton()
            .verify.recoveryScreenIsShown()
    }
}

extension LoginSignupTests {
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    private var randomEmail: String {
        return "\(randomName)@test.a"
    }
}
