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

import Combine
import Foundation
import ProtonCoreDoh
import ProtonCorePaymentsV2
import ProtonCoreUI
import StoreKit

@MainActor
public class AvailablePlansViewModel: ObservableObject {

    private struct Constants {
        static let transactionCompletedDelay: Double = 2
    }

    @Published var billingCycle: BillingCycle = .all
    @Published var filteredPlans: [PlanViewModel] = []
    @Published public var viewState: State = .idle

    @Published var confirmationCompleted: Bool = false
    @Published var updateCompleted: Bool = false
    @Published var showAlert: BannerState = .none

    public var hasAvailablePlans: Bool {
        !availablePlansViewModels.isEmpty
    }

    public var isFilterEmpty: Bool {
        filteredPlans.isEmpty
    }

    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    private let doh: DoHInterface & ServerConfig
    private var cancellables = Set<AnyCancellable>()

    let billing = BillingCycle.allCases

    public enum State {
        case dataLoaded
        case fetching
        case errorData
        case idle
        case purchasing
        case noData
    }

    private var availablePlansViewModels: [PlanViewModel] = []
    public var currentPlan: PlanViewModel?
    public let hideCurrentPlan: Bool
    public var showCloseButton: Bool {
        presentationMode == .modal
    }

    private let paymentsAPIs: PaymentsAPIs
    private let remoteManager: RemoteManager
    private let plansComposer: PlansComposer
    private let presentationMode: PresentationMode

    public init(sessionId: String,
                token: String,
                doh: DoHInterface & ServerConfig,
                appVersion: String,
                hideCurrentPlan: Bool = false,
                presentationMode: PresentationMode) {

        self.doh = doh
        paymentsAPIs = PaymentsAPIs(doh: doh)
        remoteManager = RemoteManager(sessionID: sessionId, authToken: token, appVersion: appVersion)
        plansComposer = PlansComposer(remoteManager: remoteManager, paymentsAPIs: paymentsAPIs)
        self.hideCurrentPlan = hideCurrentPlan
        self.presentationMode = presentationMode
    }

    private func fetchCurrentPlan() async throws -> PlanViewModel? {
        viewState = .fetching

        let currentPlanResponse = try await plansComposer.fetchCurrentSubscription()
        return PlanViewModel(doh: doh,
                             remoteManager: remoteManager,
                             currentPlan: currentPlanResponse)

    }

    private func fetchAvailablePlans() async throws -> [PlanViewModel] {
        viewState = .fetching

        let composedPlans = try await plansComposer.fetchAvailablePlans()

        if composedPlans.isEmpty {
            viewState = .noData
            return []
        }

        var viewModels = [PlanViewModel]()
        composedPlans.forEach { plan in
            viewModels.append(PlanViewModel(doh: doh,
                                            remoteManager: remoteManager,
                                            composedPlan: plan,
                                            plansManager: ProtonPlansManager(doh: doh,
                                                                             remoteManager: remoteManager,
                                                                             plansComposer: plansComposer)))
        }
        availablePlansViewModels = viewModels

        // before presenting the data, we filter the result based on the active billing cycle
        return billingFilter(filter: billingCycle)
    }

    public func fetchData() async {

        do {
            if !hideCurrentPlan {
                async let currentSubscription = fetchCurrentPlan()
                currentPlan = try await currentSubscription
            }
            async let plans = fetchAvailablePlans()
            filteredPlans = try await plans

            viewState = .dataLoaded
        } catch {
            viewState = .errorData
            debugPrint(error)
        }
    }

    @discardableResult
    public func billingFilter(filter: BillingCycle) ->  [PlanViewModel] {
        filteredPlans.removeAll()
        filteredPlans = filter == .all ? availablePlansViewModels : availablePlansViewModels.filter { return $0.subscriptionPeriod == filter }

        filteredPlans.forEach { [weak self] plan in
            guard let self = self else {
                return
            }

            self.transactionProgress = plan.transactionState

            plan.transactionState
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { value in
                switch value {
                case .generatingReceipt:
                    self.purchaseInProgress()
                case .transactionCompleted:
                    self.transactionProgress.send(completion: .finished)
                    self.transactionCompleted()
                case .createNewSubscription:
                    self.confirmationCompleted = true
                case .transactionCancelledByUser:
                    self.transactionProgress.send(completion: .finished)
                    self.transactionCancelledByUser()
                case .unknownError, .transactionProcessError, .mismatchTransactionIDs, .unableToGetUserTransactionUUID:
                    self.transactionProgress.send(completion: .finished)
                    self.transactionProcessError()
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
        }

        return filteredPlans
    }
}

extension AvailablePlansViewModel {

    public func transactionCompleted() {
        updateCompleted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.transactionCompletedDelay) { [weak self] in
            guard let self else { return }
            // Reset TransactionProgress flags --> Improve this logic
            self.confirmationCompleted = false
            self.updateCompleted = false
            Task {
                await self.fetchData()
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
            await fetchData()
        }
    }

    public func transactionProcessError() {
        showAlert = .error(content: PCBannerContent(message: String(localized: "Transaction_process_error", bundle: .module)))
        Task {
            await fetchData()
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

#if DEBUG
    func setCurrentPlan(_ currentPlan: PlanViewModel) {
        self.currentPlan = currentPlan
    }
#endif

#if DEBUG
    func showBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self else { return }
            self.showAlert = .error(content: PCBannerContent(message: String(localized: "Transaction_process_error",
                                                                             bundle: .module)))
        }
    }
#endif
}
