//
//  MockLokiClient.swift
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

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public class MockLokiClient: LokiClientProtocol {
    public var pushCallCount = 0
    public var entries: [String] = []
    public var endpoints: [String] = []
    public var shouldThrowError: Error?
    
    // Convenience properties for backward compatibility
    public var lastEntry: String? { entries.last }
    public var lastEndpoint: String? { endpoints.last }

    public init() {}

    public func pushToLoki(entry: String, lokiEndpoint: String) async throws {
        pushCallCount += 1
        entries.append(entry)
        endpoints.append(lokiEndpoint)

        if let error = shouldThrowError {
            throw error
        }
    }

    public func reset() {
        pushCallCount = 0
        entries.removeAll()
        endpoints.removeAll()
        shouldThrowError = nil
    }
}

