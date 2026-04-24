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
import ProtonCoreServices
import ProtonCorePaymentsV2
import ProtonCoreUIFoundations
import Combine

public final class PaymentsUIViewControllerV2: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    @Published private var viewState: AvailablePlansViewModel.State = .idle
    public private(set) var transactionProgress = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
    public private(set) var viewCycleState = CurrentValueSubject<ViewCycleState, Never>(.none)

    private let apiService: APIService
    private let presentationMode: PresentationMode
    private let hideCurrentPlan: Bool
    private var hostingViewController: UIHostingController<AvailablePlansView>!
    private var viewModel: AvailablePlansViewModel?

    public init(apiService: APIService,
                presentationMode: PresentationMode = .none,
                hideCurrentPlan: Bool = false) {
        self.apiService = apiService
        self.presentationMode = presentationMode
        self.hideCurrentPlan = hideCurrentPlan

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let vm = AvailablePlansViewModel(
            remoteManager: RemoteManager(apiService: apiService),
            hideCurrentPlan: hideCurrentPlan,
            presentationMode: presentationMode,
        )
        viewModel = vm

        Publishers
            .CombineLatest(vm.transactionProgress, vm.viewCycleState)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.transactionProgress.value = $0
                self.viewCycleState.value = $1
            }
            .store(in: &cancellables)

        let availablePlansView = AvailablePlansView(viewModel: vm)

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
        guard viewModel == nil else { return }
        setupView()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hostingViewController.view.frame = view.bounds
        guard let viewModel, viewModel.viewState == .idle || viewModel.viewState == .errorData else { return }
        Task {
            await viewModel.fetchData(from: "viewDidAppear")
        }
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
