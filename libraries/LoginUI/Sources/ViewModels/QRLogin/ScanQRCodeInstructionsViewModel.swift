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

import Combine
import Foundation
import ProtonCoreServices
import ProtonCoreLogin
import ProtonCoreAuthenticationKeyGeneration

public extension ScanQRCodeInstructionsView {
    @MainActor
    final class ViewModel: ObservableObject {
        private var shouldExecuteScanQRButtonPress = true
        private var authWithBiometricsOrPass: AuthenticateWithBiometricsOrPasscode

        @Published var showQRCodeScanner: Bool = false

        public init() {
            self.authWithBiometricsOrPass = AuthenticateWithBiometricsOrPasscode(localizedReason: LUITranslation.authenticate_to_scan_qr_description.l10n)
        }

        func handleScanQRButtonPress() {
            // Protect from abusive consecutive presses
            guard shouldExecuteScanQRButtonPress else { return }
            shouldExecuteScanQRButtonPress = false
            Task { @MainActor in
                switch await authWithBiometricsOrPass.invoke() {
                case .success:
                    showQRCodeScanner = true
                case .failure(let error):
#if DEBUG
                    debugPrint(error)
#endif
                }
                shouldExecuteScanQRButtonPress = true
            }
        }
    }
}
