//
//  ProcessDependenciesMock.swift
//  ProtonCore-Payments-Tests - Created on 09/09/2021.
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

import Foundation
import StoreKit
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_Payments

final class ProcessDependenciesMock: ProcessDependencies {

    @PropertyStub(\ProcessDependencies.storeKitDelegate, initialGet: nil) var storeKitDelegateStub
    var storeKitDelegate: StoreKitManagerDelegate? { storeKitDelegateStub() }

    @PropertyStub(\ProcessDependencies.tokenStorage, initialGet: .crash) var tokenStorageStub
    var tokenStorage: PaymentTokenStorage { tokenStorageStub() }

    @PropertyStub(\ProcessDependencies.paymentsApiProtocol, initialGet: .crash) var paymentsApiProtocolStub
    var paymentsApiProtocol: PaymentsApiProtocol { paymentsApiProtocolStub() }

    @PropertyStub(\ProcessDependencies.alertManager, initialGet: .crash) var alertManagerStub
    var alertManager: PaymentsAlertManager { alertManagerStub() }

    @PropertyStub(\ProcessDependencies.updateSubscription, initialGet: .crash) var updateSubscriptionStub
    var updateSubscription: (Subscription) -> Void { updateSubscriptionStub() }
    
    @FuncStub(ProcessDependencies.updateCurrentSubscription) var updateCurrentSubscriptionStub
    func updateCurrentSubscription(success: @escaping () -> Void, failure: @escaping (Error) -> Void) { updateCurrentSubscriptionStub(success, failure) }

    @PropertyStub(\ProcessDependencies.finishTransaction, initialGet: .crash) var finishTransactionStub
    var finishTransaction: (SKPaymentTransaction) -> Void { finishTransactionStub() }

    @PropertyStub(\ProcessDependencies.apiService, initialGet: .crash) var apiServiceStub
    var apiService: APIService { apiServiceStub() }

    @FuncStub(ProcessDependencies.addTransactionsBeforeSignup) var addTransactionsBeforeSignupStub
    func addTransactionsBeforeSignup(transaction: SKPaymentTransaction) { addTransactionsBeforeSignupStub(transaction) }

    @FuncStub(ProcessDependencies.removeTransactionsBeforeSignup) var removeTransactionsBeforeSignupStub
    func removeTransactionsBeforeSignup(transaction: SKPaymentTransaction) { removeTransactionsBeforeSignupStub(transaction) }

    @PropertyStub(\ProcessDependencies.pendingRetry, initialGet: .zero) var pendingRetryStub
    var pendingRetry: Double { pendingRetryStub() }

    @PropertyStub(\ProcessDependencies.errorRetry, initialGet: .zero) var errorRetryStub
    var errorRetry: Double { errorRetryStub() }

    @ThrowingFuncStub(ProcessDependencies.getReceipt, initialReturn: .empty) var getReceiptStub
    func getReceipt() throws -> String { try getReceiptStub() }
    
    @PropertyStub(\ProcessDependencies.bugAlertHandler, initialGet: nil) public var bugAlertHandlerStub
    public var bugAlertHandler: BugAlertHandler { return bugAlertHandlerStub() }
}
