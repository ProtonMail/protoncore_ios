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
        "Subscription": [
            "Name": "name",
            "Description": "Current plan",
            "ID": "6opBd5UdUtY_RtEz...YA==",
            "ParentMetaPlanID": "hUcV0_EeNw...g==",
            "Type": 1,
            "Title": "Visionary",
            "Cycle": 12,
            "CycleDescription": "1 year",
            "Currency": "USD",
            "Amount": 28788,
            "Offer": "default",
            "Quantity": 1,
            "PeriodStart": 1665402858,
            "PeriodEnd": 1696938858,
            "CreateTime": 1570708458,
            "CouponCode": "PROTONTEAM",
            "Discount": -28788,
            "RenewDiscount": -28788,
            "RenewAmount": 0,
            "Renew": 1,
            "External": 0,
            "Entitlements": [
                [
                    "Type": "Storage",
                    "Max": 1024,
                    "Current": 512
                ],
                [
                    "Type": "Description",
                    "Text": "500 GB storage",
                    "Icon": "http://.../blah.svg",
                    "Hint": "You win a lot of storage"
                ]
            ],
            "Decorations": [
                [
                    "Type": "Star",
                    "Icon": "<base64>"
                ],
                [
                    "Type": "Border",
                    "Color": "#xxx"
                ]
            ]
        ]
    ]
}

var currentPlanToCompare: CurrentPlan {
    .init(
        code: 1000,
        subscription: .init(
            name: "name",
            description: "Current plan",
            ID: "6opBd5UdUtY_RtEz...YA==",
            parentMetaPlanID: "hUcV0_EeNw...g==",
            type: 1,
            title: "Visionary",
            cycle: 12,
            cycleDescription: "1 year",
            currency: "USD",
            amount: 28788,
            offer: "default",
            quantity: 1,
            periodStart: 1665402858,
            periodEnd: 1696938858,
            createTime: 1570708458,
            couponCode: "PROTONTEAM",
            discount: -28788,
            renewDiscount: -28788,
            renewAmount: 0,
            renew: 1,
            external: 0,
            entitlements: [
                .storage(.init(type: "Storage", max: 1024, current: 512)),
                .description(.init(type: "Description", text: "500 GB storage", icon: "http://.../blah.svg", hint: "You win a lot of storage"))
            ],
            decorations: [
                .init(type: "Star", icon: "<base64>"),
                .init(type: "Border", color: "#xxx")
            ]
        )
    )
}
