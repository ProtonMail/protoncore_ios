//
//  SubscriptionRequestModels.swift
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

// MARK: Subscription
public struct CancelSubscription: Codable, DictionaryConvertible {
    public let reason: String?
    public let score: Int?
    public let context: String?
    public let feedback: String?
    public let reasonDetails: String?
}

public struct NewSubscriptionValues: Codable, DictionaryConvertible {
    public let amount: Int?
    public let paymentMethodID: String?
    public let payments: [String]?
    public let paymentToken: String?
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCNewSubscriptionValues: Encodable, DictionaryConvertible {
    private let amount: Int? = nil
    private let paymentMethodID: String? = nil
    private let payments: [String]? = nil
    public let paymentToken: String?
    private let external: Int = 1
}

public struct Subscription: Codable, DictionaryConvertible {
    public let cycle: Int
    public let currency: String?
    public let currencyID: Int?
    public let plans: [String: Int]?
    public let planIDs: [Int]?
    public let codes: [String]?
    public let couponCode: String?
    public let giftCode: String?
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCSubscription: Encodable, DictionaryConvertible {
    public let cycle: Int
    public let currency: String?
    private let currencyID: Int? = nil
    public let plans: [String: Int]?
    private let planIDs: [Int]? = nil
    private let codes: [String]? = nil
    private let couponCode: String? = nil
    private let giftCode: String? = nil
}

public typealias CreateSubscription = Compose<Subscription, NewSubscriptionValues>
// Omnichannel variant of the above typealias, remove the old one once all the system runs on Omnichannel
public typealias OCreateSubscription = Compose<OCSubscription, OCNewSubscriptionValues>

public struct NewSubscription: Codable, DictionaryConvertible {

    public let newSubscription: CreateSubscription

    init(newValues: NewSubscriptionValues,
         subscription: Subscription) {
        newSubscription = CreateSubscription(subscription, newValues)
    }
}

// Omnichannel variant of the above model, remove the old one once all the system runs on Omnichannel
public struct OCNewSubscription: Encodable, DictionaryConvertible {

    public let newSubscription: OCreateSubscription

    init(newValues: OCNewSubscriptionValues,
         subscription: OCSubscription) {
        newSubscription = OCreateSubscription(subscription, newValues)
    }
}

public struct RenewSubscription: Codable, DictionaryConvertible {
    public let renewalState: Int
    public let cancellationFeedback: String?
}
