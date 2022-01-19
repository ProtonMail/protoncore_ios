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

import AppKit
import ProtonCore_AccountDeletion
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_ObfuscatedConstants
import ProtonCore_QuarkCommands

final class AccountDeletionViewController: NSViewController {
    
    @IBOutlet var chooseAccountButton: NSPopUpButton!
    @IBOutlet var createAccountButton: NSButton!
    @IBOutlet var accountDetailsLabel: NSTextField!
    @IBOutlet var deleteAccountButton: NSButton!
    @IBOutlet var environmentSelector: EnvironmentSelector!
    
    @IBOutlet private var credentialsSelector: NSSegmentedControl!
    @IBOutlet private var credentialsStackView: NSStackView!
    @IBOutlet private var credentialsUsernameTextField: NSTextField!
    @IBOutlet private var credentialsPasswordTextField: NSTextField!
    
    private var selectedAccountForCreation: ((String?, String?) -> AccountAvailableForCreation)?
    private var createdAccountDetails: CreatedAccountDetails? {
        didSet {
            deleteAccountButton.isHidden = createdAccountDetails == nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseAccountButton.addItems(
            withTitles: accountsAvailableForCreation
                .map { $0(nil, nil) }
                .map(\.description)
        )
        selectedAccountForCreation = accountsAvailableForCreation.first
        deleteAccountButton.title = AccountDeletionService.defaultButtonName
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask = [.closable, .titled, .resizable]
        view.window?.minSize = NSSize(width: 600, height: 600)
        view.window?.maxSize = NSSize(width: 900, height: 900)
        view.window?.setFrame(
            NSRect(origin: view.window?.frame.origin ?? .zero, size: NSSize(width: 900, height: 600)),
            display: true
        )
    }
    
    @IBAction func onCredentialsChanged(_ sender: Any) {
        switch credentialsSelector.indexOfSelectedItem {
        case 0:
            credentialsStackView.isHidden = true
        case 1:
            credentialsStackView.isHidden = false
        default:
            assertionFailure("Misconfiguration in \(#file), \(#function), \(#line)")
            break
        }
    }
    
    @IBAction func onAccountSelectionChanged(_ sender: Any) {
        selectedAccountForCreation = accountsAvailableForCreation[chooseAccountButton.indexOfSelectedItem]
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let username: String?
        let password: String?
        if credentialsSelector.indexOfSelectedItem == 0 {
            username = nil
            password = nil
        } else {
            username = credentialsUsernameTextField.stringValue
            password = credentialsPasswordTextField.stringValue
        }
        guard let account = selectedAccountForCreation?(username, password) else { return }
        QuarkCommands.create(account: account,
                             currentlyUsedHostUrl: environmentSelector.currentDoh.getCurrentlyUsedHostUrl()) { [weak self] result in
            guard let self = self else { return }
            self.accountDetailsLabel.isHidden = false
            switch result {
            case .success(let details):
                self.createdAccountDetails = details
                self.accountDetailsLabel.stringValue = details.details
            case .failure(let error):
                self.createdAccountDetails = nil
                self.accountDetailsLabel.stringValue = error.userFacingMessageInQuarkCommands
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
                self.handleAccountDeletionFailure(error.userFacingMessageInLogin)
            case .success(let credential):
                let api = PMAPIService(doh: doh, sessionUID: "delete account test session")
                let accountDeletion = AccountDeletionService(api: api)
                accountDeletion.initiateAccountDeletionProcess(credential: credential, over: self) { [weak self] result in
                    switch result {
                    case .failure(.closedByUser): break
                    case .failure(let error): self?.handleAccountDeletionFailure(error.userFacingMessageInAccountDeletion)
                    case .success(let result): self?.handleSuccessfulAccountDeletion(result)
                    }
                }
            }
        }
    }
    
    private func handleSuccessfulAccountDeletion(_ success: AccountDeletionSuccess) {
        DispatchQueue.main.async {
            let alertController = NSAlert()
            alertController.alertStyle = .informational
            alertController.messageText = "Account deletion successful"
            alertController.runModal()
            self.accountDetailsLabel.isHidden = true
            self.deleteAccountButton.isHidden = true
        }
    }
    
    private func handleAccountDeletionFailure(_ failure: String) {
        DispatchQueue.main.async {
            let alertController = NSAlert()
            alertController.alertStyle = .warning
            alertController.messageText = "Account deletion failure"
            alertController.informativeText = failure
            alertController.runModal()
            self.accountDetailsLabel.isHidden = false
            self.deleteAccountButton.isHidden = false
        }
    }
    
}
