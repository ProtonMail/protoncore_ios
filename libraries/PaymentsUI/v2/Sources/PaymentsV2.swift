//
//  PaymentsV2Presenter.swift
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
import ProtonCorePaymentsV2
import UIKit

public enum PresentationMode {
    case modal
    case push
    case none
}

public enum PaymentsPresentationError: Error {
    case unableToGetParentViewController
    case noPresentationModeSet
    case transactionsObserverNotActive
    case unableToFindValidEnvironment
}

final public class PaymentsV2: Sendable {

    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    private let queue = DispatchQueue(label: "paymentsV2Presenter.syncQueue")
    private var presentationMode: PresentationMode = .none
    private var paymentsView: PaymentsUIViewControllerV2!

    public init() {}

    //MARK: Public functions

    //MARK: Presentation
    public func availablePlansView(sessionID: String,
                                   accessToken: String,
                                   appVersion: String,
                                   hideCurrentPlan: Bool = false,
                                   env: String) throws -> PaymentsUIViewControllerV2 {
        return try createPaymentsView(sessionID: sessionID,
                                      accessToken: accessToken,
                                      appVersion: appVersion,
                                      hideCurrentPlan: hideCurrentPlan,
                                      env: env)
    }

    public func showAvailablePlans(presentationMode: PresentationMode,
                                   sessionID: String,
                                   accessToken: String,
                                   appVersion: String,
                                   hideCurrentPlan: Bool = false,
                                   env: String) throws {

        guard TransactionsObserver.shared.isON else {
            throw PaymentsPresentationError.transactionsObserverNotActive
        }

        self.presentationMode = presentationMode

        paymentsView = try createPaymentsView(sessionID: sessionID,
                                              accessToken: accessToken,
                                              appVersion: appVersion,
                                              hideCurrentPlan: hideCurrentPlan,
                                              presentationMode: presentationMode,
                                              env: env)

        switch presentationMode {
        case .modal:
            try presentView(vc: paymentsView)
        case .push:
            try pushView(vc: paymentsView)
        case .none:
            throw PaymentsPresentationError.noPresentationModeSet
        }
    }

    public func dismissPayments() {
        switch presentationMode {
        case .modal:
            paymentsView.dismiss(animated: true)
        case .push:
            guard let viewController = UIApplication.getTopViewController(), let navController = viewController.navigationController else {
                debugPrint("PaymentsV2 dismiss error: Impossible to find top viewController or navigation controller")
                return
            }

            navController.popToViewController(paymentsView, animated: true)
        case .none:
            break
        }
    }

    //MARK: Private functions
    private func presentView(vc: UIViewController) throws {
        guard let viewController = UIApplication.getTopViewController() else {
            throw PaymentsPresentationError.unableToGetParentViewController
        }

        viewController.present(vc, animated: true)
    }

    private func pushView(vc: UIViewController) throws {
        guard let viewController = UIApplication.getTopViewController(), let navController = viewController.navigationController else {
            throw PaymentsPresentationError.unableToGetParentViewController
        }

        navController.pushViewController(vc, animated: true)
    }

    private func createPaymentsView(sessionID: String,
                                    accessToken: String,
                                    appVersion: String,
                                    hideCurrentPlan: Bool = false,
                                    presentationMode: PresentationMode = .none,
                                    env: String) throws -> PaymentsUIViewControllerV2 {

        guard let env = env.toEnvURLType else {
            throw PaymentsPresentationError.unableToFindValidEnvironment
        }

        let vc = PaymentsUIViewControllerV2(sessionId: sessionID,
                                          token: accessToken,
                                          appVersion: appVersion,
                                          env: env,
                                          presentationMode: presentationMode,
                                          hideCurrentPlan: hideCurrentPlan)
        queue.sync {
            self.transactionProgress = vc.transactionProgress
        }
        return vc
    }
}
