//
//  Environments.swift
//  ExampleApp
//
//  Created by Krzysztof Siejkowski on 07/10/2021.
//

import ProtonCore_Doh
import ProtonCore_ObfuscatedConstants

class ProdDoHMail: DoH, ServerConfig {

    let signupDomain: String = ObfuscatedConstants.liveSignupDomain
    let defaultHost: String = ObfuscatedConstants.liveDefaultHost
    let captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    let humanVerificationV3Host: String = ObfuscatedConstants.liveHumanVerificationV3Host
    let accountHost: String = ObfuscatedConstants.liveAccountHost
    let apiHost: String = ObfuscatedConstants.liveApiHost
    let defaultPath: String = ObfuscatedConstants.liveDefaultPath

    static let `default` = ProdDoHMail()
}

class ProdDoHVPN: DoH, ServerConfig {

    let signupDomain: String = ObfuscatedConstants.liveVPNSignupDomain
    let defaultHost: String = ObfuscatedConstants.liveVPNDefaultHost
    let captchaHost: String = ObfuscatedConstants.liveVPNCaptchaHost
    let humanVerificationV3Host: String = ObfuscatedConstants.liveVPNHumanVerificationV3Host
    let accountHost: String = ObfuscatedConstants.liveVPNAccountHost
    let apiHost: String = ObfuscatedConstants.liveVPNApiHost
    let defaultPath: String = ObfuscatedConstants.liveVPNDefaultPath

    static let `default` = ProdDoHVPN()
}

class BlackDoH: DoH, ServerConfig {
    let signupDomain: String = ObfuscatedConstants.blackSignupDomain
    let captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    let humanVerificationV3Host: String = ObfuscatedConstants.blackHumanVerificationV3Host
    let accountHost: String = ObfuscatedConstants.blackAccountHost
    let defaultHost: String = ObfuscatedConstants.blackDefaultHost
    let apiHost: String = ObfuscatedConstants.blackApiHost
    let defaultPath: String = ObfuscatedConstants.blackDefaultPath
    
    static let `default` = BlackDoH()
}

class PaymentsBlackDoH: DoH, ServerConfig {
    let signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    let captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    let humanVerificationV3Host: String = ObfuscatedConstants.paymentsBlackHumanVerificationV3Host
    let accountHost: String = ObfuscatedConstants.paymentsBlackAccountHost
    let defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    let apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    let defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    
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
