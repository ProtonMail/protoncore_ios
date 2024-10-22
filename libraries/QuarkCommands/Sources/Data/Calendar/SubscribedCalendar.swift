//
//  SubscribedCalendar.swift
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

public struct SubscribedCalendar {
    public var url: String
    public var title: String?
    public var event: String?
}

public let subscribedCalendarsURLs: [String: SubscribedCalendar] = [
    "publicURLtoCalendarGmail": SubscribedCalendar(
        url: "https://calendar.google.com/calendar/embed?src=e7ac1f48d170a915d3ee9da31c8e2542d01c02af417fb53dd951a18d8981a4b8%40group.calendar.google.com&ctz=Europe%2FVilnius"
    ),
    "validExternalUrl": SubscribedCalendar(
        url: "https://calendar.google.com/calendar/ical/1r1ae28ch3069m28ob4cmcaags%40group.calendar.google.com/private-b185f7b9989ba3bc097589d443165fb7/basic.ics",
        title: "[Automation] Valid URL"
    ),
    "validExternalHolidaysUrl": SubscribedCalendar(
        url: "https://www.officeholidays.com/ics/lithuania",
        title: "Lithuania Holidays"
    ),
    "validLinkWithEvent": SubscribedCalendar(
        url: "https://calendar.google.com/calendar/ical/qgnoa4s4qaa3adp6so6b5gef0o%40group.calendar.google.com/private-3db712d7de630b2243d195f0a1477068/basic.ics",
        title: "[Automation] Calendar with one event",
        event: "Event from subscribed calendar"
    ),
    "validUrlTooBigCalendar": SubscribedCalendar(
        url: "https://drive.google.com/uc?export=download&id=1VHCobb3cRP6HyUxfX_PhFugsFS8Q1R_t"
    ),
    "validUrlTempNotAccessible": SubscribedCalendar(
        url: "https://www.proton"
    ),
    "invalidUrlBeError": SubscribedCalendar(
        url: "My url is very nice https://calendar.google.com/calendar/ical/1r1ae28ch3069m28ob4cmcaags%40group.calendar.google.com/private-b185f7b9989ba3bc097589d443165fb7/basic.ics"
    )
]
