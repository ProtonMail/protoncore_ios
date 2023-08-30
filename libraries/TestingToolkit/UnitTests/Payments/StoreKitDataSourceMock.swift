//
//  StoreKitManagerMock.swift
//  ProtonCore-TestingToolkit - Created on 07/09/2021.
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
import StoreKit
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import ProtonCorePayments

public final class StoreKitDataSourceMock: NSObject, StoreKitDataSourceProtocol {

    override public init() {}

    @PropertyStub(\StoreKitDataSourceProtocol.availableProducts, initialGet: .crash) public var availableProductsStub
    public var availableProducts: [SKProduct] {
        availableProductsStub()
    }
    
    @PropertyStub(\StoreKitDataSourceProtocol.unavailableProductsIdentifiers, initialGet: .crash) public var unavailableProductsIdentifiersStub
    public var unavailableProductsIdentifiers: [String] {
        unavailableProductsIdentifiersStub()
    }
    
    @AsyncThrowingFuncStub(StoreKitDataSourceProtocol.fetchAvailableProducts(availablePlans:)) public var fetchAvailableProductsForPlansStub
    public func fetchAvailableProducts(availablePlans: AvailablePlans) async throws {
        try await fetchAvailableProductsForPlansStub(availablePlans)
    }
    
    @AsyncThrowingFuncStub(StoreKitDataSourceProtocol.fetchAvailableProducts(productIdentifiers:)) public var fetchAvailableProductsForIdentifiersStub
    public func fetchAvailableProducts(productIdentifiers: Set<String>) async throws {
        try await fetchAvailableProductsForIdentifiersStub(productIdentifiers)
    }
    
    @FuncStub(StoreKitDataSourceProtocol.filterAccordingToAvailableProducts, initialReturn: .crash) public var filterAccordingToAvailableProductsStub
    public func filterAccordingToAvailableProducts(availablePlans: AvailablePlans) -> AvailablePlans {
        filterAccordingToAvailableProductsStub(availablePlans)
    }
}
