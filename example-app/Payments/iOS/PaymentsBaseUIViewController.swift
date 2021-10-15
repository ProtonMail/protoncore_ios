//
//  PaymentsBaseUIViewController.swift
//  Example-Payments - Created on 28/01/2021.
//
//
//  Copyright (c) 2021 Proton Technologies AG
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

#if canImport(UIKit)
import UIKit
import Crypto_VPN
import ProtonCore_Payments
import ProtonCore_Services

class PaymentsBaseUIViewController: UIViewController {

    let onlyForAuthServiceDelegate = PaymentsAuthServiceDelegate()

    var bottomPaddingConstraint: CGFloat = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addKeyboardObserver(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeKeyboardObserver(self)
    }
    
    @available(iOS 13.0, *)
    var windowScene: UIWindowScene? {
        return UIApplication.getInstance()?.connectedScenes.first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }

    lazy var alertWindow: UIWindow? = {
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

extension PaymentsBaseUIViewController: NSNotificationCenterKeyboardObserverProtocol {
    func keyboardWillHideNotification(_ notification: Notification) {
        let keyboardInfo = notification.keyboardInfo
        bottomPaddingConstraint = 0.0
        UIView.animate(withDuration: keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            self.bottomPaddingConstraint = 0.0
        }, completion: nil)
    }

    func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardInfo = notification.keyboardInfo
        let info: NSDictionary = notification.userInfo! as NSDictionary
        UIView.animate(withDuration: keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            if let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.bottomPaddingConstraint = keyboardSize.height - UIEdgeInsets.saveAreaBottom
            }
        }, completion: nil)
    }
}

final class PaymentsAuthServiceDelegate: APIServiceDelegate {
    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool { true }

    var appVersion: String = "WebDrive_1.0.0" // for the sweet sweet scopes

    var locale: String { Locale.autoupdatingCurrent.identifier }

    var userAgent: String?

    func onDohTroubleshot() {}
}

#endif
