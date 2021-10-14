//
//  StoreKitManagerMock.swift
//  ProtonCore-TestingToolkit - Created on 07/09/2021.
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

import Foundation
import StoreKit
import ProtonCore_Payments

public final class StoreKitManagerMock: NSObject, StoreKitManagerProtocol {

    @FuncStub(StoreKitManagerProtocol.subscribeToPaymentQueue) public var subscribeToPaymentQueueStub
    public func subscribeToPaymentQueue() { subscribeToPaymentQueueStub() }

    @FuncStub(StoreKitManagerProtocol.isValidPurchase) public var isValidPurchaseStub
    public func isValidPurchase(storeKitProductId: String, completion: @escaping (Bool) -> Void) {
        isValidPurchaseStub(storeKitProductId, completion)
    }

    @FuncStub(StoreKitManagerProtocol.continueRegistrationPurchase) public var continueRegistrationPurchaseStub
    public func continueRegistrationPurchase(finishHandler: FinishCallback?) {
        continueRegistrationPurchaseStub(finishHandler)
    }

    @FuncStub(StoreKitManagerProtocol.updateAvailableProductsList) public var updateAvailableProductsListStub
    public func updateAvailableProductsList(completion: @escaping (Error?) -> Void) {
        updateAvailableProductsListStub(completion)
    }
    
    @ThrowingFuncStub(StoreKitManagerProtocol.readReceipt, initialReturn: .empty) public var readReceiptStub
    public func readReceipt() throws -> String { try readReceiptStub() }

    @FuncStub(StoreKitManagerProtocol.hasUnfinishedPurchase, initialReturn: false) public var hasUnfinishedPurchaseStub
    public func hasUnfinishedPurchase() -> Bool { hasUnfinishedPurchaseStub() }

    @FuncStub(StoreKitManagerProtocol.getNotifiedWhenTransactionsWaitingForTheSignupAppear, initialReturn: []) public var getNotifiedWhenTransactionsWaitingForTheSignupAppearStub
    public func getNotifiedWhenTransactionsWaitingForTheSignupAppear(completion: @escaping ([InAppPurchasePlan]) -> Void) -> [InAppPurchasePlan] {
        getNotifiedWhenTransactionsWaitingForTheSignupAppearStub(completion)
    }

    @FuncStub(StoreKitManagerProtocol.stopBeingNotifiedWhenTransactionsWaitingForTheSignupAppear) public var stopBeingNotifiedWhenTransactionsWaitingForTheSignupAppearStub
    public func stopBeingNotifiedWhenTransactionsWaitingForTheSignupAppear() {
        stopBeingNotifiedWhenTransactionsWaitingForTheSignupAppearStub()
    }

    @FuncStub(StoreKitManagerProtocol.currentTransaction, initialReturn: nil) public var currentTransactionStub
    public func currentTransaction() -> SKPaymentTransaction? {
        currentTransactionStub()
    }

    @FuncStub(StoreKitManagerProtocol.priceLabelForProduct, initialReturn: nil) public var priceLabelForProductStub
    public func priceLabelForProduct(storeKitProductId: String) -> (NSDecimalNumber, Locale)? {
        priceLabelForProductStub(storeKitProductId)
    }

    @FuncStub(StoreKitManagerProtocol.purchaseProduct, initialReturn: nil) public var purchaseProductStub
    public func purchaseProduct(plan: InAppPurchasePlan, amountDue: Int, successCompletion: @escaping SuccessCallback, errorCompletion: @escaping ErrorCallback, deferredCompletion: FinishCallback?) {
        purchaseProductStub(plan, amountDue, successCompletion, errorCompletion, deferredCompletion)
    }

    @PropertyStub(\StoreKitManagerProtocol.inAppPurchaseIdentifiers, initialGet: []) public var inAppPurchaseIdentifiersStub
    public var inAppPurchaseIdentifiers: ListOfIAPIdentifiers { inAppPurchaseIdentifiersStub() }

    @PropertyStub(\StoreKitManagerProtocol.delegate, initialGet: nil) public var delegateStub
    public var delegate: StoreKitManagerDelegate? { get { delegateStub() } set { delegateStub(newValue) } }
}

public final class StoreKitManagerDelegateMock: StoreKitManagerDelegate {

    public init() {}

    @PropertyStub(\StoreKitManagerDelegate.tokenStorage, initialGet: nil) public var tokenStorageStub
    public var tokenStorage: PaymentTokenStorage? { tokenStorageStub() }

    @PropertyStub(\StoreKitManagerDelegate.isUnlocked, initialGet: true) public var isUnlockedStub
    public var isUnlocked: Bool { isUnlockedStub() }

    @PropertyStub(\StoreKitManagerDelegate.isSignedIn, initialGet: true) public var isSignedInStub
    public var isSignedIn: Bool { isSignedInStub() }

    @PropertyStub(\StoreKitManagerDelegate.activeUsername, initialGet: nil) public var activeUsernameStub
    public var activeUsername: String? { activeUsernameStub() }

    @PropertyStub(\StoreKitManagerDelegate.userId, initialGet: nil) public var userIdStub
    public var userId: String? { userIdStub() }

    @FuncStub(StoreKitManagerDelegate.reportBugAlert) public var reportBugAlertStub
    public func reportBugAlert() { reportBugAlertStub() }
}

public final class PaymentTokenStorageMock: PaymentTokenStorage {

    public init() {}

    @FuncStub(PaymentTokenStorage.add) public var addStub
    public func add(_ token: PaymentToken) { addStub(token) }

    @FuncStub(PaymentTokenStorage.get, initialReturn: nil) public var getStub
    public func get() -> PaymentToken? { getStub() }

    @FuncStub(PaymentTokenStorage.clear) public var clearStub
    public func clear() { clearStub() }
}
