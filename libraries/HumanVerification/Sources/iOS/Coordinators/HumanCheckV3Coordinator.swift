//
//  HumanCheckMenuCoordinator.swift
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

import UIKit
import enum ProtonCore_DataModel.ClientApp
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_UIFoundations
import ProtonCore_CoreTranslation

class HumanCheckV3Coordinator {

    // MARK: - Private properties

    private let apiService: APIService
    private var method: VerifyMethod = .captcha
    private var destination: String = ""

    /// View controllers
    private let rootViewController: UIViewController?
    private var initialViewController: HumanVerifyV3ViewController?
    private var initialHelpViewController: HVHelpViewController?

    /// View models
    private let humanVerifyV3ViewModel: HumanVerifyV3ViewModel

    // MARK: - Public properties

    weak var delegate: HumanCheckMenuCoordinatorDelegate?

    // MARK: - Public methods

    init(rootViewController: UIViewController?, apiService: APIService, methods: [VerifyMethod], startToken: String?, clientApp: ClientApp) {
        self.rootViewController = rootViewController
        self.apiService = apiService
        
        self.humanVerifyV3ViewModel = HumanVerifyV3ViewModel(api: apiService, startToken: startToken, methods: methods, clientApp: clientApp)
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
        self.initialViewController = instatntiateVC(method: HumanVerifyV3ViewController.self, identifier: "HumanVerifyV3ViewController")
        self.initialViewController?.viewModel = self.humanVerifyV3ViewModel
        self.initialViewController?.delegate = self
    }

    private func showHumanVerification() {
        guard let viewController = self.initialHelpViewController ?? self.initialViewController else { return }
        if let rootViewController = rootViewController {
            let nav = UINavigationController()
            nav.modalPresentationStyle = .fullScreen
            nav.viewControllers = [viewController]
            rootViewController.present(nav, animated: true)
        } else {
            var topViewController: UIViewController?
            let keyWindow = UIApplication.getInstance()?.windows.filter { $0.isKeyWindow }.first
            if var top = keyWindow?.rootViewController {
                while let presentedViewController = top.presentedViewController {
                    top = presentedViewController
                }
                topViewController = top
            }
            let nav = UINavigationController()
            nav.modalPresentationStyle = .fullScreen
            nav.viewControllers = [viewController]
            topViewController?.present(nav, animated: true)
        }
    }
    
    private func showHelp() {
        initialViewController?.navigationController?.pushViewController(getHelpViewController, animated: true)
    }
    
    private var getHelpViewController: HVHelpViewController {
        let helpViewController = instatntiateVC(method: HVHelpViewController.self, identifier: "HumanCheckHelpViewController")
        helpViewController.delegate = self
        helpViewController.viewModel = HelpViewModel(url: apiService.humanDelegate?.getSupportURL())
        return helpViewController
    }
}

// MARK: - HumanVerifyV3ViewControllerDelegate

extension HumanCheckV3Coordinator: HumanVerifyV3ViewControllerDelegate {
    func willReopenViewController() {
        instantiateViewController()
        showHumanVerification()
    }
    
    func didDismissViewController() {
        initialViewController?.navigationController?.dismiss(animated: true, completion: nil)
        delegate?.close()
    }
    
    func didShowHelpViewController() {
        showHelp()
    }
}

// MARK: - HVHelpViewControllerDelegate

extension HumanCheckV3Coordinator: HVHelpViewControllerDelegate {
    func didDismissHelpViewController() {
        if self.initialHelpViewController != nil {
            initialHelpViewController?.dismiss(animated: true)
            delegate?.close()
        } else {
            initialViewController?.navigationController?.popViewController(animated: true)
        }
    }
}

extension HumanCheckV3Coordinator {
    private func instatntiateVC <T: UIViewController>(method: T.Type, identifier: String) -> T {
        let storyboard = UIStoryboard.init(name: "HumanVerify", bundle: HVCommon.bundle)
        let customViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return customViewController
    }
}
