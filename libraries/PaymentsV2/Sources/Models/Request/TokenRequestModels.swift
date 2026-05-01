//
//  TokenRequestModels.swift
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

// MARK: Tokens
public struct Token: Codable, DictionaryConvertible {
    private let amount: Int = 0
    private let currency: String = "CHF"
    public let payment: PaymentReceipt?
    public let paymentMethodID: String?
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCToken: Encodable {
    private let amount: Int = 0 // hardcoded for legacy reasons --> Jens will try to remove them
    private let currency: String = "CHF" // hardcoded for legacy reasons --> Jens will try to remove them
    public let payment: OCPaymentReceipt?

    enum CodingKeys: String, CodingKey {
        case amount = "Amount"
        case currency = "Currency"
        case payment = "Payment"
    }
}

public struct PaymentReceipt: Codable, Equatable, DictionaryConvertible {
    public let details: ReceiptDetails
    public let type: String
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCPaymentReceipt: Encodable, Equatable {
    public let details: OCReceiptDetails
    private let type: String = "apple-iap"

    enum CodingKeys: String, CodingKey {
        case details = "Details"
        case type = "Type"
    }
}

public struct ReceiptDetails: Codable, Equatable, DictionaryConvertible {
    public let bundleID: String
    public let productID: String
    public let receipt: String
    public let transactionID: String
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCReceiptDetails: Codable, Equatable {
    public let jws: String

    enum CodingKeys: String, CodingKey {
        case jws = "Jws"
    }
}
