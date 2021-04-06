//
//  Environments.swift
//  ExampleMailApp - Created on 01/02/2021.
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

import Foundation
import ProtonCore_Doh
import ProtonCore_Payments

class BlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.blackSignupDomain
    var defaultHost: String = ObfuscatedConstants.blackDefaultHost
    var captchaHost: String = ObfuscatedConstants.blackCaptchaHost
    var apiHost: String = ObfuscatedConstants.blackApiHost
    var defaultPath: String = ObfuscatedConstants.blackDefaultPath
    static let `default` = try! BlackDoHMail()
}

class OhmBlackDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.ohmBlackSignupDomain
    var defaultHost: String = ObfuscatedConstants.ohmBlackDefaultHost
    var captchaHost: String = ObfuscatedConstants.ohmBlackCaptchaHost
    var apiHost: String = ObfuscatedConstants.ohmBlackApiHost
    var defaultPath: String = ObfuscatedConstants.ohmBlackDefaultPath
    static let `default` = try! OhmBlackDoHMail()
}

class ProdDoHMail: DoH, ServerConfig {
    var signupDomain: String = ObfuscatedConstants.liveSignupDomain
    var defaultHost: String = ObfuscatedConstants.liveDefaultHost
    var captchaHost: String = ObfuscatedConstants.liveCaptchaHost
    var apiHost: String = ObfuscatedConstants.liveApiHost
    static let `default` = try! ProdDoHMail()
}
