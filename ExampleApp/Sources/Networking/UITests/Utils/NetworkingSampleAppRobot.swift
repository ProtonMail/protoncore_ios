//
//  NetworkingSampleAppRobot.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import fusion
import XCTest
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsHumanVerification
#else
import ProtonCoreTestingToolkit
#endif


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
