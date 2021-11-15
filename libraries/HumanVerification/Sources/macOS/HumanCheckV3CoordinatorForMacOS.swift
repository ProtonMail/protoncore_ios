//
//  HumanCheckV3CoordinatorForMacOS.swift
//  ProtonCore-HumanVerification - Created on 8/20/19.
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

import AppKit
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_UIFoundations
import ProtonCore_CoreTranslation

final class HumanCheckV3Coordinator {

    // MARK: - Private properties

    private let apiService: APIService
    private var method: VerifyMethod = .captcha
    private var destination: String = ""

    /// View controllers
    private let rootViewController: NSViewController?
    private var initialViewController: HumanVerifyV3ViewController?
    private var initialHelpViewController: HVHelpViewController?

    /// View models
    private let humanVerifyV3ViewModel: HumanVerifyV3ViewModel

    // MARK: - Public properties

    weak var delegate: HumanCheckMenuCoordinatorDelegate?

    // MARK: - Public methods

    init(rootViewController: NSViewController?,
         apiService: APIService,
         methods: [VerifyMethod],
         startToken: String?) {
        self.rootViewController = rootViewController
        self.apiService = apiService
        
        self.humanVerifyV3ViewModel = HumanVerifyV3ViewModel(api: apiService, startToken: startToken, methods: methods)
        self.humanVerifyV3ViewModel.onVerificationCodeBlock = { [weak self] verificationCodeBlock in
            guard let self = self else { return }
            self.delegate?.verificationCode(tokenType: self.humanVerifyV3ViewModel.getToken(), verificationCodeBlock: verificationCodeBlock)
        }
        
        if NSClassFromString("XCTest") == nil {
            if methods.count == 0 {
                self.initialHelpViewController = getHelpViewController
            } else {
                instantiateViewController()
            }
        }
    }

    func start() {
        showHumanVerification()
    }

    // MARK: - Private methods
    
    private func instantiateViewController() {
        self.initialViewController = instatntiateVC(method: HumanVerifyV3ViewController.self,
                                                    identifier: "HumanVerifyV3ViewController")
        self.initialViewController?.viewModel = self.humanVerifyV3ViewModel
        self.initialViewController?.delegate = self
    }

    private func showHumanVerification() {
        guard let viewController = self.initialHelpViewController ?? self.initialViewController else { return }
        if let rootViewController = rootViewController {
            rootViewController.presentAsModalWindow(viewController)
        } else {
            NSApplication.shared.keyWindow?.contentViewController?.presentAsModalWindow(viewController)
        }
    }
    
    private func showHelp() {
        guard let initialViewController = initialViewController else { return }
        initialViewController.present(getHelpViewController,
                                      asPopoverRelativeTo: .zero,
                                      of: initialViewController.helpButton,
                                      preferredEdge: .maxX,
                                      behavior: .transient)
    }
    
    private var getHelpViewController: HVHelpViewController {
        let helpViewController = instatntiateVC(method: HVHelpViewController.self,
                                                identifier: "HumanCheckHelpViewController")
        helpViewController.delegate = self
        helpViewController.viewModel = HelpViewModel(url: apiService.humanDelegate?.getSupportURL())
        return helpViewController
    }
}

// MARK: - HumanVerifyV3ViewControllerDelegate

extension HumanCheckV3Coordinator: HumanVerifyV3ViewControllerDelegate {
    func willReopenViewController() {
        if let initialViewController = initialViewController {
            initialViewController.dismiss(initialViewController)
        }
        instantiateViewController()
        showHumanVerification()
    }
    
    func didDismissViewController() {
        delegate?.close()
    }
    
    func didShowHelpViewController() {
        showHelp()
    }
}

// MARK: - HVHelpViewControllerDelegate

extension HumanCheckV3Coordinator: HVHelpViewControllerDelegate {
    func didDismissHelpViewController() {
        if let initialHelpViewController = self.initialHelpViewController {
            initialHelpViewController.dismiss(initialHelpViewController)
        }
    }
}

extension HumanCheckV3Coordinator {
    private func instatntiateVC<T: NSViewController>(method: T.Type, identifier: String) -> T {
        let storyboard = NSStoryboard.init(name: "HumanVerify", bundle: HVCommon.bundle)
        let customViewController = storyboard.instantiateController(withIdentifier: identifier) as! T
        return customViewController
    }
}
