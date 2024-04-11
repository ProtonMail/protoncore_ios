//
//  PasswordChangeViewSnapshotTests.swift
//  ProtonCore-PasswordChange - Created on 04.04.24.
//
//  Copyright (c) 2024 Proton Technologies AG
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
//  along with ProtonCore. If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import SwiftUI

import XCTest
@testable import ProtonCorePasswordChange

@MainActor
final class PasswordChangeViewSnapshotTests: SnapshotTestCase {

    func test_PasswordChangeView_idle() {
        let preview = PasswordChangeView_Previews.previews
        let navigationView = NavigationView { preview }

        checkSnapshots(controller: UIHostingController(rootView: navigationView),
                       perceptualPrecision: 0.9)
    }

    func test_PasswordChange2FAView_idle() {
        let preview = PasswordChange2FAView_Previews.previews
        let navigationView = NavigationView { preview }

        checkSnapshots(controller: UIHostingController(rootView: navigationView),
                       perceptualPrecision: 0.9)
    }
}
#endif
