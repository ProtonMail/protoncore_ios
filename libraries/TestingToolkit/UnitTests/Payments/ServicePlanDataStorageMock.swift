//
//  ServicePlanDataStorageMock.swift
//  ProtonCore-TestingToolkit - Created on 09/09/2021.
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
import ProtonCorePayments

public final class ServicePlanDataStorageMock: ServicePlanDataStorage {
    
    public init() {}

    @PropertyStub(\ServicePlanDataStorage.servicePlansDetails, initialGet: nil) public var servicePlansDetailsStub
    public var servicePlansDetails: [Plan]? { get { servicePlansDetailsStub() } set { servicePlansDetailsStub(newValue) } }

    @PropertyStub(\ServicePlanDataStorage.paymentsBackendStatusAcceptsIAP, initialGet: true) public var paymentsBackendStatusAcceptsIAPStub
    public var paymentsBackendStatusAcceptsIAP: Bool { get { paymentsBackendStatusAcceptsIAPStub() } set { paymentsBackendStatusAcceptsIAPStub(newValue) } }

    @PropertyStub(\ServicePlanDataStorage.defaultPlanDetails, initialGet: nil) public var defaultPlanDetailsStub
    public var defaultPlanDetails: Plan? { get { defaultPlanDetailsStub() } set { defaultPlanDetailsStub(newValue) } }

    @PropertyStub(\ServicePlanDataStorage.currentSubscription, initialGet: nil) public var currentSubscriptionStub
    public var currentSubscription: Subscription? { get { currentSubscriptionStub() } set { currentSubscriptionStub(newValue) } }

    @PropertyStub(\ServicePlanDataStorage.credits, initialGet: nil) public var creditsStub
    public var credits: Credits? { get { creditsStub() } set { creditsStub(newValue) } }
    
    @PropertyStub(\ServicePlanDataStorage.paymentMethods, initialGet: nil) public var paymentMethodsStub
    public var paymentMethods: [PaymentMethod]? { get { paymentMethodsStub() } set { paymentMethodsStub(newValue) } }
}
