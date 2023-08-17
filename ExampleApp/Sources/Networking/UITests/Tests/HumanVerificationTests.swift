//
//  HumanVerificationTests.swift
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

class HumanVerificationTests: NetworkingBaseTestCase {
    
    func testHumanVerificationV2IsClosable() {
        appRobot
            .humanVerificationUnauthShow()
            .verify.humanVerificationScreenIsShown()
            .close(to: NetworkingSampleAppRobot.self)
            .verify.hvUnauthButtonVisible()
    }
}
