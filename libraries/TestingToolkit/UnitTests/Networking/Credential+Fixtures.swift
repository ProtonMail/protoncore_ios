//
//  Credential+Fixtures.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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

import ProtonCore_Networking

public extension Credential {
    static var dummy: Credential {
        Credential(UID: .empty, accessToken: .empty, refreshToken: .empty, userName: .empty, userID: .empty, scopes: [])
    }

    func updated(
        UID: String? = nil, accessToken: String? = nil, refreshToken: String? = nil,
        userName: String? = nil, userID: String? = nil, scopes: Credential.Scopes? = nil
    ) -> Credential {
        Credential(UID: UID ?? self.UID,
                   accessToken: accessToken ?? self.accessToken,
                   refreshToken: refreshToken ?? self.refreshToken,
                   userName: userName ?? self.userName,
                   userID: userID ?? self.userID,
                   scopes: scopes ?? self.scopes)
    }
}
