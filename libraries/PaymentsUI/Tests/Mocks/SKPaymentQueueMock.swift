//
//  SKPaymentQueueMock.swift
//  ProtonCore-PaymentsUI-Tests - Created on 21/12/2020.
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

import StoreKit

import ProtonCore_Payments
@testable import ProtonCore_TestingToolkit

class SKPaymentQueueMock: SKPaymentQueue {
    var transactionState: SKPaymentTransactionState = .failed
    var error: Error?
    var block: (() -> Void)?
    var fire = true {
        didSet {
            if oldValue == false, fire == true, lock == false {
                lock = true
                block?()
            }
        }
    }
    var lock = false
    
    func continueWithOtherState(state: SKPaymentTransactionState) {
        transactionState = state
        block?()
    }
    
    override func add(_ payment: SKPayment) {
        block = {
            let paymentTransaction = SKPaymentTransactionMock(payment: payment, transactionDate: Date(), transactionIdentifier: "test", transactionState: self.transactionState)
            paymentTransaction.error = self.error
            paymentTransaction.payment = payment
            let paymentTransactions = [paymentTransaction]
            self.transactions = [paymentTransaction]
            if #available(iOS 14.0, *) {
                self.transactionObservers.first?.paymentQueue(self, updatedTransactions: paymentTransactions)
            } else {
                // Fallback on earlier versions
            }
        }
        if fire {
            lock = true
            block?()
        }
    }
    
    private var mockTransactions: [SKPaymentTransaction] = []
    
    override var transactions: [SKPaymentTransaction] {
        get {
            return mockTransactions
        }
        set {
            self.mockTransactions = newValue
        }
    }

}
