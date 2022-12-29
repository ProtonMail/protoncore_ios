//
//  FingerprintMocks.swift
//  ProtonCore-Authentication-Tests - Created on 12/20/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

enum FingerprintMocks {
    static let allFignerprints =
    """
    [
      {
        "pasteUsername" : [

        ],
        "frame" : {
          "name" : "username"
        },
        "uuid" : "1111-111-111-9711-111",
        "clickUsername" : 0,
        "isJailbreak" : false,
        "keyboards" : [
          "en_US@sw=QWERTY;hw=Automatic",
          "emoji@sw=Emoji"
        ],
        "v" : "2.0.3",
        "timeUsername" : [

        ],
        "preferredContentSize" : "UICTContentSizeCategoryM",
        "storageCapacity" : 499.95999999999998,
        "cellulars" : [
        ],
        "appLang" : "en",
        "isDarkmodeOn" : false,
        "copyUsername" : [
        ],
        "keydownUsername" : [

        ],
        "timezone" : "AmericaLos_Angeles",
        "deviceName" : 22222,
        "regionCode" : "US",
        "timezoneOffset" : 480
      },
      {
        "keydownRecovery" : [

        ],
        "frame" : {
          "name" : "recovery"
        },
        "isJailbreak" : false,
        "keyboards" : [
          "en_US@sw=QWERTY;hw=Automatic",
          "emoji@sw=Emoji"
        ],
        "pasteRecovery" : [

        ],
        "clickRecovery" : 0,
        "v" : "2.0.3",
        "uuid" : "1111-1111-4363-9711-1111",
        "preferredContentSize" : "UICTContentSizeCategoryM",
        "cellulars" : [

        ],
        "storageCapacity" : 499.95999999999998,
        "appLang" : "en",
        "isDarkmodeOn" : false,
        "copyRecovery" : [

        ],
        "timezone" : "AmericaLos_Angeles",
        "deviceName" : 328599075,
        "regionCode" : "US",
        "timeRecovery" : [

        ],
        "timezoneOffset" : 480
      }
    ]
    """
    
    static let deviceFignerprints =
    """
    [
      {
        "storageCapacity" : 499.95999999999998,
        "uuid" : "1111-1111-1111-1111-2222222",
        "keyboards" : [
          "en_US@sw=QWERTY;hw=Automatic",
          "emoji@sw=Emoji"
        ],
        "frame" : {
          "name" : "username"
        },
        "regionCode" : "US",
        "isDarkmodeOn" : false,
        "deviceName" : 328599075,
        "preferredContentSize" : "UICTContentSizeCategoryM",
        "cellulars" : [
    
        ],
        "appLang" : "en",
        "isJailbreak" : false,
        "timezone" : "America/Los_Angeles",
        "timezoneOffset" : 480
      },
      {
        "storageCapacity" : 499.95999999999998,
        "uuid" : "1111-1111-1111-1111-2222222",
        "keyboards" : [
          "en_US@sw=QWERTY;hw=Automatic",
          "emoji@sw=Emoji"
        ],
        "frame" : {
          "name" : "recovery"
        },
        "regionCode" : "US",
        "isDarkmodeOn" : false,
        "deviceName" : 328599075,
        "preferredContentSize" : "UICTContentSizeCategoryM",
        "cellulars" : [
    
        ],
        "appLang" : "en",
        "isJailbreak" : false,
        "timezone" : "America/Los_Angeles",
        "timezoneOffset" : 480
      }
    ]
    """
    
}
