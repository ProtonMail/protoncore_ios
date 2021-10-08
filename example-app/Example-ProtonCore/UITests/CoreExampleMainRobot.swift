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
import pmtest
import ProtonCore_TestingToolkit

final class CoreExampleMainRobot: CoreElements {

    enum Buttons: String {
        case accountSwitcher = "CoreExampleViewController.accountSwitcherButton"
        case login = "CoreExampleViewController.loginButton"
        case payments = "CoreExampleViewController.paymentsButton"
    }

    func tap<T: CoreElements>(_ buttonToTap: Buttons, to robot: T.Type) -> T {
        button(buttonToTap.rawValue).tap()
        return T()
    }
}
