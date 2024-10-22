//
//  EventsInfo.swift
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

public struct EventsInfo {
    var totalEvents: Int
    var successfulImportedEvents: Int
}

public let importedEventsNumbers: [String: EventsInfo] = [
    "gmailEventsCountYearly": EventsInfo(totalEvents: 35, successfulImportedEvents: 35),
    "gmailEventsCountMonthly": EventsInfo(totalEvents: 35, successfulImportedEvents: 35),
    "gmailEventsCountWeekly": EventsInfo(totalEvents: 39, successfulImportedEvents: 39),
    "gmailEventsCountDaily": EventsInfo(totalEvents: 37, successfulImportedEvents: 37),
    "tutanotaEventsCountDaily": EventsInfo(totalEvents: 26, successfulImportedEvents: 26),
    // Add other entries here
]

// Enum for Subscribed Calendar URL
public enum SubscribedCalendarURL: String {
    case validURL = "https://www.officeholidays.com/ics/lithuania"
}

// Enum for Test Domains
public enum TestDomains: String {
    case externalDomain = "proton.test"
}

// Struct to hold Invites Data
public struct InvitesData {
    public var organizer: String
    public var organizerEmail: String
    public var attendeeEmail: String

    public init(organizer: String, organizerEmail: String, attendeeEmail: String) {
        self.organizer = organizer
        self.organizerEmail = organizerEmail
        self.attendeeEmail = attendeeEmail
    }
}

// Constant to represent Invite with External Mandatory Attendee
public let inviteWithExtMandAttendee = InvitesData(
    organizer: "organizer",
    organizerEmail: "organizer@\(TestDomains.externalDomain.rawValue)",
    attendeeEmail: "plus@\(TestDomains.externalDomain.rawValue)"
)

// Struct for default notifications
public struct DefaultNotifications {
    public static let allDay = ["1 day before at 09:00", "1 day before at 09:00 by email"]
    public static let partDay = ["15 minutes before", "15 minutes before by email"]
}

// Struct for default calendar data
public struct DefaultCalendarData {
    public static let calendarName = "My calendar"
}
