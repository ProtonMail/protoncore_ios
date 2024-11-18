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
import ProtonCorePaymentsV2
import Combine

public protocol PaymentsUIViewControllerV2Delegate: AnyObject {
    func viewControllerWillAppear(isFirstAppearance: Bool)
    func planPurchaseError()
    func paymentsFlowStateDidChange(_state: AvailablePlansViewModel.State)
}

public final class PaymentsUIViewControllerV2: UIViewController {

    private var viewWillAppear: Bool = true
    private var cancellables = Set<AnyCancellable>()

    @Published private var viewState: AvailablePlansViewModel.State = .idle

    public weak var delegate: PaymentsUIViewControllerV2Delegate?

    public init(sessionId: String, token: String, appVersion: String, env: EnvURLType) {
        super.init(nibName: nil, bundle: nil)

        setupView(sessionId: sessionId, token: token, appVersion: appVersion, env: env)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(sessionId: String, token: String, appVersion: String, env: EnvURLType) {

        let viewModel = AvailablePlansViewModel(sessionId: sessionId, token: token, envURL: env, appVersion: appVersion)

        viewModel.$viewState.sink { [weak self] value in
            guard let self = self else { return }
            self.delegate?.paymentsFlowStateDidChange(_state: value)
        }
        .store(in: &cancellables)

        let availablePlansView = AvailablePlansView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: availablePlansView)
        addChild(hostingController)

        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("viewControllerWillAppear called with value: \(viewWillAppear)")
        delegate?.viewControllerWillAppear(isFirstAppearance: viewWillAppear)
        viewWillAppear = false
    }
}
