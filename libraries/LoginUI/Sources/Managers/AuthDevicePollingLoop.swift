//
//  AuthDeviceManager.swift
//  ProtonCore-Login - Created on 09.01.25.
//
//  Copyright (c) 2025 Proton Technologies AG
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

import Combine
import Foundation
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreNetworking
import ProtonCoreServices

public class AuthDevicePollingLoop {
    private let getAuthDevices: GetAuthDevices
    private let observingDeviceId: String

    private var timerTask: Task<Void, Never>?
    private var fetchDevicesTask: Task<Void, Never>?

    private var secondCount = 0
    private let threshold = Constants.defaultThreshold

    private let queue = DispatchQueue(label: Constants.queueName)

    public let authDeviceObserver = PassthroughSubject<AuthDevice, Never>()

    private enum Constants {
        static let defaultThreshold = 10
        static let queueName = "me.proton.protoncore.syncpendingdevices"
    }

    public init(
        apiService: any APIService,
        observingDeviceId: String
    ) {
        self.getAuthDevices = GetAuthDevices(apiService: apiService)
        self.observingDeviceId = observingDeviceId
    }
}

// MARK: - Public APIs

public extension AuthDevicePollingLoop {
    /// Start looping
    func start() {
        queue.sync { [weak self] in
            guard let self else { return }
            guard timerTask == nil else {
                return
            }

            timerTask = Task { [weak self] in
                guard let self else { return }
                await timerLoop()
            }
        }
    }

    /// Stop looping
    func stop() {
        queue.sync { [weak self] in
            guard let self else { return }

            fetchDevicesTask?.cancel()
            fetchDevicesTask = nil
            timerTask?.cancel()
            timerTask = nil
            secondCount = 0
        }
    }
}

// MARK: - Private APIs

private extension AuthDevicePollingLoop {

    /// Timer loop using async/await
    func timerLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)

            guard !Task.isCancelled else { return }

            secondCount += 1

            if secondCount >= threshold {
                secondCount = 0
                fetchDevices()
            }
        }
    }

    @objc func fetchDevices() {
        guard fetchDevicesTask == nil else { return }
        fetchDevicesTask = Task { [weak self] in
            defer {
                self?.fetchDevicesTask?.cancel()
                self?.fetchDevicesTask = nil
            }

            guard let self else { return }

            do {
                let authDevices = try await getAuthDevices.invoke()
                if let authDevice = authDevices.first(where: { $0.ID == self.observingDeviceId }) {
                    authDeviceObserver.send(authDevice)
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
}
