//
//  EnvironmentsForUITests.swift
//  ExampleLocalMailAppUITests
//
//  Created by Greg on 23.07.21.
//

import Foundation
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Doh
import ProtonCore_Payments
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

class OhmBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.ohmBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.ohmBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.ohmBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.ohmBlackApiHost
    var defaultPath: String = ObfuscatedConstants.ohmBlackDefaultPath
    static let `default` = try! OhmBlackDoHMail()
}
