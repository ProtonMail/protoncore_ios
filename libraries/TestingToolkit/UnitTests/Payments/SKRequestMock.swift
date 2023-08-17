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

let inAppPurchaseList: Set<String> = Set([
    "test1", "test2", "test3", "test4", "test5"
].map { "ios_\($0)_12_abc_non_renewing" })

let pricesList: [String: String] = ["test1": "1", "test2": "2", "test3": "3", "test4": "4", "test5": "5"]

class SKRequestMock: SKProductsRequest {
    let productIdentifiers: Set<String>
    
    var locale = Locale(identifier: "en_US@currency=USDs")
    var prices: [String: String] = pricesList
    
    override init(productIdentifiers: Set<String> = inAppPurchaseList) {
        self.productIdentifiers = productIdentifiers
        super.init()
    }
    
    func setupPrices(locale: Locale = Locale(identifier: "en_US@currency=USDs"), prices: [String: String]) {
        self.locale = locale
        self.prices = prices
    }
    
    override func start() {
        var products: [SKProduct] = []
        productIdentifiers.forEach {
            var price = "60"
            if prices.count == productIdentifiers.count {
                price = prices[$0] ?? "60"
            }
            products += [SKProduct(identifier: $0, price: price, priceLocale: locale)]
        }
        let response = SKProductsResponseMock(products: products)
        delegate?.productsRequest(self, didReceive: response)
    }
}

public extension SKProduct {
    convenience init(identifier: String, price: String, priceLocale: Locale) {
        self.init()
        self.setValue(identifier, forKey: "productIdentifier")
        self.setValue(NSDecimalNumber(string: price), forKey: "price")
        self.setValue(priceLocale, forKey: "priceLocale")
    }
}
