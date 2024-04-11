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

@testable import ProtonCoreDataModel
#if canImport(ProtonCoreTestingToolkitUnitTestsDataModel)
import ProtonCoreTestingToolkitUnitTestsDataModel
#else
import ProtonCoreTestingToolkit
#endif
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
            "HideEmbeddedImages": 1,
            "HideRemoteImages": 0,
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

    func testParseUserSettings() throws {
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
                "U2FKeys": [],
                "RegisteredKeys": []
            },
            "WeekStart": 0,
            "Telemetry": 1,
            "CrashReports": 1,
            "Referral": {
                "Link": "https://pr.tn/ref/YN9B20",
                "Eligible": false
            }
        }
        """
        let jsonDict = try XCTUnwrap(try convertStringToDictionary(text: json))
        sut.parse(userSettings: jsonDict)

        XCTAssertEqual(sut.notificationEmail, "xxxx@pm.me")
        XCTAssertEqual(sut.notify, 0)
        XCTAssertEqual(sut.passwordMode, 1)
        XCTAssertEqual(sut.twoFactor, 0)
        XCTAssertEqual(sut.weekStart, 0)
        XCTAssertEqual(sut.telemetry, 1)
        XCTAssertEqual(sut.crashReports, 1)

        let referralProgram = try XCTUnwrap(sut.referralProgram)
        XCTAssertEqual(referralProgram.link, "https://pr.tn/ref/YN9B20")
        XCTAssertFalse(referralProgram.eligible)
    }
    
    
    func testInitializeUserInfoFromResponse() throws {
        let json = """
        {
            "LockedFlags": 4
        }
        """
        let responseDict = try XCTUnwrap(try convertStringToDictionary(text: json))
        let userInfo = UserInfo(response: responseDict)
        
        XCTAssertEqual(userInfo.lockedFlags, LockedFlags.orgIssueForPrimaryAdmin)
    }

    func testInitializeUserInfoFromResponseWithNilAccountRecovery() throws {
        let json = """
        {
         "ToMigrate" : 0,
         "Currency" : "EUR",
         "Email" : "recoveco4@proton.black",
         "MaxUpload" : 26214400,
         "Type" : 1,
         "UsedBaseSpace" : 1062250,
         "ChargebeeUser" : 1,
         "Subscribed" : 0,
         "Flags" : {
         "has-temporary-password" : false,
         "protected" : false,
         "onboard-checklist-storage-granted" : false,
         "drive-early-access" : false,
         "test-account" : false,
         "no-login" : false,
         "recovery-attempt" : false,
         "sso" : false,
         "no-proton-address" : false
         },
         "MaxSpace" : 524288000,
         "MaxBaseSpace" : 524288000,
         "Role" : 0,
         "Private" : 1,
         "DisplayName" : "",
         "CreateTime" : 1712838979,
         "Keys" : [
         {
         "Active" : 1,
         "Version" : 3,
         "RecoverySecretSignature" : null,
         "Fingerprint" : "3919ce8899beef1de9d9d39f34cb59830e7a9363",
         "RecoverySecret" : null,
         "Primary" : 1,
         "ID" : "u-uRjKtsPIZjuXDTo2JC0DGfuX-BwAxSK_wFuuL1WcdN2bsIgUkjJT546saNqqyC9e8KQ7YTrhxtAIPremoGgg=="
         }
         ],
         "Services" : 1,
         "UsedDriveSpace" : 0,
         "Delinquent" : 0,
         "MnemonicStatus" : 1,
         "Credit" : 0,
         "UsedSpace" : 1062250,
         "Name" : "recoveco4",
         "MaxDriveSpace" : 2147483648,
         "ID" : "TmW3dg3wkF1AzlMEswKu9eCBZ-J7hv452tMpGibPzknEd_Wes57opk31opIRC37SKAUjX9aHTWDOFkl0VEZuNQ==",
         "ProductUsedSpace" : {
         "Contact" : 0,
         "Calendar" : 0,
         "Mail" : 1062250,
         "Drive" : 0,
         "Pass" : 0
         },
         "AccountRecovery" : null
        }
        """

        let responseDict = try XCTUnwrap(try convertStringToDictionary(text: json))
        let userInfo = UserInfo(response: responseDict)

        XCTAssertNil(userInfo.accountRecovery)

    }

    func testInitializeUserInfoFromResponseWithNotNilAccountRecovery() throws {
        let json = """
        {
         "ToMigrate" : 0,
         "Currency" : "EUR",
         "Email" : "recoveco4@proton.black",
         "MaxUpload" : 26214400,
         "Type" : 1,
         "UsedBaseSpace" : 1062250,
         "ChargebeeUser" : 1,
         "Subscribed" : 0,
         "Flags" : {
         "has-temporary-password" : false,
         "protected" : false,
         "onboard-checklist-storage-granted" : false,
         "drive-early-access" : false,
         "test-account" : false,
         "no-login" : false,
         "recovery-attempt" : false,
         "sso" : false,
         "no-proton-address" : false
         },
         "MaxSpace" : 524288000,
         "MaxBaseSpace" : 524288000,
         "Role" : 0,
         "Private" : 1,
         "DisplayName" : "",
         "CreateTime" : 1712838979,
         "Keys" : [
         {
         "Active" : 1,
         "Version" : 3,
         "RecoverySecretSignature" : null,
         "Fingerprint" : "3919ce8899beef1de9d9d39f34cb59830e7a9363",
         "RecoverySecret" : null,
         "Primary" : 1,
         "ID" : "u-uRjKtsPIZjuXDTo2JC0DGfuX-BwAxSK_wFuuL1WcdN2bsIgUkjJT546saNqqyC9e8KQ7YTrhxtAIPremoGgg=="
         }
         ],
         "Services" : 1,
         "UsedDriveSpace" : 0,
         "Delinquent" : 0,
         "MnemonicStatus" : 1,
         "Credit" : 0,
         "UsedSpace" : 1062250,
         "Name" : "recoveco4",
         "MaxDriveSpace" : 2147483648,
         "ID" : "TmW3dg3wkF1AzlMEswKu9eCBZ-J7hv452tMpGibPzknEd_Wes57opk31opIRC37SKAUjX9aHTWDOFkl0VEZuNQ==",
         "ProductUsedSpace" : {
         "Contact" : 0,
         "Calendar" : 0,
         "Mail" : 1062250,
         "Drive" : 0,
         "Pass" : 0
         },
         "AccountRecovery" : {
           "Reason" : 2,
           "UID" : "slswn2dtcgcyah2x3rpbarmab6ytn7q4",
           "StartTime" : 1712813188,
           "State" : 2,
           "EndTime" : 1714022788
         }
        }
        """

        let responseDict = try XCTUnwrap(try convertStringToDictionary(text: json))
        let userInfo = UserInfo(response: responseDict)

        XCTAssertNotNil(userInfo.accountRecovery)
        XCTAssertEqual(.authentication, userInfo.accountRecovery?.reason)
        XCTAssertEqual(1712813188, userInfo.accountRecovery?.startTime)
        XCTAssertEqual(1714022788, userInfo.accountRecovery?.endTime)
        XCTAssertEqual("slswn2dtcgcyah2x3rpbarmab6ytn7q4", userInfo.accountRecovery?.UID)
        XCTAssertEqual(.cancelled, userInfo.accountRecovery?.state)

    }

    private func convertStringToDictionary(text: String) throws -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json
        }
        return nil
    }
}
