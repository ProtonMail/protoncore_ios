//
//  LoginRobot.swift
//  ProtonCore-TestingToolkit - Created on 11.02.2021.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

#if canImport(fusion)

import fusion
import XCTest
import ProtonCoreLoginUI

private let titleId = "LoginViewController.titleLabel"
private let subtitleId = "LoginViewController.subtitleLabel"
private let loginViewCloseButtonId = "UINavigationItem.leftBarButtonItem"
private let errorBannerMessage = "Email address already used."
private let errorBannerButton = LUITranslation._core_ok_button.l10n
private let loginTextFieldId = "LoginViewController.loginTextField.textField"
private let passwordTextFieldId = "LoginViewController.passwordTextField.textField"
private let signInButtonId = "LoginViewController.signInButton"
private let invalidCredentialText = "Incorrect login credentials. Please try again."
private let signUpButtonId = "LoginViewController.signUpButton"
private let helpButtonId = "UINavigationItem.rightBarButtonItem"
private let loginFieldTitleLabel = "LoginViewController.loginTextField.titleLabel"
private let passwordFieldTitleLabel = "LoginViewController.passwordTextField.titleLabel"
private let suspendedErrorText = "This account has been suspended due to a potential policy violation. If you believe this is in error, please contact us at" // disable this hard coded link. because it will fail on black server. https://proton.me/support/abuse"
private let textPredicate = NSPredicate(format: "label CONTAINS[c] %@", suspendedErrorText)
private let textChangePassword = "Change your password"
private let buttonChangePasswordCancel = "Cancel"
private let buttonChangePassword = "Change password"
private let externalAccountsNotSupportedBannerText = "This app does not support external accounts"
private let closeButton = "UINavigationItem.leftBarButtonItem"

public final class LoginRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {

        @discardableResult
        public func loginScreenIsShown() -> LoginRobot {
            staticText(titleId).waitUntilExists().checkExists()
            staticText(subtitleId).waitUntilExists().checkExists()
            return LoginRobot()
        }

        @discardableResult
        public func switchToCreateAccountButtonIsShown() -> LoginRobot {
            button(signUpButtonId).waitUntilExists().checkExists()
            return LoginRobot()
        }

        @discardableResult
        public func switchToCreateAccountButtonIsNotPresented() -> LoginRobot {
            button(signUpButtonId).waitUntilGone()
            return LoginRobot()
        }

        @discardableResult
        public func checkEmail(email: String) -> LoginRobot {
            textField(loginTextFieldId).tap().checkHasValue(email)
            return LoginRobot()
        }

        @discardableResult
        public func emailAlreadyExists() -> LoginRobot {
            LoginRobot().textView(errorBannerMessage).waitUntilExists().checkExists()
            LoginRobot().button(errorBannerButton).tap()
            return LoginRobot()
        }

        public func incorrectCredentialsErrorDialog() {
            textView(invalidCredentialText).waitUntilExists(time: 20).checkExists()
        }

        public func suspendedErrorDialog() {
            textView(textPredicate).waitUntilExists().checkExists()
        }

        public func changePassword() -> LoginRobot {
            staticText(textChangePassword).waitUntilExists(time: 20).checkExists()
            return LoginRobot()
        }

        public func changePasswordCancel() -> LoginRobot {
            button(buttonChangePasswordCancel).waitUntilExists(time: 20).checkExists()
            return LoginRobot()
        }

        public func changePasswordConfirm() {
            button(buttonChangePassword).waitUntilExists(time: 20).checkExists()
        }

        @discardableResult
        public func closeButtonIsShown() -> LoginRobot {
            button(closeButton).waitUntilExists().checkExists()
            return LoginRobot()
        }

    }

    public func insertPassword(password: String) -> LoginRobot {
        secureTextField(passwordTextFieldId).tap().typeText(password)
        return self
    }

    public func signInButtonTapAfterEmailError<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(signInButtonId).tap()
        return Robot()
    }

    public func fillUsername(username: String) -> LoginRobot {
        textField(loginTextFieldId).forceKeyboardFocus().typeText(username)
        return self
    }

    public func fillEmail(email: String) -> LoginRobot {
        textField(loginTextFieldId).forceKeyboardFocus().typeText(email)
        return self
    }

    public func fillpassword(password: String) -> LoginRobot {
        secureTextField(passwordTextFieldId).forceKeyboardFocus().typeText(password)
        return self
    }

    public func signIn<T: CoreElements>(robot _: T.Type) -> T {
        button(signInButtonId).tap()
        return T()
    }

    public func signInElementsDisplayed() {
        button(loginViewCloseButtonId).waitUntilExists().checkExists()
        staticText(titleId).checkExists()
        staticText(loginFieldTitleLabel).checkExists()
        staticText(passwordFieldTitleLabel).checkExists()
        button(signUpButtonId).checkExists()
        button(helpButtonId).checkExists()
    }

    public func switchToCreateAccount() -> SignupRobot {
        button(signUpButtonId).tap()
        return SignupRobot()
    }

    public func needHelp() -> NeedHelpRobot {
        button(helpButtonId).tap()
        return NeedHelpRobot()
    }

    public func closeLoginScreen<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(loginViewCloseButtonId).tap()
        return Robot()
    }
}

private let externalAccountsNotSupportedText = LUITranslation._core_external_accounts_address_required_popup_title.l10n
private let externalAccountsUpdateRequiredText = LUITranslation._core_external_accounts_update_required_popup_title.l10n
private let externalAccountsNotSupportedCloseButton = LUITranslation._core_cancel_button.l10n
private let externalAccountsNotSupportedLearnMoreButton = LUITranslation.external_accounts_not_supported_popup_action_button.l10n

public final class ExternalAccountsNotSupportedDialogRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func externalAccountsNotSupportedDialog() -> ExternalAccountsNotSupportedDialogRobot {
            alert(externalAccountsNotSupportedText).wait(time: 20).checkExists()
            return ExternalAccountsNotSupportedDialogRobot()
        }

        @discardableResult
        public func externalAccountsUpdateRequireddDialog() -> ExternalAccountsNotSupportedDialogRobot {
            alert(externalAccountsUpdateRequiredText).wait(time: 20).checkExists()
            return ExternalAccountsNotSupportedDialogRobot()
        }

        @discardableResult
        public func isInsideTheApplication() -> ExternalAccountsNotSupportedDialogRobot {
            let applicationState = XCUIApplication().state
            XCTAssertTrue(applicationState == .runningForeground)
            return ExternalAccountsNotSupportedDialogRobot()
        }
    }

    public func tapClose<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(externalAccountsNotSupportedCloseButton).tap()
        return Robot()
    }

    public func tapLearnMore<Robot: CoreElements>(to: Robot.Type) -> Robot {
        button(externalAccountsNotSupportedLearnMoreButton).tap()
        return Robot()
    }
}

private let createAddressTitle = LUITranslation.create_address_screen_title.l10n
private func createAddressDescription(email: String) -> String {
    return String(format: LUITranslation.create_address_screen_info.l10n, email)
}
private let continueButtonIdentifier = "CreateAddressViewController.continueButton"
private let cancelButtonIdentifier = "CreateAddressViewController.cancelButton"
private let backButtonIdentifier = "UINavigationItem.leftBarButtonItem"
private let usernameTextFieldId = "CreateAddressViewController.addressTextField.textField"
private let errorInvalidCharacters = "Username contains invalid characters"
public final class CreateAddressRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func createAddress(email: String) -> CreateAddressRobot {
            staticText(createAddressTitle).waitUntilExists().checkExists()
            let predicate = NSPredicate(format: "label LIKE %@", createAddressDescription(email: email))
            staticText(predicate).waitUntilExists().checkExists()
            return CreateAddressRobot()
        }

        @discardableResult
        public func invalidCharactersBanner() -> CreateAddressRobot {
            textView(errorInvalidCharacters).waitUntilExists().checkExists()
            button(errorBannerButton).tap()
            return CreateAddressRobot()
        }
    }

    public func fillUsername(username: String) -> CreateAddressRobot {
        textField(usernameTextFieldId).tap().clearText().typeText(username)
        return self
    }

    @discardableResult
    public func tapContinueButton() -> CreateAddressRobot{
        button(continueButtonIdentifier).tap()
        return self
    }

    public func tapCancelButton() -> LoginRobot {
        button(cancelButtonIdentifier).tap()
        return LoginRobot()
    }

    public func tapBackButton() -> LoginRobot {
        button(backButtonIdentifier).tap()
        return LoginRobot()
    }
}

#endif
