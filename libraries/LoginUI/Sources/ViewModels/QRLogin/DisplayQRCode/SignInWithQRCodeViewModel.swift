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
import ProtonCoreNetworking
import SwiftUI
import ProtonCoreUI

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
        let handleLoginCredentials: (Credential, _ loginErrorHandler: @escaping () -> Void) -> Void
    }
}

extension SignInWithQRCodeView {

    @MainActor
    final class ViewModel: ObservableObject {

        enum ViewState {
            case qrCode
            case signInFailed
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
        private let handleLoginCredentials: (Credential, _ loginErrorHandler: @escaping () -> Void) -> Void
        private let handleBackToLoginButtonPress: () -> Void

        var forkedSession: GetForkedSession.Response?

        private var refreshQRCodeTimer: Timer?
        private var pullForkTimer: Timer?

        enum Errors: Error {
            case responseOrEncryptionKeyMissing
        }

        init(dependencies: Dependencies) {
            if let apiService = dependencies.apiService {
                self.apiService = apiService
                getUserCodeAndSelectorUseCase = GetUserCodeAndSelector(apiService: apiService)
                getForkedSessionUseCase = GetForkedSession(apiService: apiService)
            }

            if let secureHashGenerator = dependencies.secureHashGenerator,
               let clientIdProvider = dependencies.clientIdProvider {
                generateSignInQRCodeUseCase = GenerateSignInQRCode(hashGenerator: secureHashGenerator, clientIdProvider: clientIdProvider)
            }

            self.handleLoginCredentials = dependencies.handleLoginCredentials
            self.handleBackToLoginButtonPress = dependencies.handleBackToLoginButtonPress
        }

        func handleTryAgainPressed() {
            state = .qrCode
        }

        func handleBackPressed() {
            handleBackToLoginButtonPress()
        }

        private func showSignInFailureView() {
            self.state = .signInFailed
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
                    do {
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        guard let selector = self.selector, timer.isValid else { return }
#if DEBUG
                        print("PT: Fork about to be pulled")
#endif
                        self.forkedSession = try await self.getForkedSessionUseCase?.invoke(selector: selector)
                        guard let response = self.forkedSession,
                              let key = self.encryptionKey else {
                            throw Errors.responseOrEncryptionKeyMissing
                        }
                        timer.invalidate()
#if DEBUG
                        print("PT: Fork pulled successfully")
#endif
                        try self.handleReceivedForkResponse(response, encryptionKey: key)
                    } catch {
                        // Do nothing. The fork might not be available yet.
#if DEBUG
                        print("PT: Fork pull error: \(error)")
#endif
                    }
                }
            })
        }

        private func handleReceivedForkResponse(_ response: GetForkedSession.Response, encryptionKey: Data) throws {
            let securePayload = try SecurePassphrasePayload(encryptedPayload: response.payload, encryptionKey: encryptionKey)
            var credential = Credential.init(UID: response.UID,
                                             accessToken: response.accessToken,
                                             refreshToken: response.refreshToken,
                                             userName: "",
                                             userID: "",
                                             scopes: [],
                                             mailboxPassword: securePayload.passphrase)
            self.handleLoginCredentials(credential, { [weak self] in
                self?.showSignInFailureView()
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

