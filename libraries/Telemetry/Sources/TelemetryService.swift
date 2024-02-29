//
//  TelemetryService.swift
//  ProtonCore-Telemetry - Created on 26.02.2024.
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

import Foundation
import ProtonCoreLog
import ProtonCoreServices

public protocol TelemetryServiceProtocol: AnyObject {
    var isTelemetrySettingOn: Bool { get }

    func setApiService(apiService: APIService)
    func report(event: any TelemetryEventProtocol) async
    func setTelemetrySetting(isOn: Bool)
}

public class TelemetryService: TelemetryServiceProtocol {
    public static let shared = TelemetryService()

    private let telemetrySettingsService: TelemetrySettingsServiceProtocol
    private var apiService: APIService?
    
    public init(
        telemetrySettingsService: TelemetrySettingsServiceProtocol = TelemetrySettingsService(),
        apiService: APIService? = nil
    ) {
        self.telemetrySettingsService = telemetrySettingsService
        self.apiService = apiService
    }

    public var isTelemetrySettingOn: Bool {
        telemetrySettingsService.isTelemetryEnabled
    }

    public func setApiService(apiService: APIService) {
        self.apiService = apiService
    }

    public func report(event: any TelemetryEventProtocol) async {
        guard let apiService = apiService else {
            assertionFailure("APIService not initialized")
            return
        }
        guard isTelemetrySettingOn else { return }
        let request = TelemetryRequest(event: event)
        do {
            _ = try await apiService.perform(request: request)
        } catch {
            PMLog.error(error, sendToExternal:true)
        }
    }

    public func setTelemetrySetting(isOn: Bool) {
        telemetrySettingsService.setIsTelemetryEnabled(state: isOn)
    }
}
