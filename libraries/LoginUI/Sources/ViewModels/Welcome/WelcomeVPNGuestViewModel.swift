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

        enum ViewMode {
            case guest
            case signUp
        }
        @Published var viewMode = ViewMode.guest

        init(dependencies: Dependencies) {
            self.login = dependencies.login
            self.delegate = dependencies.delegate
        }

        func continueAsGuestTapped() {
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
