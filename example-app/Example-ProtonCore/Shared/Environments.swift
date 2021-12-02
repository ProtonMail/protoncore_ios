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
    var apiHost: String = ObfuscatedConstants.liveApiHost
    var defaultPath: String = ObfuscatedConstants.liveDefaultPath

    static let `default` = ProdDoHMail()
}

class BlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    
    static let `default` = BlackDoHMail()
}

class PaymentsBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    
    static let `default` = PaymentsBlackDevDoHMail()
}

var dohStatus: DoHStatus = .off

func updateDohStatus(to status: DoHStatus) {
    ProdDoHMail.default.status = status
    BlackDoHMail.default.status = status
    PaymentsBlackDevDoHMail.default.status = status
    dohStatus = status
}
