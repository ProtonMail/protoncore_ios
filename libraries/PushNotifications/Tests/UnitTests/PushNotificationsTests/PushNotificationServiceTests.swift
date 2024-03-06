//
//  PushNotificationServiceTests.swift
//  ProtonCore-PushNotifications-Unit-Tests-Crypto-Go - Created on 25/7/23.
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

import Foundation
import XCTest
import ProtonCoreCryptoGoImplementation
#if canImport(ProtonCoreTestingToolkitUnitTestsFeatureFlag)
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCorePushNotifications

final class PushNotificationServiceTests: XCTestCase {

    var apiMock: APIServiceMock!

    override func setUp() {
        super.setUp()

        apiMock = APIServiceMock()

    }

    func testSettingUpWithFeatureFlagDisabled() {
        let fakeCenter = FakeNotificationCenter(isAuthorizationRequestSuccesful: false, authorizationRequestError: nil)
        NotificationCenterFactory.theCurrent = fakeCenter

        let sut = PushNotificationService(apiService: apiMock)

        sut.setup()

        XCTAssertNil(NotificationCenterFactory.current.delegate)
        XCTAssertFalse(fakeCenter.didRequestAuthorization)
    }

    func testSettingUp() {
        let fakeCenter = FakeNotificationCenter(isAuthorizationRequestSuccesful: true, authorizationRequestError: nil)
        NotificationCenterFactory.theCurrent = fakeCenter

        withFeatureFlags([.accountRecovery]) {
            let sut = PushNotificationService(apiService: apiMock)

            sut.setup()

            XCTAssertNotNil(NotificationCenterFactory.current.delegate)
            XCTAssert(fakeCenter.didRequestAuthorization)
        }
    }

    func testDidRegisterForRemoteNotifications() {
        injectDefaultCryptoImplementation()

        apiMock.sessionUIDStub.fixture = "test session ID"
        let fakeCenter = FakeNotificationCenter(isAuthorizationRequestSuccesful: true, authorizationRequestError: nil)
        NotificationCenterFactory.theCurrent = fakeCenter

        withFeatureFlags([.accountRecovery]) {
            let sut = PushNotificationService(apiService: apiMock)

            sut.didRegisterForRemoteNotifications(withDeviceToken: Data(repeating: 130, count: 15))
            XCTAssertEqual(.registered, sut.registrationState)
        }
    }

    func testDidFailToRegisterForRemoteNotifications() {
        let fakeCenter = FakeNotificationCenter(isAuthorizationRequestSuccesful: true, authorizationRequestError: nil)
        NotificationCenterFactory.theCurrent = fakeCenter

        withFeatureFlags([.accountRecovery]) {
            let sut = PushNotificationService(apiService: apiMock)

            sut.didFailToRegisterForRemoteNotifications(withError: NSError(domain: "Test", code: 666))
            XCTAssertEqual(.failed, sut.registrationState)
        }
    }

    /* The actual reception of notifications is untestable from here. They could be tested using Local Notifications,
     but those require scheduling them using UNUserNotificationCenter (the real one, which can't be instantiated in a non-app hosted test target.
     Hence the test coverage needs to leave these out
     */
}

class FakeNotificationCenter: NotificationCenterProtocol {
    var isAuthorizationRequestSuccesful: Bool
    var authorizationRequestError: Error?
    private (set) var didRequestAuthorization = false

    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        didRequestAuthorization = true
        completionHandler(isAuthorizationRequestSuccesful, authorizationRequestError)
    }

    public var delegate: UNUserNotificationCenterDelegate?

    init(isAuthorizationRequestSuccesful: Bool, authorizationRequestError: Error?) {
        self.isAuthorizationRequestSuccesful = isAuthorizationRequestSuccesful
        self.authorizationRequestError = authorizationRequestError
    }
}
