//
//  TransactionHandlerProviding.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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
import Combine

public protocol TransactionHandlerProviding: Sendable {
    var transactionState: CurrentValueSubject<TransactionHandlerState, Never> { get }
    func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan) async throws -> ComposedPlan
    // !!!: Warning Only Omnichannel TransactionHandler implements this
    func processTransaction(_ transaction: ProtonTransaction, jwsRepresentation: String, plan: ComposedPlan) async throws -> ComposedPlan
    func updateRemoteManager(remoteManager: RemoteManagerProviding)
    func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool
    func setAppAccountToken(_ appAccountToken: UUID?)
    func updateTransactionState(state: TransactionHandlerState)
}

public enum TransactionHandlerState: Sendable, Equatable, Hashable {
    case idle

    case iapStatusCheck
    case iapPurchase
    case fetchAvailablePlans
    case fetchProtonPlans
    case fetchUserUUID

    case generatingReceipt
    case creatingTransactionToken
    case waitingTokenResponse // Omnichannel only state
    case createNewSubscription
    case transactionCompleted(planName: String, cycle: Int)
    case transactionPending

    // MARK: Error states
    case transactionCancelledByUser
    case mismatchTransactionIDs
    case transactionProcessError
    case transactionProcessErrorInvalidReq
    case unableToGetUserTransactionUUID
    case unknownError
}

public enum TransactionHandlerError: LocalizedError {

    case unableToFindPlanName(productID: String)
    case transactionIdNotEqualToOriginalTransactionId(originalID: UInt64, transactionId: UInt64)
    case unableToGetBundleIdentifier
    case fetchReceiptDidFail(description: String)
    case wrongMethodCalled
    case invalidTokenRequirements

    public var errorDescription: String? {
        switch self {
        case .transactionIdNotEqualToOriginalTransactionId:
            return PaymentsV2Localizer.Transaction_Handler_repeated_purchase.l10n
        case .fetchReceiptDidFail:
            return PaymentsV2Localizer.Transaction_Handler_receipt_update_failed.l10n
        // Take care when adding an error case to this list, it will show up as "Plan not found"
        case .unableToFindPlanName, .unableToGetBundleIdentifier, .wrongMethodCalled, .invalidTokenRequirements:
            return PaymentsV2Localizer.Transaction_Handler_plan_not_found.l10n
        }
    }

    public var failureReason: String? {
        switch self {
        case .unableToFindPlanName(let productId):
            return "Impossible to find plan name for productId: \(productId)"
        case .transactionIdNotEqualToOriginalTransactionId(let originalId, let transactionId):
            return "\(originalId) != \(transactionId) this could indicate a repeated or renewal of an existing plan"
        case .unableToGetBundleIdentifier:
            return "App Bundle identifier not found"
        case .fetchReceiptDidFail(let description):
            return "SKReceiptRefreshRequest failed with error: \(description)"
        case .wrongMethodCalled:
            return "Wrong function called"
        case .invalidTokenRequirements:
            return "POST /tokens returned invalid requirements"
        }
    }
}
