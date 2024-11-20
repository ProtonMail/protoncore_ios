//
//  AvailablePlansViewModel.swift
//  ProtonCore-PaymentsUIV2 - Created on 7/11/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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
import ProtonCorePaymentsV2
import ProtonCoreUI
import StoreKit

@MainActor
public class AvailablePlansViewModel: ObservableObject {

    private struct Constants {
        static var transactionCompletedDelay: Double = 2
    }

    @Published var billingCycle: BillingCycle = .monthly
    @Published var filteredPlans: [PlanViewModel] = []
    @Published public var viewState: State = .idle

    @Published var confirmationCompleted: Bool = false
    @Published var updateCompleted: Bool = false
    @Published var showAlert: BannerState = .none

    let billing = BillingCycle.allCases

    public enum State {
        case dataLoaded
        case fetching
        case errorData
        case idle
        case purchasing
        case noPlans
    }

    private var availablePlans: [AvailablePlan] = []
    private var availablePlansViewModels: [PlanViewModel] = []

    private let paymentsAPIs: PaymentsAPIs
    private let remoteManager: RemoteManager
    private let plansComposer: PlansComposer
    private let envURL: EnvURLType

    public init(sessionId: String,
                token: String,
                envURL: EnvURLType = .paymentsBlack,
                appVersion: String) {

        self.envURL = envURL
        paymentsAPIs = PaymentsAPIs(envURL: envURL)
        remoteManager = RemoteManager(sessionID: sessionId, authToken: token, appVersion: appVersion)
        plansComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPIs)
    }

    public func fetchAvailablePlans() async {
        viewState = .fetching
        do {

            let composedPlans = try await plansComposer.fetchAvailablePlans()

            var viewModels = [PlanViewModel]()
            composedPlans.forEach { plan in
                viewModels.append(PlanViewModel(envURL: paymentsAPIs.currentEnv(),
                                                remoteManager: remoteManager,
                                                composedPlan: plan,
                                                plansManager: ProtonPlansManager(environment: envURL,
                                                                                 remoteManager: remoteManager,
                                                                                 plansComposer: plansComposer)))
            }
            availablePlansViewModels = viewModels

            // before presenting the data, we filter the result based on the active billing cycle
            billingFilter(filter: billingCycle)

            viewState = availablePlansViewModels.isEmpty ? .noPlans : .dataLoaded
        } catch {
            viewState = .errorData
            debugPrint(error)
        }
    }

    func billingFilter(filter: BillingCycle) {

        filteredPlans = filter == .all ? availablePlansViewModels : availablePlansViewModels.filter { return $0.subscriptionPeriod == filter }

        filteredPlans.forEach { plan in
            plan.delegate = self
        }
    }
}

extension AvailablePlansViewModel: PlanViewModelDelegate {

    public func transactionCompleted() {
        updateCompleted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.transactionCompletedDelay) { [weak self] in
            guard let self else { return }
            Task {
                await self.fetchAvailablePlans()
            }
        }
    }

    public func updatingAccount() {
        confirmationCompleted = true
    }

    public func purchaseInProgress() {
        viewState = .purchasing
    }

    public func transactionCancelledByUser() {
        Task {
            await fetchAvailablePlans()
        }
    }

    public func transactionProcessError() {
        showAlert = .error(content: PCBannerContent(message: String(localized: "Transaction_process_error", bundle: .module)))
        Task {
            await fetchAvailablePlans()
        }
    }
}

extension AvailablePlansViewModel {
#if DEBUG
    func addPlanViewModels(_ plans: [PlanViewModel]) {
        availablePlansViewModels = plans
        billingCycle = .all
        billingFilter(filter: billingCycle)
    }
#endif

#if DEBUG
    func setBillingCycle(_ billingCycle: BillingCycle) {
        self.billingCycle = billingCycle
    }
#endif
}
