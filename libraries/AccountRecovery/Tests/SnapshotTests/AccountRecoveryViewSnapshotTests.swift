//
//  AccountRecoveryViewSnapshotTests.swift
//  ProtonCore-AccountRecoveryTests - Created on 19/12/22.
//
//  Copyright (c) 2023 Proton Technologies AG
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

import Foundation
@testable import ProtonCoreAccountRecovery
import XCTest
import SwiftUI
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif

class AccountRecoveryViewSnapshotTests: SnapshotTestCase {

    func testAccountRecoveryContainingScreenWithNavigationBar() {
        let preview = AccountRecoveryView_Previews.previews
        let navigationView = NavigationView { preview }

        checkSnapshots(controller: UIHostingController(rootView: navigationView))
    }

    func testGracePeriodScreen() {
        let preview = ActiveAccountRecoveryView_Previews.previews

        checkSnapshots(controller: UIHostingController(rootView: preview))
    }
}
