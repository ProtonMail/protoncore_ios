//
//  StoreKitReceiptManager.swift
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
import ProtonCoreLog
import StoreKit

public enum StoreKitReceiptManagerError: LocalizedError {
    case unableToExtractReceiptData

    public var errorDescription: String? {
        switch self {
        case .unableToExtractReceiptData:
            return PaymentsV2Localizer.SK_Receipt_impossible_to_get_receipt.l10n
        }
    }
}

public protocol StoreKitReceiptManagerProviding {
    func fetchPurchaseReceipt() throws -> String
    func recoverTransaction() async throws -> UnfinishedTransaction?
    @discardableResult
    func refreshReceipt() async throws -> String?
}

public struct UnfinishedTransaction {
    let transaction: Transaction
    let receipt: String
}

public final class StoreKitReceiptManager: NSObject, StoreKitReceiptManagerProviding {

    private var refresh: SKReceiptRefreshRequest?
    private var tokenContinuation: CheckedContinuation<Void, Error>?

    public func fetchPurchaseReceipt() throws -> String {
        guard let url = Bundle.main.appStoreReceiptURL, let data = try? Data(contentsOf: url) else {
            debugPrint("Unable to get receipt data")
            let error = StoreKitReceiptManagerError.unableToExtractReceiptData
            PMLog.error(error.errorDescription ?? "PaymentsV2 - StoreKit impssible to get receipt data", sendToExternal: true)
            throw error
        }

        return data.base64EncodedString()
    }

    public func recoverTransaction() async throws -> UnfinishedTransaction? {
        guard let transaction = await getTransactions() else {
            debugPrint("No unfinished transaction found")
            return nil
        }

        guard let receipt = try await refreshReceipt() else {
            debugPrint("No receipt found")
            return nil
        }

        return UnfinishedTransaction(transaction: transaction, receipt: receipt)
    }

    public func refreshReceipt() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            tokenContinuation = continuation
            refresh = SKReceiptRefreshRequest()
            refresh?.delegate = self
            refresh?.start()
        }

        return try? fetchPurchaseReceipt()
    }

    private func getTransactions() async -> Transaction? {
        // We assume there will possibly be only 1 unfinished transaction
        // for a Proton product for a given Apple Account.
        // Support mulitple unfinshed transaction will require changes on the BE.
        for await unfinished in Transaction.unfinished {
            switch unfinished {
            case .verified(let transaction):
                return transaction
            case .unverified(let transaction, let transactionError):
                debugPrint("Unverified unfinished transaction:\n \(transaction)\n \(transactionError)")
                return nil
            }
        }

        return nil
    }
}

extension StoreKitReceiptManager: SKRequestDelegate {

    public func requestDidFinish(_ request: SKRequest) {
        cancelActiveRequest(request)
        TransactionsObserver.shared.logHelper.logEvent(["apple_receipt_refresh": ["time": Date.now.description,
                                                                                  "status": "success"]])
        tokenContinuation?.resume()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        cancelActiveRequest(request)
        TransactionsObserver.shared.logHelper.logEvent(["apple_receipt_refresh": ["time": Date.now.description,
                                                                                  "status": "failed"]])
        tokenContinuation?.resume(throwing: TransactionHandlerError.fetchReceiptDidFail(description: error.localizedDescription))
        PMLog.error("PaymentsV2: Refresh Apple receipt failed with error: \(error.localizedDescription)", sendToExternal: true)
    }

    private func cancelActiveRequest(_ request: SKRequest) {
        request.cancel()
        refresh = nil
    }
}
