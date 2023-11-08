//
//  AccountRecoveryHandlerTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 1/8/23.
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
import UserNotifications
import ProtonCorePushNotifications
@testable import ProtonCoreAccountRecovery

final class AccountRecoveryHandlerTests: XCTestCase {

    func testHandling() {
        let content = UNMutableNotificationContent()
        content.userInfo = ["unencryptedMessage": NotificationType.accountRecoveryInitiated]

        let expectation = XCTestExpectation(description: "Handler is called")

        let sut = AccountRecoveryHandler()
        sut.handler = { notification in
            expectation.fulfill()
            return .success(())
        }

        sut.handle(notification: content)

        wait(for: [expectation], timeout: 1)
    }

    func testNonHandlingOfUnknownNotificationTypes() {
        let content = UNMutableNotificationContent()
        content.userInfo = ["unencryptedMessage": "Superunknown"]

        let expectation = XCTestExpectation(description: "Handler is called")
        expectation.isInverted = true

        let sut = AccountRecoveryHandler()
        sut.handler = { notification in
            expectation.fulfill()
            return .success(())
        }

        sut.handle(notification: content)

        wait(for: [expectation], timeout: 1)
    }
}
