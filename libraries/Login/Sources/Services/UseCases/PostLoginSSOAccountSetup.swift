//
//  PostLoginSSOAccountSetup.swift
//  ProtonCore-Login - Created on 26.11.24.
//
//  Copyright (c) 2024 Proton Technologies AG
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

#if os(iOS)

import ProtonCoreServices

public enum SSOLoginScreen {
    case newBackupPassword(UnprivatizeUserSuccess)
    case unimplemented
}

public final class PostLoginSSOAccountSetup {
    let apiService: APIService
    let userData: LoginData

    let createAuthDevice: CreateAuthDevice
    let verifyUnprivatization: VerifyUnprivatization

    public init(apiService: APIService, userData: LoginData) {
        self.apiService = apiService
        self.userData = userData

        self.createAuthDevice = CreateAuthDevice(
            userId: userData.user.ID,
            apiService: apiService,
            deviceSecretRepository: DeviceSecretRepository()
        )

        self.verifyUnprivatization = VerifyUnprivatization(apiService: apiService)
    }

    public enum State {
        case firstLogin
        // case invalidSecret
        case unimplemented
    }

    public func invoke() async throws -> SSOLoginScreen {
        let state = loginSSOState(userData: userData)
        switch state {
        case .firstLogin:
//            try await createAuthDevice.invoke()
            let verifyInfo = try await verifyUnprivatization.invoke()
            return .newBackupPassword(verifyInfo)
        case .unimplemented:
            return .unimplemented
        }
    }

    private func loginSSOState(userData: LoginData) -> State {
        if userData.user.keys.isEmpty {
            return .firstLogin
        }
        return .unimplemented
    }
}
#endif
