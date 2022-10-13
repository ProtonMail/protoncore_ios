//
//  LoginExtAccountsTests.swift
//  SampleAppUITests
//
//  Created by Greg on 29.09.22.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit

class LoginExtAccountsTests: LoginBaseTestCase {

    let mainRobot = LoginSampleAppRobot()
    
    override func setUp() {
        beforeSetUp(launchArguments: ["EXT_ACCOUNT_NOT_SUPPORTED"])
        super.setUp()
    }
    
    func testLoginExtAcountNotSupported() {
        mainRobot.showLogin()
            .fillUsername(username: "ExtUser")
            .fillpassword(password: "123")
            .signIn(robot: LoginRobot.self)
            .verify.bannerExtAccountErrorShown()
    }
}
