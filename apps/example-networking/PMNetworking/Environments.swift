//
//  Environment.swift
//  PMNetworking
//
//  Created on 22/01/2021.
//
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import ProtonCore_Doh

class BlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    static let `default` = try! BlackDoHMail()
}

class DaltonBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.daltonBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.daltonBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.daltonBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.daltonBlackApiHost
    var defaultPath: String = ObfuscatedConstants.daltonBlackDefaultPath
    static let `default` = try! DaltonBlackDoHMail()
}

class ChargaffBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.chargaffBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.chargaffBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.chargaffBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.chargaffBlackApiHost
    var defaultPath: String = ObfuscatedConstants.chargaffBlackDefaultPath
    static let `default` = try! ChargaffBlackDoHMail()
}

class PaymentsBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    static let `default` = try! PaymentsBlackDoHMail()
}

class ProdDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    var apiHost: String = ObfuscatedConstants.liveApiHost
    static let `default` = try! ProdDoHMail()
}
