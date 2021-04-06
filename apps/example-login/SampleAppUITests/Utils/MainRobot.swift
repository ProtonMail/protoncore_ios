//
//  MainRobot.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest
import ProtonCore_TestingToolkit

fileprivate let showLoginButtonLabelText = "Show login"
fileprivate let showSignupButtonLabelText = "Show signup"
fileprivate let logoutButtonLabelText = "Logout"
fileprivate let environmentBlackText = "black"
fileprivate let accountExternal = "external"

fileprivate let signupModeBothIntText = "both int"
fileprivate let signupModeBothExtText = "both ext"
fileprivate let signupModeIntOnlyText = "int ONLY"
fileprivate let signupModeExtOnlyText = "ext ONLY"
fileprivate let signupModeNoneText = "no signup"

fileprivate let welcomeScreenNoneText = "no screen"
fileprivate let welcomeScreenMailText = "mail"
fileprivate let welcomeScreenVpnText = "vpn"
fileprivate let welcomeScreenDriveText = "drive"
fileprivate let welcomeScreenCalendarText = "calendar"

fileprivate let closeSwitchText = "ViewController.closeButtonSwitch"
fileprivate let planSelectorSwitchText = "ViewController.planSelectorSwitch"
fileprivate let logoutDialogText = "Logout"
fileprivate let accountTypeUsername = "username"

public enum SignupInitalMode {
    case `internal`
    case external
}

public enum SignupMode {
    case notAvailable
    case `internal`
    case external
    case both(SignupInitalMode)
}

public enum WelcomeScreenMode {
    case noScreen
    case mail
    case vpn
    case drive
    case calendar
}

public final class MainRobot: CoreElements {
    private var app: XCUIApplication = XCUIApplication()
    
    public func showLogin() -> LoginRobot {
        button(showLoginButtonLabelText).wait().tap()
        return LoginRobot()
    }
    
    public func showWelcomeScreen() -> WelcomeRobot {
        button(showLoginButtonLabelText).wait().tap()
        return WelcomeRobot()
    }
    
    public func showSignup() -> SignupRobot {
        button(showSignupButtonLabelText).tap()
        return SignupRobot()
    }
    
    //TODO to migrate to pmtools
    public func backgroundApp<T: CoreElements>(robot _: T.Type) -> T {
        XCUIDevice.shared.press(.home)
        return T()
    }
    
    public func activateApp<T: CoreElements>(robot _: T.Type) -> T {
        app.activate()
        return T()
    }
    
    public func terminateApp<T: CoreElements>(robot _: T.Type) -> T {
        app.terminate()
        return T()
    }
    
    @discardableResult
    public func changeEnvironmentToBlack() -> MainRobot {
        button(environmentBlackText).tap()
        return self
    }
    
    public func changeAccountTypeToExternal() -> MainRobot {
        button(accountExternal).tap()
        return self
    }
    
    public func changeAccountTypeToUsername() -> MainRobot {
        button(accountTypeUsername).tap()
        return self
    }
    
    @discardableResult
    public func logoutButtonTap() -> MainRobot {
        button(logoutButtonLabelText).wait(time: 180).tap()
        return self
    }
    
    @discardableResult
    public func changeSignupMode(mode: SignupMode) -> MainRobot {
        switch mode {
        case .both(let initialMode):
            switch(initialMode) {
            case .internal:
                button(signupModeBothIntText).tap()
            case .external:
                button(signupModeBothExtText).tap()
            }
        case .internal:
            button(signupModeIntOnlyText).tap()
        case .external:
            button(signupModeExtOnlyText).tap()
        case .notAvailable:
            button(signupModeNoneText).tap()
        }
        return self
    }
    
    @discardableResult
    public func changeWelcomeScreenMode(to mode: WelcomeScreenMode) -> MainRobot {
        switch mode {
        case .noScreen: button(welcomeScreenNoneText).tap()
        case .mail: button(welcomeScreenMailText).tap()
        case .vpn: button(welcomeScreenVpnText).tap()
        case .drive: button(welcomeScreenDriveText).tap()
        case .calendar: button(welcomeScreenCalendarText).tap()
        }
        return self
    }
    
    @discardableResult
    public func closeSwitchTap() -> MainRobot {
        swittch(closeSwitchText).tap()
        return self
    }
    
    @discardableResult
    public func planSelectorSwitchTap() -> MainRobot {
        swittch(planSelectorSwitchText).tap()
        return self
    }
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        public func buttonLogoutVisible() {
            button(logoutButtonLabelText).wait(time: 60).checkExists()
        }
        
        public func buttonLogoutIsNotVisible() {
            button(logoutButtonLabelText).wait().checkDoesNotExist()
        }
        
        public func dialogLogoutShown() -> MainRobot {
            staticText(logoutDialogText).wait(time: 20).checkExists()
            return MainRobot()
        }
        
        public func buttonLoginVisible() {
            button(showLoginButtonLabelText).wait().checkExists()
        }
    }
}
