//
//  CurrentPlan+Fixture.swift
//  ProtonCore-TestingToolkit - Created on 08/09/2023.
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
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import ProtonCorePayments

public extension CurrentPlan {
    static var dummy: CurrentPlan {
        CurrentPlan(
            subscriptions: [.init(title: "dummy", name: "dummy", description: "dummy", amount: 1500, entitlements: [])]
        )
    }

    func updated(subscriptions: [Subscription]? = nil) -> CurrentPlan {
        CurrentPlan(subscriptions: subscriptions ?? self.subscriptions)
    }
}
