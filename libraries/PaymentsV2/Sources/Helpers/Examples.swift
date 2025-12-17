//
//  AvailablePlansExample.swift
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

#if DEBUG
public struct Examples {
    public static func availablePlanExample(
        title: String = "VPN Plus",
        cycle: Int = 1,
        entitlements: [Entitlement] = [
            .description(
                DescriptionEntitlement(
                    type: "description",
                    text: "10 VPN connections",
                    iconName: "shield"
                )
            ),
            .progress(
                ProgressEntitlement(
                    title: "Mail storage",
                    type: "progress",
                    text: "0.6 GB of 1 GB",
                    min: 0,
                    max: 10,
                    current: 6
                )
            )
        ],
        decorations: [Decoration] = [
            Decoration.starred(
                StarredDecoration(
                    type: "Star",
                    iconName: "star"
                )
            )
        ]
    ) -> AvailablePlan {
        .init(
            description: "Your privacy and security are our priority.",
            instances: [
                PlanInstance(
                    price: [
                        Price(
                            current: 999,
                            currency: "USD",
                            ID: "Rzo-ImiH-Y_v4CHXZw9hziBBC1zJGiRh86ZS5nSNNMnr179sULuJ7vTQbNKZfhjfimTQRqUowgb4GInUiaAFWQ=="
                        ),
                        Price(
                            current: 999,
                            currency: "EUR",
                            ID: "S-LQ3cqc5zSDnSWqQHR62CoBS0VE5Epd7Ngn9WO04S0PScm4hT16Y8vHj500TumvpEjoP8nRrMGUcscA2do2Nw=="
                        ),
                        Price(
                            current: 999,
                            currency: "CHF",
                            ID: "Sblu7zv6eRFqkl6B4JA4Ycet61lC25U-hVx6JMeNknCKPwE6LKh1eLO9WvCXj4_5YP3IRtVhoCrvAxObwI3LvQ=="
                        )
                    ],
                    description: cycle == 1 ? "Per month" : "A year",
                    cycle: cycle,
                    periodEnd: 1725207962,
                    vendors: Vendors(
                        apple: Vendor(
                            productID: "iosvpn_vpn2022_1_usd_auto_renewing",
                            customerID: nil
                        )
                    )
                )
            ],
             name: "vpn2022",
             state: 1,
             title: title,
             features: 0,
             entitlements: entitlements,
             decorations: decorations,
             ID: "q6fRrEIn0nyJBE_-YSIiVf80M2VZhOuUHW5In4heCyOdV_nGibV38tK76fPKm7lTHQLcDiZtEblk0t55wbuw4w==",
             services: 4
        )
    }

    public static func planInstance(
        productID: String = "iosvpn_bundle2022_12_usd_auto_recurring",
        cycle: Int = 1
    ) -> PlanInstance {
        return PlanInstance(
            price: [
                Price(
                    current: 1000,
                    currency: "USD",
                    ID: "asdoijqowijd"
                )
            ],
            description: cycle == 1 ? "a month" : "for 1 year",
            cycle: cycle,
            periodEnd: 12,
            vendors: Vendors(
                apple: Vendor(
                    productID: productID,
                    customerID: "asd123APPLE"
                )
            )
        )

    }
}
#endif
