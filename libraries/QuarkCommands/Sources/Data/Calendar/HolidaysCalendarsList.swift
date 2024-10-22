//
//  HolidayCalendar.swift
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

public struct SessionKey {
    public let key: String
    public let algorithm: String
}

public struct HolidayCalendar {
    public let countryCode: String
    public let language: String
    public let timezones: [String]
    public let passphrase: String
    public let sessionKey: SessionKey
}

// First on a new scientist env need to run seedHolidaysCalendars() quark command but only once
public let holidaysCalendarsList: [Int: HolidayCalendar] = [
    43: HolidayCalendar(
        countryCode: "us",
        language: "en",
        timezones: [
            "America/Adak", "America/Anchorage", "America/Boise", "America/Chicago", "America/Denver",
            "America/Detroit", "America/Indiana/Knox", "America/Indiana/Marengo", "America/Indiana/Petersburg",
            "America/Indiana/Tell_City", "America/Indiana/Vevay", "America/Indiana/Vincennes",
            "America/Indiana/Winamac", "America/Juneau", "America/Kentucky/Louisville",
            "America/Kentucky/Monticello", "America/Los_Angeles", "America/Menominee", "America/Metlakatla",
            "America/New_York", "America/Nome", "America/North_Dakota/Beulah", "America/North_Dakota/Center",
            "America/North_Dakota/New_Salem", "America/Phoenix", "America/Sitka", "America/Yakutat",
            "Pacific/Honolulu"
        ],
        passphrase: "2Wl3rCzTzqi6zJsddM5PTiRL8WtOZuMB0C/EIYrtQZo=",
        sessionKey: SessionKey(key: "fhcCr08Idg6QTKbjTmj4u3C0f+A+L+UCxS2plXcwiEA=", algorithm: "aes256")
    ),
    44: HolidayCalendar(
        countryCode: "fr",
        language: "fr",
        timezones: ["Europe/Paris"],
        passphrase: "BrrmI7HKzrnUSK9k7Sh0foP0xrnyuvSTuo+l/k6/AGw=",
        sessionKey: SessionKey(key: "kFMiu842bSQ+RrOF1kY6jdx2TICuDm3bHX9eBAND7Nw=", algorithm: "aes256")
    ),
    45: HolidayCalendar(
        countryCode: "fr",
        language: "en",
        timezones: ["Europe/Paris"],
        passphrase: "vgQy/0DtbxJ+s61UxLM7/7Ikx0C2gzqtauEIn99UEBo=",
        sessionKey: SessionKey(key: "SqODBvrVLQHBdoMY0JGH/wJ/eFLb0XE5KPiRTHLkag8=", algorithm: "aes256")
    ),
    46: HolidayCalendar(
        countryCode: "de",
        language: "de",
        timezones: ["Europe/Berlin"],
        passphrase: "nt5o0idwGDvoLHg/E3UJ+M7gHjt2qzKXLwxVwL1Kj5c=",
        sessionKey: SessionKey(key: "ahVyan2f3/CB7gR5S39eJGCJwYcEunqLLP/qbWaBSws=", algorithm: "aes256")
    ),
    47: HolidayCalendar(
        countryCode: "de",
        language: "en",
        timezones: ["Europe/Berlin"],
        passphrase: "f8G6NXOXhGZkwE2etmEagzyXCZSy60q+Uzil0gCtRvg=",
        sessionKey: SessionKey(key: "VH/9zNXyXSmuwpDPmaIRbZfuaux/kcToI6Wx8xC1I0g=", algorithm: "aes256")
    ),
    48: HolidayCalendar(
        countryCode: "nl",
        language: "nl",
        timezones: ["Europe/Amsterdam"],
        passphrase: "rR++rITb3zQ9u8T3OmOdHT7mtXjSwNBh8r8lxiuJ5SM=",
        sessionKey: SessionKey(key: "HJOWrwzfG+qJbc0nnrbsD798wVZzVzRBOuCpMa4UUvg=", algorithm: "aes256")
    ),
    49: HolidayCalendar(
        countryCode: "nl",
        language: "en",
        timezones: ["Europe/Amsterdam"],
        passphrase: "NTmzky4f3br2KWWf4J1Ezflzss0JzbPDXOzEVL2MaXA=",
        sessionKey: SessionKey(key: "4ddlvQDL3CykW2ttxiFQXwG/FbCzfCBglSLrvGEXTNA=", algorithm: "aes256")
    ),
    50: HolidayCalendar(
        countryCode: "it",
        language: "it",
        timezones: ["Europe/Rome"],
        passphrase: "+7/xxIguVHufce+1BgoTevWLaxMj/WhyIjk5qEP+R8g=",
        sessionKey: SessionKey(key: "09+AaL7GE4ARqF1rV+R0YDn8ak4Jr1X+cibcprLf0Vc=", algorithm: "aes256")
    ),
    51: HolidayCalendar(
        countryCode: "it",
        language: "en",
        timezones: ["Europe/Rome"],
        passphrase: "MKZVWBB6qGAW1lBOVfhcnFWXk3TA0t3aOB1NsnJ5t9s=",
        sessionKey: SessionKey(key: "n5noZkIdbyae9fO8EgCFW6UJcqJpSNyCyiWKHBLaOjk=", algorithm: "aes256")
    ),
    52: HolidayCalendar(
        countryCode: "pl",
        language: "pl",
        timezones: ["Europe/Warsaw"],
        passphrase: "txlFjSBC2fOwIRdamNIlEg5WfbnaEjpk+wJjOVpyjgI=",
        sessionKey: SessionKey(key: "sAey6FcmeVZJyIRaAGFb+xG9i1Zjbt3E/52UNrZxWUY=", algorithm: "aes256")
    ),
    53: HolidayCalendar(
        countryCode: "pl",
        language: "en",
        timezones: ["Europe/Warsaw"],
        passphrase: "27b1sWl6jKxGYzTWPiM2Nlm4u9xwEKdTYTpGCq4pekg=",
        sessionKey: SessionKey(key: "qdMpaFc7nIJ5H53+MF5os5IBIVTLBRtcDG4CvDyCZqA=", algorithm: "aes256")
    ),
    54: HolidayCalendar(
        countryCode: "pt",
        language: "pt",
        timezones: ["Atlantic/Azores", "Atlantic/Madeira", "Europe/Lisbon"],
        passphrase: "vR4NCD7hLk1ZDGmd65qN76NZWH0Ios9DF1DqvB5yYcI=",
        sessionKey: SessionKey(key: "BiUQLi6Cg+R1whWmvhABmVFMmSRAE9FSyW0reTwcJ8o=", algorithm: "aes256")
    ),
    55: HolidayCalendar(
        countryCode: "pt",
        language: "en",
        timezones: ["Atlantic/Azores", "Atlantic/Madeira", "Europe/Lisbon"],
        passphrase: "HFt+cSo6tC4S5trzf1fccsrQPR8GEaMHmp5egwvcFmU=",
        sessionKey: SessionKey(key: "k6MJpYBV1T/4ZlSvNqpUljngXA4YneGRan7QEHIYOOg=", algorithm: "aes256")
    ),
    56: HolidayCalendar(
        countryCode: "ru",
        language: "ru",
        timezones: [
            "Asia/Anadyr", "Asia/Barnaul", "Asia/Chita", "Asia/Irkutsk", "Asia/Kamchatka",
            "Asia/Khandyga", "Asia/Krasnoyarsk", "Asia/Magadan", "Asia/Novokuznetsk",
            "Asia/Novosibirsk", "Asia/Omsk", "Asia/Sakhalin", "Asia/Srednekolymsk",
            "Asia/Tomsk", "Asia/Ust-Nera", "Asia/Vladivostok", "Asia/Yakutsk",
            "Asia/Yekaterinburg", "Europe/Astrakhan", "Europe/Kaliningrad", "Europe/Kirov",
            "Europe/Moscow", "Europe/Samara", "Europe/Saratov", "Europe/Ulyanovsk"
        ],
        passphrase: "HFt+cSo6tC4S5trzf1fccsrQPR8GEaMHmp5egwvcFmU=",
        sessionKey: SessionKey(key: "k6MJpYBV1T/4ZlSvNqpUljngXA4YneGRan7QEHIYOOg=", algorithm: "aes256")
    ),
    57: HolidayCalendar(
        countryCode: "ru",
        language: "en",
        timezones: [
            "Asia/Anadyr", "Asia/Barnaul", "Asia/Chita", "Asia/Irkutsk", "Asia/Kamchatka",
            "Asia/Khandyga", "Asia/Krasnoyarsk", "Asia/Magadan", "Asia/Novokuznetsk",
            "Asia/Novosibirsk", "Asia/Omsk", "Asia/Sakhalin", "Asia/Srednekolymsk",
            "Asia/Tomsk", "Asia/Ust-Nera", "Asia/Vladivostok", "Asia/Yakutsk",
            "Asia/Yekaterinburg", "Europe/Astrakhan", "Europe/Kaliningrad", "Europe/Kirov",
            "Europe/Moscow", "Europe/Samara", "Europe/Saratov", "Europe/Ulyanovsk"
        ],
        passphrase: "vIVQ6+5pElS3xTNwQ81Fbp3B2XmNtjCo5hjt+EiGbh8=",
        sessionKey: SessionKey(key: "4lx5Qz0Z69SfnGn1hNKlLHm0JGDvzIAoMQBcnwtWcX0=", algorithm: "aes256")
    ),
    58: HolidayCalendar(
        countryCode: "es",
        language: "es",
        timezones: ["Africa/Ceuta", "Atlantic/Canary", "Europe/Madrid"],
        passphrase: "iO3CSE0FP49TIPrN3w8pU7Wi0nfGOqzVzhi3m5uGbWQ=",
        sessionKey: SessionKey(key: "u/A5tobxcgCR//alEQUlNIMn61w4Kfl9J+nwzEB8fvo=", algorithm: "aes256")
    ),
    59: HolidayCalendar(
        countryCode: "es",
        language: "en",
        timezones: ["Africa/Ceuta", "Atlantic/Canary", "Europe/Madrid"],
        passphrase: "xk+JzpY255eUAZ9Iti2oneOQ+EmUunBUeTl+p4swr88=",
        sessionKey: SessionKey(key: "fCGj6V80L9w4TDshbDv/sQbylmoJDcic91Y3iHZ7ll0=", algorithm: "aes256")
    ),
    60: HolidayCalendar(
        countryCode: "gb",
        language: "en",
        timezones: ["Europe/London"],
        passphrase: "qNtu61rP6neJt1titZSVcnxLtSkhWTraqbzWSbKfja0=",
        sessionKey: SessionKey(key: "v2700Doy5L7F7As2bl5eXrn1rsWc64gbLQXFXTOk0eE=", algorithm: "aes256")
    ),
    61: HolidayCalendar(
        countryCode: "ca",
        language: "en",
        timezones: [
            "America/Cambridge_Bay", "America/Dawson", "America/Dawson_Creek", "America/Edmonton",
            "America/Fort_Nelson", "America/Glace_Bay", "America/Goose_Bay", "America/Halifax",
            "America/Inuvik", "America/Iqaluit", "America/Moncton", "America/Rankin_Inlet",
            "America/Regina", "America/Resolute", "America/St_Johns", "America/Swift_Current",
            "America/Toronto", "America/Vancouver", "America/Whitehorse", "America/Winnipeg"
        ],
        passphrase: "hiOXcSloK+yddOcylhdCmf8dIB3nfLFc5KWKMeRnUSk=",
        sessionKey: SessionKey(key: "/PA+YOH74hs+mU+EzQKiRXA/p/HteIWcRGHpj0ywll4=", algorithm: "aes256")
    ),
    62: HolidayCalendar(
        countryCode: "ca",
        language: "fr",
        timezones: [
            "America/Cambridge_Bay", "America/Dawson", "America/Dawson_Creek", "America/Edmonton",
            "America/Fort_Nelson", "America/Glace_Bay", "America/Goose_Bay", "America/Halifax",
            "America/Inuvik", "America/Iqaluit", "America/Moncton", "America/Rankin_Inlet",
            "America/Regina", "America/Resolute", "America/St_Johns", "America/Swift_Current",
            "America/Toronto", "America/Vancouver", "America/Whitehorse", "America/Winnipeg"
        ],
        passphrase: "zKsKD1bII33vxcuBPpfgJbEtarhXu6si9IgE99zVN1I=",
        sessionKey: SessionKey(key: "y7yfEAiXqdGwVUtpw3NGCgE847pspaleYiE+LwTivug=", algorithm: "aes256")
    ),
    63: HolidayCalendar(
        countryCode: "ch",
        language: "fr",
        timezones: ["Europe/Zurich"],
        passphrase: "LEojMvnbSDoY7WNCYBUlSQdLIMp1oCzpr3pUgoCPvfg=",
        sessionKey: SessionKey(key: "iowP8Z63E53Pwug157A/6ULvJVdTjvcG0wxhJCdVb80=", algorithm: "aes256")
    ),
    64: HolidayCalendar(
        countryCode: "ch",
        language: "de",
        timezones: ["Europe/Zurich"],
        passphrase: "A5k9A4DlKOdkVK5vwVqa574lOTI4QRWrPfStSqm4BM0=",
        sessionKey: SessionKey(key: "JHZ0aAl7w09LLfxqfj+s9pWoq3b4r+tQvj9lKKdjmTE=", algorithm: "aes256")
    ),
    65: HolidayCalendar(
        countryCode: "ch",
        language: "it",
        timezones: ["Europe/Zurich"],
        passphrase: "tY5vd3ZaPaCU/p145JmCs/gTqdt4UvUujZ96bfqbF/E=",
        sessionKey: SessionKey(key: "tFsl7QC7x9k0fnG+UwwJgxdEnFjWLz3SY4k56+FPo/Q=", algorithm: "aes256")
    ),
    66: HolidayCalendar(
        countryCode: "ch",
        language: "en",
        timezones: ["Europe/Zurich"],
        passphrase: "sw7PNl4YmHCkepibEyfTGU4YtrJ0lLL4r61sAQCH/jQ=",
        sessionKey: SessionKey(key: "fjX4bVMITVKYoPT4Fe9WcfPzy8nF69q3pdhKQkmHsOE=", algorithm: "aes256")
    ),
    67: HolidayCalendar(
        countryCode: "au",
        language: "en",
        timezones: [
            "Antarctica/Macquarie", "Australia/Adelaide", "Australia/Brisbane",
            "Australia/Broken_Hill", "Australia/Darwin", "Australia/Eucla",
            "Australia/Hobart", "Australia/Lindeman", "Australia/Lord_Howe",
            "Australia/Melbourne", "Australia/Perth", "Australia/Sydney"
        ],
        passphrase: "1UAeHCiNCHSKcDEN1JF6vZRFt1HWnu1XBkkS+6rIAdY=",
        sessionKey: SessionKey(key: "soFJGzm9j2vLEFuMRTbOnNcNV1yrXyqyz0yfxH5cXEk=", algorithm: "aes256")
    ),
    68: HolidayCalendar(
        countryCode: "ua",
        language: "uk",
        timezones: ["Europe/Kiev", "Europe/Kyiv", "Europe/Simferopol"],
        passphrase: "qHZ6l8pW8h8dAE5wgSIRsAyZdkEIvAazlUJGf8IdfG8=",
        sessionKey: SessionKey(key: "ttz0+6QlZ1/k0ugcreSUkc9d0SYGt3rgYW9EnggGT4E=", algorithm: "aes256")
    ),
    69: HolidayCalendar(
        countryCode: "ua",
        language: "en",
        timezones: ["Europe/Kiev", "Europe/Kyiv", "Europe/Simferopol"],
        passphrase: "aluQO9SXjDP85z/jRoUF2rEe+2Mrt5CZbzWDlVwf++Y=",
        sessionKey: SessionKey(key: "FRBjf4HgS8OJE4FyPSkhASWUDR8kA1PwiHyno1Z8A6g=", algorithm: "aes256")
    ),
    70: HolidayCalendar(
        countryCode: "ro",
        language: "ro",
        timezones: ["Europe/Bucharest"],
        passphrase: "Jv7S2qdV+8f2QdOCX8OJg0z+Xs5+mlE1AVNHxmsyFQ8=",
        sessionKey: SessionKey(key: "eDL3TFs2hBXkmEUkqjkhrAtelbPWeIAAsVENIeGFsAo=", algorithm: "aes256")
    ),
    71: HolidayCalendar(
        countryCode: "ro",
        language: "en",
        timezones: ["Europe/Bucharest"],
        passphrase: "1Sqo0rUVYoV9PjPEHJRSZoNHoekYcp9tRFL4usY2sew=",
        sessionKey: SessionKey(key: "F6141M5IAQukNkCoPyKZwSkF1GKGZpjNTJmhSer4INs=", algorithm: "aes256")
    ),
    72: HolidayCalendar(
        countryCode: "be",
        language: "nl",
        timezones: ["Europe/Brussels"],
        passphrase: "OZVLzqbGNTaQmVghuC9cyv7FSAHQIJFmDsRF0TZGNEw=",
        sessionKey: SessionKey(key: "yazfpvodkarAlSoETp+4nrD+Cbbq+8YQIVepZkVdM2k=", algorithm: "aes256")
    ),
    73: HolidayCalendar(
        countryCode: "be",
        language: "fr",
        timezones: ["Europe/Brussels"],
        passphrase: "07lJslc5bJN7BPQLPvLH6BlOJpfJ/qZfn9s/n2n/dgE=",
        sessionKey: SessionKey(key: "+gMjew71H2S7201ymFSkKnSEayp/44ZVLYpQBhqkfHI=", algorithm: "aes256")
    ),
    74: HolidayCalendar(
        countryCode: "be",
        language: "en",
        timezones: ["Europe/Brussels"],
        passphrase: "FiG/FFCYXpgXVk45aXqb+XI/k+BlibCYCCl+v2DJrI8=",
        sessionKey: SessionKey(key: "zzpGlHs7w69LjloPNMVTvy/NmeFMMwXStw7tFYybOH8=", algorithm: "aes256")
    ),
    75: HolidayCalendar(
        countryCode: "cz",
        language: "cs",
        timezones: ["Europe/Prague"],
        passphrase: "SpoOmMM16i//6cwkYrbX4KyfE48uyiFGcI1g8xuercE=",
        sessionKey: SessionKey(key: "WVzl4sriZFPcSI7dPh+BQ2w2Sfd2CieZxolrHtLsC+A=", algorithm: "aes256")
    ),
    76: HolidayCalendar(
        countryCode: "cz",
        language: "en",
        timezones: ["Europe/Prague"],
        passphrase: "vr4nWXk830rrZYi1XzJnziJL8RA81kQ+Zp8OrN5jV+g=",
        sessionKey: SessionKey(key: "TfQ0qjVHE0Fw+wNGtaKMKaIyGKNtVvYeYzCUTKJnHbg=", algorithm: "aes256")
    ),

    77: HolidayCalendar(
        countryCode: "gr",
        language: "el",
        timezones: ["Europe/Athens"],
        passphrase: "w2d6c+7lO1L0wSdG5qluVL1OtN+011xdUm/vbDF6iOw=",
        sessionKey: SessionKey(key: "hc7SLYRA72TjuMWwA5WD+0BhgOdHska26R++TdH8C98=", algorithm: "aes256")
    ),
    78: HolidayCalendar(
        countryCode: "gr",
        language: "en",
        timezones: ["Europe/Athens"],
        passphrase: "GUZ92m9/BxTOduKAP2JKCRq6/trZRCxDmagRfZSwz1M=",
        sessionKey: SessionKey(key: "azi4MBJnMDOGS4xsWss8ScCOktz91N0nRRm7RisX8Uo=", algorithm: "aes256")
    ),
    79: HolidayCalendar(
        countryCode: "se",
        language: "sv",
        timezones: ["Europe/Stockholm"],
        passphrase: "AUMWYdYdvdl2fYHs1yAL9phOMg+HP/ocxipR4Z+ygpc=",
        sessionKey: SessionKey(key: "ZEhidm/aOnFrYcZJU+Sh6U1Ry7Z38Y3vKzmMgsBTKNE=", algorithm: "aes256")
    ),
    80: HolidayCalendar(
        countryCode: "se",
        language: "en",
        timezones: ["Europe/Stockholm"],
        passphrase: "ITfs+0R3D1QXB14r86tLxnELmgzwDkkNzeI4hzgIGJ4=",
        sessionKey: SessionKey(key: "JdfdlyYLxikHytJwWBlmGmbOVMbBXVpzkLh8jn/Rgb0=", algorithm: "aes256")
    ),
    81: HolidayCalendar(
        countryCode: "hu",
        language: "hu",
        timezones: ["Europe/Budapest"],
        passphrase: "MGj/ZGLBbzRailN/2nF4mUQy1wTWZwv7zSaUkLYb5Hc=",
        sessionKey: SessionKey(key: "2kND4uTsI5xJkZarHVx9JdXaUwe4p/FJDXV2eMQRZ/s=", algorithm: "aes256")
    ),
    82: HolidayCalendar(
        countryCode: "hu",
        language: "en",
        timezones: ["Europe/Budapest"],
        passphrase: "VOI2EXxTV7jPUw4ax0qUPtjKKMsFtG5P6UL5ph3zMjY=",
        sessionKey: SessionKey(key: "FMdgaStGC1FOhLGqV/VDfj/pIdz0e4jkYBwhGkRe61c=", algorithm: "aes256")
    ),
    83: HolidayCalendar(
        countryCode: "at",
        language: "de",
        timezones: ["Europe/Vienna"],
        passphrase: "4/SCf89Y/bBMe41Z7NHzqzwbouBxebAyUkUcpXY/Mwk=",
        sessionKey: SessionKey(key: "SEsdMMnNM1+lL03pxFp38nwXa1aoA693MpOrlIQ7Trk=", algorithm: "aes256")
    ),
    84: HolidayCalendar(
        countryCode: "at",
        language: "en",
        timezones: ["Europe/Vienna"],
        passphrase: "U5gz6FHbWyfQwHUGw5EdXedl1icz1uutAIaf4dCLnGc=",
        sessionKey: SessionKey(key: "aaPjftcBBBZfvZPM3kQT2e/LEvLS34bsqmpq4TKE+YM=", algorithm: "aes256")
    ),
    85: HolidayCalendar(
        countryCode: "dk",
        language: "da",
        timezones: ["Europe/Copenhagen"],
        passphrase: "GvgJ+OP3slkNLSddeckzBO3wy4pl3eNLEzBv84gqk4E=",
        sessionKey: SessionKey(key: "ZEkti6hO9qBTvjP+Ip1vPFFJ/gbheBlnqJ56v9pLQT4=", algorithm: "aes256")
    ),
    86: HolidayCalendar(
        countryCode: "dk",
        language: "en",
        timezones: ["Europe/Copenhagen"],
        passphrase: "pqAcoaIwra0J6R7oLLZUFiaxLsEYIMNKzsFR3vkyxls=",
        sessionKey: SessionKey(key: "9IRrYCTj8m3dwK61QeXDT6/Eyiim+wbMko7rqYvIHY8=", algorithm: "aes256")
    ),
    87: HolidayCalendar(
        countryCode: "fi",
        language: "fi",
        timezones: ["Europe/Helsinki"],
        passphrase: "yKRcep1PQECWghChNKWVio/3X9MqnZmaJ8a6pP4ndv0=",
        sessionKey: SessionKey(key: "o60W3b8tYiBXXSdKaG26aixttb340kPT0Lil7GoPzbc=", algorithm: "aes256")
    ),
    88: HolidayCalendar(
        countryCode: "fi",
        language: "en",
        timezones: ["Europe/Helsinki"],
        passphrase: "0GZ9fUMQmO5azqmTO3qFXaBr6klqH/g7zwSxtd4+ps8=",
        sessionKey: SessionKey(key: "dQFzHbvYP7oo3sLHkTW6FgI6Z/Qk/QIDpBSGigmeYL4=", algorithm: "aes256")
    ),
    89: HolidayCalendar(
        countryCode: "sk",
        language: "sk",
        timezones: ["Europe/Prague"],
        passphrase: "sFsKSBbf9fshvDTETNGNGdRCU6Pir7cR2CNr/J/WdCw=",
        sessionKey: SessionKey(key: "/NUzc2jTspXAYZD1FQQwRiHP+dOlkc6OPVWXkNsR/9Y=", algorithm: "aes256")
    ),
    90: HolidayCalendar(
        countryCode: "sk",
        language: "en",
        timezones: ["Europe/Prague"],
        passphrase: "Nn8mgl5jz8+KMWWrd+lBsAf+jgYHDevYuKl6lB4XZq0=",
        sessionKey: SessionKey(key: "IlzPrGp6N9GciQ5OyQ2wkWjJyEd6CY/HRpT8vsN0GUI=", algorithm: "aes256")
    ),
    91: HolidayCalendar(
        countryCode: "no",
        language: "no",
        timezones: ["Europe/Oslo"],
        passphrase: "hc2yek1eB32qkpUkwsw8L7WSVCBAn7qVkco9kPMvbkk=",
        sessionKey: SessionKey(key: "7R1JdvDUflAw5d5aPiUxK9X4Kcq3hz923fpoyZbMYag=", algorithm: "aes256")
    ),
    92: HolidayCalendar(
        countryCode: "no",
        language: "en",
        timezones: ["Europe/Oslo"],
        passphrase: "KYhIU5cuc+6oKC6HTQP9wBBinQElHSiY0ZFG8SGzLnw=",
        sessionKey: SessionKey(key: "sGyHSfsWbHPsD3LvlPEuXyQx3fTpO1B35L0Pa/k1whI=", algorithm: "aes256")
    ),
    93: HolidayCalendar(
        countryCode: "ie",
        language: "ga",
        timezones: ["Europe/Dublin"],
        passphrase: "sT9bNV/F5GPw+VhEFmrXrj6RQuCFrA0dYW0U8W/yUng=",
        sessionKey: SessionKey(key: "rznzGUQWlQux+wTgHytELrt3+HigrUnGiEfiGNEdAs8=", algorithm: "aes256")
    ),
    94: HolidayCalendar(
        countryCode: "ie",
        language: "en",
        timezones: ["Europe/Dublin"],
        passphrase: "r+57YJJ0EwRYz5Ad1QmiotSxSigTTn/UuxozQ7ViRwY=",
        sessionKey: SessionKey(key: "QjfL4dHRVBam6bGr+2E/r6gFr9KlSsFjRtMMsBdC2M4=", algorithm: "aes256")
    ),
    95: HolidayCalendar(
        countryCode: "hr",
        language: "hr",
        timezones: ["Europe/Belgrade"],
        passphrase: "KcqSRBUDsIH4PtweV3v31FomMR6w2Q0J1eVKf36LE4s=",
        sessionKey: SessionKey(key: "ASDMVpLh2qCsEjBtefrXXnDN7QW+3aCeTjlWBbSIHOw=", algorithm: "aes256")
    ),
    96: HolidayCalendar(
        countryCode: "hr",
        language: "en",
        timezones: ["Europe/Belgrade"],
        passphrase: "kaNXAy8lch/PCJSIChYZGodon4glxzU9b58vQGdWpPc=",
        sessionKey: SessionKey(key: "Ka2WfXAiRaRnWhtZNepdo1aP/uots7hvNlY6N+Ui5V4=", algorithm: "aes256")
    ),
    97: HolidayCalendar(
        countryCode: "al",
        language: "sq",
        timezones: ["Europe/Tirane"],
        passphrase: "4JVsOxzkSd7j7Vc9nqYGlgl8qV5FLXFxJcp/Nn5fRbE=",
        sessionKey: SessionKey(key: "1uxNlOkPgbcjJXcmY13aH/C8B5LegbS/RxijY11+Msw=", algorithm: "aes256")
    ),
    98: HolidayCalendar(
        countryCode: "al",
        language: "en",
        timezones: ["Europe/Tirane"],
        passphrase: "sdBwbMs53e0twNWP58yWGVto89XHb+7OE3bNP8me9uk=",
        sessionKey: SessionKey(key: "F9qh3Xixv7cfpOEZrFJFNYYAy8N3kx9xt8VTT4v/C1k=", algorithm: "aes256")
    ),
    99: HolidayCalendar(
        countryCode: "lt",
        language: "lt",
        timezones: ["Europe/Vilnius"],
        passphrase: "ose7ywPX1fsxN64+5Cj+1hbZoPcTyaTx5O6PxPCnUaI=",
        sessionKey: SessionKey(key: "QSdOBnWRBiVWNnPmn7rVerqjl0FvB8HZ+YVsN7zcr88=", algorithm: "aes256")
    ),
    100: HolidayCalendar(
        countryCode: "lt",
        language: "en",
        timezones: ["Europe/Vilnius"],
        passphrase: "za9sOfQVXTUU6CPEcW+IC7ZWc/qbt5bZekV0dWNer04=",
        sessionKey: SessionKey(key: "wtAS69KdxBsng7AwrLgoh/e0soIbPzmIiKCy30wKGtU=", algorithm: "aes256")
    ),
    101: HolidayCalendar(
        countryCode: "mk",
        language: "mk",
        timezones: ["Europe/Belgrade"],
        passphrase: "32d8O1HRf8BhUqY8UBawzlXiZBbxgfxKoRTFoZ2o1jY=",
        sessionKey: SessionKey(key: "DW8oXvp7fXfQsKiQelDvJ2wJrBNvYCWnERsdG1fpNNQ=", algorithm: "aes256")
    ),
    102: HolidayCalendar(
        countryCode: "mk",
        language: "en",
        timezones: ["Europe/Belgrade"],
        passphrase: "HF5KZleF4jZFb4KavhUERResGmn0mAgSFIeRhESfp0U=",
        sessionKey: SessionKey(key: "M/OsnjZIQp9/Mo8yq1dA6LcbbFPfgSVugHOhC3wev+8=", algorithm: "aes256")
    ),
    103: HolidayCalendar(
        countryCode: "si",
        language: "sl",
        timezones: ["Europe/Belgrade"],
        passphrase: "Bz8CWbkKx4+NI5SQVEfGIz72EEhQhWPNLc2qN8TU/NU=",
        sessionKey: SessionKey(key: "EKw2w7W9KfM1U+w+d5IZBmKuvCPMGKsi4IXyyIZQhXs=", algorithm: "aes256")
    ),
    104: HolidayCalendar(
        countryCode: "si",
        language: "en",
        timezones: ["Europe/Belgrade"],
        passphrase: "DLOWWLJCAu20UsQh6uCQu5+Ji7mG8qdwoosfyyp6ngc=",
        sessionKey: SessionKey(key: "FC4U2j1HoCuKasJm4ba25MyNo4ugVqnVjpwvxWuEpKA=", algorithm: "aes256")
    ),
    105: HolidayCalendar(
        countryCode: "lv",
        language: "lv",
        timezones: ["Europe/Riga"],
        passphrase: "ep0cEQ/OqRXubPrOQb6NzGFFLzwjFOFvH/pXqEp2Cnc=",
        sessionKey: SessionKey(key: "Jde7j+2Mas4p3IiBx3ska/+63RFhjpZRlOdNqnWKkjU=", algorithm: "aes256")
    ),
    106: HolidayCalendar(
        countryCode: "lv",
        language: "en",
        timezones: ["Europe/Riga"],
        passphrase: "/qn5E4RXJOz80pXPjqmJAYAFnFz1q0PlMglw/0qFPx0=",
        sessionKey: SessionKey(key: "ksq1vB7hsbaMWLg/Fyg4JNm2kF5q658NySGIYVXotfQ=", algorithm: "aes256")
    ),
    107: HolidayCalendar(
        countryCode: "ee",
        language: "et",
        timezones: ["Europe/Tallinn"],
        passphrase: "BOstxzXH5RTb39S4InN3HXD6ZdW2l4LPhuCT4eCMRS8=",
        sessionKey: SessionKey(key: "hSxQ8gqrhPXsnayjNBUBT8aGzMb+15VQ8xeJ8X/EWfg=", algorithm: "aes256")
    ),
    108: HolidayCalendar(
        countryCode: "ee",
        language: "en",
        timezones: ["Europe/Tallinn"],
        passphrase: "GKIhLli8MJFvV4l7qRfAaxH+m6mSzBlHruquEr+YYdQ=",
        sessionKey: SessionKey(key: "c4Yb47yCCPx0Ils1oioufvRo4QGOl6AHOQAl1C9fJSY=", algorithm: "aes256")
    ),
    109: HolidayCalendar(
        countryCode: "me",
        language: "cnr",
        timezones: ["Europe/Belgrade"],
        passphrase: "9lgvu8okAl58vhfIDjAGuzUbe+22pJlVTk9cskPdewI=",
        sessionKey: SessionKey(key: "kD1niWskS2Xl9mtXsJkl0kawWiyLAFH7B50myTUAB1M=", algorithm: "aes256")
    ),
    110: HolidayCalendar(
        countryCode: "me",
        language: "sr",
        timezones: ["Europe/Belgrade"],
        passphrase: "ccOgXlqAA7V2zhD56Zf6JxlFIMbo0/TcfBHx7K0MRn0=",
        sessionKey: SessionKey(key: "cBInRh+hC7ZD+nE6WqYL01N/oiP6t9w1YNxJctq69jE=", algorithm: "aes256")
    ),
    111: HolidayCalendar(
        countryCode: "me",
        language: "en",
        timezones: ["Europe/Belgrade"],
        passphrase: "SZeaIlw3C0gWhhsTjHuF1EvNRv+0qzjBcK2hRM136vo=",
        sessionKey: SessionKey(key: "qn9IsYmg/vJOwDODKexgkJatilyeRzi0JZBfaJyuzsI=", algorithm: "aes256")
    ),
    112: HolidayCalendar(
        countryCode: "lu",
        language: "lb",
        timezones: ["Europe/Luxembourg"],
        passphrase: "nP/WQMruCSUm03PD/5V11sG1iRG1iheMttEsEnJAPG0=",
        sessionKey: SessionKey(key: "cDzqpGsF0SP7OmUE+PM7ep1r2tU0KVfoJ/dW/B4GawI=", algorithm: "aes256")
    ),
    113: HolidayCalendar(
        countryCode: "lu",
        language: "en",
        timezones: ["Europe/Luxembourg"],
        passphrase: "qL6Jp0G4Pa71sosEG1A/ghJtFoBBtKebwWCFvnyISQU=",
        sessionKey: SessionKey(key: "7AeiOtF38kHphT49BolO7fdZnMKhhHgD19ALeLiwNcc=", algorithm: "aes256")
    ),
    114: HolidayCalendar(
        countryCode: "mt",
        language: "mt",
        timezones: ["Europe/Malta"],
        passphrase: "ByDBOyoCoExLfSEGq47wvgYza4y9S68o0eb916nBJ+Y=",
        sessionKey: SessionKey(key: "+UzX2kI1IZwNLh34wXYunyKkXcRrbL2cenMzEv3n3JE=", algorithm: "aes256")
    ),
    115: HolidayCalendar(
        countryCode: "mt",
        language: "en",
        timezones: ["Europe/Malta"],
        passphrase: "Kz8+GARv6d24s5aZBUDKNKm34HuNS1nTA3XEAzYqjXE=",
        sessionKey: SessionKey(key: "eTJSHsLJOfMOuQtnM0ezaHGN4zulJSOM/7LX+wnwgdI=", algorithm: "aes256")
    ),
    116: HolidayCalendar(
        countryCode: "is",
        language: "is",
        timezones: ["Atlantic/Reykjavik"],
        passphrase: "KHuzaQpRvNlYts5zNxYhAw0dvusOTv7tkL6DTkF1DOc=",
        sessionKey: SessionKey(key: "bs8G6pHaKJ/PIFmLBHKMsZd2K1AYJx8MO94i9e/oQSo=", algorithm: "aes256")
    ),
    117: HolidayCalendar(
        countryCode: "is",
        language: "en",
        timezones: ["Atlantic/Reykjavik"],
        passphrase: "VEGInZ3MySmmal9nlCA+x3ifrH3MNxtqhULaFRR9t+g=",
        sessionKey: SessionKey(key: "N+33OA5KZc1KDupEFWsam6eJDgHisrp/L1gLAFQv2uE=", algorithm: "aes256")
    ),
    118: HolidayCalendar(
        countryCode: "ad",
        language: "ca",
        timezones: ["Europe/Andorra"],
        passphrase: "Bc+Nz/b7+Kmu9JRH+KWGRw5uxrFzLwkD9eD9ELNGTlI=",
        sessionKey: SessionKey(key: "bdG+QdpwMFPqYgNlb7xsJNZT4QHAOApD/SulQRo/Km0=", algorithm: "aes256")
    ),
    119: HolidayCalendar(
        countryCode: "ad",
        language: "es",
        timezones: ["Europe/Andorra"],
        passphrase: "o2nHiJQunDG3vspIwMnm6aW1Uw5QSYYgF8vpup2/VWE=",
        sessionKey: SessionKey(key: "NezsETebG+GWc05fm5L5qejidh/d8gqa4x/JM3uiI+k=", algorithm: "aes256")
    ),
    120: HolidayCalendar(
        countryCode: "ad",
        language: "en",
        timezones: ["Europe/Andorra"],
        passphrase: "cV8RmBYVXSkUAdl3pTzb89H2gd1rxeY7p6uudQJ7RJo=",
        sessionKey: SessionKey(key: "vqf8K3AyLNhquYgBYnklwYuyHkPmDEFPjZVgH926+oA=", algorithm: "aes256")
    ),
    121: HolidayCalendar(
        countryCode: "mc",
        language: "fr",
        timezones: ["Europe/Monaco"],
        passphrase: "92piMEuKWsG2HVMuT7VJ54vF3APmQRO14GIe3k7eYOU=",
        sessionKey: SessionKey(key: "cDi2Yt1LzB1LO249rnfGemEZtPXDR+kHeZaXSwMCq0s=", algorithm: "aes256")
    ),
    122: HolidayCalendar(
        countryCode: "mc",
        language: "en",
        timezones: ["Europe/Monaco"],
        passphrase: "kIj+8frRcdUzZQCXK2uQrxcxyW8a+0VfqSHbbdSlh84=",
        sessionKey: SessionKey(key: "KM/AmoEOOa5+xx8SVyovYfgw4YWXu1WeNTqp4jQCw8k=", algorithm: "aes256")
    ),
    123: HolidayCalendar(
        countryCode: "sm",
        language: "it",
        timezones: ["Europe/Rome"],
        passphrase: "SSRZlYn9rPvAX7b52eA0r5fz13Ip3xoxzEmDRdDSKuA=",
        sessionKey: SessionKey(key: "iXbTxyYVahv650dOOPtbwGrBJpqaK577QjMob9JxXKA=", algorithm: "aes256")
    ),
    124: HolidayCalendar(
        countryCode: "sm",
        language: "en",
        timezones: ["Europe/Rome"],
        passphrase: "S2QiNwPMYd9h0z7FWo1lFC0M7MAxSFi9WQ0uPgxPpnA=",
        sessionKey: SessionKey(key: "qFbRyffg29xDIgfikcsdzpGFRCg8uhYkekk+YHOk6v4=", algorithm: "aes256")
    ),
    125: HolidayCalendar(
        countryCode: "br",
        language: "pt",
        timezones: [
            "America/Araguaina",
            "America/Bahia",
            "America/Belem",
            "America/Boa_Vista",
            "America/Campo_Grande",
            "America/Cuiaba",
            "America/Eirunepe",
            "America/Fortaleza",
            "America/Manaus",
            "America/Noronha",
            "America/Porto_Velho",
            "America/Recife",
            "America/Rio_Branco",
            "America/Santarem",
            "America/Sao_Paulo"
        ],
        passphrase: "7E9H4UvGuhq9ix97t4gVBnw2X+CV9EzrM6HSNTlogYg=",
        sessionKey: SessionKey(key: "S02hSMrSNi9BPCk+mI/y5TeWgPhmtBrb+m4nKV1l26Y=", algorithm: "aes256")
    ),
    126: HolidayCalendar(
        countryCode: "br",
        language: "en",
        timezones: [
            "America/Araguaina",
            "America/Bahia",
            "America/Belem",
            "America/Boa_Vista",
            "America/Campo_Grande",
            "America/Cuiaba",
            "America/Eirunepe",
            "America/Fortaleza",
            "America/Manaus",
            "America/Noronha",
            "America/Porto_Velho",
            "America/Recife",
            "America/Rio_Branco",
            "America/Santarem",
            "America/Sao_Paulo"
        ],
        passphrase: "A/FaZMMQ/drBCfJHzMvwQUibuCTgKaEE7GImaxTWWpU=",
        sessionKey: SessionKey(key: "0LhPMaViTB7IfHUqSZ8O0IF0UQi124UB/joUXJjWFj0=", algorithm: "aes256")
    ),
    127: HolidayCalendar(
        countryCode: "co",
        language: "es",
        timezones: ["America/Bogota"],
        passphrase: "hBXen+p66p7dKZXsHKfDJykIDCxzY3qGutsVCqTSYe8=",
        sessionKey: SessionKey(key: "Cq0gg36mDE2sYqNzTk4Eru4yjPanQzJ3Trqypr1Ir90=", algorithm: "aes256")
    ),
    128: HolidayCalendar(
        countryCode: "co",
        language: "en",
        timezones: ["America/Bogota"],
        passphrase: "D4VyGWXnzooV71UhCofk08VBFjuo+OWaRaYPZW7Dg2Q=",
        sessionKey: SessionKey(key: "sKCnTfq64YtnN1pMKkaGQ9cf8MLZQy6bwxYQ04q7E7Y=", algorithm: "aes256")
    ),
    129: HolidayCalendar(
        countryCode: "ar",
        language: "es",
        timezones: [
            "America/Argentina/Buenos_Aires",
            "America/Argentina/Catamarca",
            "America/Argentina/Cordoba",
            "America/Argentina/Jujuy",
            "America/Argentina/La_Rioja",
            "America/Argentina/Mendoza",
            "America/Argentina/Rio_Gallegos",
            "America/Argentina/Salta",
            "America/Argentina/San_Juan",
            "America/Argentina/San_Luis",
            "America/Argentina/Tucuman",
            "America/Argentina/Ushuaia"
        ],
        passphrase: "d407UE2xz4uW5U33keRtJvJcdDG3EUXKV6jCcE+1XlQ=",
        sessionKey: SessionKey(key: "YwjVKUAf/vtHxA8r7f5sEqiGpUTFQfitkIUiGHQk2uI=", algorithm: "aes256")
    ),
    130: HolidayCalendar(
        countryCode: "ar",
        language: "en",
        timezones: [
            "America/Argentina/Buenos_Aires",
            "America/Argentina/Catamarca",
            "America/Argentina/Cordoba",
            "America/Argentina/Jujuy",
            "America/Argentina/La_Rioja",
            "America/Argentina/Mendoza",
            "America/Argentina/Rio_Gallegos",
            "America/Argentina/Salta",
            "America/Argentina/San_Juan",
            "America/Argentina/San_Luis",
            "America/Argentina/Tucuman",
            "America/Argentina/Ushuaia"
        ],
        passphrase: "AhzFZ/1vGhwpk1sy19V2rjeeiAqUsdllRYRCdiVS3ZY=",
        sessionKey: SessionKey(key: "324EeTwMu1DIlqYMKUvAb0Iun1QhS55h/qdcTVrOZF8=", algorithm: "aes256")
    ),
    131: HolidayCalendar(
        countryCode: "pe",
        language: "es",
        timezones: ["America/Lima"],
        passphrase: "O5icsQQHyZGPSLzHI8NhDl4DAzdc80elGalq9OD5Mxg=",
        sessionKey: SessionKey(key: "EYmKNyMzt6iCXZoluh6gAMOy73gXM1WORy2Wx2z1NzQ=", algorithm: "aes256")
    ),
    132: HolidayCalendar(
        countryCode: "pe",
        language: "en",
        timezones: ["America/Lima"],
        passphrase: "ab6p1uun7AxyYe7Di7BO3iQI9NGwhOPJ9ZxpSVMBYF4=",
        sessionKey: SessionKey(key: "fvwNU3eRTvmmhO3vKY/lPaltOTr9xlGkqdbWRVGQlRc=", algorithm: "aes256")
    ),
    133: HolidayCalendar(
        countryCode: "in",
        language: "hi",
        timezones: ["Asia/Kolkata"],
        passphrase: "m4r9T74sW8kPscZ3tgZymoRZs+iN07Wj+yra+ArDzOw=",
        sessionKey: SessionKey(key: "t6bMahOy9l18FrCtsEBechc7QGSGM0Ge2mEH1YKafzI=", algorithm: "aes256")
    ),
    134: HolidayCalendar(
        countryCode: "in",
        language: "en",
        timezones: ["Asia/Kolkata"],
        passphrase: "Iblmk/D2q3Hc8ckHbVZCZ6e+cocqOyQSOJ6Kh2Btd9s=",
        sessionKey: SessionKey(key: "iLxObS+dSbTyXOEUp1PUkWojkVjwAp5v5kKwc2DgAEM=", algorithm: "aes256")
    ),
    135: HolidayCalendar(
        countryCode: "id",
        language: "id",
        timezones: ["Asia/Jakarta", "Asia/Jayapura", "Asia/Makassar", "Asia/Pontianak"],
        passphrase: "Kkk98D9SaanZnFdNVFpuXG8eQU5OMIqrnUmhI3UjBEg=",
        sessionKey: SessionKey(key: "ilhqfdzXwMR4cjviGTMWwZImjuorI+5DFe+QSe6Ojcs=", algorithm: "aes256")
    ),
    136: HolidayCalendar(
        countryCode: "id",
        language: "en",
        timezones: ["Asia/Jakarta", "Asia/Jayapura", "Asia/Makassar", "Asia/Pontianak"],
        passphrase: "aUCtA/PQTrJQQ3DI5EZ9Nm4MdhByx7HKjCGtWW140Lc=",
        sessionKey: SessionKey(key: "YZb0RX6h6NfvwX08ESgceX2ofvSE928pwdaFmi8Fe48=", algorithm: "aes256")
    ),
    137: HolidayCalendar(
        countryCode: "eg",
        language: "ar",
        timezones: ["Africa/Cairo"],
        passphrase: "rfiqFzzKb03/Ab5V32vX2ty/T+1cZKtmvzY5OLJQ+Pk=",
        sessionKey: SessionKey(key: "B3LMk/g7hBVI9UsQ61OL5u+gMrb+mTNMJLBP3wEM1yg=", algorithm: "aes256")
    ),
    138: HolidayCalendar(
        countryCode: "eg",
        language: "en",
        timezones: ["Africa/Cairo"],
        passphrase: "GPwvPJjh1n+thaPVHWZTkRg+3SWuSz6IcYQ0reXFhyI=",
        sessionKey: SessionKey(key: "nvI6pOSZngJpa+gzunxLJameyLQK2PleOHbFlE5XruI=", algorithm: "aes256")
    ),
    139: HolidayCalendar(
        countryCode: "za",
        language: "af",
        timezones: ["Africa/Johannesburg"],
        passphrase: "N3C5l9dWG5EufDZ9tRuXvFilWT/X9A21s0z8/drwcis=",
        sessionKey: SessionKey(key: "ndmDyH3W7MtD+RZOQW0i2YPicbVR7C9i7soNAbKejIo=", algorithm: "aes256")
    ),
    140: HolidayCalendar(
        countryCode: "za",
        language: "en",
        timezones: ["Africa/Johannesburg"],
        passphrase: "jVSYeUhhDamTPd8wI9O/98VBs4Mbl+lQI+PuCwXEDDc=",
        sessionKey: SessionKey(key: "6q4Pa/9oPHGW3w9g91+F0z7rGCUUFCTmHHBpD09ZvxA=", algorithm: "aes256")
    ),
    141: HolidayCalendar(
        countryCode: "ma",
        language: "ar",
        timezones: ["Africa/Casablanca"],
        passphrase: "u5h1+O20U/Mh7O2lf+8xvKacPXpWr2dZkDiFlD4FmJY=",
        sessionKey: SessionKey(key: "JJ//jW5XxMyf/qq17RMrqsrT0KTJfvAlqbFxtZw7Wdw=", algorithm: "aes256")
    ),
    142: HolidayCalendar(
        countryCode: "ma",
        language: "en",
        timezones: ["Africa/Casablanca"],
        passphrase: "Dkr4BJnxFax1WADTmdA3P1SZzafXVy9VwXckMoVHSLY=",
        sessionKey: SessionKey(key: "JMflWYU59cPbNYcy0H0vQDjM3rvZaiCGON2n6YNugmE=", algorithm: "aes256")
    )
]
