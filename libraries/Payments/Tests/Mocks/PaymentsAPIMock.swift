//
//  PaymentsApiMock.swift
//  ProtonCore-Payments-Tests - Created on 07/09/2021.
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

import Foundation
import ProtonCore_DataModel
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_Payments

final class PaymentsApiMock: PaymentsApiProtocol {
    
    static var usePathsWithoutV4PrefixInitialFixture = false
    
    @PropertyStub(\PaymentsApiMock.usePathsWithoutV4Prefix, initialGet: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) var usePathsWithoutV4PrefixStub
    var usePathsWithoutV4Prefix: Bool { usePathsWithoutV4PrefixStub() }

    @FuncStub(PaymentsApiProtocol.statusRequest, initialReturn: { StatusRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var statusRequestStub
    func statusRequest(api: APIService) -> StatusRequest { statusRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.methodsRequest, initialReturn: { MethodsRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var methodsRequestStub
    func methodsRequest(api: APIService) -> MethodsRequest { methodsRequestStub(api) }

    @ThrowingFuncStub(PaymentsApiProtocol.buySubscriptionRequest, initialReturn: { SubscriptionRequest(api: $0.0, planId: $0.1, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var buySubscriptionRequestStub
    func buySubscriptionRequest(
        api: APIService, planId: String, amount: Int, amountDue: Int, paymentAction: PaymentAction
    ) throws -> SubscriptionRequest { try buySubscriptionRequestStub(api, planId, amount, amountDue, paymentAction) }

    @FuncStub(PaymentsApiProtocol.buySubscriptionForZeroRequest, initialReturn: { SubscriptionRequest(api: $0.0, planId: $0.1, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var buySubscriptionForZeroRequestStub
    func buySubscriptionForZeroRequest(api: APIService, planId: String) -> SubscriptionRequest { buySubscriptionForZeroRequestStub(api, planId) }

    @FuncStub(PaymentsApiProtocol.getSubscriptionRequest, initialReturn: { GetSubscriptionRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var getSubscriptionRequestStub
    func getSubscriptionRequest(api: APIService) -> GetSubscriptionRequest { getSubscriptionRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.organizationsRequest, initialReturn: { OrganizationsRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var organizationsRequestStub
    func organizationsRequest(api: APIService) -> OrganizationsRequest { organizationsRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.defaultPlanRequest, initialReturn: { DefaultPlanRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var defaultPlanRequestStub
    func defaultPlanRequest(api: APIService) -> DefaultPlanRequest { defaultPlanRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.defaultPlansLegacyRequest, initialReturn: { DefaultPlansLegacyRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var defaultPlansLegacyRequestStub
    func defaultPlansLegacyRequest(api: APIService) -> DefaultPlansLegacyRequest { defaultPlansLegacyRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.plansRequest, initialReturn: { PlansRequest(api: $0, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var plansRequestStub
    func plansRequest(api: APIService) -> PlansRequest { plansRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.creditRequest, initialReturn: { CreditRequest<CreditResponse>(api: $0.0, amount: $0.1, paymentAction: $0.2, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var creditRequestStub
    func creditRequest(api: APIService, amount: Int, paymentAction: PaymentAction) -> CreditRequest<CreditResponse> {
        creditRequestStub(api, amount, paymentAction)
    }

    @FuncStub(PaymentsApiProtocol.tokenRequest, initialReturn: { TokenRequest(api: $0.0, amount: $0.1, receipt: $0.2, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var tokenRequestStub
    func tokenRequest(api: APIService, amount: Int, receipt: String) -> TokenRequest { tokenRequestStub(api, amount, receipt) }

    @FuncStub(PaymentsApiProtocol.tokenStatusRequest, initialReturn: { TokenStatusRequest(api: $0.0, token: $0.1, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var tokenStatusRequestStub
    func tokenStatusRequest(api: APIService, token: PaymentToken) -> TokenStatusRequest { tokenStatusRequestStub(api, token) }

    @FuncStub(PaymentsApiProtocol.validateSubscriptionRequest, initialReturn: { ValidateSubscriptionRequest(api: $0.0, protonPlanName: $0.1, isAuthenticated: $0.2, usePathsWithoutV4Prefix: PaymentsApiMock.usePathsWithoutV4PrefixInitialFixture) }) var validateSubscriptionRequestStub
    func validateSubscriptionRequest(api: APIService, protonPlanName: String, isAuthenticated: Bool) -> ValidateSubscriptionRequest {
        validateSubscriptionRequestStub(api, protonPlanName, isAuthenticated)
    }

    @FuncStub(PaymentsApiProtocol.getUser) var getUserStub
    func getUser(api: APIService, completion: @escaping (Result<User, Error>) -> Void) { getUserStub(api, completion) }
}
