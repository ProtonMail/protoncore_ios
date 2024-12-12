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

import UIKit
import ProtonCorePaymentsV2
import ProtonCoreFoundations

public enum PresentationMode {
    case modal
    case push
    case none
}

public enum PaymentsPresentationError: Error {
    case unableToGetParentViewController
    case noPresentationModeSet
}

final public class PaymentsV2 {

    private let keyWindow = UIApplication.firstKeyWindow

    public init() {}

    public func availablePlansView(sessionID: String,
                                   accessToken: String,
                                   appVersion: String,
                                   env: EnvURLType) -> PaymentsUIViewControllerV2 {
        return PaymentsUIViewControllerV2(sessionId: sessionID,
                                          token: accessToken,
                                          appVersion: appVersion,
                                          env: env)
    }

    public func showAvailablePlans(presentationMode: PresentationMode,
                                   sessionID: String,
                                   accessToken: String,
                                   appVersion: String,
                                   env: EnvURLType) throws {

        let vc = PaymentsUIViewControllerV2(sessionId: sessionID,
                                            token: accessToken,
                                            appVersion: appVersion,
                                            env: env,
                                            presentationMode: presentationMode)

        switch presentationMode {
        case .modal:
            try presentView(vc: vc)
        case .push:
            try pushView(vc: vc)
        case .none:
            throw PaymentsPresentationError.noPresentationModeSet
        }
    }

    private func presentView(vc: UIViewController) throws {

        guard let viewController = keyWindow?.topMostViewController else {
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
}
