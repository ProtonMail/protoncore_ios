//
//  PlansDataSource.swift
//  ProtonCorePayments - Created on 28.07.23.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.

import Foundation
import ProtonCoreServices
import Network

public protocol PlansDataSourceProtocol {
    var isIAPAvailable: Bool { get }
    var availablePlans: AvailablePlans? { get }
    var currentPlan: CurrentPlan? { get }
    var paymentMethods: [PaymentMethod]? { get }
    
    func fetchIAPAvailability() async throws
    func fetchAvailablePlans() async throws
    func fetchCurrentPlan() async throws
    func fetchPaymentMethods() async throws
    
    func willRenewAutomatically(plan: InAppPurchasePlan) -> Bool
}

class PlansDataSource: PlansDataSourceProtocol {
    var isIAPAvailable = false
    var availablePlans: AvailablePlans?
    var currentPlan: CurrentPlan?
    var paymentMethods: [PaymentMethod]?
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchIAPAvailability() async throws {
        let paymentStatusRequest = PaymentStatusRequest(api: apiService)
        let paymentStatusResponse = try await paymentStatusRequest.response(responseObject: PaymentStatusResponse())
        isIAPAvailable = paymentStatusResponse.isAvailable ?? false
    }
    
    func fetchAvailablePlans() async throws {
        let availablePlansRequest = AvailablePlansRequest(api: apiService)
        let availablePlansResponse = try await availablePlansRequest.response(responseObject: AvailablePlansResponse())
        availablePlans = availablePlansResponse.availablePlans
    }
    
    func fetchCurrentPlan() async throws {
        let currentPlanRequest = CurrentPlanRequest(api: apiService)
        let currentPlanResponse = try await currentPlanRequest.response(responseObject: CurrentPlanResponse())
        currentPlan = currentPlanResponse.currentPlan
    }
    
    func fetchPaymentMethods() async throws {
        let paymentMethodsRequest = MethodRequest(api: apiService)
        let paymentMethodsResponse = try await paymentMethodsRequest.response(responseObject: MethodResponse())
        paymentMethods = paymentMethodsResponse.methods
    }
    
    func willRenewAutomatically(plan: InAppPurchasePlan) -> Bool {
        guard let currentPlan = currentPlan else {
            return false
        }
        
        // Special coupon that will extend subscription
        if currentPlan.subscriptions.first?.renew ?? false {
            return true
        }
        
        // Has credit that will be used for renewal
        if hasEnoughCreditToExtendSubscription(plan: plan) {
            return true
        }
        
        return false
    }
    
    private func hasEnoughCreditToExtendSubscription(plan: InAppPurchasePlan) -> Bool {
        // TODO: Update once BE added Credit to the response.
        return false
    }
}
