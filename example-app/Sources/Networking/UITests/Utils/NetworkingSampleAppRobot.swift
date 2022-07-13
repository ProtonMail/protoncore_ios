//
//  NetworkingSampleAppRobot.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest
import ProtonCore_TestingToolkit

fileprivate let humanVerificationUnauthButton = "Human Verification unauth test"

public final class NetworkingSampleAppRobot: CoreElements {
    
    public func humanVerificationUnauthShow() -> HumanVerificationRobot {
        button(humanVerificationUnauthButton).wait().tap()
        return HumanVerificationRobot()
    }
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        public func hvUnauthButtonVisible() {
            button(humanVerificationUnauthButton).wait().checkExists()
        }
    }
}
