//
//  AlertManager.swift
//  ProtonCore-Payments - Created on 2/12/2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import ProtonCore_CoreTranslation
import ProtonCore_Foundations

#if canImport(UIKit)
import UIKit

public typealias ActionCallback = ((UIAlertAction) -> Void)?

class PaymentsAlertManager {
    let alertManager: AlertManagerProtocol

    init (alertManager: AlertManagerProtocol = AlertManager()) {
        self.alertManager = alertManager
    }

    func retryAlert(confirmAction: ActionCallback = nil, cancelAction: ActionCallback = nil) {
        alertManager.title = CoreString._error_apply_payment_on_registration_title
        alertManager.message = CoreString._error_apply_payment_on_registration_message
        alertManager.confirmButtonTitle = CoreString._retry
        alertManager.cancelButtonTitle = CoreString._error_apply_payment_on_registration_support
        alertManager.confirmButtonStyle = .destructive
        alertManager.cancelButtonStyle = .cancel
        alertManager.showAlert(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    func userValidationAlert(message: String, confirmButtonTitle: String, confirmAction: ActionCallback = nil) {
        alertManager.title = CoreString._warning
        alertManager.message = message
        alertManager.confirmButtonTitle = confirmButtonTitle
        alertManager.cancelButtonTitle = CoreString._no_dont_bypass_validation
        alertManager.confirmButtonStyle = .destructive
        alertManager.cancelButtonStyle = .cancel
        alertManager.showAlert(confirmAction: confirmAction, cancelAction: nil)
    }

    func errorAlert(message: String) {
        alertManager.title = CoreString._error_occured
        alertManager.message = message
        alertManager.confirmButtonTitle = CoreString._general_ok_action
        alertManager.cancelButtonTitle = nil
        alertManager.confirmButtonStyle = .cancel
        alertManager.cancelButtonStyle = .default
        alertManager.showAlert(confirmAction: nil, cancelAction: nil)
    }
}

public protocol AlertManagerProtocol: AnyObject {
    var title: String? { get set }
    var message: String? { get set }
    var confirmButtonTitle: String? { get set }
    var cancelButtonTitle: String? { get set }
    var confirmButtonStyle: UIAlertAction.Style { get set }
    var cancelButtonStyle: UIAlertAction.Style { get set }
    func showAlert(confirmAction: ActionCallback, cancelAction: ActionCallback)
}

private class AlertManager: AlertManagerProtocol {
    var title: String?
    var message: String?
    var confirmButtonTitle: String?
    var cancelButtonTitle: String?
    var confirmButtonStyle: UIAlertAction.Style = .default
    var cancelButtonStyle: UIAlertAction.Style = .default

    func showAlert(confirmAction: ActionCallback = nil, cancelAction: ActionCallback = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
            if let cancelButtonTitle = self.cancelButtonTitle {
                alert.addAction(UIAlertAction(title: cancelButtonTitle, style: self.cancelButtonStyle, handler: { action in
                    self.alertWindow = nil
                    cancelAction?(action)
                }))
            }
            if let confirmButtonTitle = self.confirmButtonTitle {
                alert.addAction(UIAlertAction(title: confirmButtonTitle, style: self.confirmButtonStyle, handler: { action in
                    self.alertWindow = nil
                    confirmAction?(action)
                }))
            }
            self.alertWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    @available(iOS 13.0, *)
    private var windowScene: UIWindowScene? {
        return UIApplication.getInstance()?.connectedScenes.first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }

    private lazy var alertWindow: UIWindow? = {
        let alertWindow: UIWindow?
        if #available(iOS 13.0, *) {
            if let windowScene = windowScene {
                alertWindow = UIWindow(windowScene: windowScene)
            } else {
                alertWindow = UIWindow(frame: UIScreen.main.bounds)
            }
        } else {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.backgroundColor = UIColor.clear
        alertWindow?.windowLevel = .alert
        alertWindow?.makeKeyAndVisible()
        return alertWindow
    }()
}

#else

// swiftlint:disable:next empty_parameters
typealias ActionCallback = ((Void) -> Void)?

class PaymentsAlertManager {

    func retryAlert(confirmAction: ActionCallback = nil, cancelAction: ActionCallback = nil) {
        // unimplemented outside UIKit
    }

    func userValidationAlert(message: String, confirmButtonTitle: String, confirmAction: ActionCallback = nil) {
        // unimplemented outside UIKit
    }

    func errorAlert(message: String) {
        // unimplemented outside UIKit
    }
}

#endif
