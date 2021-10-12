//
//  PaymentsBaseTestCase.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import pmtest
import ProtonCore_Doh
import XCTest

class PaymentsBaseTestCase: CoreTestCase {
    
    public var app = XCUIApplication()
    
    var uiTestBundle: Bundle? {
        Bundle.allBundles.first(where: { $0.bundleIdentifier == "ch.protontech.core.ios.Example-Payments-UITests" })
    }
    
    var dynamicDomain: String? {
        uiTestBundle?.object(forInfoDictionaryKey: "DYNAMIC_DOMAIN").flatMap { domain in
            guard let dynamicDomain = domain as? String, !dynamicDomain.isEmpty else { return nil }
            return dynamicDomain
        }
    }
    
    var dynamicDomainAvailable: Bool { dynamicDomain != nil }
    
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
        super.setUp()
        app.launchArguments = ["RunningInUITests"]
        if let dynamicDomain = dynamicDomain {
            print("Passing dynamic domain to the XCUIApplication: \(dynamicDomain)")
            app.launchEnvironment = ["DYNAMIC_DOMAIN": dynamicDomain]
        } else {
            print("Dynamic domain not found, nothing passed to XCUIApplication")
            print(uiTestBundle?.infoDictionary ?? "")
        }
        app.launch()
        appRobot = entryRobot.tap(.payments, to: PaymentsSampleAppRobot.self)
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
    
