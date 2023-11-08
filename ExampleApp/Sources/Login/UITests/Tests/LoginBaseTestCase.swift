//
//  LoginBaseTestCase.swift
//  SampleAppUITests
//
//  Created by denys zelenchuk on 11.02.21.
//

import fusion
import XCTest
import ProtonCoreLog
import ProtonCoreDoh
#if canImport(ProtonCoreTestingToolkitUITestsCore)
import ProtonCoreTestingToolkitUITestsCore
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreObfuscatedConstants

class LoginBaseTestCase: ProtonCoreBaseTestCase {

    let testData = TestData()

    var doh: DoHInterface {
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
    var appRobot: LoginSampleAppRobot!

    override func setUp() {
        beforeSetUp(bundleIdentifier: "ch.protontech.core.ios.Example-Login-UITests")
        super.setUp()
        appRobot = entryRobot.tap(.login, to: LoginSampleAppRobot.self)
    }
}
