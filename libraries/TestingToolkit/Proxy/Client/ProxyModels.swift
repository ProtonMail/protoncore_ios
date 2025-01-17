//
//  ProxyModels.swift
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

public struct MockObject: Codable {
    public var name: String
    public var enabled: Bool
    public let updateFile: Bool?
    public let isRawFileContent: Bool?
    public let request: RequestDetails
    public let response: ResponseDetails

    public init(name: String, enabled: Bool, updateFile: Bool? = nil, isRawFileContent: Bool? = nil, request: RequestDetails, response: ResponseDetails) {
        self.name = name
        self.enabled = enabled
        self.updateFile = updateFile
        self.isRawFileContent = isRawFileContent
        self.request = request
        self.response = response
    }
}

public struct RequestDetails: Codable {
    public let exactUrl: [String]?
    public let matchUrl: [String]?
    public let method: String?

    public enum CodingKeys: String, CodingKey {
        case exactUrl, matchUrl, method
    }

    public init(exactUrl: [String]? = nil, matchUrl: [String]? = nil, method: String? = nil) {
        self.exactUrl = exactUrl
        self.matchUrl = matchUrl
        self.method = method
    }

    public func validate() throws {
        guard exactUrl != nil || matchUrl != nil else {
            throw ValidationError.missingUrl
        }

        guard !(exactUrl != nil && matchUrl != nil) else {
            throw ValidationError.bothUrlsProvided
        }
    }

    public enum ValidationError: Error {
        case missingUrl
        case bothUrlsProvided
    }
}

// General-purpose type to handle any JSON type, including Data and Base64-encoded JSON
public struct AnyCodable: Codable {
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            // Handle strings, including "Hello World"
            value = stringValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            // Handle dictionaries
            value = dictValue.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            // Handle arrays
            value = arrayValue.map { $0.value }
        } else if container.decodeNil() {
            // Handle nil values
            value = NSNull()
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value.")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let dictValue as [String: Any]:
            // Directly encode dictionary values (including empty dictionaries)
            let anyDict = dictValue.mapValues { AnyCodable(value: $0) }
            try container.encode(anyDict)
        case let arrayValue as [Any]:
            // Directly encode arrays to preserve JSON format
            let anyArray = arrayValue.map { AnyCodable(value: $0) }
            try container.encode(anyArray)
        case let dataValue as Data:
            // Encode Data explicitly as Base64 if it was indeed Data type
            let base64String = dataValue.base64EncodedString()
            try container.encode(base64String)
        case is NSNull:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to encode value."))
        }
    }

    public init(value: Any) {
        self.value = value
    }
}

public struct ResponseDetails: Codable {
    public let statusCode: Int?
    public let body: AnyCodable?
    public let headers: AnyCodable?

    public init(statusCode: Int, body: AnyCodable? = nil, headers: AnyCodable? = nil) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
}

public struct DynamicMocksSummary: Codable {
    public let name: String
    public let description: String
    public let enabled: Bool?
    public let updateFile: Bool?

    public init(name: String, description: String, enabled: Bool?, updateFile: Bool?) {
        self.name = name
        self.description = description
        self.enabled = enabled
        self.updateFile = updateFile
    }
}

public struct DynamicMockBody: Codable {
    public let name: String
    public let enabled: Bool
    public let parameters: AnyCodable?

    public init(name: String, enabled: Bool, parameters: AnyCodable? = nil) {
        self.name = name
        self.enabled = enabled
        self.parameters = parameters
    }
}

public struct DynamicMockResponse: Codable {
    public let name: String
    public let description: String
    public let enabled: Bool
    public let updateFile: Bool
    public let mocks: [Mock]

    public init(name: String, description: String, enabled: Bool, updateFile: Bool, mocks: [Mock]) {
        self.name = name
        self.description = description
        self.enabled = enabled
        self.updateFile = updateFile
        self.mocks = mocks
    }
}

public struct Mock: Codable {
    public let request: RequestDetails
    public let response: ResponseDetails
    public let meta: MockMeta?

    public init(request: RequestDetails, response: ResponseDetails, meta: MockMeta? = nil) {
        self.request = request
        self.response = response
        self.meta = meta
    }
}

public struct MockMeta: Codable {
    public let test: String
    public let description: String

    public init(test: String, description: String) {
        self.test = test
        self.description = description
    }
}

public struct ScenarioFile: Codable {
    public let description: String?
    public let updateFile: Bool?
    public let mockFiles: [String]

    public init(description: String? = nil, updateFile: Bool? = nil, mockFiles: [String]) {
        self.description = description
        self.updateFile = updateFile
        self.mockFiles = mockFiles
    }
}

public struct ScenarioFileWithName {
    public let name: String
    public let directory: String
    public let scenarioFile: ScenarioFile

    public init(name: String, directory: String, scenarioFile: ScenarioFile) {
        self.name = name
        self.directory = directory
        self.scenarioFile = scenarioFile
    }
}

public struct LatencyInfo: Codable {
    public let enabled: Bool
    public let latency: Int

    public init(enabled: Bool, latency: Int) {
        self.enabled = enabled
        self.latency = latency
    }
}

public struct BandwidthInfo: Codable {
    public let enabled: Bool
    public let limit: Int

    public init(enabled: Bool, limit: Int) {
        self.enabled = enabled
        self.limit = limit
    }
}

public struct RequestForward: Codable {
    public let enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }
}

public enum ScenarioDataError: Error {
    case missingFile(String)
    case fileReadError(String)
    case jsonParsingError(String)

    public init(errorMessage: String) {
        switch errorMessage {
        case "missingFile":
            self = .missingFile(errorMessage)
        case "fileReadError":
            self = .fileReadError(errorMessage)
        default:
            self = .jsonParsingError(errorMessage)
        }
    }
}

public struct InvalidRequestBodySchemaResponse: Codable {
    public let instancePath: String
    public let schemaPath: String
    public let keyword: String
    public let params: [String: AnyCodable]
    public let message: String

    public init(instancePath: String, schemaPath: String, keyword: String, params: [String: AnyCodable], message: String) {
        self.instancePath = instancePath
        self.schemaPath = schemaPath
        self.keyword = keyword
        self.params = params
        self.message = message
    }
}
