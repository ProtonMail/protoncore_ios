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

public protocol RemoteManagerProviding {

    func updateSession(sessionID: String, authToken: String)

    func getFromURL<T: Decodable>(_ url: URL) async throws -> T

    func postToURL(request: APIRequest) async throws
    func postToURL<T: Decodable>(request: APIRequest) async throws -> T

    func putToURL(request: APIRequest) async throws
    func putToURL<T: Decodable>(request: APIRequest) async throws -> T

    func deleteToURL(request: APIRequest) async throws
    func deleteToURL<T: Decodable>(request: APIRequest) async throws -> T
}

enum RemoteError: Error, Comparable {
    case errorDecondingResponse
    case invalidHTTPResponse
    case responseReturnedError(errorCode: Int)
}

enum SerializationError: Error {
    case unabledToSerializeHTTPBody
}

public enum RequestTye: String {
    case PUT, POST, DELETE, GET
}

public class RemoteManager: RemoteManagerProviding {

    private var requestHTTPHeader: [APIHeader: String]!

    var session: URLSession

    public init(sessionID: String, authToken: String, appVersion: String, atlasSecret: String? = nil) {
        session = URLSession.shared
        generateRequestHeader(sessionID, authToken, appVersion, atlasSecret)
    }

    public func updateSession(sessionID: String, authToken: String) {
        requestHTTPHeader[.sessionId] = sessionID
        requestHTTPHeader[.authorization] =  "Bearer \(authToken)"
    }

    // MARK: Private methods

    private func generateRequestHeader(_ sessionID: String, _ authToken: String, _ appVersion: String, _ atlasSecret: String?) {

        requestHTTPHeader = [.sessionId: sessionID,
                             .accept: "application/json",
                             .contentType: "application/json",
                             .authorization: "Bearer \(authToken)",
                             .appVersion: appVersion]

#if DEBUG
        guard let atlasSecret = atlasSecret else {
            return
        }

        requestHTTPHeader[.atlasSecret] = atlasSecret
#endif
    }

    // MARK: GET

    public func getFromURL<T: Decodable>(_ url: URL) async throws -> T {

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

    public func postToURL<T: Decodable>(request: APIRequest) async throws -> T {

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

    public func putToURL<T: Decodable>(request: APIRequest) async throws -> T {

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

    public func deleteToURL<T: Decodable>(request: APIRequest) async throws -> T {

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
            throw RemoteError.invalidHTTPResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw RemoteError.responseReturnedError(errorCode: httpResponse.statusCode)
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

        let decodedData = try decoder.decode(T.self, from: data)

        return decodedData
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
