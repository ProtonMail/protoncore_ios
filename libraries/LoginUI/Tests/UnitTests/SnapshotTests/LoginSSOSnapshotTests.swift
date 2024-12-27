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

import XCTest
@testable import ProtonCoreLoginUI
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import SwiftUI

class LoginSSOSnapshotTests: SnapshotTestCase {

    let defaultPrecision: Float = 0.98

    @MainActor
    func testJoinOrganizationView() {
        let view = JoinOrganizationView(viewModel: .init(dependencies: .init(
            apiService: APIServiceMock(),
            loginService: nil,
            userData: .dummy,
            organizationInfo: .init(
                organizationName: "Proton AG",
                organizationAdminEmail: "admin@privacybydefault.com",
                organizationLogoID: nil,
                organizationPublicKey: .init(value: "")
            ),
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeRequestForAdminApproval() {
        let view = SignInRequestView(viewModel: .init(dependencies: .init(
            mode: .requestForAdminApproval(code: "64S3"),
            userData: .dummy,
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeRequestApproveFromAnotherDevice() {
        let view = SignInRequestView(viewModel: .init(dependencies: .init(
            mode: .requestApproveFromAnotherDevice(code: "64S3", devices: [.mock]),
            userData: .dummy,
            ssoNavigationDelegate: nil
        )))
        let viewController = UIHostingController(rootView: view)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testSignInRequestViewModeApprovingAccess() {
        let view = SignInRequestView(viewModel: .init(dependencies: .init(
            mode: .approvingAccess,
            userData: .dummy,
            ssoNavigationDelegate: nil
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
        let viewController = AccessGrantedDeniedViewController(mode: .accessGranted)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    @MainActor
    func testAccessDenied() {
        let viewController = AccessGrantedDeniedViewController(mode: .accessDenied)

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    func testRequestAdminAccess() {
        let viewController = RequestAdminAccessViewController()

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }

    func testAdminGrantAccess() {
        let viewController = AdminGrantAccessViewController()

        checkSnapshots(controller: viewController, perceptualPrecision: defaultPrecision)
    }
}

#endif
