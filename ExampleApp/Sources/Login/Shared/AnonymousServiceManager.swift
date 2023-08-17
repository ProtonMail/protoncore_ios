//
//  AnonymousServiceManager.swift
//  ExampleApp - Created on 19/11/2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import ProtonCoreCryptoGoInterface
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices

public class AnonymousServiceManager: APIServiceDelegate {
    
    public init() {}
    
    public var locale: String { Locale.autoupdatingCurrent.identifier }
    public var appVersion: String = appVersionHeader.getVersionHeader()
    public var userAgent: String?
    public var additionalHeaders: [String : String]?
    
    public func onUpdate(serverTime: Int64) { CryptoGo.CryptoUpdateTime(serverTime) }
    public func isReachable() -> Bool { true }
    public func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
