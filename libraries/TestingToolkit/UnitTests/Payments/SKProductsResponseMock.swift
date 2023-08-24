//
//  SKProductsResponseMock.swift
//  ProtonCore-TestingToolkit - Created on 21/12/2020.
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
#else
import ProtonCoreTestingToolkit
#endif
import StoreKit

public class SKProductsResponseMock: SKProductsResponse {
    @PropertyStub(\SKProductsResponse.products, initialGet: []) public var productsStub
    override public var products: [SKProduct] { productsStub() }

    @PropertyStub(\SKProductsResponse.invalidProductIdentifiers, initialGet: []) public var invalidProductIdentifiersStub
    override public var invalidProductIdentifiers: [String] { invalidProductIdentifiersStub() }
}
