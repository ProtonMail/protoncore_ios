//
//  ObservabilityService.swift
//  ProtonCore-Observability - Created on 26.01.23.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import ProtonCore_FeatureSwitch
import ProtonCore_Networking
import ProtonCore_Services

public protocol ObservabilityService {
    /// Reports events to Back-End
    /// - Parameters:
    ///   - metrics: An array of events to report.
    ///   - completion: An optional completion used for end to end testing and result validation
    func report<T: Encodable>(_ event: ObservabilityEvent<T>, completion: ((URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) -> Void)?)
}

public class ObservabilityServiceImpl: ObservabilityService {
    
    private var apiService: APIService
    
    private let encoder = JSONEncoder()
    private let endpoint = ObservabilityEndpoint()
    
    public init(apiService: APIService) {
        self.apiService = apiService
    }
    
    public func report<T: Encodable>(_ event: ObservabilityEvent<T>, completion: ((URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) -> Void)? = nil) {
        do {
            try performRequest(event: event, completion: completion)
        } catch {
            assertionFailure("Impossible to encode the event because of \(error)")
        }
    }
    
    private func performRequest<T: Encodable>(event: ObservabilityEvent<T>, completion: ((URLSessionDataTask?, Result<JSONDictionary, PMAPIService.APIError>) -> Void)?) throws {
        guard FeatureFactory.shared.isEnabled(.unauthSession) else {
            return
        }

        let metrics = Metrics(metrics: [event])
        let metricsData = try encoder.encode(metrics)
        let parameters = try JSONSerialization.jsonObject(with: metricsData, options: [])
        
        apiService.request(
            method: endpoint.method,
            path: endpoint.path,
            parameters: parameters,
            headers: endpoint.headers,
            authenticated: endpoint.isAuth,
            autoRetry: endpoint.autoRetry,
            customAuthCredential: endpoint.authCredential,
            nonDefaultTimeout: endpoint.nonDefaultTimeout,
            retryPolicy: endpoint.retryPolicy,
            jsonCompletion: { task, result in
                completion?(task, result)
            }
        )
    }
}
