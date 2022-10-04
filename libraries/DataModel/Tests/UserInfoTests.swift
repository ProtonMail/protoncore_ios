//
//  UserInfoTests.swift
//  ProtonCore-DataModel-Tests - Created on 09/05/2022.
//
//  Copyright (c) 2022 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.

@testable import ProtonCore_DataModel
import ProtonCore_TestingToolkit
import XCTest

class UserInfoTests: XCTestCase {
    var sut: UserInfo!

    override func setUp() {
        super.setUp()
        sut = UserInfo.dummy
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testUserInfoParsing() throws {
        let json = """
        {
            "AutoSaveContacts": 1,
            "ShowImages": 2,
            "ViewMode": 0,
            "SwipeLeft": 0,
            "SwipeRight": 4,
            "ImageProxy": 2,
            "RightToLeft": 0,
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

        let jsonDict = try XCTUnwrap(try convertStringToDictionary(text: json))
        sut.parse(mailSettings: jsonDict)

        XCTAssertEqual(sut.displayName, "")
        XCTAssertEqual(sut.defaultSignature, "")
        XCTAssertEqual(sut.imageProxy, .imageProxy)
        XCTAssertEqual(sut.autoSaveContact, 1)
        XCTAssertEqual(sut.showImages, .embedded)
        XCTAssertEqual(sut.swipeLeft, 0)
        XCTAssertEqual(sut.swipeRight, 4)
        XCTAssertEqual(sut.linkConfirmation, .confirmationAlert)
        XCTAssertEqual(sut.attachPublicKey, 0)
        XCTAssertEqual(sut.sign, 0)
        XCTAssertEqual(sut.enableFolderColor, 1)
        XCTAssertEqual(sut.inheritParentFolderColor, 0)
        XCTAssertEqual(sut.groupingMode, 0)
        XCTAssertEqual(sut.delaySendSeconds, 10)
        XCTAssertEqual(sut.conversationToolbarActions, .init(isCustom: true,
                                                             actions: ["toggle_read",
                                                                       "trash",
                                                                       "move"]))
        XCTAssertEqual(sut.messageToolbarActions, .init(isCustom: false,
                                                        actions: [
                                                            "toggle_read",
                                                            "trash",
                                                            "move",
                                                            "label"
                                                        ]))
        XCTAssertEqual(sut.listToolbarActions, .init(isCustom: true,
                                                     actions: []))
    }

    private func convertStringToDictionary(text: String) throws -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json
        }
        return nil
    }
}
