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
        let appVersion = apiService.serviceDelegate?.appVersion ?? ""

        let components = appVersion.split(separator: "@")

        guard components.count == 2 else {
            return appVersion
        }

        return String(components[0])
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

        var refreshWaitTimeInSeconds: TimeInterval = 600
        var pullForkIntervalInSeconds: TimeInterval = 10

        private var getUserCodeAndSelectorUseCase: GetUserCodeAndSelector?
        private var generateSignInQRCodeUseCase: GenerateSignInQRCode?
        private var getForkedSessionUseCase: GetForkedSession?
        private var selector: String?

        var forkedSession: GetForkedSession.Response?

        private var refreshQRCodeTimer: Timer?
        private var pullForkTimer: Timer?

        init(dependencies: Dependencies) {
            if let apiService = dependencies.apiService {
                getUserCodeAndSelectorUseCase = GetUserCodeAndSelector(apiService: apiService)
                getForkedSessionUseCase = GetForkedSession(apiService: apiService)
            }

            if let secureHashGenerator = dependencies.secureHashGenerator,
               let clientIdProvider = dependencies.clientIdProvider {
                generateSignInQRCodeUseCase = GenerateSignInQRCode(hashGenerator: secureHashGenerator, clientIdProvider: clientIdProvider)
            }
        }

        func generateANewQRCodeText() {
            Task {
                stopPollingFork()
                removeQRCodeText()

                guard let getUserCodeAndSelectorUseCase = getUserCodeAndSelectorUseCase, let generateSignInQRCodeUseCase = generateSignInQRCodeUseCase else {
                    return
                }

                do {
                    let userCodeAndSelector = try await getUserCodeAndSelectorUseCase.invoke()
                    let qrCode = try generateSignInQRCodeUseCase.invoke(userCode: userCodeAndSelector.userCode)

                    self.selector = userCodeAndSelector.selector
                    self.qrCodeText = qrCode.text
                } catch {
#if DEBUG
                    // TODO: Show a toast message. And give the option to retry. There's a ticket for this.
                    debugPrint(error)
#endif
                }

                scheduleQRCodeRefresh()
                startPollingFork()
            }
        }

        func cancelQRCodeRefresh() {
            refreshQRCodeTimer?.invalidate()
            refreshQRCodeTimer = nil
        }

        func startPollingFork() {
            pullForkTimer?.invalidate()
            pullForkTimer = Timer.scheduledTimer(withTimeInterval: pullForkIntervalInSeconds, repeats: true, block: { [weak self] timer in
                Task { @MainActor [weak self] in
                    do {
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        guard let selector = self.selector, timer.isValid else { return }
                        print("PT: Fork about to be pulled")
                        self.forkedSession = try await self.getForkedSessionUseCase?.invoke(selector: selector)
                        timer.invalidate()
                        print("PT: Fork pulled successfully")
                        // TODO: Notify the Login Coordinator that we should do the "post login" steps.
                        // I will need to pass the data from here back to the Login Coordinator.
                        // I will also need to add the decryption step. The payload will contain the encrypted passphrase. The encryptionKey is the one generated for the QR code.
                        // I will probably add this to the GetForkedSession use case.
                        // I will do this once I can push forks from the Logged In device.
                        // I will remove the print statements once this part is done.
                    } catch {
                        // Do nothing. The fork might not be available yet.
                        print("PT: Fork pull error: \(error)")
                    }
                }
            })
        }

        func stopPollingFork() {
            pullForkTimer?.invalidate()
            pullForkTimer = nil
        }

        private func removeQRCodeText() {
            self.qrCodeText = nil
        }

        private func scheduleQRCodeRefresh() {
            refreshQRCodeTimer?.invalidate()
            refreshQRCodeTimer = Timer.scheduledTimer(withTimeInterval: refreshWaitTimeInSeconds,
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
