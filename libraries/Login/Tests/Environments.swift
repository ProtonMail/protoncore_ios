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

class PopperBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.popperBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.popperBlackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.popperBlackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.popperBlackApiHost

    var defaultPath: String = ObfuscatedConstants.popperBlackDefaultPath
    // singleton
    static let `default` = try! PopperBlackDevDoHMail()
}

class OhmBlackDevDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.ohmBlackSignupDomain
    var captchaHost: String = ObfuscatedConstants.ohmBlackCaptchaHost
    // defind your default host
    var defaultHost: String = ObfuscatedConstants.ohmBlackDefaultHost
    // defind your query host
    var apiHost: String = ObfuscatedConstants.ohmBlackApiHost

    var defaultPath: String = ObfuscatedConstants.ohmBlackDefaultPath
    // singleton
    static let `default` = try! OhmBlackDevDoHMail()
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
