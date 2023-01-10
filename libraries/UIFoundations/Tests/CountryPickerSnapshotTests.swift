//
//  CountryPickerSnapshotTests.swift
//  ProtonCore-UIFoundations - Created on 06.01.23.
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

import XCTest
import ProtonCore_TestingToolkit
@testable import ProtonCore_UIFoundations

@available(iOS 13, *)
class CountryPickerSnapshotTests: SnapshotTestCase {

    func testCountryPickerViewControllerScreen() {
        let viewController = UIStoryboard.instantiate(storyboardName: "CountryPicker", controllerType: CountryPickerViewController.self, name: "CountryPickerViewController")
        viewController.viewModel = CountryCodeViewModel()
        checkSnapshots(controller: viewController, perceptualPrecision: 0.98)
    }
}

extension UIStoryboard {
    static func instantiate<T: UIViewController>(storyboardName: String, controllerType: T.Type, name: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: PMUIFoundations.bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: name) as! T
        return viewController
    }
}
