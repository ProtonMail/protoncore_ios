//
//  PlansData.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25/06/2021.
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

import ProtonCore_Payments
import ProtonCore_TestingToolkit
@testable import ProtonCore_PaymentsUI

final class PlansData {

    struct DateData {
        let endDate: Date
        let endDateString: String
    }

    static func getEndDate(component: Calendar.Component, value: Int) -> DateData {
        let today = Date()
        let date = Calendar.current.date(byAdding: component, value: value, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let endDateString = dateFormatter.string(from: date)
        return DateData(endDate: date, endDateString: endDateString)
    }
}
