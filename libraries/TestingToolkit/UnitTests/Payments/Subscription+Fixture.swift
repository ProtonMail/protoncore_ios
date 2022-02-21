//
//  Subscription+Fixture.swift
//  ProtonCore-TestingToolkit - Created on 07/09/2021.
//
//  Copyright (c) 2020 Proton Technologies AG
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

import ProtonCore_Payments

public extension Subscription {

    static var dummy: Subscription {
        Subscription(start: nil, end: nil, planDetails: nil, couponCode: nil, cycle: nil, amount: nil, currency: nil)
    }

    func updated(start: Date? = nil,
                 end: Date? = nil,
                 planDetails: [Plan]? = nil,
                 couponCode: String? = nil,
                 cycle: Int? = nil,
                 amount: Int? = nil,
                 currency: String? = nil) -> Subscription {
        Subscription(start: start ?? self.start,
                     end: end ?? self.end,
                     planDetails: planDetails ?? self.planDetails,
                     couponCode: couponCode ?? self.couponCode,
                     cycle: cycle ?? self.cycle,
                     amount: amount ?? self.amount,
                     currency: currency ?? self.currency)
    }
}
