//
//  BugReportViewModel.swift
//  ProtonCore-Settings - Created on 28.05.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
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
import Foundation
import UIKit
import SwiftUI
import Combine
import ProtonCoreLog
import ProtonCoreServices
import ProtonCoreUIFoundations

@available(iOS 15.0, *)
extension BugReportView {

    /// The `ObservableObject` that holds the model data for this View
    @MainActor
    public final class ViewModel: ObservableObject {
        private let apiService: APIService?
        private let username: String
        private let email: String

        @Published var title: String = ""
        @Published var description: String = ""

        @Published var sendButtonIsEnabled = false
        @Published var viewState = ViewState.idle
        @Published var bannerState: BannerState = .none

        private var cancellables = Set<AnyCancellable>()

        enum ViewState {
            case idle
            case loading
        }

        public init(dependencies: Dependencies) {
            self.apiService = dependencies.apiService
            self.username = dependencies.username
            self.email = dependencies.email
            setupBindings()
        }

        func setupBindings() {
            let handleTextfieldsChanged: (String) -> () = { [weak self] _ in
                guard let self else { return }
                self.sendButtonIsEnabled = 
                !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                self.description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
            }

            $title
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: handleTextfieldsChanged)
                .store(in: &cancellables)

            $description
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: handleTextfieldsChanged)
                .store(in: &cancellables)
        }

        func sendReportTapped() {
            guard let apiService else {
                PMLog.error("APIService not initialized")
                return
            }
            viewState = .loading
            Task { @MainActor in
                BugReportModule.initialViewController?.lockUI()
                do {
                    let bugReport = generateBugReport(title: title, description: description)
                    let bugReportRequest = BugReportRequest(bugReport: bugReport)
                    let (_, _): (URLSessionDataTask?, DefaultResponse) = try await apiService.perform(
                        request: bugReportRequest
                    )
                    bannerState = .success(content: .init(message: BugReportTranslations.reportSentSuccessfully.l10n))
                    title = ""
                    description = ""
                } catch {
                    PMLog.error(error)
                    bannerState = .error(content: .init(message: error.localizedDescription))
                }
                BugReportModule.initialViewController?.unlockUI()
                viewState = .idle
            }
        }

        func dismissView() {
            BugReportModule.initialViewController?.dismiss(animated: true)
        }

        func generateBugReport(title: String, description: String) -> BugReport {
            return BugReport(
                os: UIDevice.current.systemName,
                osVersion: UIDevice.current.systemVersion,
                client: Bundle.main.bundleIdentifier ?? "Unknown",
                clientVersion: Bundle.main.majorVersion,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username,
                email: email
            )
        }
    }
}

@available(iOS 15.0, *)
extension BugReportView.ViewModel {
    public struct Dependencies {
        let apiService: APIService?
        let username: String
        let email: String

        public init(
            apiService: APIService?,
            username: String = "",
            email: String
        ) {
            self.apiService = apiService
            self.username = username
            self.email = email
        }

        static func mock() -> Dependencies {
            return .init(apiService: nil, email: "")
        }
    }
}
#endif
