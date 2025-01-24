//
//  AuthDeviceManager.swift
//  ProtonCore-Login - Created on 03.01.25.
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

#if os(iOS)
import Combine
import ProtonCoreLogin
import ProtonCoreUIFoundations
import UIKit

public class AuthDeviceManagerUI {
    private let  authDeviceManager: AuthDeviceManager

    var appWindow: UIWindow? = {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last
    }()

    var overlayWindow: UIWindow?

    private var cancellables: Set<AnyCancellable> = .init()

    public init(authDeviceManager: AuthDeviceManager) {
        self.authDeviceManager = authDeviceManager
    }
}

public extension AuthDeviceManagerUI {
    func setup() {
        authDeviceManager.setup()
        observePendingDevices()
    }

    func forceFetchPendingDevices() {
        authDeviceManager.forceFetchPendingDevices()
    }
}

private extension AuthDeviceManagerUI {
    func observePendingDevices() {
        authDeviceManager.pendingDevicesObserver
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pendingDevicesUpdate in
                guard let self else { return }
                guard overlayWindow == nil else { return }
                Task {
                    await self.presentGrantAccessView(pendingDevicesUpdate: pendingDevicesUpdate)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func presentGrantAccessView(pendingDevicesUpdate: PendingAuthDevicesUpdate) {
        guard let windowScene = appWindow?.windowScene else { return }
        guard overlayWindow == nil else { return } // So we don't present multiple approvals at the same time

        overlayWindow = UIWindow(windowScene: windowScene)
        if let style = appWindow?.overrideUserInterfaceStyle {
            overlayWindow?.overrideUserInterfaceStyle = style
        }

        let transparentViewController = UIViewController()
        transparentViewController.view.backgroundColor = .clear
        overlayWindow?.rootViewController = transparentViewController
        overlayWindow?.makeKeyAndVisible()

        let viewController = GrantAccessViewController(dependencies: .init(
            apiService: pendingDevicesUpdate.apiService,
            authDevices: pendingDevicesUpdate.authDevices,
            userData: pendingDevicesUpdate.userData,
            navigationDelegate: self
        ))

        let navigationController = DarkModeAwareNavigationViewController(rootViewController: viewController)

        navigationController.modalPresentationStyle = .fullScreen
        transparentViewController.present(navigationController, animated: true)
    }
}

extension AuthDeviceManagerUI: GrantAccessViewNavigationDelegate {
    func dismissGrantAccessView() {
        overlayWindow?.rootViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self else { return }
            self.overlayWindow = nil
            appWindow?.makeKeyAndVisible()
        })
    }
}
#endif
