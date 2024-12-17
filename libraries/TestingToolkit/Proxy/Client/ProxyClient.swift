//
//  ProxyClient.swift
//  ProtonCore-Performance - Created on 12.09.2024.
//
// Copyright (c) 2023. Proton Technologies AG
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

// MARK: - ProxyClient
public class ProxyClient {
    private let baseURL: URL
    private let session: URLSession

    // Initialize with baseURL and session
    public init(baseURL: URL) {
        let config = URLSessionConfiguration.default
#if DEBUG
        let sessionDelegate = BypassSSLValidationDelegate()
        self.session = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
#else
        self.session = URLSession(configuration: config)
#endif
        self.baseURL = baseURL
    }

    public enum APIError: Error {
        case invalidResponse
        case decodingError(Error)
        case serverError(Int)
        case requestError(Error)
    }

    // General Request Function
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(error)))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    // Utility Method for Encoding
    private func encodeBody<T: Encodable>(_ body: T) -> Data? {
        if let staticMock = body as? MockObject {
            do {
                // Validate the request details
                try staticMock.request.validate()
            } catch {
                print("Validation failed with error: \(error)")
                return nil
            }
        }

        return try? JSONEncoder().encode(body)
    }

    // MARK: - Endpoints
    public func fetchStaticMockRoutes(completion: @escaping (Result<[String: MockObject], APIError>) -> Void) {
        request(endpoint: "mock/routes/static", method: "GET", completion: completion)
    }

    public func addStaticMockRoute(route: MockObject, completion: @escaping (Result<MockObject, APIError>) -> Void) {
        guard let body = encodeBody(route) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/route/static", method: "POST", body: body, completion: completion)
    }

    public func updateStaticMockRoutes(routes: [MockObject], completion: @escaping (Result<[MockObject], APIError>) -> Void) {
        guard let body = encodeBody(routes) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "/mock/routes/static", method: "POST", body: body, completion: completion)
    }

    public func fetchDynamicMockRoutes( completion: @escaping (Result<[DynamicMockResponse], APIError>) -> Void) {
        request(endpoint: "/mock/routes/dynamic", method: "GET", completion: completion)
    }

    public func addDynamicMockScenario(scenario: ScenarioMockObject, completion: @escaping (Result<ScenarioMockResponse, APIError>) -> Void) {
        guard let body = encodeBody(scenario) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "/mock/routes/dynamic", method: "POST", body: body, completion: completion)
    }

    public func fetchGlobalLatency( completion: @escaping (Result<LatencyInfo, APIError>) -> Void) {
        request(endpoint: "mock/latency", method: "GET", completion: completion)
    }

    public func addGlobalLatency(latencyInfo: LatencyInfo, completion: @escaping (Result<LatencyInfo, APIError>) -> Void) {
        guard let body = encodeBody(latencyInfo) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/latency", method: "POST", body: body, completion: completion)
    }

    public func fetchGlobalBandwidth( completion: @escaping (Result<BandwidthInfo, APIError>) -> Void) {
        request(endpoint: "mock/bandwidth", method: "GET", completion: completion)
    }

    public func addGlobalBandwidth(bandwidthInfo: BandwidthInfo, completion: @escaping (Result<BandwidthInfo, APIError>) -> Void) {
        guard let body = encodeBody(bandwidthInfo) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/bandwidth", method: "POST", body: body, completion: completion)
    }

    public func resetAllMocksAndSettings( completion: @escaping (Result<String, APIError>) -> Void) {
        request(endpoint: "mock/reset/all", method: "POST") { (result: Result<[String: String], APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response["message"] ?? "Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func resetLatency(completion: @escaping (Result<LatencyInfo, APIError>) -> Void) {
        let latencyInfo = LatencyInfo(enabled: false, latency: LatencyLevel.NONE.latencyMs)
        guard let body = encodeBody(latencyInfo) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/latency", method: "POST", body: body, completion: completion)
    }

    public func resetBandwidth(completion: @escaping (Result<BandwidthInfo, APIError>) -> Void) {
        let bandwidthInfo = BandwidthInfo(enabled: false, limit: BandwidthLimit.NONE.speedBytesPerSec)
        guard let body = encodeBody(bandwidthInfo) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/bandwidth", method: "POST", body: body, completion: completion)
    }

    public func resetStaticMock(staticMock: MockObject, completion: @escaping (Result<MockObject, APIError>) -> Void) {
        var updatedStaticMock = staticMock
        updatedStaticMock.enabled = false
        guard let body = encodeBody(updatedStaticMock) else {
            completion(.failure(.decodingError(NSError(domain: "EncodingError", code: 0, userInfo: nil))))
            return
        }
        request(endpoint: "mock/route/static", method: "POST", body: body, completion: completion)
    }
}

public class BypassSSLValidationDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Accept all certificates
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
