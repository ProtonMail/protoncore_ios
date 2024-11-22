//
//  Formatter.swift
//  ProtonCoreUI - Created on 7/11/2024.
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

public enum DateFormatterType: String {
    case MMddYYYY = "MMM dd, YYYY"
}

public struct Formatter {

    // Date formatter
    public static func formatDate(_ timeStamp: Double, formatType: DateFormatterType) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatType.rawValue

        return dateFormatter.string(from: date)
    }

    // Currency formatter
    public static func formatCurrency(amount: Int?, currency: String?) -> String {
        guard let amount = amount, let currency = currency else {
            return ""
        }

        return Decimal(Double(amount) / 100).formatted(.currency(code: currency).presentation(.narrow).rounded())
    }
}
