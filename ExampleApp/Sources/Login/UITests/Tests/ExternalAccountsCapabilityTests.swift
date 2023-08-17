// Copyright (c) 2023 Proton AG
//
// This file is part of Proton Drive.
//
// Proton Drive is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Drive is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Drive. If not, see https://www.gnu.org/licenses/.

import XCTest
import fusion
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsLogin
#else
import ProtonCoreTestingToolkit
#endif

final class ExternalAccountsCapabilityTests: LoginBaseTestCase {
    
    let mainRobot = LoginSampleAppRobot()
    
    // sign in capability test helpers
    let commonSigninTests = SigninExternalAccountsCapability()
    let commonSignupTests = SignupExternalAccountsCapability()
    
    override func setUp() {
        super.setUp()
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }

    // MARK: - Sign in tests

    // MARK: --- Sign in with internal account requirement (Mail, Calendar)

    func testSignInInternalAccountWithInternalAccountRequirement() {
        let (account, randomUsername, randomPassword) = internalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.showLogin()
        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignInExternalAccountWithInternalAccountRequirement() {
        let (account, randomEmail, randomPassword, randomUsername) = externalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.showLogin()
        commonSigninTests.convertExternalAccountToInternal(email: randomEmail,
                                                           password: randomPassword,
                                                           username: randomUsername,
                                                           loginRobot: loginRobot,
                                                           retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignInUsernameAccountWithInternalAccountRequirement() {
        let (account, randomUsername, randomPassword) = usernameAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.showLogin()
        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // MARK: --- Sign in with external account requirement (Drive)

    func testSignInInternalAccountWithExternalAccountRequirement() {
        let (account, randomUsername, randomPassword) = internalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToExternal().showLogin()

        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // TODO: Fix this test timing out on some environments
    func disabeldTestSignInExternalAccountWithExternalAccountRequirement() {
        let (account, randomEmail, randomPassword, _) = externalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToExternal().showLogin()

        commonSigninTests.signInWithAccount(userName: randomEmail,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignInUsernameAccountWithExternalAccountRequirement() {
        let (account, randomUsername, randomPassword) = usernameAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToExternal().showLogin()
        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // MARK: --- Sign in with username account requirement (VPN)

    func testSignInWithInternalAccountWithUsernameAccountRequirement() {
        let (account, randomUsername, randomPassword) = internalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToUsername().showLogin()
        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignInWithExternalAccountWithUsernameAccountRequirement() {
        let (account, randomEmail, randomPassword, _) = externalAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToUsername().showLogin()
        commonSigninTests.signInWithAccount(userName: randomEmail,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignInWithUsernameAccountWithUsernameAccountRequirement() {
        let (account, randomUsername, randomPassword) = usernameAccount()
        guard createAccountForTest(accountToBeCreated: account) else { return }

        let loginRobot = mainRobot.changeAccountTypeToUsername().showLogin()
        commonSigninTests.signInWithAccount(userName: randomUsername,
                                            password: randomPassword,
                                            loginRobot: loginRobot,
                                            retRobot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // MARK: - Sign up tests

    // MARK: --- Sign up with internal account requirement (Mail, Calendar)

    func testSignUpInternalAccountWithInternalAccountRequirement() {
        let signupRobot = mainRobot.showSignup()
        commonSignupTests.signUpWithInternalAccount(signupRobot: signupRobot,
                                                    username: randomName,
                                                    password: randomPassword,
                                                    userEmail: randomEmail,
                                                    verificationCode: ObfuscatedConstants.emailVerificationCode,
                                                    retRobot: CompleteRobot.self)
        .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
        .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignUpExternalAccountWithInternalAccountRequirement() {
        mainRobot
            .showSignup()
            .verify.otherAccountExtButtonIsNotShown()
    }

    // MARK: --- Sign up with external account requirement (Drive)

    func testSignUpInternalAccountWithExternalAccountRequirement() {
        let signupRobot = mainRobot.changeAccountTypeToExternal().showSignup().otherAccountButtonTap()
        commonSignupTests.signUpWithInternalAccount(signupRobot: signupRobot,
                                                    username: randomName,
                                                    password: randomPassword,
                                                    userEmail: randomEmail,
                                                    verificationCode: ObfuscatedConstants.emailVerificationCode,
                                                    retRobot: CompleteRobot.self)
        .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
        .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignUpExternalAccountWithExternalAccountRequirement() {
        let signupRobot = mainRobot.changeAccountTypeToExternal().showSignup()
        commonSignupTests.signUpWithExternalAccount(signupRobot: signupRobot,
                                                    userEmail: randomEmail,
                                                    password: randomPassword,
                                                    verificationCode: ObfuscatedConstants.emailVerificationCode,
                                                    retRobot: CompleteRobot.self)
        .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
        .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // MARK: --- Sign up with username account requirement (VPN)

    func testSignUpInternalAccountWithUsernameAccountRequirement() {
        let signupRobot = mainRobot.changeAccountTypeToUsername().showSignup().otherAccountButtonTap()
        commonSignupTests.signUpWithInternalAccount(signupRobot: signupRobot,
                                                    username: randomName,
                                                    password: randomPassword,
                                                    userEmail: randomEmail,
                                                    verificationCode: ObfuscatedConstants.emailVerificationCode,
                                                    retRobot: CompleteRobot.self)
        .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
        .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    func testSignUpExternalAccountWithUsernameAccountRequirement() {
        let signupRobot = mainRobot.changeAccountTypeToUsername().showSignup()
        commonSignupTests.signUpWithExternalAccount(signupRobot: signupRobot,
                                                    userEmail: randomEmail,
                                                    password: randomPassword,
                                                    verificationCode: ObfuscatedConstants.emailVerificationCode,
                                                    retRobot: CompleteRobot.self)
        .verify.completeScreenIsShown(robot: AccountSummaryRobot.self)
        .accountSummaryElementsDisplayed(robot: AccountSummaryRobot.self)
        .startUsingAppTap(robot: LoginSampleAppRobot.self)
        .logoutButtonTap()
        .verify.buttonLogoutIsNotVisible()
    }

    // MARK: - Helpers
    
    private func createAccountForTest(accountToBeCreated: AccountAvailableForCreation, at function: String = #function) -> Bool {
        let expectQuarkCommandToFinish = expectation(description: "Quark command should finish")
        var quarkCommandResult: Result<CreatedAccountDetails, CreateAccountError>?
        QuarkCommands.create(account: accountToBeCreated, currentlyUsedHostUrl: doh.getCurrentlyUsedHostUrl()) { result in
            quarkCommandResult = result
            expectQuarkCommandToFinish.fulfill()
        }

        wait(for: [expectQuarkCommandToFinish], timeout: 5.0)
        if case .failure(let error) = quarkCommandResult {
            XCTFail("Internal account creation failed in test \(function) because of \(error.userFacingMessageInQuarkCommands)")
            return false
        }
        return true
    }

    private func internalAccount() -> (AccountAvailableForCreation, String, String) {
        let randomPassword = randomPassword
        let randomUsername = randomName
        return (.freeWithAddressAndKeys(username: randomUsername, password: randomPassword), randomUsername, randomPassword)
    }

    private func externalAccount() -> (AccountAvailableForCreation, String, String, String) {
        let randomEmail = randomEmail
        let randomPassword = randomPassword
        let randomUsername = randomName
        return (.external(email: randomEmail, password: randomPassword), randomEmail, randomPassword, randomUsername)
    }

    private func usernameAccount() -> (AccountAvailableForCreation, String, String) {
        let randomPassword = randomPassword
        let randomUsername = randomName
        return (.freeNoAddressNoKeys(username: randomUsername, password: randomPassword), randomUsername, randomPassword)
    }
    
}
