//
//  TokenRefreshViewController.swift
//  ExampleApp - Created on 19/05/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import UIKit
import ProtonCoreAuthentication
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
import ProtonCoreFoundations
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreChallenge
import ProtonCoreFeatureSwitch

final class TokenRefreshViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, AccessibleView, AuthDelegate {
    
    @IBOutlet private var activityIndicatorView: UIView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var tokenRefreshStackView: UIStackView!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var accountDetailsLabel: UILabel!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var logInButton: UIButton!
    @IBOutlet private var getUserButton: UIButton!
    @IBOutlet private var expireSessionButton: UIButton!
    @IBOutlet private var expireSessionAndRefreshTokenButton: UIButton!
    @IBOutlet private var credentialsSelector: UISegmentedControl!
    @IBOutlet private var credentialsStackView: UIStackView!
    @IBOutlet private var credentialsUsernameTextField: UITextField!
    @IBOutlet private var credentialsPasswordTextField: UITextField!
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    private var selectedAccountForCreation: ((String?, String?, String, String, String) -> AccountAvailableForCreation)?
    private var createdAccountDetails: CreatedAccountDetails? {
        didSet {
            tokenRefreshStackView.isHidden = createdAccountDetails == nil
        }
    }
    
    private var credential: Credential?
    weak var authSessionInvalidatedDelegateForLoginAndSignup: AuthSessionInvalidatedDelegate?
    
    private let serviceDelegate = ExampleAPIServiceDelegate()
    private var quarkCommands: QuarkCommands { QuarkCommands(env: environmentSelector.currentEnvironment) }
    
    private lazy var authenticator: Authenticator = {
        let env = environmentSelector.currentEnvironment
        let api = PMAPIService.createAPIService(environment: env,
                                                sessionUID: "token refresh test session",
                                                challengeParametersProvider: .forAPIService(clientApp: clientApp, challenge: PMChallenge()))
        api.authDelegate = self
        api.serviceDelegate = self.serviceDelegate
        return .init(api: api)
    }()
    
    private let createUserFirst = "Create user first"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            environmentSelector.switchToCustomDomain(value: dynamicDomain)
            PMLog.info("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            PMLog.info("Dynamic domain not found, customDomainTextField left unfilled")
        }
        selectedAccountForCreation = accountsAvailableForCreation.first
        generateAccessibilityIdentifiers()
    }
    
    @IBAction func onCredentialsChanged(_ sender: Any) {
        switch credentialsSelector.selectedSegmentIndex {
        case 0:
            credentialsStackView.isHidden = true
        case 1:
            credentialsStackView.isHidden = false
        default:
            assertionFailure("Misconfiguration in \(#file), \(#function), \(#line)")
            break
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let username: String?
        let password: String?
        if credentialsSelector.selectedSegmentIndex == 0 {
            username = nil
            password = nil
        } else {
            username = credentialsUsernameTextField.text
            password = credentialsPasswordTextField.text
        }
        guard let account = selectedAccountForCreation?(username, password, "", "", "") else { return }
        credential = nil
        createdAccountDetails = nil
        unbanUnjail { [unowned self] in
            QuarkCommands.create(account: account,
                                 currentlyUsedHostUrl: environmentSelector.currentEnvironment.doh.getCurrentlyUsedHostUrl()) { [weak self] result in
                guard let self = self else { return }
                self.hideLoadingIndicator()
                self.tokenRefreshStackView.isHidden = false
                switch result {
                case .success(let details):
                    self.display(message: TokenRefreshStrings.createAccountSuccessfully)
                    self.createdAccountDetails = details
                    self.passwordTextField.text = details.account.password
                    UIPasteboard.general.string = details.account.password
                    self.accountDetailsLabel.text = details.details
                case .failure(let error):
                    self.createdAccountDetails = nil
                    self.passwordTextField.text = nil
                    self.accountDetailsLabel.text = error.userFacingMessageInQuarkCommands
                }
            }
        }
    }
    
    @IBAction func logIn() {
        guard let createdAccountDetails = createdAccountDetails else {
            display(message: createUserFirst)
            return
        }
        
        unbanUnjail { [weak self] in
            guard let self = self else { return }
            self.authenticator.authenticate(username: createdAccountDetails.account.username,
                                            password: createdAccountDetails.account.password,
                                            challenge: nil) { [weak self] result in
                guard let self = self else { return }
                self.hideLoadingIndicator()
                switch result {
                case .success(.newCredential(let credential, _)):
                    self.display(message: TokenRefreshStrings.loggedInSuccessfully)
                    self.credential = credential
                case .failure(let error):
                    self.display(message: error.userFacingMessageInNetworking)
                default:
                    break
                }
            }
        }
    }
    
    private func unbanUnjail(completion: @escaping () -> Void) {
        showLoadingIndicator()
        quarkCommands.unban() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.quarkCommands.disableJail { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        completion()
                    case .failure(let error):
                        self.hideLoadingIndicator()
                        self.display(message: "Disable jail error: \(error)")
                    }
                }
            case .failure(let error):
                self.display(message: "Unban error: \(error)")
                self.hideLoadingIndicator()
                completion()
            }
        }
    }
    
    @IBAction func getUser() {
        guard let credential = credential else {
            display(message: "Log in first")
            return
        }
        showLoadingIndicator()
        authenticator.getUserInfo(credential) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            switch result {
            case .success:
                self.display(message: TokenRefreshStrings.getUserSuccessfully)
            case .failure:
                self.display(message: TokenRefreshStrings.failedToGetUser)
            }
        }
    }
    
    @IBAction func expireSession() {
        guard let createdAccountDetails = createdAccountDetails else {
            display(message: createUserFirst)
            return
        }
        showLoadingIndicator()
        quarkCommands.expireSession(username: createdAccountDetails.account.username) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            switch result {
            case .success:
                self.display(message: TokenRefreshStrings.expiredSessionSuccessfully)
            case .failure(let error):
                self.display(message: error.messageForTheUser)
            }
        }
    }
    
    @IBAction func expireSessionAndRefreshToken() {
        guard let createdAccountDetails = createdAccountDetails else {
            display(message: createUserFirst)
            return
        }
        showLoadingIndicator()
        quarkCommands.expireSession(username: createdAccountDetails.account.username,
                                    expireRefreshToken: true) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            switch result {
            case .success:
                self.display(message: TokenRefreshStrings.expiredSessionSuccessfully)
            case .failure(let error):
                PMLog.info("Expire session error: \(error)")
                self.display(message: error.messageForTheUser)
            }
        }
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.messageLabel.text = nil
            self.activityIndicatorView.isHidden = false
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = true
        }
    }
    
    private func display(message: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = accountsAvailableForCreation[row](nil, nil, "", "", "").description
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: UIFont.labelFontSize)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        UIFont.labelFontSize * 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        accountsAvailableForCreation.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAccountForCreation = accountsAvailableForCreation[row]
    }
    
    // MARK: - AuthDelegate
    func authCredential(sessionUID: String) -> AuthCredential? {
        credential.map(AuthCredential.init)
    }
    
    func credential(sessionUID: String) -> Credential? {
        credential
    }
    
    func onAuthenticatedSessionInvalidated(sessionUID uid: String) {
        credential = nil
    }

    func onUnauthenticatedSessionInvalidated(sessionUID: String) {
        credential = nil
    }
    
    func onUpdate(credential: Credential, sessionUID: String) {
        self.credential = credential
    }

    func onSessionObtaining(credential: ProtonCoreNetworking.Credential) {

    }

    func onAdditionalCredentialsInfoObtained(sessionUID: String, password: String?, salt: String?, privateKey: String?) {
        
    }

    var delegate: AuthHelperDelegate?
}
