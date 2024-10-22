//
//  VCardBuilder.swift
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

public enum MediaType: String, Codable {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case webp = "image/webp"
    case tiff = "image/tiff"
    case bmp = "image/bmp"
    case svg = "image/svg+xml"
    case ico = "image/vnd.microsoft.icon"
}

public struct IAddress: Codable {
    public let street: String
    public let city: String
    public let stateProvince: String
    public let postalCode: String
    public let countryRegion: String

    public init(street: String, city: String, stateProvince: String, postalCode: String, countryRegion: String) {
        self.street = street
        self.city = city
        self.stateProvince = stateProvince
        self.postalCode = postalCode
        self.countryRegion = countryRegion
    }

    private enum CodingKeys: String, CodingKey {
        case street = "street"
        case city = "city"
        case stateProvince = "stateProvince"
        case postalCode = "postalCode"
        case countryRegion = "countryRegion"
    }
}

public struct IPhoto: Codable {
    public let url: String
    public let mediaType: String

    public init(url: String, mediaType: String) {
        self.url = url
        self.mediaType = mediaType
    }

    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case mediaType = "mediaType"
    }
}

public struct VCardData: Codable {
    public let email: String
    public let firstName: String
    public let lastName: String
    public let organization: String?
    public let homePhone: String?
    public let cellPhone: String?
    public let title: String?
    public let workPhone: String?
    public let workEmail: String?
    public let photo: IPhoto?
    public let homeAddress: IAddress?
    public let workAddress: IAddress?

    private enum CodingKeys: String, CodingKey {
        case email = "email"
        case firstName = "firstName"
        case lastName = "lastName"
        case organization = "organization"
        case homePhone = "homePhone"
        case cellPhone = "cellPhone"
        case title = "title"
        case workPhone = "workPhone"
        case workEmail = "workEmail"
        case photo = "photo"
        case homeAddress = "homeAddress"
        case workAddress = "workAddress"
    }

    public init(email: String,
                firstName: String,
                lastName: String,
                organization: String? = nil,
                homePhone: String? = nil,
                cellPhone: String? = nil,
                title: String? = nil,
                workPhone: String? = nil,
                workEmail: String? = nil,
                photo: IPhoto? = nil,
                homeAddress: IAddress? = nil,
                workAddress: IAddress? = nil) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.organization = organization
        self.homePhone = homePhone
        self.cellPhone = cellPhone
        self.title = title
        self.workPhone = workPhone
        self.workEmail = workEmail
        self.photo = photo
        self.homeAddress = homeAddress
        self.workAddress = workAddress
    }
}

// MARK: - VCardBuilder Class

public class VCardBuilder {
    private var vCardLines: [String] = []
    private var fullName: String = ""
    private var emailAddress: String = ""

    public init(data: VCardData) {
        self.buildVCard(from: data)
    }

    private func buildVCard(from data: VCardData) {
        vCardLines.append("BEGIN:VCARD")
        vCardLines.append("VERSION:4.0")

        setEmail(data.email)
        setName(firstName: data.firstName, lastName: data.lastName)
        setFullName(firstName: data.firstName, lastName: data.lastName)

        if let cellPhone = data.cellPhone {
            setCellPhone(cellPhone)
        }

        if let organization = data.organization {
            setOrganization(organization)
        }

        if let homePhone = data.homePhone {
            setHomePhone(homePhone)
        }

        if let title = data.title {
            setJobTitle(title)
        }

        if let workPhone = data.workPhone {
            setWorkPhone(workPhone)
        }

        if let workEmail = data.workEmail {
            setWorkEmail(workEmail)
        }

        if let photo = data.photo {
            setPhoto(photo)
        }

        if let homeAddress = data.homeAddress {
            setHomeAddress(address: homeAddress)
        }

        if let workAddress = data.workAddress {
            setWorkAddress(address: workAddress)
        }

        vCardLines.append("END:VCARD")
    }

    @discardableResult
    public func setName(firstName: String, lastName: String) -> VCardBuilder {
        // Format: LastName;FirstName;;;
        let name = "\(lastName);\(firstName);;;"
        vCardLines.append("N:\(name)")
        return self
    }

    @discardableResult
    public func setFullName(firstName: String, lastName: String) -> VCardBuilder {
        // Format: FirstName LastName
        self.fullName = "\(firstName) \(lastName)"
        vCardLines.append("FN:\(self.fullName)")
        return self
    }

    // Computed property for fullName (replaces getFullName)
    public var fullNameValue: String {
        return self.fullName
    }

    @discardableResult
    public func setOrganization(_ organization: String) -> VCardBuilder {
        vCardLines.append("ORG:\(organization)")
        return self
    }

    @discardableResult
    public func setJobTitle(_ title: String) -> VCardBuilder {
        vCardLines.append("TITLE:\(title)")
        return self
    }

    @discardableResult
    public func setWorkPhone(_ workPhone: String) -> VCardBuilder {
        vCardLines.append("TEL;TYPE=work:\(workPhone)")
        return self
    }

    @discardableResult
    public func setHomePhone(_ homePhone: String) -> VCardBuilder {
        vCardLines.append("TEL;TYPE=home:\(homePhone)")
        return self
    }

    @discardableResult
    public func setCellPhone(_ cellPhone: String) -> VCardBuilder {
        vCardLines.append("TEL;TYPE=cell:\(cellPhone)")
        return self
    }

    @discardableResult
    public func setEmail(_ email: String) -> VCardBuilder {
        self.emailAddress = email
        vCardLines.append("EMAIL:\(email)")
        return self
    }

    // Computed property for emailAddress (replaces getEmail)
    public var emailValue: String {
        return self.emailAddress
    }

    @discardableResult
    public func setWorkEmail(_ workEmail: String) -> VCardBuilder {
        vCardLines.append("EMAIL;TYPE=work:\(workEmail)")
        return self
    }

    @discardableResult
    public func setHomeAddress(address: IAddress) -> VCardBuilder {
        // Format: PO Box;Extended Address;Street;City;State/Province;Postal Code;Country/Region
        let formattedAddress = ";;\(address.street);\(address.city);\(address.stateProvince);\(address.postalCode);\(address.countryRegion)"
        vCardLines.append("ADR;TYPE=home:\(formattedAddress)")
        return self
    }

    @discardableResult
    public func setWorkAddress(address: IAddress) -> VCardBuilder {
        let formattedAddress = ";;\(address.street);\(address.city);\(address.stateProvince);\(address.postalCode);\(address.countryRegion)"
        vCardLines.append("ADR;TYPE=work:\(formattedAddress)")
        return self
    }

    @discardableResult
    public func setPhoto(_ photo: IPhoto) -> VCardBuilder {
        vCardLines.append("PHOTO;MEDIATYPE=\(photo.mediaType):\(photo.url)")
        return self
    }

    @discardableResult
    public func setUrl(_ url: String) -> VCardBuilder {
        // Add a URL to the vCard
        vCardLines.append("URL:\(url)")
        return self
    }

    @discardableResult
    public func setBirthday(_ birthday: String) -> VCardBuilder {
        // Add a birthday to the vCard, in the format YYYY-MM-DD
        vCardLines.append("BDAY:\(birthday)")
        return self
    }

    @discardableResult
    public func setNote(_ note: String) -> VCardBuilder {
        // Add a note to the vCard
        vCardLines.append("NOTE:\(note)")
        return self
    }

    // Method to get the full formatted vCard string
    public func getFormattedString() -> String {
        return vCardLines.joined(separator: "\n")
    }
}
