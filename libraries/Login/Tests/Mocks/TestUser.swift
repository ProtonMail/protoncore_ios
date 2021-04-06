//
//  TestUser.swift
//  ProtonCore-Login-Tests - Created on 13/11/2020.
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

import ProtonCore_DataModel
import ProtonCore_Networking
@testable import ProtonCore_Login

class TestUser {
    let username: String
    let password: String
    let twoFactorCode: String = "123456"

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    static let defaultUser = TestUser(username: ObfuscatedConstants.existingUsername, password: ObfuscatedConstants.mockUserPassword)

    static let credential = Credential(UID: "", accessToken: "", refreshToken: "", expiration: Date(), scope: [])
    static var user: User {
        let json = "{\n        \"ID\": \"ID\",\n        \"Name\": null,\n        \"usedSpace\": 0,\n        \"currency\": \"EUR\",\n        \"credit\": 0,\n        \"maxSpace\": 104857600,\n        \"maxUpload\": 26214400,\n        \"subscribed\": 0,\n        \"services\": 1,\n        \"driveEarlyAccess\": 0,\n        \"role\": 0,\n        \"private\": 1,\n        \"delinquent\": 0,\n        \"keys\": [\n            {\n                \"ID\": \"ID\",\n                \"version\": 3,\n                \"primary\": 1,\n                \"privateKey\": \"\",\n                \"fingerprint\": \"fingerprint\"\n            }\n        ],\n        \"email\": \"email\",\n        \"displayName\": \"\"\n    }"
        return try! JSONDecoder().decode(User.self, from: json.data(using: .utf8)!)
    }

    static var externalUserWithoutKeys: User {
        try! JSONDecoder().decode(User.self, from: """
            {
                "ID": "test id", "email": "test email", "displayName": "test name",
                "currency": "test currency", "credit": 0, "usedSpace": 0, "maxSpace": 0, "maxUpload": 0,
                "subscribed": 1, "services": 1, "role": 1, "private": 0, "delinquent": 1,
                "name": null, "keys": []
            }
        """.data(using: .utf8)!)
    }
}
