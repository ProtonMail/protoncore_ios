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
    public var id: UInt64
    public var originalID: UInt64
    public var productID: String
    public var price: Decimal?
    public var userTransactionUUID: UUID?
    public var currencyIdentifier: String?
}

extension Product: ProductProtocol {}

extension Transaction {

    public func toProtonTransaction() -> ProtonTransaction {
        ProtonTransaction(
            id: id,
            originalID: originalID,
            productID: productID,
            price: price,
            userTransactionUUID: appAccountToken,
            currencyIdentifier: currency?.identifier)
    }
}
