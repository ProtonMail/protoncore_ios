//
//  CoreExampleMainRobot.swift
//  CoreExample - Created on 07/10/2021.
//
//  Copyright (c) 2021 Proton Technologies AG
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

import Foundation
import fusion
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
#else
import ProtonCoreTestingToolkit
#endif
import XCTest

final class CoreExampleMainRobot: CoreElements {

    enum Buttons: String {
        case accountDeletion = "ExampleViewController.accountDeletionButton"
        case accountSwitcher = "ExampleViewController.accountSwitcherButton"
        case login = "ExampleViewController.loginButton"
        case networking = "ExampleViewController.networkingButton"
        case payments = "ExampleViewController.paymentsButton"
        case settings = "ExampleViewController.settingsButton"
        case appVersionReset = "ExampleViewController.appVersionResetButton"
        case tokenRefresh = "ExampleViewController.tokenRefreshButton"
    }

    let appVersionTextField = "ExampleViewController.appVersionTextField"

    func tap<T: CoreElements>(_ buttonToTap: Buttons, to robot: T.Type) -> T {
        button(buttonToTap.rawValue).tap()
        return T()
    }

    func changeAppVersion(version: String) -> CoreExampleMainRobot {
        button(Buttons.appVersionReset.rawValue).tap()
        textField(appVersionTextField).tap().typeText(version).typeText(XCUIKeyboardKey.return.rawValue)
        return CoreExampleMainRobot()
    }

    @discardableResult
    func changeAlternativeRoutingSwitch(name: String) -> CoreExampleMainRobot {
        button(name).tap()
        return self
    }
}
