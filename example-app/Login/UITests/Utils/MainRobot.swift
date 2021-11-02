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
fileprivate let environmentPaymentsBlackText = "payments"
fileprivate let environmentCustomText = "custom"
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

fileprivate let closeSwitchText = "LoginViewController.closeButtonSwitch"
fileprivate let planSelectorSwitchText = "LoginViewController.planSelectorSwitch"
fileprivate let logoutDialogText = "Logout"
fileprivate let accountTypeUsername = "username"
fileprivate let mailApp = "Login-Mail-AppStoreIAP"

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

public final class LoginSampleAppRobot: CoreElements {
    
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
    public func backgroundApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        XCUIDevice.shared.press(.home)
        let background = app.wait(for: .runningBackground, timeout: 5)
        XCTAssertTrue(background)
        return T()
    }
    
    public func activateApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        app.activate()
        XCTAssertTrue(app.state == .runningForeground)
        return T()
    }
    
    public func activateAppWithSiri<T: CoreElements>(robot _: T.Type) -> T {
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Open \(mailApp)")
        return T()
    }
    
    public func launchApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        app.launch()
        return T()
    }
    
    public func terminateApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        app.terminate()
        return T()
    }
    
    @discardableResult
    public func changeEnvironmentToCustomIfDomainHereBlackOtherwise(_ dynamicDomainAvailable: Bool) -> LoginSampleAppRobot {
        if dynamicDomainAvailable {
            button(environmentCustomText).tap()
        } else {
            button(environmentBlackText).tap()
        }
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToPaymentsBlack() -> LoginSampleAppRobot {
        button(environmentPaymentsBlackText).tap()
        return self
    }
    
    public func changeAccountTypeToExternal() -> LoginSampleAppRobot {
        button(accountExternal).tap()
        return self
    }
    
    public func changeAccountTypeToUsername() -> LoginSampleAppRobot {
        button(accountTypeUsername).tap()
        return self
    }
    
    @discardableResult
    public func logoutButtonTap() -> LoginSampleAppRobot {
        button(logoutButtonLabelText).wait(time: 180).tap()
        return self
    }
    
    @discardableResult
    public func changeSignupMode(mode: SignupMode) -> LoginSampleAppRobot {
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
    public func changeWelcomeScreenMode(to mode: WelcomeScreenMode) -> LoginSampleAppRobot {
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
    public func closeSwitchTap() -> LoginSampleAppRobot {
        swittch(closeSwitchText).tap()
        return self
    }
    
    @discardableResult
    public func planSelectorSwitchTap() -> LoginSampleAppRobot {
        swittch(planSelectorSwitchText).tap()
        return self
    }
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        public func buttonLogoutVisible() {
            button(logoutButtonLabelText).wait(time: 90).checkExists()
        }
        
        public func buttonLogoutIsNotVisible() {
            button(logoutButtonLabelText).wait().checkDoesNotExist()
        }
        
        public func dialogLogoutShown() -> LoginSampleAppRobot {
            staticText(logoutDialogText).wait(time: 20).checkExists()
            return LoginSampleAppRobot()
        }
        
        public func buttonLoginVisible() {
            button(showLoginButtonLabelText).wait().checkExists()
        }
    }
}
