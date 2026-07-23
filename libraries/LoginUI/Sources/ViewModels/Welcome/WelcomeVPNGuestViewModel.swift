//  Copyright (c) 2025 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

#if os(iOS)

import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreTelemetry
import ProtonCoreUIFoundations
import SwiftUI

typealias WelcomeLoginControllerDelegate = LoginViewControllerDelegate & WelcomeViewControllerDelegate

extension WelcomeVPNGuestView {
    struct Dependencies {
        let login: Login
        let delegate: WelcomeLoginControllerDelegate?
        /// Provider for the optional top banner (e.g. kill-switch blocking).
        /// When the banner has a `blockingAlert`, "Continue as guest" is intercepted with it.
        let loginScreenBannerProvider: (() -> LoginScreenBanner?)?

        init(login: Login, delegate: WelcomeLoginControllerDelegate?, loginScreenBannerProvider: (() -> LoginScreenBanner?)? = nil) {
            self.login = login
            self.delegate = delegate
            self.loginScreenBannerProvider = loginScreenBannerProvider
        }
    }
}

extension WelcomeVPNGuestView {

    @MainActor
    final class ViewModel: ObservableObject, ProductMetricsMeasurable {
        var productMetrics: ProductMetrics = .init(
            group: TelemetryMeasurementGroup.signUp.rawValue,
            flow: TelemetryFlow.signUpFull.rawValue,
            screen: .welcome
        )
        private var login: Login
        private weak var delegate: WelcomeLoginControllerDelegate?

        enum ViewState {
            case idle
            case loading
        }
        @Published var viewState = ViewState.idle
        @Published var bannerState = BannerState.none
        /// Persistent top banner mirroring the login screen (e.g. kill-switch blocking).
        @Published var killSwitchBannerState = BannerState.none
        /// Set to show the blocking confirmation when the user tries to proceed while blocked.
        @Published var blockingAlert: LoginScreenBanner.BlockingAlert?

        /// The current banner, replaced by any successors once the banner's action runs (e.g. KS turned off). The view
        /// reads it to make sure that banners blocking login are pinned.
        private(set) var loginScreenBanner: LoginScreenBanner?

        enum ViewMode {
            case guest
            case signUp
        }
        @Published var viewMode = ViewMode.guest

        init(dependencies: Dependencies) {
            self.login = dependencies.login
            self.delegate = dependencies.delegate
            self.loginScreenBanner = dependencies.loginScreenBannerProvider?()
            updateKillSwitchBanner()
        }

        /// If the banner is currently blocking, surfaces its confirmation and returns `true` (so the caller
        /// aborts). Confirming the alert runs the banner's action (e.g. turning off the kill switch).
        private func presentBlockingAlertIfNeeded() -> Bool {
            guard let blockingAlert = loginScreenBanner?.blockingAlert else { return false }
            self.blockingAlert = blockingAlert
            return true
        }

        func turnOffKillSwitchConfirmed() {
            blockingAlert = nil
            Task { [weak self] in
                guard let self else { return }
                let nextBanner = await self.loginScreenBanner?.action?() ?? nil
                self.loginScreenBanner = nextBanner
                self.updateKillSwitchBanner()
            }
        }

        private func updateKillSwitchBanner() {
            guard let banner = loginScreenBanner else {
                killSwitchBannerState = .none
                return
            }
            let content = PCBannerContent(
                message: banner.message,
                buttonTitle: banner.actionTitle,
                buttonAction: banner.actionTitle == nil ? nil : { [weak self] in self?.turnOffKillSwitchConfirmed() }
            )
            killSwitchBannerState = banner.style == .error ? .error(content: content) : .success(content: content)
        }

        func continueAsGuestTapped() {
            guard !presentBlockingAlertIfNeeded() else { return }
            measureOnViewClicked(item: "sign_in_guest")
            Task {
                do {
                    viewState = .loading
                    let status = try await login.loginWithCredentialLessUser()
                    switch status {
                    case .finished(let userData):
                        delegate?.loginViewControllerDidFinish(endLoading: { [weak self] in
                            self?.viewState = .idle
                        }, data: userData)
                    default:
                        throw LoginError.invalidState
                    }
                } catch {
                    viewState = .idle
                    PMLog.error(error, sendToExternal: true)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                    if let responseError = error as? ResponseError,
                       let responseCode = responseError.responseCode,
                       responseCode == APIErrorCode.accountCredentialLessInvalid {
                        PMLog.debug("ACCOUNT_CREDENTIALLESS_INVALID(10200) error received. Switching to sign up")
                        viewMode = .signUp
                        return
                    }
                }
            }
        }

        func signInTapped() {
            // Sign in / create account just navigate to the login screen, which shows its own banner and
            // blocks the actual sign-in there. Only "Continue as guest" is blocked on the welcome screen.
            measureOnViewClicked(item: "sign_in")
            delegate?.userWantsToLogIn(username: nil)
        }

        func signUpTapped() {
            measureOnViewClicked(item: "sign_up")
            delegate?.userWantsToSignUp()
        }
    }
}
#if DEBUG
extension WelcomeVPNGuestView.ViewModel {
    static func mock() -> WelcomeVPNGuestView.ViewModel {
        let dependencies = WelcomeVPNGuestView.Dependencies(
            login: LoginStub(),
            delegate: nil
        )
        let viewModel = WelcomeVPNGuestView.ViewModel(dependencies: dependencies)
        return viewModel
    }
}
#endif

#endif
