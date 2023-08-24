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
                "Name": "name 1",
                "Title": "title 1",
                "State": 1,
                "Type": 1,
                "Description": "description 1",
                "Features": 1,
                "Layout": "default",
                "Instances": [
                    [
                        "ID": "id 1",
                        "Cycle": 1,
                        "Description": "description 1",
                        "PeriodEnd": 1691915780,
                        "Price": [
                            ["current": 1, "default": 1]
                        ],
                        "Vendors": [
                            "Apple": [
                                "ID": "apple id 1"
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
                        "Type": "star",
                        "Icon": "<base64>"
                    ],
                    [
                        "Type": "border",
                        "Color": "#xxx"
                    ]
                ]
            ],
            [
                "Name": "name 2",
                "Title": "title 2",
                "State": 2,
                "Type": 2,
                "Description": "description 2",
                "Features": 2,
                "Layout": "default",
                "Instances": [
                    [
                        "ID": "id 2",
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
                name: "name 1",
                title: "title 1",
                state: 1,
                type: 1,
                description: "description 1",
                features: 1,
                layout: "default",
                instances: [
                    .init(
                        ID: "id 1",
                        cycle: 1,
                        description: "description 1",
                        periodEnd: 1691915780,
                        price: [.init(current: 1, default: 1)],
                        vendors: .init(apple: .init(ID: "apple id 1"))
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
                    .star(.init(
                        type: "star",
                        icon: "<base64>"
                    )),
                    .border(.init(
                        type: "border",
                        color: "#xxx"
                    ))
                ]
            ),
            .init(
                name: "name 2",
                title: "title 2",
                state: 2,
                type: 2,
                description: "description 2",
                features: 2,
                layout: "default",
                instances: [
                    .init(
                        ID: "id 2",
                        cycle: 2,
                        description: "description 2",
                        periodEnd: 1691915780,
                        price: [.init(current: 2, default: 2)]
                    )
                ],
                entitlements: [],
                decorations: []
            )
        ]
    )
}
