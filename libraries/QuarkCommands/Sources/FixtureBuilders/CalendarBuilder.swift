//
//  CalendarBuilder.swift
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

//
//  CalendarBuilder.swift
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
//
//  CalendarBuilder.swift
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

// Struct for Subscription Parameters
public struct Subscribed: Codable {
    public var url: String?
    public var status: String?

    public init(url: String? = nil, status: String? = nil) {
        self.url = url
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case url = "Url"
        case status = "Status"
    }
}

// Struct for Holidays Calendar Parameters
public struct Holidays: Codable {
    public var passphrase: String
    public var sessionKey: String
    public var countryCode: String
    public var language: String
    public var timezones: [String]

    public init(passphrase: String, sessionKey: String, countryCode: String, language: String, timezones: [String]) {
        self.passphrase = passphrase
        self.sessionKey = sessionKey
        self.countryCode = countryCode
        self.language = language
        self.timezones = timezones
    }

    enum CodingKeys: String, CodingKey {
        case passphrase = "Passphrase"
        case sessionKey = "SessionKey"
        case countryCode = "CountryCode"
        case language = "Language"
        case timezones = "Timezones"
    }
}

// Struct for a Calendar
public struct Calendar: Codable {
    public var name: String
    public var description: String?
    public var color: String?
    public var display: Bool?
    public var generateCalendarKey: Bool?
    public var email: String?
    public var subscriptionParameters: Subscribed?
    public var holidayParameters: Holidays?

    public init(
        name: String,
        description: String? = nil,
        color: String? = nil,
        display: Bool? = nil,
        generateCalendarKey: Bool? = nil,
        email: String? = nil,
        subscriptionParameters: Subscribed? = nil,
        holidayParameters: Holidays? = nil
    ) {
        self.name = name
        self.description = description
        self.color = color
        self.display = display
        self.generateCalendarKey = generateCalendarKey
        self.email = email
        self.subscriptionParameters = subscriptionParameters
        self.holidayParameters = holidayParameters
    }

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case description = "Description"
        case color = "Color"
        case display = "Display"
        case generateCalendarKey = "GenerateCalendarKey"
        case email = "Email"
        case subscriptionParameters = "SubscriptionParameters"
        case holidayParameters = "HolidayParameters"
    }
}

// Struct for Calbox CalboxSettings and Calendar List
public struct Calbox: Codable {
    public struct CalboxSettings: Codable {
        public var primaryTimezone: String
        public var secondaryTimezone: String?
        public var autoImportInvite: String?

        public init(primaryTimezone: String, secondaryTimezone: String? = nil, autoImportInvite: String? = nil) {
            self.primaryTimezone = primaryTimezone
            self.secondaryTimezone = secondaryTimezone
            self.autoImportInvite = autoImportInvite
        }

        enum CodingKeys: String, CodingKey {
            case primaryTimezone = "PrimaryTimezone"
            case secondaryTimezone = "SecondaryTimezone"
            case autoImportInvite = "AutoImportInvite"
        }
    }

    public var settings: CalboxSettings?
    public var calendars: [Calendar] = []

    public init(settings: CalboxSettings, calendars: [Calendar] = []) {
        self.settings = settings
        self.calendars = calendars
    }

    enum CodingKeys: String, CodingKey {
        case settings = "Settings"
        case calendars = "Calendars"
    }
}

public class CalboxBuilder {
    private var calbox: Calbox

    public init() {
        self.calbox = Calbox(settings: Calbox.CalboxSettings(primaryTimezone: "UTC"))
    }

    public func setPrimaryTimezone(_ value: String) -> CalboxBuilder {
        self.calbox.settings?.primaryTimezone = value
        return self
    }

    @discardableResult
    public func addPersonalCalendars(count: Int = 1, name: String? = nil, description: String? = nil, color: String? = nil) -> CalboxBuilder {
        for _ in 0..<count {
            let calendarName = name ?? UUID().uuidString.prefix(10).description // Generate a random name if not provided
            let calendar = createPersonalCalendar(name: calendarName, description: description, color: color)
            self.calbox.calendars.append(calendar)
        }
        return self
    }

    @discardableResult
    public func addSinglePersonalCalendar(name: String? = nil, description: String? = nil, color: String? = nil) -> CalboxBuilder {
        return self.addPersonalCalendars(count: 1, name: name, description: description, color: color)
    }

    @discardableResult
    public func addHolidaysCalendars(count: Int = 1) -> CalboxBuilder {
        let holidayCals = holidaysCalendarsList.sorted { $0.key < $1.key }.map { $0.value }

        for i in 0..<min(count, holidayCals.count) {
            let holidayCalendar = holidayCals[i]
            let calendar = createHolidaysCalendar(
                name: "Holidays in \(holidayCalendar.countryCode.uppercased())",
                countryCode: holidayCalendar.countryCode,
                language: holidayCalendar.language,
                passphrase: holidayCalendar.passphrase,
                sessionKey: holidayCalendar.sessionKey.key,
                timezones: holidayCalendar.timezones
            )
            self.calbox.calendars.append(calendar)
        }
        return self
    }

    @discardableResult
    public func addSubscribedCalendars(count: Int = 1, name: String? = nil, url: String? = nil) -> CalboxBuilder {
        for _ in 0..<count {
            let calendarName = name ?? "Subscribed \(UUID().uuidString.prefix(5))"
            let calendar = createSubscribedCalendar(name: calendarName, url: url ?? "http://example.com")
            self.calbox.calendars.append(calendar)
        }
        return self
    }

    public func hasCalendars() -> Bool {
        return !self.calbox.calendars.isEmpty
    }

    func getDataAsYaml() throws -> String {
        var calendarsNode: Node = Node.mapping([:])

        var calendarsArray: [Node] = []
        for calendar in calbox.calendars {
            var calendarNode: Node = ["Name": Node.scalar(Node.Scalar(calendar.name))]

            if let holidayParams = calendar.holidayParameters {
                let holidayParametersNode: Node = [
                    "Passphrase": Node.scalar(Node.Scalar(holidayParams.passphrase)),
                    "SessionKey": Node.scalar(Node.Scalar(holidayParams.sessionKey)),
                    "CountryCode": Node.scalar(Node.Scalar(holidayParams.countryCode)),
                    "Language": Node.scalar(Node.Scalar(holidayParams.language)),
                    "Timezones": Node.sequence(Node.Sequence(holidayParams.timezones.map { Node.scalar(Node.Scalar($0)) }))
                ]
                calendarNode["HolidayParameters"] = holidayParametersNode
            }

            calendarsArray.append(calendarNode)
        }
        calendarsNode = Node.mapping(["Calendars": Node.sequence(Node.Sequence(calendarsArray))])

        return try Yams.dump(object: calendarsNode)
    }

    private func createPersonalCalendar(name: String, description: String? = nil, color: String? = nil, display: Bool? = nil, generateCalendarKey: Bool? = nil, email: String? = nil) -> Calendar {
        return Calendar(
            name: name,
            description: description,
            color: color,
            display: display,
            generateCalendarKey: generateCalendarKey,
            email: email
        )
    }

    private func createHolidaysCalendar(name: String, countryCode: String, language: String, passphrase: String, sessionKey: String, timezones: [String]) -> Calendar {
        let holidaysProperties = Holidays(
            passphrase: passphrase,
            sessionKey: sessionKey,
            countryCode: countryCode,
            language: language,
            timezones: timezones
        )
        return Calendar(name: name, holidayParameters: holidaysProperties)
    }

    private func createSubscribedCalendar(name: String, url: String?) -> Calendar {
        let subscribedProperties = Subscribed(url: url)
        return Calendar(name: name, subscriptionParameters: subscribedProperties)
    }
}

public enum YamlGenerationError: Error {
    case yamlDumpFailed(Error)
}
