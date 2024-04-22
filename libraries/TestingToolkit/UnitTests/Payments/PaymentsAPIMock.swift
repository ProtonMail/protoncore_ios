//
//  PaymentsApiMock.swift
//  ProtonCore-Payments-Tests - Created on 07/09/2021.
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
import ProtonCoreDataModel
import ProtonCoreServices
@testable import ProtonCorePayments

public final class PaymentsApiMock: PaymentsApiProtocol {
    public init() { }

    @FuncStub(PaymentsApiProtocol.paymentStatusRequest, initialReturn: { V5PaymentStatusRequest(api: $0) }) public var paymentStatusRequestStub
    public func paymentStatusRequest(api: APIService) -> PaymentStatusRequest {
        paymentStatusRequestStub(api)
    }

    @ThrowingFuncStub(PaymentsApiProtocol.buySubscriptionRequest, initialReturn: {
        V5SubscriptionRequest(api: $0.0, planName: $0.1.planName)
    }) public var buySubscriptionRequestStub
    public func buySubscriptionRequest(
        api: APIService, plan: PlanToBeProcessed, amountDue: Int, paymentAction: PaymentAction, isCreditingAllowed: Bool
    ) throws -> SubscriptionRequest { try buySubscriptionRequestStub(api, plan, amountDue, paymentAction, isCreditingAllowed) }

    @FuncStub(PaymentsApiProtocol.buySubscriptionForZeroRequest, initialReturn: {
        V5SubscriptionRequest(api: $0.0, planName: $0.1.planName)
    }) public var buySubscriptionForZeroRequestStub
    public func buySubscriptionForZeroRequest(api: APIService, plan: PlanToBeProcessed) -> SubscriptionRequest { buySubscriptionForZeroRequestStub(api, plan) }

    @FuncStub(PaymentsApiProtocol.getSubscriptionRequest, initialReturn: { V5GetSubscriptionRequest(api: $0) }) public var getSubscriptionRequestStub
    public func getSubscriptionRequest(api: APIService) -> GetSubscriptionRequest { getSubscriptionRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.organizationsRequest, initialReturn: { OrganizationsRequest(api: $0) }) public var organizationsRequestStub
    public func organizationsRequest(api: APIService) -> OrganizationsRequest { organizationsRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.defaultPlanRequest, initialReturn: { V5DefaultPlanRequest(api: $0) }) public var defaultPlanRequestStub
    public func defaultPlanRequest(api: APIService) -> DefaultPlanRequest { defaultPlanRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.plansRequest, initialReturn: { V5PlansRequest(api: $0) }) public var plansRequestStub
    public func plansRequest(api: APIService) -> PlansRequest { plansRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.creditRequest, initialReturn: { CreditRequest(api: $0.0, amount: $0.1, paymentAction: $0.2) }) public var creditRequestStub
    public func creditRequest(api: APIService, amount: Int, paymentAction: PaymentAction) -> CreditRequest {
        creditRequestStub(api, amount, paymentAction)
    }

    @FuncStub(PaymentsApiProtocol.methodsRequest, initialReturn: { V5MethodRequest(api: $0) }) public var methodsRequestStub
    public func methodsRequest(api: APIService) -> MethodRequest { methodsRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.paymentTokenOldRequest, initialReturn: { PaymentTokenOldRequest(api: $0.0, amount: $0.1, receipt: $0.2) }) public var paymentTokenOldRequestStub
    public func paymentTokenOldRequest(api: APIService, amount: Int, receipt: String) -> PaymentTokenOldRequest { paymentTokenOldRequestStub(api, amount, receipt) }

    @FuncStub(PaymentsApiProtocol.paymentTokenRequest, initialReturn: { PaymentTokenRequest(api: $0.0, amount: $0.1, receipt: $0.2, transactionId: $0.3, bundleId: $0.4, productId: $0.5) }) public var paymentTokenRequestStub
    public func paymentTokenRequest(api: APIService, amount: Int, receipt: String, transactionId: String, bundleId: String, productId: String) -> PaymentTokenRequest { paymentTokenRequestStub(api, amount, receipt, transactionId, bundleId, productId) }

    @FuncStub(PaymentsApiProtocol.paymentTokenStatusRequest, initialReturn: { V5PaymentTokenStatusRequest(api: $0.0, token: $0.1) }) public var paymentTokenStatusRequestStub
    public func paymentTokenStatusRequest(api: APIService, token: PaymentToken) -> PaymentTokenStatusRequest { paymentTokenStatusRequestStub(api, token) }

    @FuncStub(PaymentsApiProtocol.validateSubscriptionRequest, initialReturn: { V5ValidateSubscriptionRequest(api: $0.0, protonPlanName: $0.1, isAuthenticated: $0.2, cycle: $0.3) }) public var validateSubscriptionRequestStub
    public func validateSubscriptionRequest(api: APIService, protonPlanName: String, isAuthenticated: Bool, cycle: Int) -> ValidateSubscriptionRequest {
        validateSubscriptionRequestStub(api, protonPlanName, isAuthenticated, cycle)
    }

    @FuncStub(PaymentsApiProtocol.countriesCountRequest, initialReturn: { CountriesCountRequest(api: $0) }) public var countriesCountRequestStub
    public func countriesCountRequest(api: APIService) -> CountriesCountRequest {
        countriesCountRequestStub(api)
    }

    @ThrowingFuncStub(PaymentsApiProtocol.getUser, initialReturn: .crash) public var getUserStub
    public func getUser(api: APIService) throws -> User { try getUserStub(api) }
}
