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

    static let `default` = try! ProdDoHMail()
}

class BlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    static let `default` = try! BlackDoHMail()
}

class ChargaffBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.chargaffBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.chargaffBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.chargaffBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.chargaffBlackApiHost
    var defaultPath: String = ObfuscatedConstants.chargaffBlackDefaultPath
    static let `default` = try! ChargaffBlackDevDoHMail()
}

class PaymentsBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    static let `default` = try! PaymentsBlackDevDoHMail()
}

class MauryBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.mauryBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.mauryBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.mauryBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.mauryBlackApiHost
    var defaultPath: String = ObfuscatedConstants.mauryBlackDefaultPath
    static let `default` = try! MauryBlackDevDoHMail()
}

class KlaprothBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.klaprothBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.klaprothBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.klaprothBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.klaprothBlackApiHost
    var defaultPath: String = ObfuscatedConstants.klaprothBlackDefaultPath
    static let `default` = try! KlaprothBlackDevDoHMail()
}

class DaltonBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.daltonBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.daltonBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.daltonBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.daltonBlackApiHost
    var defaultPath: String = ObfuscatedConstants.daltonBlackDefaultPath
    static let `default` = try! DaltonBlackDoHMail()
}

class LowellBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.lowellBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.lowellBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.lowellBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.lowellBlackApiHost
    var defaultPath: String = ObfuscatedConstants.lowellBlackDefaultPath
    static let `default` = try! LowellBlackDoHMail()
}

class VerificationBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.verificationBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.verificationBlackCaptchaHost
    var defaultHost: String = ObfuscatedConstants.verificationBlackDefaultHost
    var apiHost: String = ObfuscatedConstants.verificationBlackApiHost
    var defaultPath: String = ObfuscatedConstants.verificationBlackDefaultPath
    static let `default` = try! VerificationBlackDevDoHMail()
}
