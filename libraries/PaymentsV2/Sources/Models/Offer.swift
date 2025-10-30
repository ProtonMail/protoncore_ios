//
//  Offer.swift
//  ProtonCore-PaymentsV2 - Created on 16/10/2025.
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

public struct Offer: Sendable {

    public enum PaymentType: String, Sendable {
        case payAsYouGo
        case payUpFront
        case freeTrial

        public var description: String {
            switch self {
            case .payUpFront:
                return PaymentsV2Localizer.PayUpFront_offer_description.l10n
            case .payAsYouGo:
                return PaymentsV2Localizer.PayAsYouGo_offer_description.l10n
            case .freeTrial:
                return PaymentsV2Localizer.FreeTrial_offer_description.l10n
            }
        }
    }

    public enum Kind: String, Sendable {
        case IntroOffer
        case AdhocOffer // Promotional offer
        case Winback
    }

    public enum PeriodUnit: Sendable {
        case day
        case week
        case month
        case year
        case unknown
    }

    public let id: String?
    public let type: Offer.Kind?
    public let displayPrice: String
    public let price: Decimal
    public let paymentType: Offer.PaymentType?
    public let periodCount: Int
    public let periodUnit: Offer.PeriodUnit
}

// MARK: StoreKit extensions

extension Product.SubscriptionOffer {
    func toOffer() -> Offer {
        Offer(id: self.id,
              type: self.type.toOfferType(),
              displayPrice: self.displayPrice,
              price: self.price,
              paymentType: self.paymentMode.toOfferPaymentType(),
              periodCount: self.periodCount,
              periodUnit: self.period.unit.toOfferPeriodUnit())
    }
}

extension Product.SubscriptionOffer.PaymentMode {
    func toOfferPaymentType() -> Offer.PaymentType? {
        Offer.PaymentType(rawValue: self.rawValue)
    }
}

extension Product.SubscriptionOffer.OfferType {
    func toOfferType() -> Offer.Kind? {
        Offer.Kind(rawValue: self.rawValue)
    }
}

extension Product.SubscriptionPeriod.Unit {
    func toOfferPeriodUnit() -> Offer.PeriodUnit {
        switch self {
        case .day:
            return Offer.PeriodUnit.day
        case .week:
            return Offer.PeriodUnit.week
        case .month:
            return Offer.PeriodUnit.month
        case .year:
            return Offer.PeriodUnit.year
        @unknown default:
            return Offer.PeriodUnit.unknown
        }
    }
}
