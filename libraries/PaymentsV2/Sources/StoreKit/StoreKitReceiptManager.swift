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
    case taskMissing

    public var errorDescription: String? {
        switch self {
        case .unableToExtractReceiptData:
            return PaymentsV2Localizer.SK_Receipt_impossible_to_get_receipt.l10n
        case .taskMissing:
            return PaymentsV2Localizer.SK_Receipt_task_not_found.l10n
        }
    }
}

public protocol StoreKitReceiptManagerProviding {
    func recoverTransaction() async throws -> UnfinishedTransaction?
    @discardableResult
    func refreshReceipt() async throws -> String
}

public struct UnfinishedTransaction {
    let transaction: Transaction
    let receipt: String
    let jwsRepresentation: String
}

public final class StoreKitReceiptManager: StoreKitReceiptManagerProviding {
    internal static let queue = DispatchQueue(label: "ch.proton.payments.receipt.refresh")
    private var requests: Set<ReceiptRefreshRequest> = []

    public init() {}

    deinit {
        requests.forEach { $0.cancel() }
    }

    public func recoverTransaction() async throws -> UnfinishedTransaction? {

        let details = await getTransactionDetails()
        guard let transaction = details.0 else {
            debugPrint("No unfinished transaction found")
            return nil
        }

        let receipt = try await refreshReceipt()

        return UnfinishedTransaction(transaction: transaction, receipt: receipt, jwsRepresentation: details.1)
    }

    public func refreshReceipt() async throws -> String {
        let request = ReceiptRefreshRequest()

        Self.queue.sync {
            _ = requests.insert(request)
        }

        defer {
            Self.queue.sync {
                _ = requests.remove(request)
            }
        }

        request.start()

        return try await request.result.base64EncodedString()
    }

    private func getTransactionDetails() async -> (Transaction?, String) {
        // We assume there will be at most one unfinished transaction for a Proton product for a given Apple Account.
        // Support for multiple unfinished transactions will require changes on the BE.
        for await unfinished in Transaction.unfinished {
            switch unfinished {
            case .verified(let transaction):
                return (transaction, unfinished.jwsRepresentation)
            case .unverified(let transaction, let transactionError):
                debugPrint("Unverified unfinished transaction:\n \(transaction)\n \(transactionError)")
                return (nil, "")
            }
        }

        return (nil, "")
    }
}

/// Wraps every receipt refresh request up into its own delegate so that subsequent requests don't stomp on each other.
final class ReceiptRefreshRequest: SKReceiptRefreshRequest, SKRequestDelegate, Identifiable {
    let id = UUID()

    private var completionHandler: ((Result<(), Error>) -> Void)?
    private var task: Task<(), Error>?
    private var done: Bool = false

    public var result: Data {
        get async throws {
            // Make sure that the request has finished before querying the value
            guard try await task?.value != nil else {
                PMLog.error("ReceiptRefreshRequest task is missing!", sendToExternal: true)
                throw StoreKitReceiptManagerError.taskMissing
            }

            // Introduce a (sad) short delay to make sure `appStoreReceiptURL` gets updated
            try await Task.sleep(for: .milliseconds(500))

            guard let url = Bundle.main.appStoreReceiptURL else {
                let error = StoreKitReceiptManagerError.unableToExtractReceiptData
                PMLog.error(error.errorDescription ?? "PaymentsV2 - StoreKit impossible to get receipt data", sendToExternal: true)
                throw error
            }

            let (data, _) = try await URLSession.shared.data(from: url)

            return data
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        PMLog.info("Receipt refresh request finished successfully: \(id)")
        StoreKitReceiptManager.queue.async { self.done = true }
        completionHandler?(.success(()))
    }

    func request(_ request: SKRequest, didFailWithError error: any Error) {
        PMLog.info("Receipt refresh request encountered an error: \(id) (\(String(describing: error)))")
        StoreKitReceiptManager.queue.async { self.done = true }
        completionHandler?(.failure(error))
    }

    override init() {
        super.init()
        self.delegate = self
    }

    override func start() {
        task = Task {
            try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    completionHandler = { result in
                        switch result {
                        case .success:
                            continuation.resume(returning: ())
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } onCancel: { [completionHandler, id] in
                PMLog.info("Receipt refresh request was cancelled: \(id)")
                completionHandler?(.failure(CancellationError()))
            }
        }

        PMLog.info("Starting receipt refresh request: \(id)")
        super.start()
    }

    override func cancel() {
        PMLog.info("Cancelling receipt refresh request: \(id)")
        super.cancel()

        // Narrow race window - it's possible for a request to be cancelled just as it was fetching the value.
        // Include this check to make sure that we don't accidentally invoke the continuation twice.
        if StoreKitReceiptManager.queue.sync(execute: { self.done }) {
            return
        }

        task?.cancel()
    }
}
