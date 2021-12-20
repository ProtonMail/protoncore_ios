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
import ProtonCore_Foundations
import ProtonCore_Login
import ProtonCore_Services

final class AccountDeletionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, AccessibleView {
    
    @IBOutlet private var accountPickerView: UIPickerView!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var accountDetailsLabel: UILabel!
    @IBOutlet private var deleteAccountButton: UIButton!
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    private var selectedAccountForCreation: AccountAvailableForCreation?
    private var createdAccountDetails: CreatedAccountDetails? {
        didSet {
            deleteAccountButton.isHidden = createdAccountDetails == nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedAccountForCreation = accountsAvailableForCreation.first
        environmentSelector.switchToCustomDomain(value: ObfuscatedConstants.accountDeletionTestingEnvironment)
        deleteAccountButton.setTitle(AccountDeletionService.defaultButtonName, for: .normal)
        generateAccessibilityIdentifiers()
    }
 
    @IBAction func createAccount(_ sender: Any) {
        guard let account = selectedAccountForCreation else { return }
        create(account: account,
               doh: environmentSelector.currentDoh) { [weak self] result in
            guard let self = self else { return }
            self.accountDetailsLabel.isHidden = false
            switch result {
            case .success(let details):
                self.createdAccountDetails = details
                self.accountDetailsLabel.text = details.details
            case .failure(let error):
                self.createdAccountDetails = nil
                self.accountDetailsLabel.text = error.messageForTheUser
            }
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        guard let createdAccountDetails = createdAccountDetails else { return }
        let doh = environmentSelector.currentDoh
        LoginCreatedUser(doh: doh).login(account: createdAccountDetails) { [weak self] loginResult in
            guard let self = self else { return }
            switch loginResult {
            case .failure(let error):
                self.handleAccountDeletionFailure(error.messageForTheUser)
            case .success(let credential):
                let api = PMAPIService(doh: doh, sessionUID: "delete account test session")
                let accountDeletion = AccountDeletionService(api: api)
                accountDeletion.initiateAccountDeletionProcess(credential: credential, over: self) { [weak self] result in
                    switch result {
                    case .failure(AccountDeletionError.closedByUser): break;
                    case .failure(let error): self?.handleAccountDeletionFailure(error.messageForTheUser)
                    case .success(let result): self?.handleSuccessfulAccountDeletion(result)
                    }
                }
            }
        }
    }
    
    private func handleSuccessfulAccountDeletion(_ success: AccountDeletionSuccess) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Account deletion success", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.accountDetailsLabel.isHidden = true
            self.deleteAccountButton.isHidden = true
        }
    }
    
    private func handleAccountDeletionFailure(_ failure: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Account deletion failure", message: "\(failure)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.accountDetailsLabel.isHidden = false
            self.deleteAccountButton.isHidden = false
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = accountsAvailableForCreation[row].description
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
