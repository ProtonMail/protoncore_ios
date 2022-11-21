//
//  AvailableAddressViewControllerTests.swift
//  ProtonCore-Login-Unit-Tests - Created on 16/11/2022.
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

import XCTest
import ProtonCore_Login
import ProtonCore_Networking
import ProtonCore_DataModel
import ProtonCore_TestingToolkit
import SnapshotTesting
@testable import ProtonCore_LoginUI

@available(iOS 13, *)
final class AvailableAddressViewControllerTests: SnapshotTestCase {

    func testAvailableAddressViewController() {
        let authCredential = AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date(), userName: "userName", userID: "userName", privateKey: nil, passwordKeySalt: nil)
        let user = User(ID: "ID", name: nil, usedSpace: 0, currency: "currency", credit: 0, maxSpace: 0, maxUpload: 0, role: 0, private: 0, subscribed: 0, services: 0, delinquent: 0, orgPrivateKey: nil, email: nil, displayName: nil, keys: [])
        let createAddressData = CreateAddressData(email: "test.test@test.com", credential: authCredential, user: user, mailboxPassword: "mailboxPassword")
        
        let availableAddressViewController = UIStoryboard.instantiate(storyboardName: "PMLogin", controllerType: AvailableAddressViewController.self)
        availableAddressViewController.createAddressData = createAddressData
        checkSnapshots(controller: availableAddressViewController)
    }
}
