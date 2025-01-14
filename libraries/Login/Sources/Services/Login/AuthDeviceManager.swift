//
//  AuthDeviceManager.swift
//  ProtonCore-Login - Created on 03.01.25.
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

import Combine
import Foundation
import ProtonCoreFeatureFlags
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices
import UIKit

public protocol UserManagerProvider {
    func getAllUsers() async throws -> [UserData]
}

public protocol APIManagerProvider {
    func getApiService(userId: String) throws -> any APIService
}

public struct PendingAuthDevicesUpdate {
    public let apiService: any APIService
    public let userData: UserData
    public let authDevices: [AuthDevice]
}

public class AuthDeviceManager {

    private var userManagerProvider: any UserManagerProvider
    private var apiManagerProvider: any APIManagerProvider

    private var fetchPendingDevicesTask: Task<Void, Never>?
    private var activeTasks = [String: Task<Void, any Error>]()

    public let pendingDevicesObserver = PassthroughSubject<PendingAuthDevicesUpdate, Never>()

    public init(
        userManagerProvider: any UserManagerProvider,
        apiManagerProvider: any APIManagerProvider
    ) {
        self.userManagerProvider = userManagerProvider
        self.apiManagerProvider = apiManagerProvider
    }
}

// MARK: - Public APIs

public extension AuthDeviceManager {

    func setup() {
        guard FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.externalSSO, reloadValue: true) else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchPendingDevices),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func forceFetchPendingDevices() {
        fetchPendingDevices()
    }

}

// MARK: - Private APIs

private extension AuthDeviceManager {

    @objc func fetchPendingDevices() {
        guard FeatureFlagsRepository.shared.isEnabled(CoreFeatureFlagType.externalSSO, reloadValue: true) else { return }
        guard fetchPendingDevicesTask == nil else { return }
        fetchPendingDevicesTask = Task { @MainActor [weak self] in
            defer {
                // swiftlint:disable discouraged_optional_self
                self?.fetchPendingDevicesTask?.cancel()
                self?.fetchPendingDevicesTask = nil
                // swiftlint:enable discouraged_optional_self
            }

            guard let self else { return }

            let allUsers = (try? await userManagerProvider.getAllUsers()) ?? []
            let ssoUsers = allUsers.filter({ $0.user.isSSOAccount })
            for user in ssoUsers {
                if activeTasks[user.user.ID] != nil {
                    PMLog.info("Previous task not finished for userId: \(user.user.ID)")
                } else {
                    activeTasks[user.user.ID] = Task { [weak self] in
                        guard let self else { return }

                        defer {
                            self.activeTasks[user.user.ID] = nil
                        }

                        await executeAuthDevicesSync(currentUser: user)
                    }
                }
            }
        }
    }

    func executeAuthDevicesSync(currentUser: UserData) async {
        do {
            if Task.isCancelled { return }

            let apiService = try apiManagerProvider.getApiService(userId: currentUser.user.ID)
            let authDevices = try await GetAuthDevices(apiService: apiService).invoke()
            let pendingDevices = authDevices
                .filter({ $0.state == .pendingActivation || $0.state == .pendingAdminActivation })
            if !pendingDevices.isEmpty {
                pendingDevicesObserver.send(.init(
                    apiService: apiService,
                    userData: currentUser,
                    authDevices: pendingDevices
                ))
            }
        } catch {
            PMLog.error(error)
            if let responseError = error as? ResponseError,
               let httpCode = responseError.httpCode,
               (500...599).contains(httpCode) {
                PMLog.debug("Server is down, backing off")
            }
        }
    }
}
#endif
