//
//  Environments.swift
//  ExampleApp
//
//  Created by Krzysztof Siejkowski on 07/10/2021.
//

import ProtonCore_Doh
import ProtonCore_ObfuscatedConstants

class ProdDoHMail: DoH, ServerConfig {

    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    var humanVerificationV3Host: String = ObfuscatedConstants.liveHumanVerificationV3Host
    var apiHost: String = ObfuscatedConstants.liveApiHost
    var defaultPath: String = ObfuscatedConstants.liveDefaultPath

    static let `default` = ProdDoHMail()
}

class ProdDoHVPN: DoH, ServerConfig {

    var signupDomain: String = ObfuscatedConstants.liveVPNSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveVPNDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveVPNCaptchaHost
    var humanVerificationV3Host: String = ObfuscatedConstants.liveVPNHumanVerificationV3Host
    var apiHost: String = ObfuscatedConstants.liveVPNApiHost
    var defaultPath: String = ObfuscatedConstants.liveVPNDefaultPath

    static let `default` = ProdDoHVPN()
}

class BlackDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var humanVerificationV3Host: String = ObfuscatedConstants.blackHumanVerificationV3Host
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    
    static let `default` = BlackDoH()
}

class PaymentsBlackDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var humanVerificationV3Host: String = ObfuscatedConstants.paymentsHumanVerificationV3Host
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    
    static let `default` = PaymentsBlackDoH()
}

var dohStatus: DoHStatus = .off

func updateDohStatus(to status: DoHStatus) {
    ProdDoHMail.default.status = status
    ProdDoHVPN.default.status = status
    BlackDoH.default.status = status
    PaymentsBlackDoH.default.status = status
    dohStatus = status
}
