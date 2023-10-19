//
//  MainRobot.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import fusion
import XCTest
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
import ProtonCoreTestingToolkitUITestsPaymentsUI
#else
import ProtonCoreTestingToolkit
#endif

private let titleLabelText = "Payments example"
private let showPaymentsUIButtonLabelText = "New user subscription with UI"
private let environmentBlackText = "black"
private let environmentPaymentText = "payments"
private let environmentCustomText = "custom"

public final class PaymentsSampleAppRobot: CoreElements {
    
    public func showPaymentsUI() -> PaymentsNewUserSubscriptionUIRobot {
        button(showPaymentsUIButtonLabelText).waitUntilExists().tap()
        return PaymentsNewUserSubscriptionUIRobot()
    }

    public func backgroundApp<T: CoreElements>(robot _: T.Type) -> T {
        XCUIDevice.shared.press(.home)
        return T()
    }
    
    public func activateApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        app.activate()
        return T()
    }
    
    public func terminateApp<T: CoreElements>(app: XCUIApplication, robot _: T.Type) -> T {
        app.terminate()
        return T()
    }
    
    @discardableResult
    public func changeEnvironmentToBlack() -> PaymentsSampleAppRobot {
        button(environmentBlackText).tap()
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToPayments() -> PaymentsSampleAppRobot {
        button(environmentPaymentText).tap()
        return self
    }
    
    @discardableResult
    public func changeEnvironmentToCustomIfDomainHereBlackOtherwise(_ dynamicDomainAvailable: Bool) -> PaymentsSampleAppRobot {
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
            button(titleLabelText).waitUntilExists().checkExists()
        }
        
        public func buttonPaymentsUIVisible() {
            button(showPaymentsUIButtonLabelText).waitUntilExists().checkExists()
        }
    }
}
