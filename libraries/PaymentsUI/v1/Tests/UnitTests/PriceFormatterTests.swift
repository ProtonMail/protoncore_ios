//
//  PriceFormatterTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 29.08.23.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import XCTest
@testable import ProtonCorePaymentsUI

final class PriceFormatterTests: XCTestCase {
    func test_priceFormatter_twoDecimals() {
        // Given
        let price = PriceFormatter.formatPlanPrice(price: 12, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(price, "$12.00")
    }

    func test_priceFormatter_noDecimal() {
        // Given
        let price = PriceFormatter.formatPlanPrice(price: 0, locale: Locale(identifier: "en_US"), maximumFractionDigits: 0)
        XCTAssertEqual(price, "$0")
    }
}
