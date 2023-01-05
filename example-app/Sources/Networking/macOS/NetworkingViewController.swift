//
//  NetworkingViewController.swift
//  Example-macOS - Created on 10/11/2021.
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

import Foundation
import AppKit
import ProtonCore_Authentication
import ProtonCore_APIClient
import ProtonCore_CoreTranslation
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_HumanVerification
import ProtonCore_ObfuscatedConstants

class NetworkingViewController: NSViewController {
    
    private let sessionId = "macos example networking session id"
    
    private var testApi: PMAPIService!
    private var authHelper: AuthHelper!
    private var humanVerificationDelegate: HumanVerifyDelegate?
    
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTestApi()
    }
    
    func createTestApi() {
        testApi = PMAPIService.createAPIService(environment: environmentSelector.currentEnvironment, sessionUID: sessionId, challangeParametersProvider: .empty)
        authHelper = AuthHelper()
        testApi.authDelegate = authHelper
        testApi.serviceDelegate = self
        let url = HVCommon.defaultSupportURL(clientApp: clientApp)
        humanVerificationDelegate = HumanCheckHelper(apiService: testApi, supportURL: url, viewController: self, clientApp: clientApp, responseDelegate: self, paymentDelegate: self)
        testApi.humanDelegate = humanVerificationDelegate
    }
        
    @IBAction func humanVerificationAuthAction(_ sender: Any) {
        createTestApi()
        getCredentialsAlertView { userName, password in
            self.humanVerification(userName: userName, password: password)
        }
    }
    
    func humanVerification(userName: String, password: String) {
        let authApi: Authenticator = Authenticator(api: testApi)
        authApi.authenticate(username: userName, password: password, challenge: nil) { result in
            switch result {
            case .failure(Authenticator.Errors.networkingError(let error)): // error response returned by server
                let alert = NSAlert()
                alert.messageText = error.networkResponseMessageForTheUser
                alert.alertStyle = .critical
                alert.runModal()
            case .failure(Authenticator.Errors.apiMightBeBlocked(let message, _)):
                let alertController = NSAlert()
                alertController.alertStyle = .critical
                alertController.messageText = "API might be blocked"
                alertController.informativeText = message
                alertController.addButton(withTitle: CoreString._net_api_might_be_blocked_button)
                let response = alertController.runModal()
                switch response {
                case .alertFirstButtonReturn:
                    self.onDohTroubleshot()
                default: return
                }
            case .failure(Authenticator.Errors.emptyServerSrpAuth):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyClientSrpAuth):
                PMLog.info("")
            case .failure(Authenticator.Errors.wrongServerProof):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyAuthResponse):
                PMLog.info("")
            case .failure(Authenticator.Errors.emptyAuthInfoResponse):
                PMLog.info("")
            case .failure(_): // network or parsing error
                PMLog.info("")
            case .success(.ask2FA(let context)): // success but need 2FA
                PMLog.info(String(describing: context))
            case .success(.newCredential(_, let passwordMode)): // success without 2FA
                PMLog.info("pwd mode: \(passwordMode)")
                self.showHumanVerification()
                break
            case .success(.updatedCredential):
                assert(false, "Should never happen in this flow")
            }
            PMLog.info(String(describing: result))
        }
    }
    
    @IBAction func humanVerificationUnauthAction(_ sender: Any) {
        createTestApi()
        showHumanVerification()
    }
    
    func showHumanVerification() {
        let client = TestApiClient(api: self.testApi)
        client.triggerHumanVerify(isAuth: false) { (_, response) in
            guard let message = response.error?.networkResponseMessageForTheUser else { return }
            let alert = NSAlert()
            alert.messageText = message
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
    
    @IBAction func humanVerificationHelpAction(_ sender: Any) {
        createTestApi()
        let storyboard = NSStoryboard.init(name: "HumanVerify", bundle: HVCommon.bundle)
        let helpViewController = storyboard.instantiateController(
            withIdentifier: "HumanCheckHelpViewController"
        ) as! HVHelpViewController
        helpViewController.viewModel = HelpViewModel(url: testApi.humanDelegate?.getSupportURL(), clientApp: clientApp)
        presentAsModalWindow(helpViewController)
    }
    
    func getCredentialsAlertView(result: @escaping (String, String) -> Void) {
        let alertController = NSAlert()
        alertController.addButton(withTitle: "Log in")
        alertController.addButton(withTitle: "Cancel")
        let usernameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholderString = "username"
        usernameTextField.stringValue = ObfuscatedConstants.mailFreeUsername
        let passwordTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholderString = "password"
        passwordTextField.stringValue = ObfuscatedConstants.mailFreePassword
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
        let response = alertController.runModal()
        switch response {
        case .alertFirstButtonReturn:
            result(usernameTextField.stringValue, passwordTextField.stringValue)
        default: return
        }
    }
}

extension NetworkingViewController : APIServiceDelegate {
    
    var additionalHeaders: [String : String]? { nil }
    
    var locale: String { Locale.autoupdatingCurrent.identifier }

    var userAgent: String? { "" }
    
    func isReachable() -> Bool { true }
    
    var appVersion: String { appVersionHeader.getVersionHeader() }
    
    func onUpdate(serverTime: Int64) {}
    
    func onDohTroubleshot() {
        PMLog.info("\(#file) \(#function)")
    }
}

extension NetworkingViewController: HumanVerifyPaymentDelegate {
    var paymentToken: String? { nil }
    func paymentTokenStatusChanged(status: PaymentTokenStatusResult) {}
}

extension NetworkingViewController: HumanVerifyResponseDelegate {
    func onHumanVerifyStart() {
        
    }
    
    func onHumanVerifyEnd(result: HumanVerifyEndResult) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.informativeText = "This popup comes from the example app and not from HV v3 module"
            alert.alertStyle = .informational
            switch result {
            case .success:
                alert.messageText = "Human Verification success"
            case .cancel:
                alert.messageText = "Human Verification cancelled"
            }
            alert.runModal()
        }
    }
    
    func humanVerifyToken(token: String?, tokenType: String?) {
        
    }
}
