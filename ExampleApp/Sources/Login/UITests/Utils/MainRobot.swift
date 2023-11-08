//
//  MainRobot.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import fusion
import XCTest
import ProtonCoreFeatureSwitch
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsLogin
#else
import ProtonCoreTestingToolkit
#endif

private let showLoginButtonLabelText = "Show login"
private let showSignupButtonLabelText = "Show signup"
private let logoutButtonLabelText = "Logout"
private let environmentBlackText = "black"
private let environmentProdText = "prod"
private let environmentPaymentsBlackText = "payments"
private let environmentFosseyBlackText = "fossey"
private let environmentCustomText = "custom"
private let accountExternal = "external"
private let accountInternal = "internal"

private let welcomeScreenNoneText = "no screen"
private let welcomeScreenMailText = "mail"
private let welcomeScreenVpnText = "vpn"
private let welcomeScreenDriveText = "drive"
private let welcomeScreenCalendarText = "calendar"

private let closeSwitchText = "LoginViewController.closeButtonSwitch"
private let planSelectorSwitchText = "LoginViewController.planSelectorSwitch"
private let humanVerificationSwitch = "LoginViewController.humanVerificationSwitch"
private let logoutDialogText = "Logout"
private let accountTypeUsername = "username"
private let mailApp = "Login-Mail-AppStoreIAP"
private let hv3LabelText = "v3"

private let deleteAccountButtonLabelText = "Delete account"
private let deleteAccountDeleteButton = "Delete"
private let deleteAccountCancelButton = "Cancel"
private let deleteAccountWarning = "Yes, I want to permanently delete this account and all its data."

public enum SignupInitialMode {
    case `internal`
    case external
}

public enum WelcomeScreenMode {
    case noScreen
    case mail
    case vpn
    case drive
    case calendar
}

public final class LoginSampleAppRobot: CoreElements {
    
    @discardableResult
    public func showLogin() -> LoginRobot {
        button(showLoginButtonLabelText).waitUntilExists().tap()
        return LoginRobot()
    }
    
    public func showWelcomeScreen() -> WelcomeRobot {
        button(showLoginButtonLabelText).waitUntilExists().tap()
        return WelcomeRobot()
    }
    
    public func showSignup() -> SignupRobot {
        button(showSignupButtonLabelText).tap()
        return SignupRobot()
    }
    
    // TODO to migrate to pmtools
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
    public func changeEnvironmentToProd() -> LoginSampleAppRobot {
        button(environmentProdText).tap()
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToPaymentsBlack() -> LoginSampleAppRobot {
        button(environmentPaymentsBlackText).tap()
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToFosseyBlack() -> LoginSampleAppRobot {
        button(environmentFosseyBlackText).tap()
        return self
    }
    
    public func changeAccountTypeToExternal() -> LoginSampleAppRobot {
        button(accountExternal).tap()
        return self
    }
    
    public func changeAccountTypeToInternal() -> LoginSampleAppRobot {
        button(accountInternal).tap()
        return self
    }
    
    public func changeAccountTypeToUsername() -> LoginSampleAppRobot {
        button(accountTypeUsername).tap()
        return self
    }
    
    @discardableResult
    public func logoutButtonTap() -> LoginSampleAppRobot {
        button(logoutButtonLabelText).waitUntilExists(time: 180).tap()
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
    
    @discardableResult
    public func humanVerificationSwitchTap() -> LoginSampleAppRobot {
        swittch(humanVerificationSwitch).tap()
        return self
    }
    
    @discardableResult
    public func showDeleteAccount() -> LoginSampleAppRobot {
        button(deleteAccountButtonLabelText).waitUntilExists().tap()
        return self
    }
    
    public let verify = Verify()
    public let verifyDeleteAccount = VerifyDeleteAccount()
    
    public class Verify: CoreElements {
        public func buttonLogoutVisible() {
            button(logoutButtonLabelText).waitUntilExists(time: 90).checkExists()
        }
        
        public func buttonLogoutIsNotVisible() {
            button(logoutButtonLabelText).waitUntilGone()
        }
        
        public func dialogLogoutShown() -> LoginSampleAppRobot {
            staticText(logoutDialogText).waitUntilExists(time: 20).checkExists()
            return LoginSampleAppRobot()
        }
        
        public func buttonLoginVisible() {
            button(showLoginButtonLabelText).waitUntilExists().checkExists()
        }
        
        @discardableResult
        public func buttonDeleAccountVisible() -> LoginSampleAppRobot {
            button(deleteAccountButtonLabelText).waitUntilExists(time: 90).checkExists()
            return LoginSampleAppRobot()
        }
    }
    
    public class VerifyDeleteAccount: CoreElements {
        public func deleteAccountShown() {
            button(deleteAccountDeleteButton).waitUntilExists(time: 30).checkExists()
            button(deleteAccountCancelButton).checkExists()
            staticText(deleteAccountWarning).checkExists()
        }
    }
    
    @discardableResult
    public func updateFeatures(featureEnv: String) -> LoginSampleAppRobot {
        XCUIApplication().launchEnvironment = ["FeatureSwitch": featureEnv]
        return self
    }
}
