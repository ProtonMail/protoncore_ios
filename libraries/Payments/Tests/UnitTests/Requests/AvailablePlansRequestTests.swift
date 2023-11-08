//
//  AvailablePlansRequestTests.swift
//  ProtonCorePaymentsTests - Created on 13.07.23.
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

import XCTest
@testable import ProtonCorePayments
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

final class AvailablePlansRequestTests: XCTestCase {
    var sut: AvailablePlansRequest!
    var apiService: APIServiceMock!

    override func setUp() {
        super.setUp()
        apiService = .init()
        sut = .init(api: apiService)
    }

    func test_availablePlans_path() {
        XCTAssertEqual(sut.path, "/payments/v5/plans")
    }
}
