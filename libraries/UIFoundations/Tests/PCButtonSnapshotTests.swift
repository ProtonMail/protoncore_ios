//
//  PCButtonSnapshotTests.swift
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
final class PCButtonSnapshotTests: SnapshotTestCase {

    func test_PCButton_solid_idle() {
        let view = PCButton(
            style: .constant(.init(mode: .solid)),
            content: .constant(.init(title: "Default Button", action: {}))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }

    func test_PCButton_solid_animating() {
        let view = PCButton(
            style: .constant(.init(mode: .solid)),
            content: .constant(.init(title: "Default Button", isAnimating: true, action: {}))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }


    func test_PCButton_solid_disabled() {
        let view = PCButton(
            style: .constant(.init(mode: .solid)),
            content: .constant(.init(title: "Default Button", isEnabled: false, action: {}))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }


    func test_PCButton_text_idle() {
        let view = PCButton(
            style: .constant(.init(mode: .text)),
            content: .constant(.init(title: "Default Button", action: {}))
        )

        checkSnapshots(view: view, perceptualPrecision: 0.98, name: #function, line: #line)
    }
}
#endif
