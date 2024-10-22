//
//  MailboxBuilder.swift
//  ProtonCore-QuarkCommands - Created on 15.10.2024.
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
import Yams

// Settings struct for mailbox
public struct MailboxSettings: Codable {
    public var viewMode: String
    public var pgpScheme: String
    
    public init(viewMode: String, pgpScheme: String) {
        self.viewMode = viewMode
        self.pgpScheme = pgpScheme
    }
    
    enum CodingKeys: String, CodingKey {
        case viewMode = "ViewMode"
        case pgpScheme = "PGPScheme"
    }
}

// Message struct for emails
public struct Message: Codable {
    public var path: String
    public var state: MessageState
    
    enum CodingKeys: String, CodingKey {
        case path = "Path"
        case state = "State"
    }
    
    init(path: String, state: MessageState) {
        self.path = path
        self.state = state
    }
}

// Enum for message state
public enum MessageState: String, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case received = "Received"
}

public class MailboxBuilder {
    public var user: UserBuilder
    public var emails: [EmailBuilder] = []
    public var emailStates: [(EmailBuilder, MessageState?)] = []
    
    var settings: MailboxSettings
    
    public init(user: UserBuilder, viewMode: String = "Conversation", pgpScheme: String = "PGPInline") {
        self.user = user
        self.settings = MailboxSettings(viewMode: viewMode, pgpScheme: pgpScheme)
    }
    
    @discardableResult
    public func addEml(eml: EmailBuilder, messageState: MessageState? = nil) -> Self {
        emails.append(eml)
        emailStates.append((eml, messageState))
        return self
    }
    
    public func getDataAsYaml() throws -> String {
        // Create an array of messages for YAML output
        let messages: [[String: String]] = emailStates.map { (email, state) in
            return [
                "Path": email.options.path ?? "Unknown Path",  // Use nil-coalescing to provide a fallback value
                "State": state?.rawValue ?? "Draft"
            ]
        }
        
        // Construct the YAML content dictionary
        let yamlContent: [String: Any] = [
            "Settings": [
                "ViewMode": settings.viewMode,
                "PGPScheme": settings.pgpScheme
            ],
            "Messages": messages
        ]
        
        return try Yams.dump(object: yamlContent)
    }
}
