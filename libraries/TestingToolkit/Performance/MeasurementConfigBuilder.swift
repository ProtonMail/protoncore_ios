//
//  MeasurementConfigBuilder.swift
//  ProtonCore-Performance - Created on 13.06.2024.
//
// Copyright (c) 2025. Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Foundation

public class MeasurementConfigBuilder {

    public init() {}

    @discardableResult
    public func lokiEndpoint(_ endpoint: String) -> Self {
        MeasurementConfig.setLokiEndpoint(endpoint)
        return self
    }

    @discardableResult
    public func environment(_ env: String) -> Self {
        MeasurementConfig.setEnvironment(env)
        return self
    }

    @discardableResult
    public func certificate(_ cert: String) -> Self {
        MeasurementConfig.setLokiCertificate(cert)
        return self
    }

    @discardableResult
    public func certificatePassphrase(_ passphrase: String) -> Self {
        MeasurementConfig.setLokiCertificatePassphrase(passphrase)
        return self
    }

    @discardableResult
    public func bundle(_ bundle: Bundle) -> Self {
        MeasurementConfig.setBundle(bundle)
        return self
    }

    @discardableResult
    public func appVersion(_ version: String) -> Self {
        MeasurementConfig.setAppVersion(version)
        return self
    }

    public func build() throws -> MeasurementConfig.Type {
        try MeasurementConfig.validate()
        return MeasurementConfig.self
    }
}

