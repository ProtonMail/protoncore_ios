//
//  TestUser.swift
//  ProtonCore-Authentication-Tests - Created on 03.06.2021
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

struct TestUser {
    let username: String
    let password: String
}

extension TestUser {
    static let liveTestUser = TestUser(username: ObfuscatedConstants.liveTestUserUsername, password: ObfuscatedConstants.liveTestUserPassword)
    static let liveTest2FAUser = TestUser(username: ObfuscatedConstants.liveTest2FAUserUsername, password: ObfuscatedConstants.liveTest2FAUserPassword)
    static let blueDriveTestUser = TestUser(username: ObfuscatedConstants.blueDriveUserUsername, password: ObfuscatedConstants.blueDriveUserPassword)
    static let externalTestUser = TestUser(username: ObfuscatedConstants.externalUserUsername, password: ObfuscatedConstants.externalUserPassword)
    
    static let blackTestUser0 = TestUser(username: ObfuscatedConstants.blackAutotestv0Username, password: ObfuscatedConstants.blackAutotestv0Password)
    
}
