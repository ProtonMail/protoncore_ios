//
//  EndToEndViewController.swift
//  ExampleApp - Created on 12/15/2022.
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
import ProtonCore_Authentication
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands
import ProtonCore_Foundations
import ProtonCore_Log
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_Challenge

enum EndToEndTest: CaseIterable {
    case deviceFingerprintsOnPostSession
    var description:  String {
        switch self {
        case .deviceFingerprintsOnPostSession:
            return "Send device fingerprints on POST Session call"
        }
    }
    
    static var allCases: [EndToEndTest] {
        return [.deviceFingerprintsOnPostSession]
    }
}

final class EndToEndViewController: UIViewController,
                                    UIPickerViewDataSource,
                                    UIPickerViewDelegate,
                                    AccessibleView, AuthDelegate {
    
    @IBOutlet private var activityIndicatorView: UIView!
    @IBOutlet private var tokenRefreshStackView: UIStackView!
    @IBOutlet private var accountDetailsLabel: UILabel!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var copyLogButton: UIButton!
    @IBOutlet private var clearLogButton: UIButton!
    @IBOutlet private var credentialsSelector: UISegmentedControl!
    @IBOutlet private var credentialsStackView: UIStackView!
    @IBOutlet private var credentialsUsernameTextField: UITextField!
    @IBOutlet private var credentialsPasswordTextField: UITextField!
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    private var selectedTest: EndToEndTest?
    private var createdAccountDetails: CreatedAccountDetails? {
        didSet {
            tokenRefreshStackView.isHidden = createdAccountDetails == nil
        }
    }
    
    private var credential: Credential?
    
    private let serviceDelegate = ExampleAPIServiceDelegate()
    private var quarkCommands: QuarkCommands { QuarkCommands(env: environmentSelector.currentEnvironment) }
    
    private lazy var authenticator: Authenticator = {
        let env = environmentSelector.currentEnvironment
        let api = PMAPIService(environment: env, sessionUID: "token refresh test session")
        api.authDelegate = self
        api.serviceDelegate = self.serviceDelegate
        return .init(api: api)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            environmentSelector.switchToCustomDomain(value: dynamicDomain)
            PMLog.info("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            PMLog.info("Dynamic domain not found, customDomainTextField left unfilled")
        }
        selectedTest = EndToEndTest.allCases.first
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
    
    @IBAction func runTests(_ sender: Any) {
        testDeviceFingerprintsOnPostSession()
    }
    
    private func testDeviceFingerprintsOnPostSession() {
        let env = environmentSelector.currentEnvironment
        let api = PMAPIService(environment: env, sessionUID: "token refresh test session")
        api.authDelegate = self
        api.serviceDelegate = self.serviceDelegate
        var output = "Server: \n"
        output.append("RUL: \(api.doh.getCurrentlyUsedHostUrl()) \n")
        let deviceChallenge = PMChallenge.shared().export().deviceFingerprintDict()
        let challenge = ChallengeProperties.init(challenges: deviceChallenge, productPrefix: "mail")
        let sessionsRequest = SessionsRequest.init(challenge: challenge)
        
        self.showLoadingIndicator()
        api.sessionRequest(request: sessionsRequest) { (task, result: Result<SessionsRequestResponse, NSError>) in
            self.hideLoadingIndicator()
            if let body = task?.originalRequest?.httpBody {
                output.append("Request: \n")
                output.append(body.prettyPrintedJSONString!)
                output.append("\n")
            }
            switch result {
            case .success(let sessionsResponse):
                output.append("Response: \n")
                output.append("UID: \(sessionsResponse.UID) \n")
                output.append("AccessToken: \(sessionsResponse.accessToken) \n")
                output.append("RefreshToken: \(sessionsResponse.refreshToken) \n")
                output.append("TokenType: \(sessionsResponse.tokenType) \n")
                output.append("Scops: ")
                for scop in sessionsResponse.scopes {
                    output.append("    Scop: \(scop)")
                }
            case .failure(let error):
                output.append("Error: \n")
                output.append(error.localizedDescription)
            }
            self.display(message: output)
        }
    }
    
    @IBAction func copyLog() {
        let log = self.accountDetailsLabel.text
        UIPasteboard.general.string = log
    }
    
    @IBAction func clearLog() {
        self.accountDetailsLabel.text = ""
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.accountDetailsLabel.text = ""
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
            self.accountDetailsLabel.text = message
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = EndToEndTest.allCases[row].description
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: UIFont.labelFontSize)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        UIFont.labelFontSize * 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        EndToEndTest.allCases.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTest = EndToEndTest.allCases[row]
    }
    
    // MARK: - AuthDelegate
    func authCredential(sessionUID: String) -> AuthCredential? {
        credential.map(AuthCredential.init)
    }
    
    func credential(sessionUID: String) -> Credential? {
        credential
    }
    
    func onLogout(sessionUID uid: String) {}
    
    func onUpdate(credential: Credential, sessionUID: String) {
        self.credential = credential
    }
    
    func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) {
        guard let credential = credential else { return }
        authenticator.refreshCredential(credential) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            switch result {
            case .success(.updatedCredential(let credential)):
                self.credential = credential
                self.display(message: TokenRefreshStrings.refreshAccessTokenSuccessfully)
            case .failure:
                self.display(message: TokenRefreshStrings.refreshAccessTokenFailed)
            default:
                break
            }
        }
    }
}

extension Data {
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }
        
        return prettyPrintedString
    }
}
