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

final class AccountDeletionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        guard let id = createdAccountDetails?.id else { return }
        print("Not implemented yet, but it will delete account with id \(id)")
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
