//
//  Environments.swift
//  ProtonCore-Login-Tests - Created on 19.01.2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import Foundation

import ProtonCore_Doh
@testable import ProtonCore_Login

class BlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.blackApiHost

    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    // singleton
    static let `default` = try! BlackDoHMail()
}

class ChargaffBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.chargaffBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.chargaffBlackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.chargaffBlackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.chargaffBlackApiHost

    var defaultPath: String = ObfuscatedConstants.chargaffBlackDefaultPath
    // singleton
    static let `default` = try! ChargaffBlackDevDoHMail()
}

class PaymentsBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost

    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    // singleton
    static let `default` = try! PaymentsBlackDevDoHMail()
}

class SalamBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.salamBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.salamBlackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.salamBlackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.salamBlackApiHost

    var defaultPath: String = ObfuscatedConstants.salamBlackDefaultPath
    // singleton
    static let `default` = try! SalamBlackDevDoHMail()
}

class LiveDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    /// defind your default host
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    /// defind your query host
    var apiHost: String = ObfuscatedConstants.liveApiHost
    /// singleton
    static let `default` = try! LiveDoHMail()
}
