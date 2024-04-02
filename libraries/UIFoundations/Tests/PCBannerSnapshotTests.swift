//
//  PCBannerSnapshotTests.swift
//  ProtonCore-UIFoundations - Created on 02.04.24.
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
//  along with ProtonCore. If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import XCTest

@testable import ProtonCoreUIFoundations

@MainActor
final class PCBannerSnapshotTests: SnapshotTestCase {

    func test_PCBanner_default_error() {
        let view = PCBanner(
            style: .constant(.init(style: .error)),
            content: .constant(.init(message: "This is a banner"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCBanner_button_error() {
        let view = PCBanner(
            style: .constant(.init(style: .error)),
            content: .constant(.init(message: "This is a banner", buttonTitle: "Action"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCBanner_default_success() {
        let view = PCBanner(
            style: .constant(.init(style: .success)),
            content: .constant(.init(message: "This is a banner"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCBanner_button_success() {
        let view = PCBanner(
            style: .constant(.init(style: .success)),
            content: .constant(.init(message: "This is a banner", buttonTitle: "Action"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCBanner_default_warning() {
        let view = PCBanner(
            style: .constant(.init(style: .warning)),
            content: .constant(.init(message: "This is a banner"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCBanner_button_warning() {
        let view = PCBanner(
            style: .constant(.init(style: .warning)),
            content: .constant(.init(message: "This is a banner", buttonTitle: "Action"))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }
}
#endif
