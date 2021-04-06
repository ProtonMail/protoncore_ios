//
//  SampleAppRobot.swift
//  SampleAppUITests
//
//  Created by Krzysztof Siejkowski on 07/06/2021.
//

import Foundation
import pmtest
import ProtonCore_TestingToolkit

private let switcherComponentButton = "ViewController.switcherComponentButton"
private let switcherScreenButton = "ViewController.switcherScreenButton"

final class SampleAppRobot: CoreElements {

    public let verify = Verify()

    public final class Verify: CoreElements {
        @discardableResult
        public func sampleAppScreenIsDisplayed() -> SampleAppRobot {
            button(switcherComponentButton).wait().checkExists()
            button(switcherScreenButton).wait().checkExists()
            return SampleAppRobot()
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
