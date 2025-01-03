//
//  RequestAdminAccessViewModel.swift
//  ProtonCore-LoginUI - Created on 26/09/2024.
//
//  Copyright (c) 2024 Proton AG
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
import ProtonCoreServices
import ProtonCoreUIFoundations
import SwiftUI

extension RequestAdminAccessView {
    struct Dependencies {
        let apiService: APIService?
        let userData: LoginData
        let unprivatizationInfo: UnprivatizationInfo
        let ssoNavigationDelegate: GlobalSSONavigationDelegate?
    }
}

extension RequestAdminAccessView {

    @MainActor
    final class ViewModel: ObservableObject {
        let apiService: APIService?
        let userData: LoginData
        let unprivatizationInfo: UnprivatizationInfo

        @Published var bannerState: BannerState = .none

        weak var ssoNavigationDelegate: GlobalSSONavigationDelegate?

        var requestAdminHelp: RequestAdminHelp?

        init(dependencies: Dependencies) {
            self.apiService = dependencies.apiService
            self.userData = dependencies.userData
            self.unprivatizationInfo = dependencies.unprivatizationInfo
            self.ssoNavigationDelegate = dependencies.ssoNavigationDelegate

            if let apiService = dependencies.apiService {
                self.requestAdminHelp = RequestAdminHelp(
                    apiService: apiService,
                    deviceSecretRepository: DeviceSecretRepository()
                )
            }
        }

        func continueActionButtonTapped() {
            Task {
                do {
                    guard let requestAdminHelp else { throw LoginError.invalidState }
                    try await requestAdminHelp.invoke(userId: userData.user.ID)
                    ssoNavigationDelegate?.showRequestAdminHelp(data: userData)
                } catch {
                    PMLog.error(error)
                    self.bannerState = .error(content: .init(message: error.localizedDescription))
                }
            }
        }
    }
}

#endif
