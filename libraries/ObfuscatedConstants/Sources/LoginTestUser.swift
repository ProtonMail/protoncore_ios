//
//  LoginTestUser.swift
//  ProtonCore-Login-Tests - Created on 13/11/2020.
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

import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreAuthentication
import ProtonCoreServices

public class LoginTestUser {
    public let username: String
    public let password: String
    public let twoFactorCode: String = "123456"
    public func fido2SignatureWithAuthenticationOptions(_ options: AuthenticationOptions) -> Fido2Signature {
        .init(signature: Data(
            base64Encoded: "MEQCIACXYgPg+2eCHc72pFAan0JhYFaOIqQ++7E9AJwoW3evAiAqYv2S1VG4I4wU/rEeg9ppLx9FmnCfpcMVzqqGdlILkA=="
        )!,
              credentialID: Data(
                [214, 89, 242, 193, 240, 89, 89, 49, 22, 245, 29, 37, 39, 207, 145, 53, 240, 133, 121, 30, 193,
                 196, 143, 230, 104, 21, 129, 81, 32, 172, 93, 34, 150, 176, 62, 233, 66, 142, 140, 171, 100, 11,
                 72, 233, 203, 148, 132, 168, 88, 189, 25, 126, 20, 65, 35, 17, 42, 224, 110, 50, 203, 203, 166, 82]
              ),
              authenticatorData: Data(base64Encoded: "+95oJ+45pI2RXXNJa4EVk4mJnlacXl6FI+/xqhhc7H4BAAABHQ==")!,
              clientData: Data(base64Encoded: "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiRm5NbEttV1lXSVhMUl9xZG5YSWtzTFF5Q293Tlg1N3dnSUdQQTQwcUJoRSIsIm9yaWdpbiI6Imh0dHBzOi8vYWNjb3VudC5wcm90b24uYmxhY2sifQ==")!,
              authenticationOptions: options)
    }

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public static let defaultUser = LoginTestUser(username: "username", password: ObfuscatedConstants.mockUserPassword)

    public static let credential = Credential(UID: "", accessToken: "", refreshToken: "", userName: "", userID: "", scopes: [])
    public static var user: ProtonCoreDataModel.User {
        let json = "{\n        \"ID\": \"ID\",\n        \"Name\": null,\n        \"usedSpace\": 0,\n        \"currency\": \"EUR\",\n        \"credit\": 0,\n        \"maxSpace\": 104857600,\n        \"maxUpload\": 26214400,\n        \"subscribed\": 0,\n        \"services\": 1,\n        \"driveEarlyAccess\": 0,\n        \"role\": 0,\n        \"private\": 1,\n        \"delinquent\": 0,\n        \"keys\": [\n            {\n                \"ID\": \"ID\",\n                \"version\": 3,\n                \"primary\": 1,\n                \"privateKey\": \"\",\n                \"fingerprint\": \"fingerprint\"\n            }\n        ],\n        \"email\": \"email\",\n        \"displayName\": \"\"\n    }"
        return try! JSONDecoder().decode(ProtonCoreDataModel.User.self, from: json.data(using: .utf8)!)
    }

    public static var externalUserWithoutKeys: ProtonCoreDataModel.User {
        try! JSONDecoder().decode(ProtonCoreDataModel.User.self, from: """
            {
                "ID": "test id", "email": "test email", "displayName": "test name",
                "currency": "test currency", "credit": 0, "usedSpace": 0, "maxSpace": 0, "maxUpload": 0,
                "subscribed": 1, "services": 1, "role": 1, "private": 1, "delinquent": 1,
                "name": null, "keys": []
            }
        """.data(using: .utf8)!)
    }
}
