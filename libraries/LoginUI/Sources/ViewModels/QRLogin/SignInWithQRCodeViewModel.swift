//
//  Created on 12.03.2025.
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

class SecureHashGeneratorImplentation: SecureHashGenerator {
    func random(bits: Int32) throws -> Data {
        try PasswordHash.random(bits: bits)
    }
}

class ClientIdProviderImplementation: ClientIdProvider {
    private var apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func clientId() -> String {
        apiService.serviceDelegate?.appVersion ?? ""
    }
}

extension SignInWithQRCodeView {
    struct Dependencies {
        let apiService: APIService?
        let secureHashGenerator: SecureHashGenerator?
        let clientIdProvider: ClientIdProvider?
    }
}

extension SignInWithQRCodeView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var qrCodeText: String?

        var refreshWaitTimeInSeconds: Int = 600

        private var getUserCodeAndSelectorUseCase: GetUserCodeAndSelector?
        private var generateSignInQRCodeUseCase: GenerateSignInQRCode?
        private var userCode: String?
        private var selector: String?

        private var timer: Timer?

        init(dependencies: Dependencies) {
            if let apiService = dependencies.apiService {
                getUserCodeAndSelectorUseCase = GetUserCodeAndSelector(apiService: apiService)
            }

            if let secureHashGenerator = dependencies.secureHashGenerator,
               let clientIdProvider = dependencies.clientIdProvider {
                generateSignInQRCodeUseCase = GenerateSignInQRCode(hashGenerator: secureHashGenerator, clientIdProvider: clientIdProvider)
            }
        }

        func generateANewQRCodeText() {
            Task {
                // Remove the old qrCodeText
                removeQRCodeText()

                guard let getUserCodeAndSelectorUseCase = getUserCodeAndSelectorUseCase, let generateSignInQRCodeUseCase = generateSignInQRCodeUseCase else {
                    return
                }

                do {
                    let userCodeAndSelector = try await getUserCodeAndSelectorUseCase.invoke()
                    let qrCode = try generateSignInQRCodeUseCase.invoke(userCode: userCodeAndSelector.userCode)

                    self.userCode = userCodeAndSelector.userCode
                    self.selector = userCodeAndSelector.selector
                    self.qrCodeText = qrCode.text
                } catch {
#if DEBUG
                    // TODO: Show a toast message. And give the option to retry. There's a ticket for this.
                    debugPrint(error)
#endif
                }

                // Refresh the qr code every refreshWaitTimeInSeconds
                scheduleQRCodeRefresh()
            }
        }

        func cancelQRCodeRefresh() {
            timer?.invalidate()
            timer = nil
        }

        private func removeQRCodeText() {
            self.qrCodeText = nil
        }

        private func scheduleQRCodeRefresh() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshWaitTimeInSeconds),
                                         repeats: false,
                                         block: { [weak self] timer in
                guard timer.isValid else { return }
                Task { @MainActor [weak self] in
                    self?.generateANewQRCodeText()
                }
            })
        }
    }
}
