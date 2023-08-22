//
//  CurrentPlanTestsData.swift
//  ProtonCorePaymentsTests - Created on 03.08.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

@testable import ProtonCorePayments

var currentPlanResponse: [String: Any] {
    [
        "Code": 1000,
        "Subscriptions": [[
            "VendorName": "VendorName",
            "Title": "Title",
            "Description": "Description",
            "CycleDescription": "CycleDescription",
            "Currency": "Currency",
            "Amount": 28788,
            "PeriodEnd": 1696938858,
            "Renew": true,
            "External": 1,
            "Entitlements": [
                [
                    "Type": "progress",
                    "Text": "19.55 MB of 15 GB",
                    "Min": 0,
                    "Max": 1024,
                    "Current": 512
                ],
                [
                    "Type": "description",
                    "Text": "500 GB storage",
                    "IconName": "http://.../blah.svg",
                    "Hint": "You win a lot of storage"
                ]
            ]
        ]]
    ]
}

var currentPlanToCompare: CurrentPlan {
    .init(
        subscriptions: [.init(
            vendorName: "VendorName",
            title: "Title",
            description: "Description",
            cycleDescription: "CycleDescription",
            currency: "Currency",
            amount: 28788,
            periodEnd: 1696938858,
            renew: true,
            external: .apple,
            entitlements: [
                .progress(
                    .init(
                        type: "progress",
                        text: "19.55 MB of 15 GB",
                        min: 0,
                        max: 1024,
                        current: 512
                    )
                ),
                .description(
                    .init(
                        type: "description",
                        text: "500 GB storage",
                        iconName: "http://.../blah.svg",
                        hint: "You win a lot of storage"
                     )
                )
            ]
        )]
    )
}
