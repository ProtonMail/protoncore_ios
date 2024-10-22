//
//  ContactBuilder.swift
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

// MARK: - IContact Structures

// Define IContact which holds an array of contacts
public struct IContact: Codable {
    public var contacts: [Contact]

    public init(contacts: [Contact]) {
        self.contacts = contacts
    }

    private enum CodingKeys: String, CodingKey {
        case contacts = "Contacts"
    }
}

// Define the Contact struct
public struct Contact: Codable {
    public let name: String
    public let cards: [Card]

    public init(name: String, cards: [Card]) {
        self.name = name
        self.cards = cards
    }

    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case cards = "Cards"
    }
}

// Define the Card struct
public struct Card: Codable {
    public let data: String

    public init(data: String) {
        self.data = data
    }

    private enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public class ContactBuilder {
    private var contactList: IContact
    public let user: UserBuilder

    public init(user: UserBuilder) {
        self.contactList = IContact(contacts: [])
        self.user = user
    }

    @discardableResult
    public func addContact(vcard: VCardBuilder) -> ContactBuilder {
        let name = vcard.fullNameValue // We extract the full name from the vCard
        let card = Card(data: vcard.getFormattedString()) // Create a Card object with vCard data
        let contactEntry = Contact(name: name, cards: [card])
        self.contactList.contacts.append(contactEntry)
        return self
    }

    public func hasContacts() -> Bool {
        return !self.contactList.contacts.isEmpty
    }

    private func build() -> IContact {
        return self.contactList
    }

    public func getDataAsYaml() throws -> String {
        let flattenedData = self.flattenForYaml() // Flatten data for easier serialization
        let yamlString = try Yams.dump(object: flattenedData)
        return yamlString
    }

    private func flattenForYaml() -> [String: Any] {
        var contactsArray: [[String: Any]] = []

        for contact in self.contactList.contacts {
            var contactDict: [String: Any] = [:]
            contactDict["Name"] = contact.name
            contactDict["Cards"] = contact.cards.map { card in
                return ["Data": card.data]
            }
            contactsArray.append(contactDict)
        }

        return ["Contacts": contactsArray]
    }
}
