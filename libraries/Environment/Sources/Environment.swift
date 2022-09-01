//
//  Environment.swift
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
import TrustKit

public enum Environment {
    case prod
    case vpnProd
    case black
    case blackPayment
    case blackFossey
    
    case custom(String)
}

extension Environment {
    public static var prebuild: [Environment] = [.prod, .vpnProd, .black, .blackPayment, .blackFossey]
}

extension Environment: Equatable {
    public static func ==(lhs: Environment, rhs: Environment) -> Bool {
        switch (lhs, rhs) {
        case (.prod, .prod), (.vpnProd, .vpnProd), (.black, .black), (.blackPayment, .blackPayment), (.blackFossey, .blackFossey):
            return true
        case (.custom(let lvalue), .custom(let rvalue)):
            return lvalue == rvalue
        default:
            return false
        }
    }
}

extension Environment {
    static var supported: [Environment] = [.black]
    public static func setup(scopes: [Environment]) -> Void {
        supported = scopes
    }
    
    public func updateDohStatus(to status: DoHStatus) {
        switch self {
        case .prod:
            Production.default.status = status
        case .vpnProd:
            ProductionVPN.default.status = status
        case .black:
            BlackServer.default.status = status
        case .blackPayment:
            BlackPaymentsServer.default.status = status
        case .blackFossey:
            BlackFosseyServer.default.status = status
        case .custom(let customDomain):
            buildCustomDoh(customDomain: customDomain).status = status
        }
    }
        
    public var doh: DoH & ServerConfig {
        switch self {
        case .prod:
            return Production.default
        case .vpnProd:
            return ProductionVPN.default
        case .black:
            return BlackServer.default
        case .blackPayment:
            return BlackPaymentsServer.default
        case .blackFossey:
            return BlackFosseyServer.default
        case .custom(let customDomain):
            return buildCustomDoh(customDomain: customDomain)
        }
    }
    
    public var dohModifiable: DoH & VerificationModifiable {
        switch self {
        case .prod:
            return Production.default
        case .vpnProd:
            return ProductionVPN.default
        case .black:
            return BlackServer.default
        case .blackPayment:
            return BlackPaymentsServer.default
        case .blackFossey:
            return BlackFosseyServer.default
        default:
            fatalError("Invalid index")
        }
    }
    
    func buildCustomDoh(customDomain: String) -> CustomServerConfigDoH {
        return CustomServerConfigDoH.build(
            signupDomain: customDomain,
            captchaHost: "https://api.\(customDomain)",
            humanVerificationV3Host: "https://verify.\(customDomain)",
            accountHost: "https://account.\(customDomain)",
            defaultHost: "https://\(customDomain)",
            apiHost: ObfuscatedConstants.blackApiHost,
            defaultPath: ObfuscatedConstants.blackDefaultPath
        )
    }
}

extension Environment {
    public static func start(delegate: TrustKitDelegate, customConfiguration: Configuration? = nil) -> TrustKit? {
        TrustKitWrapper.start(delegate: delegate, customConfiguration: customConfiguration)
        return TrustKitWrapper.current
    }
    
    public static var trustKit: TrustKit? {
        TrustKitWrapper.current
    }
    
    public static func pinningConfigs(hardfail: Bool) -> Configuration {
        return TrustKitWrapper.getConfiguration(hardfail: hardfail)
    }
}
