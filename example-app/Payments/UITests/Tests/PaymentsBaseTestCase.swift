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

class PaymentsBaseTestCase: ProtonCoreBaseTestCase {
    
    var doh: DoH & ServerConfig {
        let customDomain = dynamicDomain.map { "https://\($0)" } ?? ObfuscatedConstants.blackDefaultHost
        return try! CustomServerConfigDoH(
            signupDomain: customDomain,
            captchaHost: "https://api.\(customDomain)",
            defaultHost: "https://\(customDomain)",
            apiHost: ObfuscatedConstants.blackApiHost,
            defaultPath: ObfuscatedConstants.blackDefaultPath
        )
    }
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: PaymentsSampleAppRobot!
        
    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-Payments-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.payments, to: PaymentsSampleAppRobot.self)
    }
}
    
