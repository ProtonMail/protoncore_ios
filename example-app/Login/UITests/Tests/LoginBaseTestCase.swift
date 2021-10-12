//
//  LoginBaseTestCase.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import pmtest
import XCTest

class LoginBaseTestCase: CoreTestCase {
    
    let testData = TestData()
    public var app = XCUIApplication()
    
    var uiTestBundle: Bundle? {
        Bundle.allBundles.first(where: { $0.bundleIdentifier == "ch.protontech.core.ios.Example-Login-UITests" })
    }
    
    var dynamicDomain: String? {
        uiTestBundle?.object(forInfoDictionaryKey: "DYNAMIC_DOMAIN").flatMap { domain in
            guard let dynamicDomain = domain as? String, !dynamicDomain.isEmpty else { return nil }
            return dynamicDomain
        }
    }
    
    var dynamicDomainAvailable: Bool { dynamicDomain != nil }
    
    var host: String { dynamicDomain.map { "https://\($0)" } ?? ObfuscatedConstants.blackDefaultHost }
    
    let entryRobot = CoreExampleMainRobot()
    var appRobot: LoginSampleAppRobot!
        
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
        appRobot = entryRobot.tap(.login, to: LoginSampleAppRobot.self)
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
