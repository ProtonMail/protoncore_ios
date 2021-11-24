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

    @FuncStub(PaymentsApiProtocol.statusRequest, initialReturn: { StatusRequest(api: $0) }) var statusRequestStub
    func statusRequest(api: APIService) -> StatusRequest { statusRequestStub(api) }

    @ThrowingFuncStub(PaymentsApiProtocol.buySubscriptionRequest, initialReturn: { SubscriptionRequest(api: $0.0, planId: $0.1) }) var buySubscriptionRequestStub
    func buySubscriptionRequest(
        api: APIService, planId: String, amount: Int, amountDue: Int, paymentAction: PaymentAction
    ) throws -> SubscriptionRequest { try buySubscriptionRequestStub(api, planId, amount, amountDue, paymentAction) }

    @FuncStub(PaymentsApiProtocol.buySubscriptionForZeroRequest, initialReturn: { SubscriptionRequest(api: $0.0, planId: $0.1) }) var buySubscriptionForZeroRequestStub
    func buySubscriptionForZeroRequest(api: APIService, planId: String) -> SubscriptionRequest { buySubscriptionForZeroRequestStub(api, planId) }

    @FuncStub(PaymentsApiProtocol.getSubscriptionRequest, initialReturn: { GetSubscriptionRequest(api: $0) }) var getSubscriptionRequestStub
    func getSubscriptionRequest(api: APIService) -> GetSubscriptionRequest { getSubscriptionRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.organizationsRequest, initialReturn: { OrganizationsRequest(api: $0) }) var organizationsRequestStub
    func organizationsRequest(api: APIService) -> OrganizationsRequest { organizationsRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.defaultPlanRequest, initialReturn: { DefaultPlanRequest(api: $0) }) var defaultPlanRequestStub
    func defaultPlanRequest(api: APIService) -> DefaultPlanRequest { defaultPlanRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.plansRequest, initialReturn: { PlansRequest(api: $0) }) var plansRequestStub
    func plansRequest(api: APIService) -> PlansRequest { plansRequestStub(api) }

    @FuncStub(PaymentsApiProtocol.creditRequest, initialReturn: { CreditRequest<CreditResponse>(api: $0.0, amount: $0.1, paymentAction: $0.2) }) var creditRequestStub
    func creditRequest(api: APIService, amount: Int, paymentAction: PaymentAction) -> CreditRequest<CreditResponse> {
        creditRequestStub(api, amount, paymentAction)
    }

    @FuncStub(PaymentsApiProtocol.tokenRequest, initialReturn: { TokenRequest(api: $0.0, amount: $0.1, receipt: $0.2) }) var tokenRequestStub
    func tokenRequest(api: APIService, amount: Int, receipt: String) -> TokenRequest { tokenRequestStub(api, amount, receipt) }

    @FuncStub(PaymentsApiProtocol.tokenStatusRequest, initialReturn: { TokenStatusRequest(api: $0.0, token: $0.1) }) var tokenStatusRequestStub
    func tokenStatusRequest(api: APIService, token: PaymentToken) -> TokenStatusRequest { tokenStatusRequestStub(api, token) }

    @FuncStub(PaymentsApiProtocol.validateSubscriptionRequest, initialReturn: { ValidateSubscriptionRequest(api: $0.0, protonPlanName: $0.1, isAuthenticated: $0.2) }) var validateSubscriptionRequestStub
    func validateSubscriptionRequest(api: APIService, protonPlanName: String, isAuthenticated: Bool) -> ValidateSubscriptionRequest {
        validateSubscriptionRequestStub(api, protonPlanName, isAuthenticated)
    }

    @ThrowingFuncStub(PaymentsApiProtocol.getUser, initialReturn: .crash) var getUserStub
    func getUser(api: APIService) throws -> User { try getUserStub(api) }
}
