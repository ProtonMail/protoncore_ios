//
//  SKPaymentTransactionMock.swift
//  ProtonCore-TestingToolkit - Created on 21/12/2020.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import StoreKit

public class SKPaymentTransactionMock: SKPaymentTransaction {
    
    public var mockError: Error?
    public var mockOriginal: SKPaymentTransaction?
    public var mockPayment: SKPayment
    public var mockTransactionDate: Date?
    public var mockTransactionIdentifier: String?
    public var mockTransactionState: SKPaymentTransactionState
    
    public init(error: Error? = nil, original: SKPaymentTransaction? = nil, payment: SKPayment, transactionDate: Date?, transactionIdentifier: String?, transactionState: SKPaymentTransactionState) {
        self.mockError = error
        self.mockOriginal = original
        self.mockPayment = payment
        self.mockTransactionDate = transactionDate
        self.mockTransactionIdentifier = transactionIdentifier
        self.mockTransactionState = transactionState
    }
    
    // Only set if state is SKPaymentTransactionFailed
    override public var error: Error? {
        get {
            return mockError
        }
        set {
            mockError = newValue
        }
    }

    // Only valid if state is SKPaymentTransactionStateRestored
    override public var original: SKPaymentTransaction? {
        get {
            return mockOriginal
        }
        set {
            mockOriginal = newValue
        }
    }
    
    override public var payment: SKPayment {
        get {
            return mockPayment
        }
        set {
            mockPayment = newValue
        }
    }

    // The date when the transaction was added to the server queue.  Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
    override public var transactionDate: Date? {
        get {
            return mockTransactionDate
        }
        set {
            mockTransactionDate = newValue
        }
    }
    
    // The unique server-provided identifier.  Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
    override public var transactionIdentifier: String? {
        get {
            return mockTransactionIdentifier
        }
        set {
            mockTransactionIdentifier = newValue
        }
    }
    
    override public var transactionState: SKPaymentTransactionState {
        get {
            return mockTransactionState
        }
        set {
            mockTransactionState = newValue
        }
    }
}
