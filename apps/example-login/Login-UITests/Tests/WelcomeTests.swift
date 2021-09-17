//
//  WelcomeTests.swift
//  SampleAppUITests
//
//  Created by Krzysztof Siejkowski on 28/06/2021.
//

import XCTest
import pmtest
import ProtonCore_TestingToolkit

final class WelcomeTests: BaseTestCase {

    let mainRobot = MainRobot()
    
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
            .changeSignupMode(mode: .notAvailable)
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .verify.signUpButtonDoesNotExist()
    }

    func testSignUpButtonIsPresentedOnWelcomeScreenWhenItShouldBe() {
        mainRobot
            .changeSignupMode(mode: .internal)
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .verify.signUpButtonExists()
    }

    func testLoginButtonLeadsToLoginScreenWithSignUpWhenNeeded() {
        mainRobot
            .changeSignupMode(mode: .internal)
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .logIn()
            .verify.switchToCreateAccountButtonIsShown()
    }

    func testLoginButtonLeadsToSignUpLessLoginScreenWhenNeeded() {
        mainRobot
            .changeSignupMode(mode: .notAvailable)
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .logIn()
            .verify.switchToCreateAccountButtonIsNotPresented()
    }

    func testSignUpButtonLeadsToSignUpScreen() {
        mainRobot
            .changeSignupMode(mode: .internal)
            .changeWelcomeScreenMode(to: .mail)
            .showWelcomeScreen()
            .signUp()
            .verify.signupScreenIsShown()
    }

}
