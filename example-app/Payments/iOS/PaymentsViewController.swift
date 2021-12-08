//
//  PaymentsViewController.swift
//  Example-Payments - Created on 04/12/2020.
//
//
//  Copyright (c) 2020 Proton Technologies AG
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

import UIKit
import ProtonCore_Doh
import ProtonCore_Foundations
import ProtonCore_Services
import ProtonCore_Payments
import ProtonCore_ObfuscatedConstants
import ProtonCore_UIFoundations
import StoreKit

class PaymentsViewController: UIViewController, AccessibleView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var envSegmentedControl: UISegmentedControl!
    @IBOutlet weak var customEnvironmentTextField: UITextField!
    @IBOutlet weak var testCardSwitch: UISwitch!
    @IBOutlet weak var unfinishedTransactionsButton: UIButton!

    private var unfinishedTransactions: [SKPaymentTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            customEnvironmentTextField.text = dynamicDomain
            customEnvironmentTextField.isHidden = false
            envSegmentedControl.selectedSegmentIndex = 4
            print("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            print("Dynamic domain not found, customDomainTextField left unfilled")
        }
        label.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        useTestCardSwitchValueChanged()
        generateAccessibilityIdentifiers()
    }

    @IBAction private func useTestCardSwitchValueChanged() {
        if testCardSwitch.isOn {
            TemporaryHacks.testCardForPayments = ObfuscatedConstants.paymentsCard
        } else {
            TemporaryHacks.testCardForPayments = nil
        }
    }
    
    @IBAction private func environmentChanged() {
        customEnvironmentTextField.isHidden = envSegmentedControl.selectedSegmentIndex != 3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removePaymentsObserver()
        if let viewController = segue.destination as? PaymentsNewUserSubscriptionVC, segue.identifier == "NewUserSegue" {
            viewController.currentEnv = currentEnv
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsRegistrationSubscriptionVC, segue.identifier == "RegistrationSegue" {
            viewController.currentEnv = currentEnv
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsNewUserSubscriptionUIVC, segue.identifier == "NewUserUISegue" {
            viewController.currentEnv = currentEnv
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.updateCredits = updateCredits
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsReceiptDetailsViewController {
            PMAPIService.noTrustKit = true
            viewController.testApi = PMAPIService(doh: BlackDoH.default,
                                                  sessionUID: "testSessionUID")
        }
    }

    private var currentEnv: DoH & ServerConfig {
        switch envSegmentedControl.selectedSegmentIndex {
        case 0:
            if clientApp == .vpn {
                return ProdDoHVPN.default
            } else {
                return ProdDoHMail.default
            }
        case 1: return BlackDoH.default
        case 2: return PaymentsBlackDoH.default
        case 3:
            guard let customDomain = customEnvironmentTextField.text else { fatalError("No custom domain") }
            let doh = CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                humanVerificationV3Host: "https://verify.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
            doh.status = dohStatus
            return doh
        default: fatalError("wrong configuration in storyboard")
        }
    }

    private var testDataVariant: PaymentsTestUserPickerData.Variant? {
        switch envSegmentedControl.selectedSegmentIndex {
        case 0: return nil
        case 1: return .black
        case 2: return .payments
        case 3: return .black
        default: fatalError("wrong configuration in storyboard")
        }
    }

    @IBAction private func clearTransactions() {
        let defaultPaymentQueue = SKPaymentQueue.default()
        if unfinishedTransactions.isEmpty {
            guard defaultPaymentQueue.transactions.isEmpty else {
                paymentQueue(defaultPaymentQueue, updatedTransactions: defaultPaymentQueue.transactions)
                return
            }
            defaultPaymentQueue.add(self)
            unfinishedTransactionsButton.setTitle("Checking for unfinished transactions...", for: .normal)
            unfinishedTransactionsButton.isUserInteractionEnabled = false
            unfinishedTransactionsButton.isEnabled = false
        } else {
            unfinishedTransactions.forEach(defaultPaymentQueue.finishTransaction)
            unfinishedTransactions.removeAll()
            removePaymentsObserver()
        }
    }

    private func removePaymentsObserver() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.remove(self)
        unfinishedTransactionsButton.setTitle("Check for unfinished transactions", for: .normal)
        unfinishedTransactionsButton.isUserInteractionEnabled = true
        unfinishedTransactionsButton.isEnabled = true
    }
}

extension PaymentsViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        unfinishedTransactions.append(contentsOf: transactions)
        if transactions.isEmpty {
            removePaymentsObserver()
        } else {
            queue.remove(self)
            unfinishedTransactionsButton.isUserInteractionEnabled = true
            unfinishedTransactionsButton.isEnabled = true
            unfinishedTransactionsButton.setTitle("Remove found unfinished transactions", for: .normal)
        }
    }
}

extension PaymentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
