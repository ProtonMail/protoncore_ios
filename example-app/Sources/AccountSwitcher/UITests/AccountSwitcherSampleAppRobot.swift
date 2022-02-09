//
//  AccountSwitcherSampleAppRobot.swift
//  CoreExample - Created on 07/06/2021.
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

private let switcherComponentButton = "AccountSwitcherViewController.switcherComponentButton"
private let switcherScreenButton = "AccountSwitcherViewController.switcherScreenButton"

final class AccountSwitcherSampleAppRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func sampleAppScreenIsDisplayed() -> AccountSwitcherSampleAppRobot {
            button(switcherComponentButton).wait().checkExists()
            button(switcherScreenButton).wait().checkExists()
            return AccountSwitcherSampleAppRobot()
        }
    }

    func showSwitcherComponent() -> AccountSwitcherComponentRobot {
        button(switcherComponentButton).tap()
        return AccountSwitcherComponentRobot()
    }

    func showSwitcherScreen() -> AccountSwitcherScreenRobot {
        button(switcherScreenButton).tap()
        return AccountSwitcherScreenRobot()
    }

}
