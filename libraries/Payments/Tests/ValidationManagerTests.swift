//
//  ValidationManagerTests.swift
//  ProtonCore-Payments-Tests - Created on 16/03/2021.
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

import XCTest
import StoreKit

import PromiseKit
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Payments
import ProtonCore_TestingToolkit

final class ValidationManagerTests: XCTestCase {

    func testPurchaseValidationFailForUnknownProduct() {
        // given
        let dependencies = ValidationManagerDependenciesMock()
        dependencies.productsStub.fixture = []
        let out = ValidationManager(dependencies: dependencies)

        // when
        let result = out.canPurchaseProduct(storeKitProductId: "test_storeKitProductId")
        let isValid = out.isValidPurchase(storeKitProductId: "test_storeKitProductId")

        // then
        guard case .failure(StoreKitManagerErrors.unavailableProduct) = result else { XCTFail(); return }
        XCTAssertFalse(isValid)
    }

    func testPurchaseValidationFailsIfUserHasExistingSubscription() {
        // given
        let dependencies = ValidationManagerDependenciesMock()
        dependencies.productsStub.fixture = [
            SKProduct(identifier: "test_storeKitProductId", price: "0.0", priceLocale: Locale(identifier: "en_US"))
        ]
        let planService = ServicePlanDataServiceMock()
        planService.currentSubscriptionStub.fixture = Subscription.dummy
            .updated(planDetails: [Plan.dummy.updated(name: "test_plan")])
        dependencies.planServiceStub.fixture = planService
        let out = ValidationManager(dependencies: dependencies)

        // when
        let result = out.canPurchaseProduct(storeKitProductId: "test_storeKitProductId")
        let isValid = out.isValidPurchase(storeKitProductId: "test_storeKitProductId")

        // then
        guard case .failure(StoreKitManagerErrors.invalidPurchase) = result else { XCTFail(); return }
        XCTAssertFalse(isValid)
    }

    func testPurchaseIsValid() {
        // given
        let dependencies = ValidationManagerDependenciesMock()
        let testProduct = SKProduct(identifier: "test_storeKitProductId", price: "0.0", priceLocale: Locale(identifier: "en_US"))
        dependencies.productsStub.fixture = [testProduct]
        let planService = ServicePlanDataServiceMock()
        planService.currentSubscriptionStub.fixture = .dummy
        dependencies.planServiceStub.fixture = planService
        let out = ValidationManager(dependencies: dependencies)

        // when
        let result = out.canPurchaseProduct(storeKitProductId: "test_storeKitProductId")
        let isValid = out.isValidPurchase(storeKitProductId: "test_storeKitProductId")

        // then
        guard isValid, case .success(let product) = result else { XCTFail(); return }
        XCTAssertEqual(product, testProduct)
    }
}
