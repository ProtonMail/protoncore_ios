//
//  PlansDataSourceMock.swift
//  ProtonCore-TestingToolkit - Created on 29.08.23.
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

public final class PlansDataSourceMock: NSObject, PlansDataSourceProtocol {

    @PropertyStub(\PlansDataSourceProtocol.isIAPAvailable, initialGet: false) public var isIAPAvailableStub
    public var isIAPAvailable: Bool {
        isIAPAvailableStub()
    }

    @PropertyStub(\PlansDataSourceProtocol.availablePlans, initialGet: nil) public var availablePlansStub
    public var availablePlans: AvailablePlans? {
        availablePlansStub()
    }

    @PropertyStub(\PlansDataSourceProtocol.currentPlan, initialGet: nil) public var currentPlanStub
    public var currentPlan: CurrentPlan? {
        currentPlanStub()
    }

    @PropertyStub(\PlansDataSourceProtocol.paymentMethods, initialGet: nil) public var paymentMethodsStub
    public var paymentMethods: [PaymentMethod]? {
        paymentMethodsStub()
    }

    @PropertyStub(\PlansDataSourceProtocol.willRenewAutomatically, initialGet: false) public var willRenewAutomaticallyStub
    public var willRenewAutomatically: Bool {
        willRenewAutomaticallyStub()
    }

    @PropertyStub(\PlansDataSourceProtocol.hasPaymentMethods, initialGet: false) public var hasPaymentMethodsStub
    public var hasPaymentMethods: Bool {
        hasPaymentMethodsStub()
    }

    @AsyncThrowingFuncStub(PlansDataSourceProtocol.fetchIAPAvailability) public var fetchIAPAvailabilityStub
    public func fetchIAPAvailability() async throws {
        try await fetchIAPAvailabilityStub()
    }

    @AsyncThrowingFuncStub(PlansDataSourceProtocol.fetchAvailablePlans) public var fetchAvailablePlansStub
    public func fetchAvailablePlans() async throws {
        try await fetchAvailablePlansStub()
    }

    @AsyncThrowingFuncStub(PlansDataSourceProtocol.fetchCurrentPlan) public var fetchCurrentPlanStub
    public func fetchCurrentPlan() async throws {
        try await fetchCurrentPlanStub()
    }

    @AsyncThrowingFuncStub(PlansDataSourceProtocol.fetchPaymentMethods) public var fetchPaymentMethodsStub
    public func fetchPaymentMethods() async throws {
        try await fetchPaymentMethodsStub()
    }

    @FuncStub(PlansDataSourceProtocol.createIconURL(iconName:), initialReturn: nil) public var createIconURLStub
    public func createIconURL(iconName: String) -> URL? {
        createIconURLStub(iconName)
    }

    @FuncStub(PlansDataSourceProtocol.detailsOfAvailablePlanCorrespondingToIAP, initialReturn: nil)
    public var detailsOfAvailablePlanCorrespondingToIAPStub
    public func detailsOfAvailablePlanCorrespondingToIAP(
        _ iap: ProtonCorePayments.InAppPurchasePlan
    ) -> ProtonCorePayments.AvailablePlans.AvailablePlan? {
        detailsOfAvailablePlanCorrespondingToIAPStub(iap)
    }

    @FuncStub(PlansDataSourceProtocol.detailsOfAvailablePlanInstanceCorrespondingToIAP, initialReturn: nil)
    public var detailsOfAvailablePlanInstanceCorrespondingToIAPStub
    public func detailsOfAvailablePlanInstanceCorrespondingToIAP(
        _ iap: ProtonCorePayments.InAppPurchasePlan
    ) -> ProtonCorePayments.AvailablePlans.AvailablePlan.Instance? {
        detailsOfAvailablePlanInstanceCorrespondingToIAPStub(iap)
    }
}
