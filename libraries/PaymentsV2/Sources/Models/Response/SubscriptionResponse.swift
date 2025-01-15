//
//  SubscriptionResponse.swift
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

public struct SubscriptionResponse: Decodable, Hashable, Identifiable, Sendable {

    public let id: String
    public let invoiceID: String?
    public let cycle: Int?
    public let periodStart: Int
    public let periodEnd: Int
    public let createTime: Int
    public let couponCode: String?
    public let currency: String
    public let amount: Int
    public let discount: Int
    public let renewDiscount: Int
    public let plans: [Plan]
    public let renewAmount: Int
    public let renew: Int
    public let external: Int
}

public struct CurrentSubscriptionResponse: Decodable, Hashable, Identifiable, Sendable {

    public let id: String?
    public let name: String?
    public let title: String
    public let description: String
    public let cycle: Int?
    public let cycleDescription: String?
    public let currency: String?
    public let amount: Int?
    public let offer: String?
    public let periodStart: Int?
    public let periodEnd: Int?
    public let createTime: Int?
    public let couponCode: String?
    public let discount: Int?
    public let renewDiscount: Int?
    public let renewAmount: Int?
    public let renew: Int?
    public let external: Int?
    public let entitlements: [Entitlement]
    public let decorations: [Decoration]

    public init(id: String?,
                name: String?,
                title: String,
                description: String,
                cycle: Int?,
                cycleDescription: String?,
                currency: String?,
                amount: Int?,
                offer: String?,
                periodStart: Int?,
                periodEnd: Int?,
                createTime: Int?,
                couponCode: String?,
                discount: Int?,
                renewDiscount: Int?,
                renewAmount: Int?,
                renew: Int?,
                external: Int?,
                entitlements: [Entitlement],
                decorations: [Decoration]) {
        self.id = id
        self.name = name
        self.title = title
        self.description = description
        self.cycle = cycle
        self.cycleDescription = cycleDescription
        self.currency = currency
        self.amount = amount
        self.offer = offer
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.createTime = createTime
        self.couponCode = couponCode
        self.discount = discount
        self.renewDiscount = renewDiscount
        self.renewAmount = renewAmount
        self.renew = renew
        self.external = external
        self.entitlements = entitlements
        self.decorations = decorations
    }
}

public struct CurrentSubscription: Decodable, Sendable {
    public let code: Int
    public let subscriptions: [CurrentSubscriptionResponse]
    public let upcomingSubscriptions: [CurrentSubscriptionResponse]?
}

public struct NewSubscriptionResponse: Decodable, Sendable {
    public let code: Int
    public let subscription: SubscriptionResponse
    public let upcomingSubscriptions: [SubscriptionResponse]?
}

public struct LastSubscription: Decodable, Sendable {
    public let code: Int
    public let lastSubscriptionEnd: Int
}

public struct ValidateSubscriptionResponse: Decodable, Sendable {
    public let code: Int
    public let amount: Int
    public let amountDue: Int
    public let proration: Int
    public let couponDiscount: Int
    public let coupon: Coupon
    public let unusedCredit: Int
    public let credit: Int
    public let currency: String
    public let cycle: Int
    public let gift: Int
}
