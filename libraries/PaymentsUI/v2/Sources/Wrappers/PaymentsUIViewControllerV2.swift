//
//  PaymentsUIViewControllerV2.swift
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

import SwiftUI
import ProtonCoreDoh
import ProtonCorePaymentsV2
import ProtonCoreUI
import Combine

public final class PaymentsUIViewControllerV2: UIViewController {

    private var viewWillAppear: Bool = true
    private var cancellables = Set<AnyCancellable>()
    @Published private var viewState: AvailablePlansViewModel.State = .idle
    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    public init(sessionId: String,
                token: String,
                appVersion: String,
                doh: DoHInterface & ServerConfig,
                presentationMode: PresentationMode = .none,
                hideCurrentPlan: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        setupView(sessionId: sessionId,
                  token: token,
                  appVersion: appVersion,
                  doh: doh,
                  presentationMode: presentationMode,
                  hideCurrentPlan: hideCurrentPlan)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(sessionId: String,
                           token: String,
                           appVersion: String,
                           doh: DoHInterface & ServerConfig,
                           presentationMode: PresentationMode,
                           hideCurrentPlan: Bool = false) {

        let viewModel = AvailablePlansViewModel(sessionId: sessionId,
                                                token: token,
                                                doh: doh,
                                                appVersion: appVersion,
                                                hideCurrentPlan: hideCurrentPlan,
                                                presentationMode: presentationMode)

        transactionProgress = viewModel.transactionProgress

        let availablePlansView = AvailablePlansView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: availablePlansView)
        addChild(hostingController)

        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)

        if presentationMode == .push {
            title = hideCurrentPlan ? String(localized: "Select_plan_nav_title", bundle: .module) : String(localized: "Subscriptions_nav_title", bundle: .module)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavBarButton())
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("viewControllerWillAppear called with value: \(viewWillAppear)")
        viewWillAppear = false
    }

    private func customNavBarButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.setImage(Theme.icon.arrowLeft, for: .normal)
        button.addTarget(self, action: #selector(popView), for: .touchUpInside)
        button.tintColor = Theme.color.textNorm
        return button
    }

    @objc
    private func popView() {
        navigationController?.popViewController(animated: true)
    }
}
