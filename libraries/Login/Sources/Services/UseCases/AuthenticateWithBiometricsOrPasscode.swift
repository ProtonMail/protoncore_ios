//
//  Created on 19.03.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import LocalAuthentication

/// Describes various authentication failures from Local Authentication.
public enum DeviceAuthenticationError: Error {
    /// The device cannot perform authentication (no passcode or biometrics).
    case notAvailable(String)
    /// User explicitly canceled (e.g., tapped “Cancel”).
    case userCanceled
    /// User tapped the fallback button (e.g., "Enter Password").
    case userFallback
    /// The system canceled the authentication (e.g., another app came to foreground).
    case systemCanceled
    /// The device has no passcode set, so authentication cannot proceed.
    case passcodeNotSet
    /// Face ID / Touch ID is not available on this device.
    case biometryNotAvailable
    /// Face ID / Touch ID is available but not enrolled (no fingerprints/face setup).
    case biometryNotEnrolled
    /// The device locked Face ID / Touch ID due to too many failed attempts.
    case biometryLockout
    /// The user failed the authentication too many times.
    case authenticationFailed
    /// Any other error we did not explicitly handle.
    case unknown(Error?)
}

public struct AuthenticateWithBiometricsOrPasscode {

    private let localizedReason: String

    /// localizedReason represents the string the user will see when asked to authenticate with TouchID or Passcode.
    public init(localizedReason: String) {
        self.localizedReason = localizedReason
    }

    /// Requests device-owner authentication (Face ID / Touch ID or passcode fallback).
    /// Returns nil if successful
    /// Returns DeviceAuthenticationError if not successful
    /// - Note: `deviceOwnerAuthentication` tries biometrics first (if available), and
    ///   automatically falls back to the device passcode if biometrics fail or aren’t enrolled.
    public func invoke() async -> Result<Bool, DeviceAuthenticationError> {
        let context = LAContext()
        var authError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) else {
            return .failure(authError.map { mapLAError($0) } ?? .unknown(nil))
        }

        do {
            try await withCheckedThrowingContinuation { continuation in
                context.evaluatePolicy(.deviceOwnerAuthentication,
                                       localizedReason: localizedReason) { success, error in
                    if success {
                        continuation.resume(returning: ())
                    } else {
                        continuation.resume(
                            throwing: error ?? LAError(.authenticationFailed)
                        )
                    }
                }
            }
            return .success(true)
        } catch {
            return .failure(mapLAError(error))
        }
    }
}

private func mapLAError(_ error: Error) -> DeviceAuthenticationError {
    guard let laError = error as? LAError else {
        return .unknown(error)
    }

    switch laError.code {
    case .authenticationFailed:
        return .authenticationFailed
    case .userCancel:
        return .userCanceled
    case .userFallback:
        return .userFallback
    case .systemCancel:
        return .systemCanceled
    case .passcodeNotSet:
        return .passcodeNotSet
    case .biometryNotAvailable:
        return .biometryNotAvailable
    case .biometryNotEnrolled:
        return .biometryNotEnrolled
    case .biometryLockout:
        return .biometryLockout
    default:
        return .unknown(laError)
    }
}
