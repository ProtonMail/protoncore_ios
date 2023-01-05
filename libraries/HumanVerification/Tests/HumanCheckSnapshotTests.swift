//
//  HumanCheckSnapshotTests.swift
//  ProtonCore-HumanVerification-Tests - Created on 06/01/22.
//
//  Copyright (c) 2022 Proton Technologies AG
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

import XCTest
import ProtonCore_TestingToolkit
import ProtonCore_UIFoundations
import ProtonCore_Services
@testable import ProtonCore_HumanVerification

@available(iOS 13, *)
class HumanCheckSnapshotTests: SnapshotTestCase {
    
    func testHumanVerificationScreen() {
        let viewController = UIStoryboard.instantiate(storyboardName: "HumanVerify", controllerType: HumanVerifyViewController.self, name: "HumanVerifyViewController")
        let dohMock = DohMock()
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: dohMock,
                                                                     challangeParametersProvider: .forAPIService(prefix: "core"))
        let viewModel = HumanVerifyViewModel(api: apiService, startToken: nil, methods: nil, clientApp: .mail)
        viewController.viewModel = viewModel
        
        dohMock.getHumanVerificationV3HostStub.bodyIs { _ in "test.proton.test" }
        dohMock.getHumanVerificationV3HeadersStub.bodyIs { _ in [:] }
        
        let navigationViewController = DarkModeAwareNavigationViewController()
        navigationViewController.modalPresentationStyle = .fullScreen
        navigationViewController.viewControllers = [viewController]
        navigationViewController.hideBackground()
        
        checkSnapshots(controller: navigationViewController, perceptualPrecision: 0.98)
    }
}

extension UIStoryboard {
    static func instantiate<T: UIViewController>(storyboardName: String, controllerType: T.Type, name: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: HVCommon.bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: name) as! T
        return viewController
    }
}
