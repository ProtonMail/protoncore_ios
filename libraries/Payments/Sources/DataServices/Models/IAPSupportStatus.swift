//
//  Created on 07.02.2025.
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

/// Returned from the `/payments/v6/status/apple` endpoint.
///
/// This enum is used to either signal that IAP is available for the current account, or that it is disabled for some
/// reason. In the latter case, a localized reason describing why *may* be provided, but isn't guaranteed.
public enum IAPSupportStatus: Codable {
    case enabled
    case disabled(localizedReason: String?)

    public var isEnabled: Bool {
        guard case .enabled = self else {
            return false
        }
        return true
    }
}
