//
//  AccountRecoveryHelperTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 15/12/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
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
//

import XCTest
import ProtonCoreDataModel
import ProtonCoreUIFoundations
import UIKit

public class AccountRecoveryHelperTests: XCTestCase {

    var noRecovery = User.AccountRecovery(state: .none,
                                          startTime: Date.distantPast.timeIntervalSince1970,
                                          endTime: Date.distantFuture.timeIntervalSince1970,
                                          UID: "UUID")
    var gracePeriod = User.AccountRecovery(state: .grace,
                                           startTime: Date.distantPast.timeIntervalSince1970,
                                           endTime: Date.distantFuture.timeIntervalSince1970,
                                           UID: "UUID")
    var automaticallyCancelled =  User.AccountRecovery(state: .cancelled,
                                                       reason: .authentication,
                                                       startTime: Date.distantPast.timeIntervalSince1970,
                                                       endTime: Date.distantFuture.timeIntervalSince1970,
                                                       UID: "UUID")
    var explicitlyCancelled =  User.AccountRecovery(state: .cancelled,
                                                    reason: .cancelled,
                                                    startTime: Date.distantPast.timeIntervalSince1970,
                                                    endTime: Date.distantFuture.timeIntervalSince1970,
                                                    UID: "UUID")
    var insecureState =  User.AccountRecovery(state: .insecure,
                                              startTime: Date.distantPast.timeIntervalSince1970,
                                              endTime: Date.distantFuture.timeIntervalSince1970,
                                              UID: "UUID")
    var expired =  User.AccountRecovery(state: .expired,
                                        startTime: Date.distantPast.timeIntervalSince1970,
                                        endTime: Date.distantFuture.timeIntervalSince1970,
                                        UID: "UUID")

    func testSettingsVisibilityFromState() {
        XCTAssertFalse(noRecovery.shouldShowSettingsItem)
        XCTAssert(gracePeriod.shouldShowSettingsItem)
        XCTAssert(automaticallyCancelled.shouldShowSettingsItem)
        XCTAssertFalse(explicitlyCancelled.shouldShowSettingsItem)
        XCTAssert(insecureState.shouldShowSettingsItem)
        XCTAssertFalse(expired.shouldShowSettingsItem)
    }

    func testSettingsValueFromState() {
        XCTAssertEqual("Pending", gracePeriod.valueForSettingsItem)
        XCTAssertEqual("Cancelled", automaticallyCancelled.valueForSettingsItem)
        XCTAssertEqual("Available", insecureState.valueForSettingsItem)
    }

    func testSettingsImageFromState() {
        XCTAssertEqual(IconProvider.exclamationCircle.imageAsset, gracePeriod.imageForSettingsItem?.imageAsset)
        XCTAssertEqual(IconProvider.exclamationCircle.imageAsset, automaticallyCancelled.imageForSettingsItem?.imageAsset)
        XCTAssertEqual(IconProvider.checkmarkCircle.imageAsset, insecureState.imageForSettingsItem?.imageAsset)
    }


}
