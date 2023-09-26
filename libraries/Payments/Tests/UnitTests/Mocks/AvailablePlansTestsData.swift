//
//  AvailablePlansTestsData.swift
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

var availablePlansResponse: [String: Any] {
    [
        "Plans": [
            [
                "ID": "ID 1",
                "Name": "name 1",
                "Title": "title 1",
                "State": 1,
                "Type": 1,
                "Description": "description 1",
                "Features": 1,
                "Layout": "default",
                "Instances": [
                    [
                        "Cycle": 1,
                        "Description": "description 1",
                        "PeriodEnd": 1691915780,
                        "Price": [
                            ["current": 1, "default": 1, "currency": "USD"]
                        ],
                        "Vendors": [
                            "Apple": [
                                "ProductID": "apple id 1"
                            ],
                        ]
                    ]
                ],
                "Entitlements": [
                    [
                        "Type": "description",
                        "IconName": "icon 1",
                        "Text": "text 1",
                        "Hint": "hint"
                    ]
                ],
                "Decorations": [
                    [
                        "Type": "starred",
                        "IconName": "<base64>"
                    ],
                    [
                        "Type": "border",
                        "Color": "#xxx"
                    ]
                ]
            ],
            [
                "ID": "ID 2",
                "Name": "name 2",
                "Title": "title 2",
                "State": 2,
                "Type": 2,
                "Description": "description 2",
                "Features": 2,
                "Layout": "default",
                "Instances": [
                    [
                        "Cycle": 2,
                        "Description": "description 2",
                        "PeriodEnd": 1691915780,
                        "Price": [
                            ["currency": "USD", "current": 2, "default": 2]
                        ]
                    ]
                ],
                "Entitlements": [],
                "Decorations": []
            ]
        ]
    ]
}

var availablePlansToCompare: AvailablePlans {
    .init(
        plans: [
            .init(
                ID: "ID 1",
                name: "name 1",
                title: "title 1",
                description: "description 1",
                instances: [
                    .init(
                        cycle: 1,
                        description: "description 1",
                        periodEnd: 1691915780,
                        price: [.init(current: 1, default: 1, currency: "USD")],
                        vendors: .init(apple: .init(productID: "apple id 1"))
                    )
                ],
                entitlements: [
                    .description(
                        .init(
                            type: "description",
                            iconName: "icon 1",
                            text: "text 1",
                            hint: "hint"
                        )
                    )
                ],
                decorations: [
                    .starred(.init(
                        type: "starred",
                        iconName: "<base64>"
                    )),
                    .border(.init(
                        type: "border",
                        color: "#xxx"
                    ))
                ]
            ),
            .init(
                ID: "ID 2",
                name: "name 2",
                title: "title 2",
                description: "description 2",
                instances: [
                    .init(
                        cycle: 2,
                        description: "description 2",
                        periodEnd: 1691915780,
                        price: [.init(current: 2, default: 2, currency: "USD")]
                    )
                ],
                entitlements: [],
                decorations: []
            )
        ]
    )
}
