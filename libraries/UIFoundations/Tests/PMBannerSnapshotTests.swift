//
//  PMBannerSnapshotTests.swift
//  ProtonCore-UIFoundations - Created on 22.03.23.
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
//  along with ProtonCore. If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
import XCTest

@testable import ProtonCoreUIFoundations

@available(iOS 13, *)
final class PMBannerSnapshotTests: SnapshotTestCase {
    func testTopBanner_in_regular_viewController() {
        runTest(position: .top, in: UIViewController.self)
    }

    func testBottomBanner_in_regular_viewController() {
        runTest(position: .bottom, in: UIViewController.self)
    }

    func testTopBanner_in_tableViewController() {
        runTest(position: .top, in: UITableViewController.self)
    }

    func testBottomBanner_in_tableViewController() {
        runTest(position: .bottom, in: UITableViewController.self)
    }

    private func runTest(
        position: PMBannerPosition,
        in cls: UIViewController.Type,
        name: String = #function,
        line: UInt = #line
    ) {
        let viewController = cls.init()
        viewController.view.backgroundColor = ColorProvider.BackgroundNorm

        let sut = PMBanner(message: "Foo", style: PMBannerNewStyle.info)
        sut.show(at: position, on: viewController)

        checkSnapshots(controller: viewController, perceptualPrecision: 0.98, name: name, line: line)
    }
}

#endif
