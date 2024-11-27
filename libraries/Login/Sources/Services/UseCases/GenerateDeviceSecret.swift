//
//  GenerateDeviceSecret.swift
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

import Foundation
import ProtonCoreDataModel


/// Generate new random device secret.
///
/// return: 32-byte, base64-ed random salt as String
struct GenerateDeviceSecret {
    private enum Constants {
        static let deviceSecretBytes = 32
    }

    func invoke() throws -> String {
        var keyData = Data(count: Constants.deviceSecretBytes)
        _ = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, Constants.deviceSecretBytes, $0.baseAddress!)
        }
        return keyData.base64EncodedString()
    }
}
