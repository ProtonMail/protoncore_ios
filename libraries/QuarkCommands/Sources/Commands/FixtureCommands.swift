//
//  FixtureCommands.swift
//  ProtonCore-QuarkCommands - Created on 15.10.2024.
//
// Copyright (c) 2023. Proton Technologies AG
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
import Combine
import Yams

private let fixturesLoad: String = "quark/raw::qa:fixtures:load"

public extension Quark {

    @discardableResult
    func uploadFixtures(props: LoadFixturesProps) throws -> User {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // Create the multipart form body
        for file in props.files {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(file.filename)\"; filename=\"\(file.filename)\"\r\n")
            body.append("Content-Type: application/octet-stream\r\n\r\n")
            body.append(file.fixtureData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")

        var args = [
            "--output-format=json"
        ]

        for file in props.files {
            if file.filename == "user.yml" {
                args.append("definition-paths[]=uploads://\(file.filename)")
            }
        }

        let request = try self.route(fixturesLoad)
            .httpMethod("POST")
            .args(args)
            .setRawData(body)
            .onRequestBuilder { request in
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 120 // Set timeout as per the requirements
            }
            .build()

        let (data, response) = try self.executeQuarkRequest(request)

        // Handle the response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw QuarkError(urlResponse: response, message: "Cannot load fixture: \(props.description)")
        }

        return try parseUserFromResponse(data: data)
    }
}

private func parseUserFromResponse(data: Data) throws -> User {
    // Decode regular User
    let userResponse = try JSONDecoder().decode(FixtureUserResponse.self, from: data)
    guard let user = userResponse.users.first else {
        throw NSError(domain: "InvalidResponse", code: -1, userInfo: [
            "reason": "No users found in response"
        ])
    }

    return User(
        id: user.ID.raw,
        name: user.name,
        password: user.password,
        email: "\(user.name)@black.com",
        publicKey: Data(base64Encoded: user.keys.first?.publicKey ?? "")?.base64EncodedString() ?? "",
        privateKey: Data(base64Encoded: user.keys.first?.privateKey ?? "")?.base64EncodedString() ?? ""
    )
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

public struct LoadFixturesProps {
    let files: [(filename: String, fixtureData: Data)]

    public init(files: [(filename: String, fixtureData: Data)]) {
        self.files = files
    }
    
    public var description: String {
        let fileDescriptions = files.map { file -> String in
            let filenameDescription = "Filename: \(file.filename)"
            let fixtureDataContent = "\(String(data: file.fixtureData, encoding: .utf8) ?? "Invalid UTF-8 data")"

            return "\(filenameDescription)\n\(fixtureDataContent)"
        }

        return "LoadFixturesProps:\n" + fileDescriptions.joined(separator: "\n\n")
    }
}
