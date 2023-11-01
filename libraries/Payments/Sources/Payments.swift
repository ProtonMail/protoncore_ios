//
//  Payments.swift
//  ProtonCore-Payments - Created on 16/08/2021.
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
import ProtonCoreFeatureFlags
import ProtonCoreServices
import ProtonCoreUtilities

typealias ListOfIAPIdentifiersGet = () -> ListOfIAPIdentifiers
typealias ListOfIAPIdentifiersSet = (ListOfIAPIdentifiers) -> Void

public final class Payments {
    
    public static let transactionFinishedNotification = Notification.Name("StoreKitManager.transactionFinished")
    
    var inAppPurchaseIdentifiers: ListOfIAPIdentifiers
    var reportBugAlertHandler: BugAlertHandler
    let apiService: APIService
    let localStorage: ServicePlanDataStorage
    let canExtendSubscription: Bool
    var paymentsAlertManager: PaymentsAlertManager
    var paymentsApi: PaymentsApiProtocol

    public var alertManager: AlertManagerProtocol {
        get { paymentsAlertManager.alertManager }
        set { paymentsAlertManager.alertManager = newValue }
    }

    public internal(set) lazy var purchaseManager: PurchaseManagerProtocol = PurchaseManager(
        planService: planService, storeKitManager: storeKitManager, paymentsApi: paymentsApi, apiService: apiService
    )

    lazy var storeKitDataSource: StoreKitDataSource = StoreKitDataSource()

    private enum FeatureFlagError: Error {
        case wrongConfiguration
    }

    public internal(set) lazy var planService: Either<ServicePlanDataServiceProtocol, PlansDataSourceProtocol> = {
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.dynamicPlan) {
            return .right(PlansDataSource(
                apiService: apiService,
                storeKitDataSource: storeKitDataSource,
                localStorage: localStorage
            ))
        } else {
            return .left(
                ServicePlanDataService(
                    inAppPurchaseIdentifiers: { [weak self] in self?.inAppPurchaseIdentifiers ?? [] },
                    paymentsApi: paymentsApi,
                    apiService: apiService,
                    localStorage: localStorage,
                    paymentsAlertManager: paymentsAlertManager
                )
            )
        }

    }()

    public internal(set) lazy var storeKitManager: StoreKitManagerProtocol = {
        let dataSource: StoreKitDataSource?
        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.dynamicPlan) {
            dataSource = storeKitDataSource
        } else {
            dataSource = nil
        }
        return StoreKitManager(
            inAppPurchaseIdentifiersGet: { [weak self] in self?.inAppPurchaseIdentifiers ?? [] },
            inAppPurchaseIdentifiersSet: { [weak self] in self?.inAppPurchaseIdentifiers = $0 },
            planService: planService,
            storeKitDataSource: dataSource,
            paymentsApi: paymentsApi,
            apiService: apiService,
            canExtendSubscription: canExtendSubscription,
            paymentsAlertManager: paymentsAlertManager,
            reportBugAlertHandler: reportBugAlertHandler,
            refreshHandler: { _ in } // default refresh handler does nothing
        )
    }()

    public init(inAppPurchaseIdentifiers: ListOfIAPIdentifiers,
                apiService: APIService,
                localStorage: ServicePlanDataStorage,
                alertManager: AlertManagerProtocol? = nil,
                canExtendSubscription: Bool = false,
                reportBugAlertHandler: BugAlertHandler) {
        self.inAppPurchaseIdentifiers = inAppPurchaseIdentifiers
        self.reportBugAlertHandler = reportBugAlertHandler
        self.apiService = apiService
        self.localStorage = localStorage
        self.canExtendSubscription = canExtendSubscription && !FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.dynamicPlan)
        paymentsAlertManager = PaymentsAlertManager(alertManager: alertManager ?? AlertManager())
        paymentsApi = PaymentsApiImplementation()
    }

    public func activate(delegate: StoreKitManagerDelegate, storeKitProductsFetched: @escaping (Error?) -> Void = { _ in }) {
        // Setting delegate is a requirement before any purchase-related operation is performed
        storeKitManager.delegate = delegate

        // To initiate purchase recovery path, start listening for the transactions in the payment queue
        // If there are no transactions, nothing will happen
        // If there are transactions, they will be processed
        // Part of the processing will be fetching the available plans from the BE
        storeKitManager.subscribeToPaymentQueue()

        if FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.dynamicPlan) {
            // No-op by design
            // In the dynamic plans, fetching available IAPs from StoreKit is not a prerequisite.
            // It is done alongside fetching available plans
        } else {
            // Before dynamic plans, to be ready to present the available plans, we must fetch the available IAPs from StoreKit
            storeKitManager.updateAvailableProductsList(completion: storeKitProductsFetched)
        }
    }

    public func deactivate() {
        // After we unsubscribe from payments queue, StoreKit won't be informing us about any purchases, neither new nor restored
        storeKitManager.unsubscribeFromPaymentQueue()

        // In case any reference was captured in the refresh handler, we clean it
        // The handler will be re-registered next time we call `showPaymentsUI`
        storeKitManager.refreshHandler = { _ in }

        storeKitManager.delegate = nil
    }
    
    public func updateService(completion: @escaping (Result<(), Error>) -> Void) {
        switch planService {
        case .left(let planService):
            storeKitManager.updateAvailableProductsList { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                planService.updateServicePlans(success: { completion(.success) }, failure: { error in completion(.failure(error)) })
            }
        case .right(let plansDataSource):
            Task {
                do {
                    try await plansDataSource.fetchIAPAvailability()
                    completion(.success)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

extension Payments {
    public func executeDohTroubleshootMethodFromApiDelegate() {
        apiService.serviceDelegate?.onDohTroubleshot()
    }
}
