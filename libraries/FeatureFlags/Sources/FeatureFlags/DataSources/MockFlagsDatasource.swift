//
// MockFlagsDatasource.swift
// Proton - Created on 10/10/2023.
// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton. If not, see https://www.gnu.org/licenses/.


/// Remote flags datasource used for mocking, it always returns a predefined set of feature flags.
public class MockFlagsDatasource: RemoteFeatureFlagsProtocol {
    private var flags: [FeatureFlag]

    init(flags: [FeatureFlag]) {
        self.flags = flags
    }

    public func getFlags() async throws -> [FeatureFlag] {
        flags
    }
}
