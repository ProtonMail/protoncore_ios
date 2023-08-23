//
//  SKRequestMock.swift
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
#endif
import StoreKit

public class SKRequestMock: SKProductsRequest {

    @PropertyStub(\SKRequestMock.delegate, initialGet: nil) public var delegateStub
    public override var delegate: SKProductsRequestDelegate? {
        get { delegateStub() }
        set { delegateStub(newValue) }
    }

    @FuncStub(SKRequestMock.start) public var startStub
    public override func start() { startStub() }
}

public extension SKProduct {
    convenience init(identifier: String, price: String, priceLocale: Locale) {
        self.init()
        self.setValue(identifier, forKey: "productIdentifier")
        self.setValue(NSDecimalNumber(string: price), forKey: "price")
        self.setValue(priceLocale, forKey: "priceLocale")
    }
}
