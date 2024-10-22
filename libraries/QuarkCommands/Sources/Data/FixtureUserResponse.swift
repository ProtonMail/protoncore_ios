//
//  FixtureUserResponse.swift
//  ProtonCore-QuarkCommands - Created on 08.12.2023.
//
// Copyright (c) 2023. Proton Technologies AG
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

public struct FixtureUserResponse: Decodable {
    let users: [FixtureUser]
}

public struct FixtureUser: Decodable {
    let ID: FixtureIDInfo
    let name: String
    let password: String
    let keys: [FixtureKeyInfo]
}

public struct FixtureIDInfo: Decodable {
    let raw: Int
}

public struct FixtureKeyInfo: Decodable {
    let publicKey: String
    let privateKey: String

    public enum CodingKeys: String, CodingKey {
        case publicKey = "public"
        case privateKey = "private"
    }
}
