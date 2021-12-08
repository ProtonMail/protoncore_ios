//
//  LoginViewController.swift
//  ExampleApp - Created on 19/11/2021.
//  
//  Copyright (c) 2021 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import AppKit
import ProtonCore_DataModel
import ProtonCore_Doh
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_HumanVerification

final class LoginViewController: NSViewController {
    
    private let sessionId = "macos example login session id"
    private let serviceDelegate = AnonymousServiceManager()
    private let authManager = AuthManager()
    
    private var loginService: LoginService? = nil
    private var signupService: SignupService? = nil
    private var humanDelegate: HumanVerifyDelegate? = nil
    
    @IBOutlet var environmentSelector: EnvironmentSelector!
    @IBOutlet var logoutButton: NSButton!
    @IBOutlet var accountTypeSegmentedControl: NSSegmentedControl!
    @IBOutlet var signupTypeSegmentedControl: NSSegmentedControl!
    
    private var getAccountType: AccountType {
        switch accountTypeSegmentedControl.selectedSegment {
        case 0: return .username
        case 1: return .external
        case 2: return .internal
        default: fatalError("Invalid index")
        }
    }
    
    // MARK: - Login flow
    
    @IBAction func login(_ sender: Any?) {
        let service = PMAPIService(doh: environmentSelector.currentDoh, sessionUID: sessionId)
        service.serviceDelegate = serviceDelegate
        service.authDelegate = authManager
        let url = URL(string: "https://protonmail.com/support/knowledge-base/human-verification/")!
        humanDelegate = HumanCheckHelper(
            apiService: service, supportURL: url, viewController: self, clientApp: clientApp
        )
        service.humanDelegate = humanDelegate
        loginService = LoginService(api: service,
                                    authManager: authManager,
                                    sessionId: sessionId,
                                    minimumAccountType: getAccountType)
        loginService?.updateAvailableDomain(type: .login) { [weak self] domain in
            guard domain != nil else {
                self?.handleCreateAddressFailure(.generic(message: "Available domain request failed"))
                return
            }
            self?.getLoginCredentialsAlert { [weak self] username, password in
                self?.performLogin(username, password)
            }
        }
    }
    
    private func performLogin(_ username: String, _ password: String) {
        loginService?.login(username: username, password: password, completion: getLoginResultCompletionBlock())
    }
    
    func getLoginResultCompletionBlock() -> (Result<LoginStatus, LoginError>) -> Void {
        {
            [weak self] (result: Result<LoginStatus, LoginError>) in
            switch result {
            case .success(.finished(let loginData)):
                self?.handleSuccessfulLogin(loginData)
            case .success(.ask2FA):
                self?.handle2FARequest()
            case .success(.askSecondPassword):
                self?.handleSecondPasswordRequest()
            case .success(.chooseInternalUsernameAndCreateInternalAddress(let addressData)):
                self?.handleChooseUsernameRequest(addressData)
            case .failure(let loginError):
                self?.handleFailedLogin(loginError)
            }
        }
    }
    
    private func handleSuccessfulLogin(_ loginData: LoginData) {
        let alertController = NSAlert()
        alertController.alertStyle = .informational
        alertController.messageText = "Login successful"
        alertController.runModal()
        logoutButton.isHidden = false
    }
    
    private func handle2FARequest() {
        get2FAAlert { [weak self] twoFA in
            guard let completion = self?.getLoginResultCompletionBlock() else { return }
            self?.loginService?.provide2FACode(twoFA, completion: completion)
        }
    }
    
    private func handleSecondPasswordRequest() {
        getSecondPasswordAlert { [weak self] secondPassword in
            guard let completion = self?.getLoginResultCompletionBlock() else { return }
            self?.loginService?.finishLoginFlow(mailboxPassword: secondPassword, completion: completion)
        }
    }
    
    private func handleChooseUsernameRequest(_ addressData: CreateAddressData) {
        getUsernameAlert { [weak self] username in
            self?.loginService?.checkAvailability(username: username) { [weak self] result in
                switch result {
                case .success:
                    self?.handleAvailableUsername(username, addressData)
                case .failure(let error):
                    self?.handleFailedAvailabilityCheck(error)
                }
            }
        }
    }
    
    private func handleAvailableUsername(_ username: String, _ data: CreateAddressData) {
        loginService?.createAccountKeysIfNeeded(
            user: data.user, addresses: nil, mailboxPassword: data.mailboxPassword
        ) { [weak self] result in
            switch result {
            case .success(let user):
                self?.loginService?.setUsername(username: username) { [weak self] result in
                    switch result {
                    case .success:
                        self?.handleSettingUsername(user, data)
                    case .failure(let error):
                        self?.handleSetUsernameFailure(error)
                    }
                }
            case .failure(let error):
                self?.handleFailedLogin(error)
            }
        }
    }
    
    private func handleSettingUsername(_ user: User, _ data: CreateAddressData) {
        loginService?.createAddress { [weak self] result in
            switch result {
            case .success(let address):
                self?.loginService?.createAddressKeys(
                    user: user, address: address, mailboxPassword: data.mailboxPassword
                ) { [weak self] result in
                    switch result {
                    case .success:
                        guard let completion = self?.getLoginResultCompletionBlock() else { return }
                        self?.loginService?.finishLoginFlow(
                            mailboxPassword: data.mailboxPassword, completion: completion
                        )
                    case .failure(let error):
                        self?.handleCreateAddressKeysFailure(error)
                    }
                }
            case .failure(let error):
                self?.handleCreateAddressFailure(error)
            }
        }
    }
    
    private func handleFailedLogin(_ loginError: LoginError) {
        handleFailure(loginError.messageForTheUser)
    }
    
    // MARK: - Signup flow
    
    @IBAction func signup(_ sender: Any?) {
        let service = PMAPIService(doh: environmentSelector.currentDoh, sessionUID: sessionId)
        service.serviceDelegate = serviceDelegate
        service.authDelegate = authManager
        let url = URL(string: "https://protonmail.com/support/knowledge-base/human-verification/")!
        humanDelegate = HumanCheckHelper(
            apiService: service, supportURL: url, viewController: self, clientApp: clientApp
        )
        service.humanDelegate = humanDelegate
        loginService = LoginService(api: service,
                                    authManager: authManager,
                                    sessionId: sessionId,
                                    minimumAccountType: getAccountType)
        final class EmptyChallangeParametersProvider: ChallangeParametersProvider {
            func provideParameters() -> [[String : Any]] {[]}
        }
        signupService = SignupService(api: service,
                                      challangeParametersProvider: EmptyChallangeParametersProvider(),
                                      clientApp: clientApp)
        switch signupTypeSegmentedControl.selectedSegment {
        case 0: handleInternalUserSignup()
        case 1: handleExternalUserSignup()
        default: fatalError("Invalid index")
        }
    }
    
    private func handleFailedSignup(_ signupError: SignupError) {
        handleFailure(signupError.messageForTheUser)
    }
    
    private func handleFailedAvailabilityCheck(_ availabilityError: AvailabilityError) {
        handleFailure(availabilityError.messageForTheUser)
    }
    
    private func handleSetUsernameFailure(_ setUsernameError: SetUsernameError) {
        handleFailure(setUsernameError.messageForTheUser)
    }
    
    private func handleCreateAddressFailure(_ createAddressError: CreateAddressError) {
        handleFailure(createAddressError.messageForTheUser)
    }
    
    private func handleCreateAddressKeysFailure(_ createAddressKeysError: CreateAddressKeysError) {
        handleFailure(createAddressKeysError.messageForTheUser)
    }
    
    private func handleFailure(_ message: String) {
        let alertController = NSAlert()
        alertController.alertStyle = .critical
        alertController.messageText = "Login/Signup failed"
        alertController.informativeText = message
        alertController.runModal()
    }
    
    private func handleInternalUserSignup() {
        getSignupCredentialsAlert { [weak self] username, password in
            self?.loginService?.updateAvailableDomain(type: .signup) { [weak self] _ in
                self?.signupService?.createNewUser(userName: username, password: password) { [weak self] result in
                    switch result {
                    case .success:
                        self?.performLogin(username, password)
                    case .failure(let error):
                        self?.handleFailedSignup(error)
                    }
                }
            }
        }
    }
    
    private func handleExternalUserSignup() {
        getEmailAlert { [weak self] email in
            self?.signupService?.requestValidationToken(email: email) { [weak self] result in
                switch result {
                case .success:
                    self?.handleValidationTokenRequest(email)
                case .failure(let error):
                    self?.handleFailedSignup(error)
                }
            }
        }
    }
    
    private func handleValidationTokenRequest(_ email: String) {
        getValidationTokenAlert { [weak self] verifyToken in
            self?.signupService?.checkValidationToken(email: email, token: verifyToken) { [weak self] result in
                switch result {
                case .success:
                    self?.handleValidationResponse(email, verifyToken)
                case .failure(let error):
                    self?.handleFailedSignup(error)
                }
            }
        }
    }
    
    private func handleValidationResponse(_ email: String, _ verifyToken: String) {
        getPasswordAlert { [weak self] password in
            self?.signupService?.createNewExternalUser(
                email: email, password: password, verifyToken: verifyToken
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.performLogin(email, password)
                case .failure(let error):
                    self?.handleFailedSignup(error)
                }
            }
        }
    }
    
    // MARK: - Login and signup flow UI
    
    private func getLoginCredentialsAlert(result: @escaping (String, String) -> Void) {
        showTwoTextfieldsAlert(
            message: "Provide login credentials", confirmButton: "Log in", cancelButton: "Cancel", firstPlaceholder: "username", secondPlaceholder: "password", result: result
        )
    }
    
    private func get2FAAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide 2FA text", confirmButton: "Send 2FA", cancelButton: "Cancel", placeholder: "2FA", result: result
        )
    }
    
    private func getSecondPasswordAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide second password", confirmButton: "Send second password", cancelButton: "Cancel", placeholder: "Second password", result: result
        )
    }
    
    private func getUsernameAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide username", confirmButton: "Choose username", cancelButton: "Cancel", placeholder: "username", result: result
        )
    }
    
    private func getSignupCredentialsAlert(result: @escaping (String, String) -> Void) {
        showTwoTextfieldsAlert(
            message: "Provide new account credentials", confirmButton: "Sign up", cancelButton: "Cancel", firstPlaceholder: "username", secondPlaceholder: "password", result: result
        )
    }
    
    private func getEmailAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide external email", confirmButton: "Choose email", cancelButton: "Cancel", placeholder: "email", result: result
        )
    }
    
    private func getValidationTokenAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide validation code", confirmButton: "Send validation code", cancelButton: "Cancel", placeholder: "validation code", result: result
        )
    }
    
    private func getPasswordAlert(result: @escaping (String) -> Void) {
        showSingleTextfieldAlert(
            message: "Provide password for the new account", confirmButton: "Choose password", cancelButton: "Cancel", placeholder: "password", result: result
        )
    }
    
    private func showTwoTextfieldsAlert(
        message: String, confirmButton: String, cancelButton: String, firstPlaceholder: String, secondPlaceholder: String, result: @escaping (String, String) -> Void
    ) {
        let alertController = NSAlert()
        alertController.messageText = message
        alertController.addButton(withTitle: confirmButton)
        alertController.addButton(withTitle: cancelButton)
        let usernameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholderString = firstPlaceholder
        let passwordTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholderString = secondPlaceholder
        let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 200, height: 64))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.orientation = .vertical
        stackView.spacing = 16
        alertController.accessoryView = stackView
        alertController.alertStyle = .informational
        usernameTextField.nextKeyView = passwordTextField
        let response = alertController.runModal()
        switch response {
        case .alertFirstButtonReturn:
            result(usernameTextField.stringValue, passwordTextField.stringValue)
        default: return
        }
    }
    
    private func showSingleTextfieldAlert(
        message: String, confirmButton: String, cancelButton: String, placeholder: String, result: @escaping (String) -> Void
    ) {
        let alertController = NSAlert()
        alertController.messageText = message
        alertController.addButton(withTitle: confirmButton)
        alertController.addButton(withTitle: cancelButton)
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholderString = placeholder
        alertController.accessoryView = textField
        alertController.alertStyle = .informational
        let response = alertController.runModal()
        switch response {
        case .alertFirstButtonReturn:
            result(textField.stringValue)
        default: return
        }
    }
    
    // MARK: - Logout flow
    
    @IBAction func logout(_ sender: Any?) {
        guard let credential = authManager.getToken(bySessionUID: sessionId) else {
            assertionFailure("No credentials in auth manager indicates a misconfiguration")
            return
        }
        loginService?.logout(credential: credential) { [weak self] result in
            switch result {
            case .success:
                self?.logoutButton.isHidden = true
                self?.handleSuccessfulLogout()
            case .failure(let error):
                self?.handleLogoutFailure(error: error)
            }
        }
    }
    
    private func handleSuccessfulLogout() {
        let alertController = NSAlert()
        alertController.alertStyle = .informational
        alertController.messageText = "Log out successful"
        alertController.runModal()
    }
    
    private func handleLogoutFailure(error: Error) {
        let alertController = NSAlert()
        alertController.alertStyle = .warning
        alertController.messageText = "Log out failure"
        alertController.informativeText = error.messageForTheUser
        alertController.runModal()
    }
}
