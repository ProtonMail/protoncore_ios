//
//  ProtonCoreBaseTestCase.swift
//  ProtonCore-TestingToolkit-UITests-Core - Created on 18.10.21.
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import pmtest
import XCTest
import ProtonCore_Log

open class ProtonCoreBaseTestCase: CoreTestCase {
    
    public let app = XCUIApplication()
    public var bundleIdentifier: String = "ch.protontech.core.ios.testing-toolkit.uitests"
    public var launchArguments: [String] = []
    public var launchEnvironment: [String: String] = [:]
    
    public var uiTestBundle: Bundle? {
        Bundle.allBundles.first(where: { $0.bundleIdentifier == bundleIdentifier })
    }
    
    public var dynamicDomain: String? {
        uiTestBundle?.object(forInfoDictionaryKey: "DYNAMIC_DOMAIN").flatMap { domain in
            guard let dynamicDomain = domain as? String, !dynamicDomain.isEmpty
            else { return nil }
            return dynamicDomain
        }
    }
    
    public var dynamicDomainAvailable: Bool { dynamicDomain != nil }
    
    open var host: String? { dynamicDomain.map { "https://\($0)" } }
    
    public func beforeSetUp(bundleIdentifier: String,
                            launchArguments: [String] = [],
                            launchEnvironment: [String: String] = [:]) {
        self.bundleIdentifier = bundleIdentifier
        self.launchArguments = launchArguments
        self.launchEnvironment = launchEnvironment
    }
        
    open override func setUp() {
        super.setUp()
        launchArguments.append("RunningInUITests")
        launchEnvironment["UITestsLogsDirectory"] = PMLog.logsDirectory!.absoluteString
        if let dynamicDomain = dynamicDomain {
            print("Passing dynamic domain to the XCUIApplication: \(dynamicDomain)")
            launchEnvironment["DYNAMIC_DOMAIN"] = dynamicDomain
        } else {
            print("Dynamic domain not found, nothing passed to XCUIApplication")
            print(uiTestBundle?.infoDictionary ?? "")
        }
        app.launchArguments = launchArguments
        app.launchEnvironment = launchEnvironment
        app.launch()
    }

    open override func tearDown() {
        super.tearDown()
        guard let log = PMLog.logFile else { return }
        PMLog.info("UI TEST ENDED")
        let logsAttachment = XCTAttachment(contentsOfFile: log)
        logsAttachment.lifetime = .keepAlways
        add(logsAttachment)
        try? FileManager.default.removeItem(at: log)
    }
}
