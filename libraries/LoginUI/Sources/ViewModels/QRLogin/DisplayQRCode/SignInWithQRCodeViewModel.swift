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

#if os(iOS)

import Combine
import Foundation
import ProtonCoreServices
import ProtonCoreLogin
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreNetworking
import SwiftUI
import ProtonCoreUI
import ProtonCoreObservability
import ProtonCoreLog

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
        let handleBackToLoginButtonPress: () -> Void
        let handleLoginCredentials: (Credential,
                                     _ loginErrorHandler: @escaping () -> Void,
                                     _ loginSuccessHandler: @escaping () -> Void) -> Void
    }
}

extension SignInWithQRCodeView {

    @MainActor
    final class ViewModel: ObservableObject {

        enum ViewState {
            case qrCode
            case genericFail
            case requirePasswordFail
        }

        @Published var qrCodeText: String?
        @Published var state: ViewState = .qrCode
        @Published var bannerState: BannerState = .none

        weak var navigationController: UINavigationController?

        var refreshWaitTimeInSeconds: TimeInterval = 540
        var pullForkIntervalInSeconds: TimeInterval = 5

        private var getUserCodeAndSelectorUseCase: GetUserCodeAndSelector?
        private var generateSignInQRCodeUseCase: GenerateSignInQRCode?
        private var getForkedSessionUseCase: GetForkedSession?
        private var selector: String?
        private var encryptionKey: Data?
        private var apiService: APIService?
        private var clientIdProvider: ClientIdProvider?
        private let handleLoginCredentials: (Credential,
                                             _ loginErrorHandler: @escaping () -> Void,
                                             _ loginSuccessHandler: @escaping () -> Void) -> Void
        private let handleBackToLoginButtonPress: () -> Void

        var forkedSession: GetForkedSession.Response?

        private var refreshQRCodeTimer: Timer?
        private var pullForkTimer: Timer?

        private let generateEntryptionKey: Bool

        enum Errors: Error {
            case responseMissing
            case encryptionKeyMissing
            case payloadMissing
            case passphraseMissing
        }

        /// If you don't need the passphrase to log in, set generateEncryptionKey to false. This will omit the encrytion key from the QR Code.
        /// If an encryption key is not present in the QR Code the passphrase won't be sent. The payload, when pulling the fork, will be null.
        init(dependencies: Dependencies, generateEncryptionKey: Bool = true) {
            if let apiService = dependencies.apiService {
                self.apiService = apiService
                getUserCodeAndSelectorUseCase = GetUserCodeAndSelector(apiService: apiService)
                getForkedSessionUseCase = GetForkedSession(apiService: apiService)
            }

            if let secureHashGenerator = dependencies.secureHashGenerator,
               let clientIdProvider = dependencies.clientIdProvider {
                generateSignInQRCodeUseCase = GenerateSignInQRCode(hashGenerator: secureHashGenerator, clientIdProvider: clientIdProvider)
            }

            self.clientIdProvider = dependencies.clientIdProvider
            self.handleLoginCredentials = dependencies.handleLoginCredentials
            self.handleBackToLoginButtonPress = dependencies.handleBackToLoginButtonPress
            self.generateEntryptionKey = generateEncryptionKey
        }

        func handleTryAgainPressed() {
            state = .qrCode
        }

        func handleBackPressed() {
            handleBackToLoginButtonPress()
        }

        private func showGenericFailureView() {
            self.state = .genericFail
        }

        private func showRequirePasswordFailureView() {
            self.state = .requirePasswordFail
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
                    let qrCode = try generateSignInQRCodeUseCase.invoke(
                        userCode: userCodeAndSelector.userCode,
                        withEncryptionKey: self.generateEntryptionKey)

                    self.selector = userCodeAndSelector.selector
                    self.encryptionKey = qrCode.encryptionKey
                    self.qrCodeText = qrCode.text
                    scheduleQRCodeRefresh()
                    startPollingFork()
                } catch {
                    cancelQRCodeRefresh()
                    stopPollingFork()
                    bannerState = .error(content: PCBannerContent(
                        message: LUITranslation.qr_code_load_error_description.l10n,
                        buttonTitle: LUITranslation.retry.l10n,
                        buttonAction: { [weak self] in
                            self?.generateANewQRCodeText()
                        }))
                    ObservabilityEnv.report(.qrLoginShowQRCodeScreenState(stateId: .errorBanner))
                }
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
                    guard let self = self else {
                        timer.invalidate()
                        return
                    }

                    do {
                        guard let selector = self.selector, timer.isValid else { return }
                        try await pullTheFork(for: selector)
                        // Pulled success. Invalidate timer.
                        timer.invalidate()
                    } catch {
                        if error.httpCode == APIErrorCode.HTTP422 {
                            // Expected error when polling and the fork is not yet pushed
                            return
                        }

                        timer.invalidate()

                        ObservabilityEnv.report(.qrLoginResult(status: .failure))
                        PMLog.error("Could not handle the response of pulling the fork: \(error)")

                        guard let error = error as? Errors else {
                            self.showGenericFailureView()
                            return
                        }

                        switch error {
                        case .responseMissing:
                            self.showGenericFailureView()
                        case .passphraseMissing, .encryptionKeyMissing, .payloadMissing:
                            self.showRequirePasswordFailureView()
                        }
                    }
                }
            })
        }

        func stopPollingFork() {
            pullForkTimer?.invalidate()
            pullForkTimer = nil
        }

        // MARK: QR code utilities

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

        // MARK: Pull fork utilities

        private func pullTheFork(for selector: String) async throws {
            self.forkedSession = try await self.getForkedSessionUseCase?.invoke(selector: selector)
            guard let response = self.forkedSession else {
                throw Errors.responseMissing
            }

            let mailboxPassword: String = try extractMailboxPassword(from: response, with: encryptionKey)

            let credential = Credential.init(UID: response.UID,
                                             accessToken: response.accessToken,
                                             refreshToken: response.refreshToken,
                                             userName: "",
                                             userID: "",
                                             scopes: [],
                                             mailboxPassword: mailboxPassword)
             self.handleLoginCredentials(credential, { [weak self] in
                // Failure
                ObservabilityEnv.report(.qrLoginResult(status: .failure))
                self?.showRequirePasswordFailureView()
            }, {
                // Success
                ObservabilityEnv.report(.qrLoginResult(status: .success))
            })
        }

        private func extractMailboxPassword(from response: GetForkedSession.Response, with encryptionKey: Data?) throws -> String {
            let clientId = clientIdProvider?.clientId().lowercased() ?? ""

            guard let encryptionKey = encryptionKey else {
                if clientId.contains("vpn") {
                    return ""
                } else {
                    throw Errors.encryptionKeyMissing
                }
            }

            guard let payload = response.payload else {
                if clientId.contains("vpn") {
                    return ""
                } else {
                    throw Errors.payloadMissing
                }
            }

            let securePayload = try SecurePassphrasePayload(encryptedPayload: payload, encryptionKey: encryptionKey)

            guard securePayload.passphrase != "" else {
                if clientId.contains("vpn") {
                    return ""
                } else {
                    throw Errors.passphraseMissing
                }
            }

            return securePayload.passphrase
        }
    }
}

#endif
