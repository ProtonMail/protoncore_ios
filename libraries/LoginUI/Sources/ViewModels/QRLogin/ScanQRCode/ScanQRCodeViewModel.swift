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
import ProtonCoreServices
import ProtonCoreLogin
import ProtonCoreLog
import ProtonCoreObservability

extension ScanQRCodeView {
    struct Dependencies {
        let passphrase: String
        let userEmail: String
        let apiService: APIService
    }
}

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

        private var decodeQRCodeUseCase = DecodeSignInQRCode()
        private var pushSessionForkUseCase: PushSessionFork

        private let passphrase: String
        private let apiService: APIService

        init(dependencies: Dependencies) {
            self.passphrase = dependencies.passphrase
            self.apiService = dependencies.apiService
            self.email = dependencies.userEmail
            self.pushSessionForkUseCase = PushSessionFork(apiService: apiService)
        }

        func handleQRCodeDetected(_ code: String) {
            Task { @MainActor in
                await processQRCode(code)
            }
        }

        func processQRCode(_ code: String) async {
            guard !code.isEmpty else {
                return
            }

            state = .verifying

            do {
                let decodedQRCode = try decodeQRCodeUseCase.invoke(qrCode: code)
                // encrypt the passphrase
                let securePassphrase = try SecurePassphrasePayload(passphrase: passphrase, encryptionKey: decodedQRCode.encryptionKey)
                // push the fork -> Show sucess on 200
                let _ = try await pushSessionForkUseCase.invoke(encryptedPayload: securePassphrase.encryptedPayload,
                                                                clientId: decodedQRCode.clientId,
                                                                userCode: decodedQRCode.userCode)
                state = .success
            } catch {
                PMLog.error(error.localizedDescription, sendToExternal: true)
                state = .failure
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
            navigationController?.navigationBar.isHidden = false
        }

        var clientName: String? {
            let componentsSeparatedByAt = self.apiService.serviceDelegate?.appVersion.components(separatedBy: "@")

            guard let componentsSeparatedByAt = componentsSeparatedByAt,
                  componentsSeparatedByAt.count == 2 else {
                return nil
            }

            let componentsSeparatedByDash = componentsSeparatedByAt[0].components(separatedBy: "-")

            guard componentsSeparatedByDash.count == 2 else {
                return nil
            }

            return componentsSeparatedByDash[1]
        }
    }
}

#endif
