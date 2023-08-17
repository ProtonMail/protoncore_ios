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
        "Code": 1000,
        "Plans": [
            [
                "Instances": [
                    [
                        "Month": 1,
                        "ID": "id 1",
                        "Description": "description 1",
                        "PeriodEnd": 1691915780,
                        "Price": [
                            ["currency": "EUR", "current": 1, "default": 1]
                        ],
                        "Vendors": [
                            "Google": [
                                "ID": "google id 1",
                                "CustomerID": "google customer id 1"
                            ],
                            "Apple": [
                                "ID": "apple id 1",
                                "CustomerID": "apple customer id 1"
                            ],
                        ]
                    ]
                ],
                "Type": 1,
                "Name": "name 1",
                "Title": "title 1",
                "State": 1,
                "Entitlements": [
                    [
                        "Type": "type 1",
                        "Text": "text 1",
                        "Icon": "icon 1",
                        "Hint": nil
                    ]
                ],
                "Offers": [
                    [
                        "Name": "name 1",
                        "StartTime": 1584763447,
                        "EndTime": 1700063447,
                        "Months": 1,
                        "Price": [
                            ["Currency": "USD", "Current": 1],
                            ["Currency": "EUR", "Current": 2],
                            ["Currency": "CHF", "Current": 3]
                        ]
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
            ],
            [
                "Instances": [
                    [
                        "Month": 2,
                        "ID": "id 2",
                        "Description": "description 2",
                        "PeriodEnd": 1691915780,
                        "Price": [
                            ["currency": "USD", "current": 2, "default": 2]
                        ]
                    ]
                ],
                "Type": 2,
                "Name": "name 2",
                "Title": "title 2",
                "State": 2,
                "Entitlements": [],
                "Decorations": [
                    [
                        "Type": "Star"
                    ]
                ]
            ]
        ]
    ]
}

var availablePlansToCompare: AvailablePlans {
    .init(
        code: 1000,
        plans: [
            .init(
                instances: [
                    .init(
                        month: 1,
                        ID: "id 1",
                        description: "description 1",
                        periodEnd: 1691915780,
                        price: [
                            .init(currency: "EUR", current: 1, default: 1)
                        ],
                        vendors: .init(
                            google: .init(
                                ID: "google id 1",
                                customerID: "google customer id 1"
                            ),
                            apple: .init(
                                ID: "apple id 1",
                                customerID: "apple customer id 1"
                            )
                        )
                    )
                ],
                type: 1,
                name: "name 1",
                title: "title 1",
                state: 1,
                entitlements: [
                    .init(
                        type: "type 1",
                        text: "text 1",
                        icon: "icon 1"
                    )
                ],
                offers: [
                    .init(
                        name: "name 1",
                        startTime: 1584763447,
                        endTime: 1700063447,
                        months: 1,
                        price: [
                            .init(currency: "USD", current: 1),
                            .init(currency: "EUR", current: 2),
                            .init(currency: "CHF", current: 3)
                        ]
                    )
                ],
                decorations: [
                    .init(
                        type: "Star",
                        icon: "<base64>"
                    ),.init(
                        type: "Border",
                        color: "#xxx"
                    )
                ]
            ),
            .init(
                instances: [
                    .init(
                        month: 2,
                        ID: "id 2",
                        description: "description 2",
                        periodEnd: 1691915780,
                        price: [
                            .init(currency: "USD", current: 2, default: 2)
                        ]
                    )
                ],
                type: 2,
                name: "name 2",
                title: "title 2",
                state: 2,
                entitlements: [],
                decorations: [
                    .init(type: "Star")
                ]
            )
        ]
    )
}
