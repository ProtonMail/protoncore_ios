//
//  CreateAddressUISnapshotTests.swift
//  ProtonCore-LoginUI-Unit-TestsUsingCrypto - Created on 17/11/22.
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
//

#if os(iOS)

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
import ProtonCoreTestingToolkitUnitTestsLogin
import ProtonCoreTestingToolkitUnitTestsServices
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreLogin
import ProtonCoreServices
import ProtonCoreUtilities
import ProtonCoreNetworking
import ProtonCoreDataModel
import ProtonCoreAuthentication
import ProtonCoreDoh
import ProtonCoreUIFoundations
@testable import ProtonCoreLoginUI

@available(iOS 13, *)
final class CreateAddressUISnapshotTests: SnapshotTestCase {

    private func createViewModel(defaultUsername: String? = nil, email: String) -> CreateAddressViewModel {
        let authCredential = AuthCredential(
            sessionID: "sessionID",
            accessToken: "accessToken",
            refreshToken: "refreshToken",
            userName: "userName",
            userID: "userName",
            privateKey: nil,
            passwordKeySalt: nil
        )
        let user = User(
            ID: "ID",
            name: nil,
            usedSpace: 0,
            usedBaseSpace: 0,
            usedDriveSpace: 0,
            currency: "currency",
            credit: 0,
            maxSpace: 0,
            maxBaseSpace: 0,
            maxDriveSpace: 0,
            maxUpload: 0,
            role: 0,
            private: 0,
            subscribed: [],
            services: 0,
            delinquent: 0,
            orgPrivateKey: nil,
            email: nil,
            displayName: nil,
            keys: []
        )
        let createAddressData = CreateAddressData(
            email: email,
            credential: authCredential,
            user: user,
            mailboxPassword: "mailboxPassword",
            passwordMode: .one
        )

        let authDelegate = AuthHelper()
        let serviceDelegate = AnonymousServiceManager()
        let api = PMAPIService.createAPIService(doh: DohMock() as DoHInterface, sessionUID: "test session ID", challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        let login = LoginService(api: api, clientApp: .other(named: "core"), minimumAccountType: .internal)

        return CreateAddressViewModel(data: createAddressData, login: login, defaultUsername: defaultUsername)
    }

    private func createViewController(defaultUsername: String? = nil, email: String, inAppTheme: InAppTheme = .default) -> UIViewController {
        let viewModel = createViewModel(defaultUsername: defaultUsername, email: email)
        let createAddressViewController = UIStoryboard.instantiate(storyboardName: "PMLogin", controllerType: CreateAddressViewController.self, inAppTheme: { inAppTheme })
        createAddressViewController.viewModel = viewModel
        return createAddressViewController
    }

    func testCreateAddressViewControllerWithUsername() {
        let controller = createViewController(defaultUsername: "testUserTest", email: "test.test@test.com")
        checkSnapshots(controller: controller, perceptualPrecision: 0.98)
    }

    func testCreateAddressViewControllerWithoutUsername() {
        let controller = createViewController(email: "test.test@test.com")
        checkSnapshots(controller: controller, perceptualPrecision: 0.98)
    }

    func testCreateAddressViewControllerEnforceLightMode() {
        let controller = createViewController(defaultUsername: "testUserTest", email: "test.test@test.com", inAppTheme: .light)
        checkSnapshots(controller: controller, perceptualPrecision: 0.98)
    }

    func testCreateAddressViewControllerEnforceDarkMode() {
        let controller = createViewController(defaultUsername: "testUserTest", email: "test.test@test.com", inAppTheme: .dark)
        checkSnapshots(controller: controller, perceptualPrecision: 0.98)
    }
}

#endif
