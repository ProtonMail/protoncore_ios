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
import ProtonCoreUtilities
import ProtonCoreUIFoundations
import StoreKit

public enum ViewCycleState {
    case none
    case displayed
    case dismissed
}

@MainActor
public class AvailablePlansViewModel: ObservableObject {

    private struct Constants {
        static let transactionCompletedDelay: Double = 2

        static func bottomPadding(presentationMode: PresentationMode) -> CGFloat {
            return presentationMode == .modal ? 75 : 0
        }
    }

    @Published var billingCycle: BillingCycle = .all
    @Published var filteredPlans: [PlanViewModel] = []
    @Published public var viewState: State = .idle

    @Published var confirmationCompleted: Bool = false
    @Published var updateCompleted: Bool = false
    @Published var showAlert: BannerState = .none
    @Published var hideCurrentPlan: Bool = false
    @Published var isPurchasing: Bool = false

    public var hideAvailablePlans: Bool {
        guard let isFreePlan = currentPlan?.isFreePlan else {
            return false
        }
        return !isFreePlan
    }

    public var hasAvailablePlans: Bool {
        !availablePlansViewModels.isEmpty
    }

    public var isFilterEmpty: Bool {
        filteredPlans.isEmpty
    }

    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    public private(set) var viewCycleState = CurrentValueSubject<ViewCycleState, Never>(.none)

    private let doh: DoHInterface & ServerConfig
    private var cancellables = Set<AnyCancellable>()

    let billing = BillingCycle.allCases

    public enum State {
        case dataLoaded
        case fetching
        case errorData
        case idle
        case noData
    }

    private var availablePlansViewModels: [PlanViewModel] = []
    public var currentPlan: PlanViewModel?
    public var showCloseButton: Bool {
        presentationMode == .modal
    }

    public var bottomPadding: CGFloat {
        return Constants.bottomPadding(presentationMode: presentationMode)
    }

    private let paymentsAPIs: PaymentsAPIs
    private let remoteManager: RemoteManager
    private let presentationMode: PresentationMode
    private let protonPlansManager: ProtonPlansManager

    public init(sessionId: String,
                token: String,
                doh: DoHInterface & ServerConfig,
                appVersion: String,
                hideCurrentPlan: Bool = false,
                presentationMode: PresentationMode) {

        self.doh = doh
        paymentsAPIs = PaymentsAPIs(doh: doh)
        remoteManager = RemoteManager(sessionID: sessionId, authToken: token, appVersion: appVersion, atlasSecret: doh.getProxyToken())
        protonPlansManager = ProtonPlansManager(doh: doh,
                                                remoteManager: remoteManager,
                                                plansComposer: PlansComposer(remoteManager: remoteManager,
                                                                             paymentsAPIs: paymentsAPIs))
        self.hideCurrentPlan = hideCurrentPlan
        self.presentationMode = presentationMode

        TransactionsObserver.shared.transactionProgress
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.transactionProgress.value = value
                switch value {
                case .generatingReceipt:
                    self.purchaseInProgress()
                case .transactionPending:
                    self.isPurchasing = false
                    self.transactionProgress.send(completion: .finished)
                    self.transactionPending()
                case .transactionCompleted:
                    self.transactionProgress.send(completion: .finished)
                    self.transactionCompleted()
                case .createNewSubscription:
                    self.confirmationCompleted = true
                case .transactionCancelledByUser:
                    self.isPurchasing = false
                    self.transactionProgress.send(completion: .finished)
                case .unknownError, .transactionProcessError, .mismatchTransactionIDs, .unableToGetUserTransactionUUID:
                    self.isPurchasing = false
                    self.transactionProgress.send(completion: .finished)
                    self.transactionProcessError()
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
    }

    private func fetchCurrentPlan() async throws -> PlanViewModel? {
        viewState = .fetching

        let currentPlanResponse = try await protonPlansManager.getCurrentPlan()
        return PlanViewModel(doh: doh,
                             remoteManager: remoteManager,
                             currentPlan: currentPlanResponse)

    }

    private func fetchAvailablePlans() async throws -> [PlanViewModel] {
        viewState = .fetching

        let composedPlans = try await protonPlansManager.getAvailablePlans()

        if composedPlans.isEmpty {
            return []
        }

        var viewModels = [PlanViewModel]()
        composedPlans.forEach { plan in
            viewModels.append(PlanViewModel(doh: doh,
                                            remoteManager: remoteManager,
                                            composedPlan: plan,
                                            plansManager: protonPlansManager))
        }
        availablePlansViewModels = viewModels

        // before presenting the data, we filter the result based on the active billing cycle
        return billingFilter(filter: billingCycle)
    }

    public func fetchData(from: String) async {
        debugPrint("fetchData from: " + from)
        do {
            if !hideCurrentPlan {
                async let currentSubscription = fetchCurrentPlan()
                currentPlan = try await currentSubscription
            }

            if try await protonPlansManager.checkIAPStatus().isAvailable {
                async let plans = fetchAvailablePlans()
                filteredPlans = try await plans
                viewState = filteredPlans.isEmpty && !hideAvailablePlans ? .noData : .dataLoaded
            } else {
                viewState = .dataLoaded
            }
        } catch {
            viewState = .errorData
            debugPrint(error)
        }
    }

    @discardableResult
    public func billingFilter(filter: BillingCycle) -> [PlanViewModel] {
        filteredPlans.removeAll()
        filteredPlans = filter == .all ? availablePlansViewModels : availablePlansViewModels.filter { return $0.subscriptionPeriod == filter }

        return filteredPlans
    }

    public func viewStateDidChange(_ state: ViewCycleState) {
        viewCycleState.send(state)
        if state == .dismissed {
            viewCycleState.send(completion: .finished)
        }
    }
}

extension AvailablePlansViewModel {

    public func transactionCompleted() {
        updateCompleted = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(Constants.transactionCompletedDelay * 1_000_000_000))
            self.resetTransactionState()
            await self.fetchData(from: "Transaction Completed")
        }
    }

    private func resetTransactionState() {
        confirmationCompleted = false
        updateCompleted = false
        hideCurrentPlan = false
        isPurchasing = false
    }

    public func updatingAccount() {
        confirmationCompleted = true
    }

    public func purchaseInProgress() {
        isPurchasing = true
    }

    public func transactionProcessError() {
        showAlert = .error(content: PCBannerContent(message: PaymentsUIV2Localizer.Transaction_process_error.l10n))
        Task {
            await fetchData(from: "Transaction Process error")
        }
    }

    public func transactionPending() {
        showAlert = .success(content: PCBannerContent(message: PaymentsUIV2Localizer.Transaction_pending.l10n))
    }
}

extension AvailablePlansViewModel {
#if DEBUG
    func addPlanViewModels(_ plans: [PlanViewModel]) {
        availablePlansViewModels = plans
        billingCycle = .all
        billingFilter(filter: billingCycle)
        viewState = .dataLoaded
    }

    func setBillingCycle(_ billingCycle: BillingCycle) {
        self.billingCycle = billingCycle
    }

    func setCurrentPlan(_ currentPlan: PlanViewModel) {
        self.currentPlan = currentPlan
    }

    func showBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self else { return }
            self.showAlert = .error(content: PCBannerContent(message: PaymentsV2Localizer.Plans_Manager_impossible_to_get_user_uuid.l10n))
        }
    }
#endif
}
