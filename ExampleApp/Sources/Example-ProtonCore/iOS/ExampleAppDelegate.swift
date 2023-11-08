//
//  ExampleAppDelegate.swift
//  CoreExample - Created on 06/10/2021.
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

import ProtonCoreLog
import ProtonCoreObfuscatedConstants
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif
import UIKit
import Sentry

import CommonCrypto
import CryptoKit
import ProtonCoreUIFoundations

@main
class ExampleAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        injectDefaultCryptoImplementation()
        if let logsDirectory = ProcessInfo.processInfo.environment["UITestsLogsDirectory"] {
            PMLog.logsDirectory = URL(fileURLWithPath: logsDirectory, isDirectory: true)
        }
        setUpCrashReporting()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "DefaultConfiguration", sessionRole: connectingSceneSession.role)
    }

    private func setUpCrashReporting() {
        SentrySDK.start { options in
            options.dsn = ObfuscatedConstants.sentryDSN
            options.logLevel = .error
            options.debug = true
        }
        SentryCrash.sharedInstance().addConsoleLogToReport = true
    }
}
