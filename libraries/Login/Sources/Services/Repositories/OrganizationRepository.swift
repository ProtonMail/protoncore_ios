//
//  GetOrganizationRequest.swift
//  ProtonCore-Login - Created on 28.11.24.
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

import ProtonCoreServices

public struct OrganizationRepository {
    let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func getOrganization() async throws -> Organization {
        let request = GetOrganizationRequest()
        let (_, result): (_, OrganizationResponse) = try await apiService.perform(request: request)
        return result.organization
    }

    public func getOrganizationSettings() async throws -> OrganizationSettingsResponse {
        let request = GetOrganizationSettingsRequest()
        let (_, result): (_, OrganizationSettingsResponse) = try await apiService.perform(request: request)
        return result
    }

    public func getOrganizationSignature() async throws -> OrganizationSignatureResponse {
        let request = GetOrganizationSignatureRequest()
        let (_, result): (_, OrganizationSignatureResponse) = try await apiService.perform(request: request)
        return result
    }
}
