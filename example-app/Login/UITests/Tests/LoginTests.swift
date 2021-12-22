//
//  LoginTests.swift
//  SampleAppUITests
//
//  Created by Kristina Jureviciute on 2021-04-23.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands

class LoginTests: LoginBaseTestCase {
    
    let mainRobot = LoginSampleAppRobot()
    let loginRobot = LoginRobot()
    let twoFaRobot = TwoFaRobot()
    let needHelpRobot = NeedHelpRobot()
    let createProtonmailRobot = CreateProtonmailRobot()
    
    let password = ObfuscatedConstants.password
    let emailVerificationCode = ObfuscatedConstants.emailVerificationCode
    
    override func setUp() {
        super.setUp()
        
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }
    
    func testSignInScreenElements() {
        mainRobot.showLogin()
            .signInElementsDisplayed()
    }
    
    func testCloseLoginScreen() {
        mainRobot.showLogin()
            .closeLoginScreen(to: LoginSampleAppRobot.self)
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
            .goBackToSampleApp(app: app).forgotPasswordLink()
            .goBackToSampleApp(app: app).otherSignInIssuesLink()
            .goBackToSampleApp(app: app).customerSupportLink()
        
    }
    
    func testLoginWithOnePassUser() {
        let user = testData.onePassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLogoutUserWithOnePass() {
        let user = testData.onePassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: LoginSampleAppRobot.self)
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
            .unlock(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithTwoFAUser() {
        let user = testData.onePassUserWith2Fa
        
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: TwoFaRobot.self)
            .fillTwoFACode(code: user.generateCode())
            .confirm2FA(robot: LoginSampleAppRobot.self)
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
            .unlock(robot: LoginSampleAppRobot.self)
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
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithOrgPublicUser() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createOrgUser(host: host, username: randomUsername, password: ObfuscatedConstants.password, createPrivateUser: false)
        let email = "\(username)@proton.green"
        mainRobot.showLogin()
            .fillEmail(email: email)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithOrgPrivateUser() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createOrgUser(host: host, username: randomUsername, password: ObfuscatedConstants.password, createPrivateUser: true)
        let email = "\(username)@proton.green"
        mainRobot.showLogin()
            .fillEmail(email: email)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    
    //TODO find out why private org members created via quark command are not required password change
    
    //    func testLoginWithNewOrgPrivateUser() {
    //        let randomUsername = StringUtils.randomAlphanumericString()
    //        let (username, password) = createOrgUser(host: host, username: randomUsername, password: ObfuscatedConstants.password)
    //        let email = "\(username)@proton.green"
    //
    //        mainRobot.changeAccountTypeToExternal().showLogin()
    //            .fillEmail(email: email)
    //            .fillpassword(password: password)
    //            .signIn(robot: LoginRobot.self)
    //            .verify.changePassword()
    //            .verify.changePasswordCancel()
    //            .verify.changePasswordConfirm()
    //    }
    
    func testLoginNewExtAccountSuccessInternalAccType() {
        let randomEmail = self.randomEmail
        mainRobot
            .showSignup()
            .otherAccountButtonTap()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: CreateProtonmailRobot.self)
            .fillPMUsername(username: randomName)
            .pressNextButton()
            .pressCreateAddress(to: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginNewExtAccountSuccessExternalAccType() {
        let randomEmail = self.randomEmail
        mainRobot.changeAccountTypeToExternal()
            .showSignup()
            .otherAccountButtonTap()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginNewExtAccountSuccessUsernameAccType() {
        let randomEmail = self.randomEmail
        mainRobot.changeAccountTypeToUsername()
            .showSignup()
            .otherAccountButtonTap()
            .insertExternalEmail(name: randomEmail)
            .nextButtonTap(robot: EmailVerificationRobot.self)
            .verify.emailVerificationScreenIsShown()
            .insertCode(code: emailVerificationCode)
            .nextButtonTap(robot: PasswordRobot.self)
            .insertPassword(password: password)
            .insertRepeatPassword(password: password)
            .nextButtonTap(robot: CompleteRobot.self)
            .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
            .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
            .startUsingAppTap(robot: LoginSampleAppRobot.self)
            .showLogin()
            .fillEmail(email: randomEmail)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUser() {
        let user = testData.usernameVpnFreeUser
        mainRobot.changeAccountTypeToUsername().showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
        
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUserInternal() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createVPNUser(host: host, username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithVPNOnlyFreeUserExternal() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createVPNUser(host: host, username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.changeAccountTypeToExternal().showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAddressNoKeysInternalAccType() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createUserWithAddressNoKeys(host: host, username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAddressNoKeysExternalAccType() {
        let randomUsername = StringUtils.randomAlphanumericString()
        let (username, password) = createUserWithAddressNoKeys(host: host, username: randomUsername, password: ObfuscatedConstants.password)
        mainRobot.changeAccountTypeToExternal().showLogin()
            .fillUsername(username: username)
            .fillpassword(password: password)
            .signIn(robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
    
    func testLoginWithAppInBackground() {
        let user = testData.onePassUser
        mainRobot.showLogin()
            .fillUsername(username: user.username)
            .fillpassword(password: user.password)
            .signIn(robot: LoginSampleAppRobot.self)
            .backgroundApp(app: app, robot: LoginSampleAppRobot.self)
            .activateApp(app: app, robot: LoginSampleAppRobot.self)
            .verify.buttonLogoutVisible()
    }
}
