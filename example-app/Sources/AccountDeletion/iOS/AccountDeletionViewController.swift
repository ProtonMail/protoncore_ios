//
//  AccountDeletionViewController.swift
//  ExampleApp - Created on 10/12/2021.
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

import UIKit
import ProtonCore_AccountDeletion
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands
import ProtonCore_Foundations
import ProtonCore_Login
import ProtonCore_Services

final class AccountDeletionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, AccessibleView {
    
    @IBOutlet private var activityIndicatorView: UIView!
    @IBOutlet private var accountDeletionStackView: UIStackView!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var accountDetailsLabel: UILabel!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var deleteAccountButton: UIButton!
    @IBOutlet private var credentialsSelector: UISegmentedControl!
    @IBOutlet private var credentialsStackView: UIStackView!
    @IBOutlet private var credentialsUsernameTextField: UITextField!
    @IBOutlet private var credentialsPasswordTextField: UITextField!
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    private var selectedAccountForCreation: ((String?, String?) -> AccountAvailableForCreation)?
    private var createdAccountDetails: CreatedAccountDetails? {
        didSet {
            accountDeletionStackView.isHidden = createdAccountDetails == nil
        }
    }
    
    private let authManager = AuthManager()
    private let serviceDelegate = ExampleAPIServiceDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedAccountForCreation = accountsAvailableForCreation.first
        deleteAccountButton.setTitle(AccountDeletionService.defaultButtonName, for: .normal)
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
        guard let account = selectedAccountForCreation?(username, password) else { return }
        self.showLoadingIndicator()
        QuarkCommands.create(account: account,
                             currentlyUsedHostUrl: environmentSelector.currentDoh.getCurrentlyUsedHostUrl()) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            self.accountDeletionStackView.isHidden = false
            switch result {
            case .success(let details):
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
    
    @IBAction func deleteAccount(_ sender: Any) {
        guard let createdAccountDetails = createdAccountDetails else { return }
        let doh = environmentSelector.currentDoh
        self.showLoadingIndicator()
        let api = PMAPIService(doh: doh, sessionUID: "delete account test session")
        api.authDelegate = self.authManager
        api.serviceDelegate = self.serviceDelegate
        LoginCreatedUser(api: api, authManager: authManager).login(account: createdAccountDetails) { [weak self] loginResult in
            guard let self = self else { return }
            switch loginResult {
            case .failure(let error):
                self.handleAccountDeletionFailure(error.userFacingMessageInLogin)
            case .success:
                let accountDeletion = AccountDeletionService(api: api)
                accountDeletion.initiateAccountDeletionProcess(over: self) { [weak self] in
                    self?.hideLoadingIndicator()
                } completion: { [weak self] result in
                    switch result {
                    case .failure(AccountDeletionError.closedByUser): break;
                    case .failure(let error): self?.handleAccountDeletionFailure(error.userFacingMessageInAccountDeletion)
                    case .success(let result): self?.handleSuccessfulAccountDeletion(result)
                    }
                }
            }
        }
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = true
        }
    }
    
    private func handleSuccessfulAccountDeletion(_ success: AccountDeletionSuccess) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Account deletion success", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.accountDeletionStackView.isHidden = true
        }
    }
    
    private func handleAccountDeletionFailure(_ failure: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Account deletion failure", message: "\(failure)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.accountDeletionStackView.isHidden = false
            self.hideLoadingIndicator()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = accountsAvailableForCreation[row](nil, nil).description
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
}
