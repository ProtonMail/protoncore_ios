//
//  GenerateConfirmationCode.swift
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
import UIKit
import ProtonCoreServices
import ProtonCoreCrypto

/// Generate confirmation code using Crockford32
struct GenerateConfirmationCode {
    let deviceSecretRepository: DeviceSecretRepositoryProtocol

    init(deviceSecretRepository: DeviceSecretRepositoryProtocol) {
        self.deviceSecretRepository = deviceSecretRepository
    }

    func invoke(userId: String) throws -> String {
        let deviceSecret = try deviceSecretRepository.getByUserId(userId: userId)
        guard let secret = deviceSecret?.secret else { throw SSOLoginError.deviceSecretNotFound }
        let sha256EncodedSecret = Crockford32.encode(secret.sha256.data(using: .utf8)!)
        return String(sha256EncodedSecret.prefix(4))
    }
}

#endif
