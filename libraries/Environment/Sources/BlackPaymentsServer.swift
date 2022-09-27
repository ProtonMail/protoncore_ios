//
//  BlackPaymentsServer.swift
//  ProtonCore-Doh - Created on 24/03/22.
//
//  Copyright (c) 2022 Proton Technologies AG
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
import ProtonCore_ObfuscatedConstants

class BlackPaymentsServer: DoH, VerificationModifiable {
    var _humanVerificationV3Host: String = ObfuscatedConstants.paymentsBlackHumanVerificationV3Host
    let signupDomain: String = ObfuscatedConstants.paymentsBlackSignupDomain
    let captchaHost: String = ObfuscatedConstants.paymentsBlackCaptchaHost
    var humanVerificationV3Host: String {
        _humanVerificationV3Host
    }
    let accountHost: String = ObfuscatedConstants.paymentsBlackAccountHost
    let defaultHost: String = ObfuscatedConstants.paymentsBlackDefaultHost
    let apiHost: String = ObfuscatedConstants.paymentsBlackApiHost
    let defaultPath: String = ObfuscatedConstants.paymentsBlackDefaultPath
    
    static let `default` = BlackPaymentsServer()
}