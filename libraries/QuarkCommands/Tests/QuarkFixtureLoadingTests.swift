//
//  QuarkFixtureLoadingTests.swift
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

import XCTest

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
#if canImport(ProtonCoreTestingToolkitUnitTestsDoh)
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreQuarkCommands

final class QuarkFixtureLoadingTests: XCTestCase {

    var dohMock: DohMock!

    override func setUp() {
        super.setUp()
        dohMock = DohMock()

        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
            // You can add logging here if needed
        }

        stub(condition: isHost("test.quark.commands.url")) { request in
            let bundle = Bundle.module
            guard let url = bundle.url(forResource: "FixtureSuccess", withExtension: "json") else {
                return HTTPStubsResponse(error: NSError(domain: "FixtureLoadingTests", code: 404, userInfo: [NSLocalizedDescriptionKey: "FixtureSuccess.json not found in bundle"]))
            }
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
        }
        // Mock URL
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }
    }

    func testFixtureLoading() throws {
        // Mock response
        let quarkCommand = Quark().baseUrl(dohMock)
        let username = "rXl98Als0UALNZdN"
        let password = "Test2134"

        let userBuilder = UserBuilder(userName: username, password: password)

        // Create an instance of EmailOptions
        let emailOptions = EmailOptions(
            from: "sender@example.com",
            to: "recipient@example.com",
            subject: "Draft Email Subject",
            html: "<p>This is the draft email body in HTML format</p>",
            date: "Mon, 26 Sep 2024 15:30:00 +0000",
            mimeType: .html
        )

        // Create VCardData with sample details
        let vCardData = VCardData(
            email: "johndoe@example.com",
            firstName: "John",
            lastName: "Doe",
            organization: "Example Org",
            homePhone: "123-456-7890",
            cellPhone: "987-654-3210",
            title: "Software Engineer",
            workPhone: "111-222-3333",
            workEmail: "john.doe@work.com",
            photo: IPhoto(url: "https://example.com/photo.jpg", mediaType: "image/jpeg"),
            homeAddress: IAddress(street: "123 Main St", city: "Hometown", stateProvince: "HT", postalCode: "12345", countryRegion: "CountryX"),
            workAddress: IAddress(street: "456 Work Ave", city: "Worktown", stateProvince: "WT", postalCode: "67890", countryRegion: "CountryY")
        )

        let vCardBuilder = VCardBuilder(data: vCardData)

        userBuilder.mailbox.addEml(eml: EmailBuilder(options: emailOptions), messageState: .draft)
        userBuilder.calbox.addHolidaysCalendars(count: 2)
        userBuilder.calbox.addSubscribedCalendars(name: "testcalendar", url: SubscribedCalendarURL.validURL.rawValue)
        userBuilder.calbox.addPersonalCalendars()
        userBuilder.contacts.addContact(vcard: vCardBuilder)

        let fixtures = try userBuilder.generateUserFixture()

        // Validation for Fixtures
        XCTAssertEqual(fixtures.files.count, 5, "Expected 5 fixture files, but found \(fixtures.files.count).")

        for file in fixtures.files {
            XCTAssertFalse(file.filename.isEmpty, "Fixture file has an empty filename.")

            guard let fixtureString = String(data: file.fixtureData, encoding: .utf8), !fixtureString.isEmpty else {
                XCTFail("Fixture file '\(file.filename)' has empty data or could not be converted to String.")
                continue
            }

            // Specific validation based on the filename using predefined data
            switch file.filename {
            case "user.yml":
                XCTAssertTrue(fixtureString.contains(username), "user.yml does not contain the expected username.")
                XCTAssertTrue(fixtureString.contains(password), "user.yml does not contain the expected password.")
            case "calendars.yml":
                XCTAssertTrue(fixtureString.contains("HolidayParameters:\n    Passphrase: 2Wl3rCzTzqi6zJsddM5PTiRL8WtOZuMB0C/EIYrtQZo=\n    SessionKey: fhcCr08Idg6QTKbjTmj4u3C0f+A+L+UCxS2plXcwiEA=\n"), "calendars.yml does not contain 'holidays'.")
                XCTAssertTrue(fixtureString.contains("testcalendar"), "calendars.yml does not contain 'holidays'.")
            case "contacts.yml":
                XCTAssertTrue(fixtureString.contains(vCardData.email), "contacts.yml does not contain the expected email '\(vCardData.email)'.")
            case "mailbox.yml":
                XCTAssertTrue(fixtureString.contains(MessageState.draft.rawValue), "mailbox.yml does not contain the expected state '\(MessageState.draft.rawValue)'.")
            case let filename where filename.hasSuffix(".eml"):
                XCTAssertTrue(fixtureString.contains(emailOptions.html!), "Fixture file '\(filename)' does not contain the expected HTML content.")
            default:
                XCTFail("Unexpected fixture file '\(file.filename)' found.")
            }

            // Print fixture details for confirmation (optional, can be removed in production tests)
//            print("Fixture filename: \(file.filename), Data: \(fixtureString)")
        }

        let user = try userBuilder.seedUser(quark: quarkCommand)

        // Validation for User
        XCTAssertNotNil(user.name, "User name should not be empty.")
        XCTAssertNotNil(user.password, "Password should not be empty.")
    }
}
