//
//  TransactionStubber.swift
//  ProtonCore
//
//  Created by Tiziano Bruni on 20/11/2025.
//

import Foundation
import StoreKitTest
import ProtonCorePaymentsV2

struct TransactionStubber {
    public static func convertStoreTestTransaction(_ transaction: SKTestTransaction, price: Decimal, currencyId: String, renewal: Bool) -> ProtonTransaction {
        ProtonTransaction(id: UInt64(transaction.identifier),
                          originalID: UInt64(transaction.originalTransactionIdentifier),
                          productID: transaction.productIdentifier,
                          price: price,
                          userTransactionUUID: UUID(uuidString: "123e4567-e89b-12d3-a456-426655440000"),
                          currencyIdentifier: currencyId,
                          renewal: renewal)
    }
}
