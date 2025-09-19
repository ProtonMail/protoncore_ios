//
//  RemoteManager.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

public protocol RemoteManagerProviding: Sendable {

    func updateSession(sessionID: String, authToken: String)

    func getFromURL<T: Decodable>(_ url: URL) async throws -> T

    func postToURL(request: APIRequest) async throws
    func postToURL<T: Decodable>(request: APIRequest) async throws -> T

    func putToURL(request: APIRequest) async throws
    func putToURL<T: Decodable>(request: APIRequest) async throws -> T

    func deleteToURL(request: APIRequest) async throws
    func deleteToURL<T: Decodable>(request: APIRequest) async throws -> T
}

public enum RemoteError: LocalizedError, Comparable {
    case errorDecondingResponse(details: String)
    case invalidHTTPResponse(url: String)
    case responseReturnedError(errorCode: Int, urlString: String)

    public var errorDescription: String? {
        switch self {
        default:
            return PaymentsV2Localizer.Remote_manager_error.l10n
        }
    }

    public var failureReason: String? {
        switch self {
        case .errorDecondingResponse(let details):
            return "Error deconding response: \(details)"
        case .invalidHTTPResponse(let url):
            return "Invalid http response for url: \(url)"
        case .responseReturnedError(let errorCode, let urlString):
            return "Request: \(urlString) returned error code: \(errorCode)"
        }
    }
}

enum SerializationError: Error {
    case unabledToSerializeHTTPBody
}

public enum RequestTye: String {
    case PUT, POST, DELETE, GET
}

public final class RemoteManager: RemoteManagerProviding, @unchecked Sendable {

    private var requestHTTPHeader: [APIHeader: String]!
    private let queue = DispatchQueue(label: "paymentsV2.remoteManager.syncQueue")

    private var session: URLSession

    public init(sessionID: String, authToken: String, appVersion: String, atlasSecret: String? = nil) {
        session = URLSession.shared
        generateRequestHeader(sessionID, authToken, appVersion, atlasSecret)
    }

    public func updateSession(sessionID: String, authToken: String) {
        queue.sync {
            requestHTTPHeader[.sessionId] = sessionID
            requestHTTPHeader[.authorization] = "Bearer \(authToken)"
        }
    }

    // Used for testing
    func setSession(_ session: URLSession) {
        queue.sync {
            self.session = session
        }
    }

    // MARK: Private methods

    private func generateRequestHeader(_ sessionID: String, _ authToken: String, _ appVersion: String, _ atlasSecret: String?) {
        queue.sync {
            requestHTTPHeader = [.sessionId: sessionID,
                                 .accept: "application/json",
                                 .contentType: "application/json",
                                 .authorization: "Bearer \(authToken)",
                                 .appVersion: appVersion]
            guard let atlasSecret else {
                return
            }

            requestHTTPHeader[.atlasSecret] = atlasSecret
        }
    }

    // MARK: GET

    public func getFromURL<T: Decodable & Sendable>(_ url: URL) async throws -> T {

        let (data, response) = try await session.data(for: requestFactory(url: url,
                                                                          requestType: .GET))

        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)

        return try decodeResponse(data: data)
    }

    // MARK: POST

    public func postToURL(request: APIRequest) async throws {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .POST,
                                                                          body: request.body))
        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)
    }

    public func postToURL<T: Decodable & Sendable>(request: APIRequest) async throws -> T {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .POST,
                                                                          body: request.body))

        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)
        return try decodeResponse(data: data)
    }

    // MARK: PUT

    public func putToURL(request: APIRequest) async throws {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .PUT,
                                                                          body: request.body))

        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)
    }

    public func putToURL<T: Decodable & Sendable>(request: APIRequest) async throws -> T {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .PUT,
                                                                          body: request.body))

        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)

        return try decodeResponse(data: data)
    }

    // MARK: DELETE

    public func deleteToURL(request: APIRequest) async throws {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .DELETE,
                                                                          body: request.body))
        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)
    }

    public func deleteToURL<T: Decodable & Sendable>(request: APIRequest) async throws -> T {

        let (data, response) = try await session.data(for: requestFactory(url: request.url,
                                                                          requestType: .DELETE,
                                                                          body: request.body))

        try verifyBodyResponse(data: data)
        try verifyResponse(response: response)

        return try decodeResponse(data: data)
    }

    // MARK: Private methods

    private func verifyResponse(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = RemoteError.invalidHTTPResponse(url: response.url?.absoluteString ?? "")
            PMLog.error(error.failureReason ?? "PaymentsV2 - invalidHTTPResponse", sendToExternal: true)
            throw error
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let error = RemoteError.responseReturnedError(errorCode: httpResponse.statusCode, urlString: httpResponse.url?.absoluteString ?? "")
            PMLog.error(error.failureReason ?? "PaymentsV2 - responseReturnedError \(httpResponse.statusCode)", sendToExternal: true)
            throw error
        }
    }

    private func verifyBodyResponse(data: Data) throws {

        let statusCode: StatusResponse = try decodeResponse(data: data)

        if let error = APICodeError(rawValue: statusCode.code) {
            throw error
        }
    }

    private func decodeResponse<T: Decodable>(data: Data) throws -> T {

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCamelCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            let error = RemoteError.errorDecondingResponse(details: error.localizedDescription)
            PMLog.error(error.failureReason ?? "PaymentsV2 - errorDecondingResponse", sendToExternal: true)
            throw error
        }
    }

    private func requestFactory(url: URL,
                                requestType: RequestTye,
                                body: [String: Any]? = nil) throws -> URLRequest {

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue

        if let body = body {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        }

        urlRequest.allHTTPHeaderFields = formatHTTPHeader()

        return urlRequest
    }

    private func formatHTTPHeader() -> [String: String]  {

        var formattedHTTPHeader: [String: String] = [:]
        requestHTTPHeader.keys.forEach { key in
            formattedHTTPHeader[key.rawValue] = requestHTTPHeader[key]
        }

        return formattedHTTPHeader
    }
}
