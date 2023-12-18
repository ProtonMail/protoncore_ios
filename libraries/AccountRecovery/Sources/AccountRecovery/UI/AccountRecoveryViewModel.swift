//
//  AccountRecoveryViewModel.swift
//  Pods - Created on 5/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if os(iOS)
import Foundation
import ProtonCoreDataModel
import ProtonCorePasswordRequest
import UIKit

public enum AccountRecoveryViewError: Error {
    case missingArguments
    case couldNotPresentPasswordUI
}

extension AccountRecoveryView {

    /// The `ObservableObject` that holds the model data for this View
    /// @MainActor
    public final class ViewModel: ObservableObject, PasswordVerifierViewControllerDelegate {

        @Published var email: String = ""
        @Published var remainingTime: TimeInterval = 0
        @Published var state: User.RecoveryState = .none
        @Published var reason: User.RecoveryReason = .none
        @Published var isLoaded = false

        private var username: String?
        private let accountRepository: AccountRecoveryRepositoryProtocol?

        public init(accountRepository: AccountRecoveryRepositoryProtocol? = nil) {
            self.accountRepository = accountRepository

            loadData()
        }

        func populateWithAccountRecoveryInfo(_ info: RecoveryInfo) {
            let (username, email, recovery) = info
            guard let username, let email, let recovery else {
                state = .none
                isLoaded = true
                return
            }

            state = recovery.state
            reason = recovery.reason ?? .none
            self.email = email
            remainingTime = recovery.endTime - Date().timeIntervalSince1970
            self.username = username
            isLoaded = true
        }

        func loadData() {
            guard let accountRepository else { return }

            Task { @MainActor in
                do {
                    let info = try await accountRepository.fetchRecoveryState()
                    populateWithAccountRecoveryInfo(info)
                } catch {
                    isLoaded = false
                }
            }
        }

        /// Signals that the view requested that the **Account Recovery** process be aborted
        /// - Parameter completion: Closure called upon completion of the request, to allow the UI to be updated
        /// Limiting availability for now to iOS
        @MainActor
        public func cancelPressed() async {
            do {
                guard let accountRepository, let username else {
                    throw AccountRecoveryViewError.missingArguments
                }

                let verifier = PasswordVerifier(apiService: accountRepository.authService.apiService,
                                                username: username,
                                                endpoint: AbortRecoveryEndpoint()
                )
                async let viewController = PasswordVerifierViewController()
                await viewController.viewModel = verifier
                await viewController.delegate = self

                guard let rootVC = UIApplication.shared.topMostViewController else {
                    throw AccountRecoveryViewError.couldNotPresentPasswordUI
                }
                await rootVC.present(viewController, animated: true) {}
            } catch {
                // error state
                isLoaded = false
            }
        }

        public func userUnlocked() {
            isLoaded = false
            loadData()
        }

        public func didCloseVerifyPassword() {
            // nothing to do. We refresh data just in case something has changed backend-side
            isLoaded = false
            loadData()
        }

        public func didCloseWithError(code: Int, description: String) {
// TODO: change state to error and inform the user
        }
    }
}
#endif
