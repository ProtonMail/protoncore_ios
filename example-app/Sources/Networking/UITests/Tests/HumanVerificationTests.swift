//
//  HumanVerificationTests.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest
import ProtonCore_TestingToolkit

class HumanVerificationTests: NetworkingBaseTestCase {
    
    func testHumanVerificationV2IsClosable() {
        appRobot
            .humanVerificationUnauthShow()
            .verify.humanVerificationScreenIsShown()
            .close(to: NetworkingSampleAppRobot.self)
            .verify.hvUnauthButtonVisible()
    }
}
