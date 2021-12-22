//
//  QuarkCommands.swift
//  ProtonCore-TestingToolkit-UITests-Core - Created on 23.07.21.
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

public final class QuarkCommands {
    private let doh: DoH & ServerConfig
    
    public init(doh: DoH & ServerConfig) {
        self.doh = doh
    }
    
    public func createUser(
        username: String, password: String, protonPlanName: String, completion: ((Result<(), Error>) -> Void)? = nil
    ) {
        let account = AccountAvailableForCreation(
            type: protonPlanName == "free" ? .free : .plan(named: protonPlanName),
            username: username, password: password,
            description: "Account with plan \(protonPlanName)"
        )
        QuarkCommands.create(account: account, currentlyUsedHostUrl: doh.getCurrentlyUsedHostUrl()) {
            completion?($0.map { _ in () }.mapError { $0 })
        }
    }
    
    public func unban(completion: ((Result<(), Error>) -> Void)? = nil) {
        QuarkCommands.unban(currentlyUsedHostUrl: doh.getCurrentlyUsedHostUrl()) {
            completion?($0.map { _ in () }.mapError { $0 })
        }
    }
}
