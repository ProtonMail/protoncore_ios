//
//  ProductProtocol.swift
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
import StoreKit

/// Protocol that matches Apple's Product interface so that we don't depend on
/// the actual Product struct
public protocol ProductProtocol: Hashable, Sendable {
    var displayName: String { get }
    var description: String { get }
    var displayPrice: String { get }
    var price: Decimal { get }
    var id: String { get }
    var priceFormatStyle: Decimal.FormatStyle.Currency { get }
    var subscription: Product.SubscriptionInfo? { get }
}

public protocol ProtonTransactionProviding: Sendable {
    var id: UInt64 { get }
    var originalID: UInt64 { get }
    var productID: String { get }
    var price: Decimal? { get }
    var userTransactionUUID: UUID? { get }
    var currencyIdentifier: String? { get }
}

public struct ProtonTransaction: ProtonTransactionProviding {
    public let id: UInt64
    public let originalID: UInt64
    public let productID: String
    public let price: Decimal?
    public let userTransactionUUID: UUID?
    public let currencyIdentifier: String?
    public let renewal: Bool

    public init(id: UInt64, originalID: UInt64, productID: String, price: Decimal?, userTransactionUUID: UUID?, currencyIdentifier: String?, renewal: Bool) {
        self.id = id
        self.originalID = originalID
        self.productID = productID
        self.price = price
        self.userTransactionUUID = userTransactionUUID
        self.currencyIdentifier = currencyIdentifier
        self.renewal = renewal
    }
}

extension Product: ProductProtocol {}

extension Transaction {

    public func toProtonTransaction() -> ProtonTransaction {
        if #available(iOS 17.0, macOS 14.0, *) {
            ProtonTransaction(
                id: id,
                originalID: originalID,
                productID: productID,
                price: price,
                userTransactionUUID: appAccountToken,
                currencyIdentifier: currency?.identifier,
                renewal: reason == .renewal)
        } else {
            ProtonTransaction(
                id: id,
                originalID: originalID,
                productID: productID,
                price: price,
                userTransactionUUID: appAccountToken,
                currencyIdentifier: currency?.identifier,
                renewal: purchaseDate != originalPurchaseDate)
        }
    }
}
