//
//  PaymentStatusRequest.swift
//  ProtonCore-Payments - Created on 2/12/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
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

public struct IAPStatus: Decodable {
    /* Sample V6 response
     {
       "Code": 1000,
       "Location": {
         "CountryCode": "LT",
         "State": null,
         "ZipCode": null
       },
       "PaymentMethods": {
         "Bitcoin": {
           "State": 0,
           "Reason": null
         },
         "Card": {
           "State": 0,
           "Reason": null
         },
         "InApp": {
           "State": 1,
           "Reason": null
         },
         "Paypal": {
           "State": 0,
           "Reason": null
         }
       }
     }
     */

    var isAvailable: Bool
    var unavailabilityReason: String?

    public var status: IAPSupportStatusV2 {
        guard isAvailable else { return .disabled(localizedReason: unavailabilityReason) }
        return .enabled
    }

    enum CodingKeys: CodingKey {
        case paymentMethods
    }

    struct PaymentMethods: Decodable {
        var inApp: InApp?

        struct InApp: Decodable {
            var state: Int?
            var reason: String?
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paymentMethods = try container.decodeIfPresent(PaymentMethods.self, forKey: .paymentMethods)
        // Value can be 0 or 1, values > 1 are reserved for future use.
        // For now we will assume that such values mean it is disabled.
        self.isAvailable = paymentMethods?.inApp?.state == 1
        self.unavailabilityReason = paymentMethods?.inApp?.reason
    }
}
