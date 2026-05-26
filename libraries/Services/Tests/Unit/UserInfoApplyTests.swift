//
//  UserInfoApplyTests.swift
//  ProtonCore-Services-Tests - Created on 21/05/2026.
//
//  Copyright (c) 2026 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
import ProtonCoreDataModel
@testable import ProtonCoreServices

class UserInfoApplyTests: XCTestCase {

    var jsonDecoder: JSONDecoder!
    var sut: UserInfo!

    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder.decapitalisingFirstLetter
        sut = UserInfo.getDefault()
    }

    override func tearDown() {
        jsonDecoder = nil
        sut = nil
        super.tearDown()
    }

    func testApplyUserSettings() throws {
        let json = """
        {
            "Email": {
                "Value": "xxxx@pm.me",
                "Status": 1,
                "Notify": 0,
                "Reset": 1
            },
            "Password": {
                "Mode": 1,
                "ExpirationTime": null
            },
            "2FA": {
                "Enabled": 0,
                "Allowed": 3,
                "ExpirationTime": null,
                "RegisteredKeys": []
            },
            "WeekStart": 0,
            "Telemetry": 1,
            "CrashReports": 1,
            "Referral": {
                "Link": "https://pr.tn/ref/YN9B20",
                "Eligible": false
            },
            "Flags": {
                "EdmOptOut": 1
            }
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let userSettings = try jsonDecoder.decode(UserSettings.self, from: data)
        sut.apply(userSettings)

        XCTAssertEqual(sut.notificationEmail, "xxxx@pm.me")
        XCTAssertEqual(sut.notify, 0)
        XCTAssertEqual(sut.passwordMode, 1)
        XCTAssertEqual(sut.twoFactor, 0)
        XCTAssertEqual(sut.weekStart, 0)
        XCTAssertEqual(sut.telemetry, 1)
        XCTAssertEqual(sut.crashReports, 1)
        XCTAssertEqual(sut.edmOptOut, 1)

        let referralProgram = try XCTUnwrap(sut.referralProgram)
        XCTAssertEqual(referralProgram.link, "https://pr.tn/ref/YN9B20")
        XCTAssertFalse(referralProgram.eligible)
    }

    func testApplyUserSettingsLeavesAbsentFieldsUntouched() throws {
        sut.weekStart = 5
        sut.telemetry = 0
        sut.edmOptOut = 1

        let json = """
        {
            "Password": { "Mode": 2 },
            "2FA": { "Enabled": 0, "RegisteredKeys": [] }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let userSettings = try jsonDecoder.decode(UserSettings.self, from: data)
        sut.apply(userSettings)

        XCTAssertEqual(sut.passwordMode, 2)
        XCTAssertEqual(sut.weekStart, 5)
        XCTAssertEqual(sut.telemetry, 0)
        XCTAssertEqual(sut.edmOptOut, 1)
    }

    func testApplyMailSettings() throws {
        let json = """
        {
            "AutoSaveContacts": 1,
            "HideEmbeddedImages": 1,
            "HideRemoteImages": 0,
            "ViewMode": 0,
            "SwipeLeft": 0,
            "SwipeRight": 4,
            "ImageProxy": 2,
            "AttachPublicKey": 0,
            "Sign": 0,
            "ConfirmLink": 1,
            "DelaySendSeconds": 10,
            "DisplayName": "",
            "Signature": "",
            "EnableFolderColor": 1,
            "InheritParentFolderColor": 0,
            "MobileSettings": {
                "ConversationToolbar": {
                    "IsCustom": true,
                    "Actions": ["toggle_read", "trash", "move"]
                },
                "MessageToolbar": {
                    "IsCustom": false,
                    "Actions": ["toggle_read", "trash", "move", "label"]
                },
                "ListToolbar": {
                    "IsCustom": true,
                    "Actions": []
                }
            }
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let mailSettings = try jsonDecoder.decode(MailSettings.self, from: data)
        sut.apply(mailSettings)

        XCTAssertEqual(sut.displayName, "")
        XCTAssertEqual(sut.defaultSignature, "")
        XCTAssertEqual(sut.imageProxy, .imageProxy)
        XCTAssertEqual(sut.autoSaveContact, 1)
        XCTAssertEqual(sut.hideEmbeddedImages, 1)
        XCTAssertEqual(sut.hideRemoteImages, 0)
        XCTAssertEqual(sut.swipeLeft, 0)
        XCTAssertEqual(sut.swipeRight, 4)
        XCTAssertEqual(sut.linkConfirmation, .confirmationAlert)
        XCTAssertEqual(sut.attachPublicKey, 0)
        XCTAssertEqual(sut.sign, 0)
        XCTAssertEqual(sut.enableFolderColor, 1)
        XCTAssertEqual(sut.inheritParentFolderColor, 0)
        XCTAssertEqual(sut.groupingMode, 0)
        XCTAssertEqual(sut.delaySendSeconds, 10)
        XCTAssertEqual(sut.conversationToolbarActions,
                       .init(isCustom: true, actions: ["toggle_read", "trash", "move"]))
        XCTAssertEqual(sut.messageToolbarActions,
                       .init(isCustom: false, actions: ["toggle_read", "trash", "move", "label"]))
        XCTAssertEqual(sut.listToolbarActions,
                       .init(isCustom: true, actions: []))
    }
}
