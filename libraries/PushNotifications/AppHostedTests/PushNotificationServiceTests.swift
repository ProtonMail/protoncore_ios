//
//  PushNotificationServiceTests.swift
//  proton-push-notifications - Created on 14/6/23.
//
//  Copyright (c) 2023 Proton AG
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
@testable import ProtonCorePushNotifications
import UserNotifications

// These tests are disabled in the test plan, because they need an Application Host
// for several reasons (access to UNNotificationCenter, Keychain, custom Info.plist settings…)
// and that can't be configured from an SPM Package
// We'll need to add stand-alone micro-projects for running these

final class PushNotificationServiceTests: XCTestCase {
 

    func testSetupSetsNotificationCenterDelegate() {

        // given
        let sharedService = PushNotificationService.shared

        // when
        sharedService.setup(launchOptions: nil)

        // then
        XCTAssertEqual(UNUserNotificationCenter.current().delegate as? PushNotificationService, sharedService)
    }

    func testRegisteringForRemoteNotificationsSavesDeviceToken() {
        let sut = PushNotificationService.shared

        sut.didRegisterForRemoteNotifications(withDeviceToken: Data([0xDE, 0xCA, 0xFB, 0xAD]))

        XCTAssertEqual("decafbad", sut.latestDeviceToken)
    }

    func testInitialState() {
        let sut = PushNotificationService() // can't reset shared in tests

        XCTAssertEqual(.unregistered, sut.registrationState)
    }

    func testRegisteringForRemoteNotificationsChangesStateToRegistered() {
        let sut = PushNotificationService.shared

        sut.didRegisterForRemoteNotifications(withDeviceToken: Data([0xDE, 0xCA, 0xFB, 0xAD]))

        XCTAssertEqual(.registered, PushNotificationService.shared.registrationState)

    }

    func testFailingRegistrationChangesStateToFailed() {
        let sut = PushNotificationService.shared

        sut.didFailToRegisterForRemoteNotifications(withError: UNError(.notificationsNotAllowed))

        XCTAssertEqual(.failed, PushNotificationService.shared.registrationState)

    }
}
