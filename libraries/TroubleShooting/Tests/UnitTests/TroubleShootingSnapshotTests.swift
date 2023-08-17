//
//  TroubleShootingSnapshotTests.swift
//  ProtonCore-TroubleShooting - Created on 12/20/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import XCTest
import ProtonCoreServices
import ProtonCoreEnvironment
#if SPM
import ProtonCoreTestingToolkitUnitTestsCore
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreUIFoundations
@testable import ProtonCoreTroubleShooting

@available(iOS 13, *)
class TroubleShootingSnapshotTests: SnapshotTestCase {
    var sut: TroubleShootingViewController!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    private func setupSut() {
        let dohStatusHelper = DohStatusHelper.init(doh: Environment.black.doh)
        let viewModel = TroubleShootingViewModel.init(doh: dohStatusHelper)
        sut = TroubleShootingViewController.init(viewModel: viewModel)
    }
    
    func testTroubleShootingSnapshot() {
        // setup
        setupSut()
        // Then
        let image = UIImage()
        let navigationViewController = DarkModeAwareNavigationViewController()
        navigationViewController.modalPresentationStyle = .fullScreen
        navigationViewController.viewControllers = [sut]
        checkSnapshots(controller: navigationViewController, perceptualPrecision: 0.96)
    }
}

#endif
