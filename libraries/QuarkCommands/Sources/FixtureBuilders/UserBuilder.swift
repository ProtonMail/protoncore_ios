//
//  UserBuilder.swift
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
import Yams // Make sure to include Yams in your project for YAML serialization

public struct IUser: Encodable {
    public var userName: String
    public var password: String
    public var settings: UserSettings
    public var subscriptionHistory: [UserSubscriptionHistory]?
    
    public init(userName: String, password: String, settings: UserSettings, subscriptionHistory: [UserSubscriptionHistory]? = nil) {
        self.userName = userName
        self.password = password
        self.settings = settings
        self.subscriptionHistory = subscriptionHistory
    }
    
    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case password = "Password"
        case settings = "Settings"
        case subscriptionHistory = "SubscriptionHistory"
    }
}

public struct UserSettings: Encodable {
    public var flags: UserFlags
    public var timeFormat: String
    public var weekStart: String
    
    public init(flags: UserFlags, timeFormat: String, weekStart: String) {
        self.flags = flags
        self.timeFormat = timeFormat
        self.weekStart = weekStart
    }
    
    enum CodingKeys: String, CodingKey {
        case flags = "Flags"
        case timeFormat = "TimeFormat"
        case weekStart = "WeekStart"
    }
}

public struct UserFlags: Encodable {
    public var welcomed: Bool
    
    public init(welcomed: Bool) {
        self.welcomed = welcomed
    }
    
    enum CodingKeys: String, CodingKey {
        case welcomed = "Welcomed"
    }
}

public struct UserSubscriptionHistory: Encodable {
    public var plan: String
    
    public init(plan: String) {
        self.plan = plan
    }
    
    enum CodingKeys: String, CodingKey {
        case plan = "Plan"
    }
}

public final class UserBuilder {
    
    var user: IUser
    public lazy var mailbox: MailboxBuilder = MailboxBuilder(user: self)
    public lazy var contacts: ContactBuilder = ContactBuilder(user: self)
    public lazy var calbox: CalboxBuilder = CalboxBuilder()
    
    private var yamlDataInMemory: String = "" // In-memory storage for YAML data
    private var fixturesInMemory: [String: String] = [:] // In-memory storage for all YAML data
    
    public init(userName: String = "sasasa", password: String = "test1234") {
        self.user = IUser(
            userName: userName,
            password: password,
            settings: UserSettings(flags: UserFlags(welcomed: true), timeFormat: "Default", weekStart: "Default"),
            subscriptionHistory: [UserSubscriptionHistory(plan: "mail2022")]
        )
    }
    
    public func seedUser(quark: Quark) throws -> User {
        let fixturesToUpload = try self.generateUserFixture()
        
        return try quark.uploadFixtures(props: fixturesToUpload)
    }
    
    private func getDataAsYaml() {
        do {
            let encoder = YAMLEncoder()
            let encodedYAML = try encoder.encode(user)
            self.yamlDataInMemory = encodedYAML
            self.fixturesInMemory["user.yml"] = encodedYAML
        } catch {
            print("Error saving user data to memory: \(error)")
        }
    }
    
    public func generateUserFixture() throws -> LoadFixturesProps {
        // Save user data
        self.getDataAsYaml()
        
        // Save contacts
        if self.contacts.hasContacts() {
            let contactsYaml = try self.contacts.getDataAsYaml()
            self.fixturesInMemory["contacts.yml"] = contactsYaml
        }
        
        // Save mailbox messages
        if try self.mailbox.getDataAsYaml().isEmpty == false {
            let mailboxYaml = try self.mailbox.getDataAsYaml()
            self.fixturesInMemory["mailbox.yml"] = mailboxYaml
            
            for eml in self.mailbox.emails {
                let emlYaml = eml.generateRFC2822()
                self.fixturesInMemory[eml.options.path ?? "default.eml"] = emlYaml
            }
        }
        
        // Save calendar data if available
        if try self.calbox.getDataAsYaml().isEmpty == false{
            let calboxYaml = try self.calbox.getDataAsYaml()
            self.fixturesInMemory["calendars.yml"] = calboxYaml
        }
        
        let files: [(filename: String, fixtureData: Data)] = self.fixturesInMemory.compactMap { (filename, content) in
            if let data = content.data(using: .utf8) {
                return (filename, data)
            }
            return nil
        }
        
        return LoadFixturesProps(files: files)
    }
}
