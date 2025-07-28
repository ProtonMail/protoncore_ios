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
import ProtonCoreUIFoundations
import Combine

public final class PaymentsUIViewControllerV2: UIViewController {

    private var viewWillAppear: Bool = true
    private var cancellables = Set<AnyCancellable>()
    @Published private var viewState: AvailablePlansViewModel.State = .idle
    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)

    private let sessionId: String
    private let token: String
    private let appVersion: String
    private let doh: DoHInterface & ServerConfig
    private let presentationMode: PresentationMode
    private let hideCurrentPlan: Bool
    private var hostingViewController: UIHostingController<AvailablePlansView>!

    public init(sessionId: String,
                token: String,
                appVersion: String,
                doh: DoHInterface & ServerConfig,
                presentationMode: PresentationMode = .none,
                hideCurrentPlan: Bool = false) {
        self.sessionId = sessionId
        self.token = token
        self.appVersion = appVersion
        self.doh = doh
        self.presentationMode = presentationMode
        self.hideCurrentPlan = hideCurrentPlan

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let viewModel = AvailablePlansViewModel(sessionId: sessionId,
                                                token: token,
                                                doh: doh,
                                                appVersion: appVersion,
                                                hideCurrentPlan: hideCurrentPlan,
                                                presentationMode: presentationMode)

        viewModel.transactionProgress.sink { [weak self] value in
            guard let self = self else {
                return
            }
            self.transactionProgress.value = value
        }
        .store(in: &cancellables)

        let availablePlansView = AvailablePlansView(viewModel: viewModel)

        hostingViewController = UIHostingController(rootView: availablePlansView)
        addChild(hostingViewController)

        view.addSubview(hostingViewController.view)
        hostingViewController.view.frame = view.bounds
        hostingViewController.didMove(toParent: self)

        if presentationMode == .push {
            title = hideCurrentPlan ? PaymentsUIV2Localizer.Select_plan_nav_title.l10n : PaymentsUIV2Localizer.Subscriptions_nav_title.l10n
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavBarButton())
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("viewControllerWillAppear called with value: \(viewWillAppear)")
        viewWillAppear = false
        setupView()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hostingViewController.view.frame = view.bounds
    }

    private func customNavBarButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.setImage(IconProvider.arrowLeft, for: .normal)
        button.addTarget(self, action: #selector(popView), for: .touchUpInside)
        button.tintColor = ColorProvider.TextNorm
        return button
    }

    @objc
    private func popView() {
        navigationController?.popViewController(animated: true)
    }
}
