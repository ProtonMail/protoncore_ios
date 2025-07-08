//
//  SentryCoreManager.swift
//  ProtonCore-Log - Created on 17/01/2024.
//
//  Copyright (c) 2023 Proton Technologies AG
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

import Sentry
#if canImport(UIKit)
import UIKit
#endif

public protocol ExternalLogProtocol {
    func capture(errorMessage: String, level: PMLog.LogLevel)

    func breadcrumb(
        message: String,
        category: String,
        level: PMLog.LogLevel,
        type: SentryBreadcrumbType,
        timestamp: Date,
        data: [String: Any]?
    )
}

extension ExternalLogProtocol {
    public func breadcrumb(
        message: String,
        category: String = "",
        level: PMLog.LogLevel = .info,
        type: SentryBreadcrumbType = .empty,
        data: [String: Any]? = nil
    ) {
        breadcrumb(
            message: message,
            category: category,
            level: level,
            type: type,
            timestamp: Date(),
            data: data
        )
    }
}

public enum SentryBreadcrumbType: String {
    case http
    case navigation
    case empty
    case user
}

public final class SentryCoreManager: ExternalLogProtocol {

    enum Constants {
        static let sentryDSNKey = "2c74eb763791400d9a3c17db8bf57dea"
        static let clientName = "client.name"
        static let device = "device"
        static let deviceFamily = "device.family"
        static let os = "os"
        static let osName = "os.name"
    }

    private var hub: SentryHub!

    public let host: String

    public init(_ host: String) {
        let hostURL = URL(string: host)
        self.host = hostURL?.host() ?? host
        setup()
    }

    func setup() {
        let options = Sentry.Options()
        options.dsn = "https://\(Constants.sentryDSNKey)@\(host)/core/v4/reports/sentry/56"
        #if DEBUG
        options.debug = true
        #endif

        var environment: String
        if host.contains("black") {
            environment = "black"
        } else {
            environment = "production"
        }
        options.environment = environment

        let scope = Scope()
        let clientName = Bundle.main.bundleIdentifier ?? "Unknown"
        scope.setTag(value: clientName, key: Constants.clientName)
        #if canImport(UIKit)
        scope.setTag(value: UIDevice.current.name, key: Constants.device)
        scope.setTag(value: UIDevice.current.systemName, key: Constants.deviceFamily)
        scope.setTag(value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)", key: Constants.os)
        scope.setTag(value: UIDevice.current.systemName, key: Constants.osName)
        #endif
        #if os(macOS)
        scope.setTag(value: ProcessInfo.processInfo.operatingSystemVersionString, key: Constants.os)
        #endif

        hub = SentryHub(
            client: .init(options: options),
            andScope: scope
        )
    }

    public func breadcrumb(
        message: String,
        category: String = "",
        level: PMLog.LogLevel = .info,
        type: SentryBreadcrumbType = .empty,
        timestamp: Date = Date(),
        data: [String: Any]? = nil
    ) {
        let crumb = Breadcrumb(level: level.sentryLevel, category: category)
        crumb.message = message
        crumb.timestamp = timestamp
        crumb.type = type.rawValue
        crumb.data = data
        hub.add(crumb)
    }

    public func capture(errorMessage: String, level: PMLog.LogLevel) {
        let event = Event(level: level.sentryLevel)
        event.message = SentryMessage(formatted: errorMessage)
        hub.capture(event: event)
    }
}

extension PMLog.LogLevel {
    var sentryLevel: SentryLevel {
        switch self {
        case .fatal: return .fatal
        case .error: return .error
        case .warn: return .warning
        case .info: return .info
        case .debug, .trace: return .debug
        }
    }
}
