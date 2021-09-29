//
//  Environments.swift
//  Example-Payments - Created on 01/02/2021.
//
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

import Foundation
import ProtonCore_Doh
import ProtonCore_Payments

class BlackDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    static let `default` = try! BlackDoH()
}

class LowellBlackDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.lowellBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.lowellBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.lowellBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.lowellBlackApiHost
    var defaultPath: String = ObfuscatedConstants.lowellBlackDefaultPath
    static let `default` = try! LowellBlackDoH()
}

class PaymentsBlackDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    var defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    static let `default` = try! PaymentsBlackDoH()
}

class ProdDoH: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    var apiHost: String = ObfuscatedConstants.liveApiHost
    static let `default` = try! ProdDoH()
}
