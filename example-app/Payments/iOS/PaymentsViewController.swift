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
    @IBOutlet weak var environmentSelector: EnvironmentSelector!
    @IBOutlet weak var testCardSwitch: UISwitch!
    @IBOutlet weak var unfinishedTransactionsButton: UIButton!

    private var unfinishedTransactions: [SKPaymentTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dynamicDomain = ProcessInfo.processInfo.environment["DYNAMIC_DOMAIN"] {
            environmentSelector.switchToCustomDomain(value: dynamicDomain)
            print("Filled customDomainTextField with dynamic domain: \(dynamicDomain)")
        } else {
            print("Dynamic domain not found, customDomainTextField left unfilled")
        }
        useTestCardSwitchValueChanged()
        generateAccessibilityIdentifiers()
    }

    @IBAction private func useTestCardSwitchValueChanged() {
        if testCardSwitch.isOn {
            ProtonCore_Payments.TemporaryHacks.testCardForPayments = ObfuscatedConstants.paymentsCard
        } else {
            ProtonCore_Payments.TemporaryHacks.testCardForPayments = nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removePaymentsObserver()
        if let viewController = segue.destination as? PaymentsNewUserSubscriptionVC, segue.identifier == "NewUserSegue" {
            viewController.currentEnv = environmentSelector.currentDoh
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsRegistrationSubscriptionVC, segue.identifier == "RegistrationSegue" {
            viewController.currentEnv = environmentSelector.currentDoh
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsNewUserSubscriptionUIVC, segue.identifier == "NewUserUISegue" {
            viewController.currentEnv = environmentSelector.currentDoh
            viewController.inAppPurchases = listOfIAPIdentifiers
            viewController.serviceDelegate = ExampleAPIServiceDelegate()
            viewController.updateCredits = updateCredits
            viewController.testPicker = testDataVariant.map(PaymentsTestUserPickerData.init(variant:))
        } else if let viewController = segue.destination as? PaymentsReceiptDetailsViewController {
            viewController.testApi = PMAPIService(doh: BlackDoH.default, sessionUID: "testSessionUID")
        }
    }

    private var testDataVariant: PaymentsTestUserPickerData.Variant? {
        if environmentSelector.currentDoh.defaultHost == ObfuscatedConstants.paymentsBlackDefaultHost {
            return .payments
        } else if environmentSelector.currentDoh.defaultHost.contains(".black") {
            return .black
        } else {
            return nil
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
