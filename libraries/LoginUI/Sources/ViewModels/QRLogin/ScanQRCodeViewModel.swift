//
//  Created on 24.03.2025.
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

#if os(iOS)

import UIKit
import Combine

extension ScanQRCodeView {
    @MainActor
    final class ViewModel: ObservableObject {

        enum ViewState {
            case scanning
            case verifying
            case success
            case failure
            case cameraNotAllowed
        }

        @Published var state: ViewState = .scanning
        @Published var email: String = ""

        weak var navigationController: UINavigationController?

        func handleQRCode(_ code: String) {
            if code != "" {
                state = .verifying
                print("PT: QR CODE STRING -> \(code)")
            }
        }

        func handleCameraUseNotAllowed() {
            state = .cameraNotAllowed
        }

        func handleCameraUsePermissionRequestRejection() {
            navigationController?.popToRootViewController(animated: true)
        }

        func handleScanQRCodePressed() {
            state = .scanning
        }

        func handleGoToSettingsPressed() {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }

        func handleCloseButtonPressed() {
            navigationController?.popViewController(animated: true)
        }

        func handleGotItButtonPressed() {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

#endif
