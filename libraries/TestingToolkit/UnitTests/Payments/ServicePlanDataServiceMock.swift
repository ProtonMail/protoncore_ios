//
//  ServicePlanDataServiceMock.swift
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
import ProtonCore_Payments
import ProtonCore_Services
import ProtonCore_DataModel

public final class ServicePlanDataServiceMock: ServicePlanDataServiceProtocol {

    public init() {}

    @PropertyStub(\ServicePlanDataServiceProtocol.isIAPAvailable, initialGet: true) public var isIAPAvailableStub
    public var isIAPAvailable: Bool { isIAPAvailableStub() }

    @PropertyStub(\ServicePlanDataServiceProtocol.credits, initialGet: nil) public var creditsStub
    public var credits: Credits? { creditsStub() }
    
    @PropertyStub(\ServicePlanDataServiceProtocol.countriesCount, initialGet: nil) public var countriesCountStub
    public var countriesCount: [Countries]? { countriesCountStub() }
    
    @PropertyStub(\ServicePlanDataServiceProtocol.user, initialGet: nil) public var userStub
    public var user: User? { userStub() }
    
    @PropertyStub(\ServicePlanDataServiceProtocol.paymentMethods, initialGet: nil) public var paymentMethodsStub
    public var paymentMethods: [PaymentMethod]? { get { paymentMethodsStub() } set { paymentMethodsStub(newValue) } }

    @PropertyStub(\ServicePlanDataServiceProtocol.plans, initialGet: []) public var plansStub
    public var plans: [Plan] { plansStub() }

    @PropertyStub(\ServicePlanDataServiceProtocol.defaultPlanDetails, initialGet: nil) public var defaultPlanDetailsStub
    public var defaultPlanDetails: Plan? { defaultPlanDetailsStub() }

    @PropertyStub(\ServicePlanDataServiceProtocol.availablePlansDetails, initialGet: []) public var availablePlansDetailsStub
    public var availablePlansDetails: [Plan] { availablePlansDetailsStub() }

    @PropertyStub(\ServicePlanDataServiceProtocol.currentSubscription, initialGet: nil) public var currentSubscriptionStub
    public var currentSubscription: Subscription? { get { currentSubscriptionStub() } set { currentSubscriptionStub(newValue) } }

    @PropertyStub(\ServicePlanDataServiceProtocol.currentSubscriptionChangeDelegate, initialGet: nil) public var currentSubscriptionChangeDelegateStub
    public var currentSubscriptionChangeDelegate: CurrentSubscriptionChangeDelegate? {
        get { currentSubscriptionChangeDelegateStub() } set { currentSubscriptionChangeDelegateStub(newValue) }
    }

    @FuncStub(ServicePlanDataServiceProtocol.detailsOfServicePlan, initialReturn: nil) public var detailsOfServicePlanStub
    public func detailsOfServicePlan(named name: String) -> Plan? { detailsOfServicePlanStub(name) }

    @ThrowingFuncStub(ServicePlanDataServiceMock.updateServicePlans as (ServicePlanDataServiceMock) -> () throws -> Void) public var updateServicePlansStub
    public func updateServicePlans() throws {
        try updateServicePlansStub()
    }
    
    @FuncStub(ServicePlanDataServiceProtocol.updateServicePlans(callBlocksOnParticularQueue:success:failure:)) public var updateServicePlansSuccessFailureStub
    public func updateServicePlans(callBlocksOnParticularQueue: DispatchQueue?, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        updateServicePlansSuccessFailureStub(callBlocksOnParticularQueue, success, failure)
    }

    @FuncStub(ServicePlanDataServiceProtocol.updateCurrentSubscription) public var updateCurrentSubscriptionSuccessFailureStub
    public func updateCurrentSubscription(callBlocksOnParticularQueue: DispatchQueue?, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        updateCurrentSubscriptionSuccessFailureStub(callBlocksOnParticularQueue, success, failure)
    }

    @FuncStub(ServicePlanDataServiceProtocol.updateCredits) public var updateCreditsStub
    public func updateCredits(callBlocksOnParticularQueue: DispatchQueue?, success: @escaping () -> Void, failure: @escaping (Error) -> Void) { updateCreditsStub(callBlocksOnParticularQueue, success, failure) }
    
    @FuncStub(ServicePlanDataServiceProtocol.updateCountriesCount) public var updateCountriesCountStub
    public func updateCountriesCount(callBlocksOnParticularQueue: DispatchQueue?, success: @escaping () -> Void, failure: @escaping (Error) -> Void) { updateCountriesCountStub(callBlocksOnParticularQueue, success, failure) }

    @PropertyStub(\ServicePlanDataServiceProtocol.service, initialGet: .crash) public var serviceStub
    public var service: APIService { serviceStub() }
    
    @FuncStub(ServicePlanDataServiceProtocol.willRenewAutomatically, initialReturn: false) public var willRenewAutomaticallyStub
    public func willRenewAutomatically(plan: InAppPurchasePlan) -> Bool {
        willRenewAutomaticallyStub(plan) }
}
