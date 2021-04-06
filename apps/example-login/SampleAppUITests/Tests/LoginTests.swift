//
//  LoginTests.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit

class LoginTests: BaseTestCase {
    
    let mainRobot = MainRobot()
    let loginRobot = LoginRobot()
    let twoFaRobot = TwoFaRobot()
    let needHelpRobot = NeedHelpRobot()
    let createProtonmailRobot = CreateProtonmailRobot()
    
    let password = ObfuscatedConstants.password
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    private var randomName: String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    func generateRandomEmail() -> String {
        return "\(randomName)@test.a"
    }
    
    
    override func setUp() {
        super.setUp()
        
        mainRobot
            .changeEnvironmentToBlack()
    }
    
    func testSignInScreenElemets() {
        mainRobot.showLogin()
            .signInElementsDisplayed()
    }
    
    func testCloseLoginScreen() {
        mainRobot.showLogin()
            .closeLoginScreen(to: MainRobot.self)
            .verify.buttonLoginVisible()
    }
    
    func testSwitchToCreateAccount() {
        mainRobot.showLogin()
            .switchToCreateAccount()
            .verify.signupScreenIsShown()
    }
    
    func testNeedHelpClosed() {
        mainRobot.showLogin()
            .needHelp()
            .needHelpOptionsDisplayed()
            .closeNeedHelpScreen()
            .verify.loginScreenIsShown()
    }
    
    func testNeedHelpOptionsLink() {
        mainRobot.showLogin()
            .needHelp().needHelpOptionsDisplayed()
            .forgotUsernameLink()
            .goBackToSampleApp().forgotPasswordLink()
            .goBackToSampleApp().otherSignInIssuesLink()
            .goBackToSampleApp().customerSupportLink()
        
    }
    
    func testLoginWithOnePassUser() {
        let user = testData.onePassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLogoutUserWithOnePass() {
        let user = testData.onePassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .logoutButtonTap()
            .verify.dialogLogoutShown()
            .verify.buttonLogoutIsNotVisible()
    }
    
    func testLoginWithTwoPassUser() {
        let user = testData.twoPassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MailboxPasswordRobot.self)
            .fillMailboxPassword(mailboxPassword: user.mailboxPassword)
            .unlock(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithTwoFAUser() {
        let user = testData.onePassUserWith2Fa
        
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: TwoFaRobot.self)
            .fillTwoFACode(code: user.generateCode())
            .confirm2FA(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithTwoPassAnd2FAUser() {
        let user = testData.twoPassUserWith2Fa
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: TwoFaRobot.self)
            .fillTwoFACode(code: user.generateCode())
            .confirm2FA(robot: MailboxPasswordRobot.self)
            .fillMailboxPassword(mailboxPassword: user.mailboxPassword)
            .unlock(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithInvalidPassword() {
        let user = testData.onePassUser
        let invalidPassword = " " + user.password
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: invalidPassword)
            .signIn(robot: LoginRobot.self)
            .verify.incorrectCredentialsErrorDialog()
    }
    
    func  testLoginWithInvalidMailboxPassword() {
        let user = testData.twoPassUser
        let invalidMailboxPassword = " " + user.mailboxPassword
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MailboxPasswordRobot.self)
            .fillMailboxPassword(mailboxPassword: invalidMailboxPassword)
            .unlock(robot: MailboxPasswordRobot.self)
            .verify.incorrectMailboxPasswordErrorDialog()
    }
    
    func testLoginWithIncorrectTwoFACodeUser() {
        let user = testData.onePassUserWith2Fa
        let invalidTwoFACode = ObfuscatedConstants.invalidTwoFACode
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: TwoFaRobot.self)
            .fillTwoFACode(code: invalidTwoFACode)
            .confirm2FA(robot: TwoFaRobot.self)
            .verify.incorrectCredentialsErrorDialog()
    }
    
    func testLoginWithTwoPassUserInvalidTwoFACode() {
        let user = testData.twoPassUserWith2Fa
        let invalidTwoFACode = ObfuscatedConstants.invalidTwoFACode
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: TwoFaRobot.self)
            .fillTwoFACode(code: invalidTwoFACode)
            .confirm2FA(robot: TwoFaRobot.self)
            .verify.incorrectCredentialsErrorDialog()
    }
    
    func testLoginWithDisabledUser() {
        let user = testData.disabledUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: LoginRobot.self)
            .verify.suspendedErrorDialog()
    }
    
    
    func testLoginWithOrgAdminUser() {
        let user = testData.orgAdminUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithOrgPublicUser() {
        let user = testData.orgPublicUser
        mainRobot.showLogin()
            .fillEmail(email: user.email)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithOrgPrivateUser() {
        let user = testData.orgPrivateUser
        mainRobot.showLogin()
            .fillEmail(email: user.email)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithNewOrgPrivateUser() {
        let user = testData.orgNewPrivateUser
        mainRobot.changeAccountTypeToExternal().showLogin()
            .fillEmail(email: user.email)
            .fillpassword(password: user.password)
            .signIn(robot: LoginRobot.self)
            .verify.changePassword()
            .verify.changePasswordCancel()
            .verify.changePasswordConfirm()
    }
    
    func testLoginNewExtAccountSuccessInternalAccType() {
        let randomEmail = generateRandomEmail()
        mainRobot
            .showSignup()
            .otherAccountButtonTap()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: MainRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: CreateProtonmailRobot.self)
            .fillPMUsername(username: randomName)
            .pressNextButton()
            .pressCreateAddress(to: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginNewExtAccountSuccessExternalAccType() {
        let randomEmail = generateRandomEmail()
        mainRobot.changeAccountTypeToExternal()
            .showSignup()
            .otherAccountButtonTap()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: MainRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginNewExtAccountSuccessUsernameAccType() {
        let randomEmail = generateRandomEmail()
        mainRobot.changeAccountTypeToUsername()
            .showSignup()
            .otherAccountButtonTap()
            .insertName(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: MainRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUser() {
        let user = testData.usernameVpnFreeUser
        mainRobot.changeAccountTypeToUsername().showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUserInternal() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createVPNUser(username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUserExternal() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createVPNUser(username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.changeAccountTypeToExternal().showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAddressNoKeysInternalAccType() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createUserWithAddressNoKeys(username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAddressNoKeysExternalAccType() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createUserWithAddressNoKeys(username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.changeAccountTypeToExternal().showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: MainRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAppInBackground() {
           let user = testData.onePassUser
           mainRobot.showLogin()
               .fillUsername(username: user.username)
               .fillpassword(password: user.password)
               .signIn(robot: MainRobot.self)
               .backgroundApp(robot: MainRobot.self)
               .activateApp(robot: MainRobot.self)
               .verify.buttonLogoutVisible()
       }
}
