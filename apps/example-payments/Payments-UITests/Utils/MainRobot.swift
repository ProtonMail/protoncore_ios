//
//  MainRobot.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import pmtest
import XCTest
import ProtonCore_TestingToolkit

fileprivate let titleLabelText = "Payments example"
fileprivate let showPaymentsUIButtonLabelText = "New user subscription with UI"
fileprivate let environmentBlackText = "black"
fileprivate let environmentPaymentText = "payments"
fileprivate let environmentCustomText = "custom"

public final class MainRobot: CoreElements {
    private var app: XCUIApplication = XCUIApplication()
    
    public func showPaymentsUI() -> NewUserSubscriptionUIRobot {
        button(showPaymentsUIButtonLabelText).wait().tap()
        return NewUserSubscriptionUIRobot()
    }

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
    
    @discardableResult
    public func changeEnvironmentToPayments() -> MainRobot {
        button(environmentPaymentText).tap()
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToCustomIfDomainHereBlackOtherwise(_ dynamicDomainAvailable: Bool) -> MainRobot {
        if dynamicDomainAvailable {
            button(environmentCustomText).tap()
        } else {
            button(environmentBlackText).tap()
        }
        return self
    }
    
    public let verify = Verify()
    
    public class Verify: CoreElements {
        public func mainScreenVisible() {
            button(titleLabelText).wait().checkExists()
        }
        
        public func buttonPaymentsUIVisible() {
            button(showPaymentsUIButtonLabelText).wait().checkExists()
        }
    }
}

