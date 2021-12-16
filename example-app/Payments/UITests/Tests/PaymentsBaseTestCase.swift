//
//  PaymentsBaseTestCase.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import pmtest
import XCTest
import ProtonCore_Doh
import ProtonCore_TestingToolkit
import ProtonCore_ObfuscatedConstants

class PaymentsBaseTestCase: ProtonCoreBaseTestCase {
    
    let testData = TestData()
    
    var doh: DoH & ServerConfig {
        if let customDomain = dynamicDomain.map({ "\($0)" }) {
            return CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                humanVerificationV3Host: "https://verify.\(customDomain)",
                accountHost: "https://account.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
        } else {
            return CustomServerConfigDoH(
                signupDomain: ObfuscatedConstants.blackSignupDomain,
                captchaHost: ObfuscatedConstants.blackCaptchaHost,
                humanVerificationV3Host: ObfuscatedConstants.blackHumanVerificationV3Host,
                accountHost: ObfuscatedConstants.blackAccountHost,
                defaultHost: ObfuscatedConstants.blackDefaultHost,
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
        }
    }
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: PaymentsSampleAppRobot!
        
    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-Payments-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.payments, to: PaymentsSampleAppRobot.self)
    }
}
    
