//
//  LoginSSOSnapshotTests.swift
//  ProtonCore-LoginUI-Unit-TestsUsingCrypto - Created on 23/08/2024.
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

#if os(iOS)

import ProtonCoreLogin
@testable import ProtonCoreLoginUI
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsServices
#endif
import XCTest
import SwiftUI

class LoginSSOSnapshotTests: SnapshotTestCase {

    let defaultPrecision: Float = 0.98

    let unprivatizationInfo = UnprivatizationInfo(
        state: .pending,
        adminEmail: "admin@privacybydefault.com",
        orgKeyFingerprintSignature: .init(value: ""),
        orgPublicKey: .init(value: "")
    )

    @MainActor
    func testJoinOrganizationView() {
        let view = SetBackupPasswordView(viewModel: .init(dependencies: .init(
            mode: .setNewBackupPassword(organizationInfo: .init(
                organizationName: "Proton AG",
                organizationAdminEmail: "admin@privacybydefault.com",
                organizationLogoID: nil,
                organizationPublicKey: .init(value: "")
            )),
            apiService: APIServiceMock(),
            userData: .dummy,
            loginService: nil,
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeRequestForAdminApproval() {
        let view = SignInRequestView(viewModel: .init(dependencies: .init(
            mode: .requestForAdminApproval(code: "64S3", adminEmail: "admin@privacybydefault.com"),
            apiService: nil,
            userData: .dummy,
            ssoNavigationDelegate: nil,
            onDeviceActivatedAction: {},
            onDeviceRejectedAction: {}
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeRequestApproveFromAnotherDevice() {
        let view = SignInRequestView(viewModel: .init(dependencies: .init(
            mode: .requestApproveFromAnotherDevice(code: "64S3", devices: [.mock]),
            apiService: nil,
            userData: .dummy,
            ssoNavigationDelegate: nil,
            onDeviceActivatedAction: {},
            onDeviceRejectedAction: {}
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeApprovingAccess() {
        let view = GrantAccessView(viewModel: .init(dependencies: .init(
            apiService: nil,
            authDevices: [.mock, .mock],
            userData: .dummy,
            navigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testEnterBackupPassword() {
        let view = EnterBackupPasswordView(viewModel: .init(dependencies: .init(
            userData: .dummy,
            apiService: nil,
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testAccessGranted() {
        let view = AccessGrantedDeniedView(viewModel: .init(dependencies: .init(
            mode: .accessGranted(userData: .dummy),
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testAccessDenied() {
        let view = AccessGrantedDeniedView(viewModel: .init(dependencies: .init(
            mode: .accessDenied,
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    func testRequestAdminAccess() {
        let viewController = RequestAdminAccessViewController(dependencies: .init(
            apiService: nil,
            userData: .dummy,
            adminEmail: "admin@privacybydefault.com",
            ssoNavigationDelegate: nil
        ))

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }
}

#endif
