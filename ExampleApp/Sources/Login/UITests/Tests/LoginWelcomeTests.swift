//
//  LoginWelcomeTests.swift
//  SampleAppUITests
//
//  Created by Krzysztof Siejkowski on 28/06/2021.
//

import XCTest
import fusion
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsLogin
#else
import ProtonCoreTestingToolkit
#endif

final class LoginWelcomeTests: LoginBaseTestCase {

    let mainRobot = LoginSampleAppRobot()
    
    override func setUp() {
        super.setUp()
        
        mainRobot
            .changeEnvironmentToCustomIfDomainHereBlackOtherwise(dynamicDomainAvailable)
    }

    func testNoWelcomeScreenIsShown() {
        mainRobot
            .changeWelcomeScreenMode(to: .noScreen)
            .showWelcomeScreen()
            .verify.welcomeScreenIsNotPresented()
    }

    func testMailWelcomeScreenIsShown() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .verify.welcomeScreenVariantIsShown(variant: .mail)
    }

    func testVpnWelcomeScreenIsShown() {
        mainRobot
            .changeWelcomeScreenMode(to: .vpn)
            .showWelcomeScreen()
            .verify.welcomeScreenVariantIsShown(variant: .vpn)
    }

    func testDriveWelcomeScreenIsShown() {
        mainRobot
            .changeWelcomeScreenMode(to: .drive)
            .showWelcomeScreen()
            .verify.welcomeScreenVariantIsShown(variant: .drive)
    }

    func testCalendarWelcomeScreenIsShown() {
        mainRobot
            .changeWelcomeScreenMode(to: .calendar)
            .showWelcomeScreen()
            .verify.welcomeScreenVariantIsShown(variant: .calendar)
    }

    func testSignUpButtonIsNotPresentedOnWelcomeScreenWhenItShouldNotBe() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .verify.signUpButtonDoesNotExist()
    }

    func testSignUpButtonIsPresentedOnWelcomeScreenWhenItShouldBe() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .verify.signUpButtonExists()
    }

    func testLoginButtonLeadsToLoginScreenWithSignUpWhenNeeded() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .logIn()
            .verify.switchToCreateAccountButtonIsShown()
    }

    func testLoginButtonLeadsToSignUpLessLoginScreenWhenNeeded() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .logIn()
            .verify.switchToCreateAccountButtonIsNotPresented()
    }

    func testSignUpButtonLeadsToSignUpScreen() {
        mainRobot
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .signUp()
            .verify.signupScreenIsShown()
    }

}
