//
//  PMActionSheetSnapshotTests.swift
//  ProtonCore-UIFoundations - Created on 11.01.23.
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

import XCTest
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#elseif canImport(ProtonCoreTestingToolkit)
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreUIFoundations

@available(iOS 13, *)
class PMActionSheetSnapshotTests: SnapshotTestCase {

    func testSimpleActionSheet() {
        let viewController = UIViewController()
        let sheet: PMActionSheet
        let items = (0...5).map {
            PMActionSheetItem(style: .default(IconProvider.star, "star \($0)"), handler: nil)
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(viewController, animated: true)
        checkSnapshots(controller: viewController, perceptualPrecision: 0.98)
    }

    func testSheetAssemble_with_toggle_twoColumns_and_selectGroup() {
        let viewController = UIViewController()
        let sheet: PMActionSheet
        let toggleItems = [
            PMActionSheetItem(style: .toggle("Toggle row true", true), handler: nil),
            PMActionSheetItem(style: .toggle("Toggle row false", false), handler: nil)
        ]
        let toggleGroup = PMActionSheetItemGroup(items: toggleItems, style: .toggle)

        let twoColItems = [
            PMActionSheetItem(style: .twoColumn("Item1", "Item2"), handler: nil),
            PMActionSheetItem(style: .twoColumn("Item3", "lisjflkdjfslkfjlkefjwifldsjvkxn,mvniwjrfwiejfwl"), handler: nil)
        ]
        let twoColGroup = PMActionSheetItemGroup(items: twoColItems, style: .toggle)

        let selectItems = [
            PMActionSheetItem(style: .text("Select 1"), markType: .checkMark, handler: nil),
            PMActionSheetItem(style: .text("Select 2"), markType: .dash, handler: nil)
        ]
        let selectGroup = PMActionSheetItemGroup(title: "Select", items: selectItems, style: .singleSelection)

        sheet = PMActionSheet(headerView: nil, itemGroups: [toggleGroup, twoColGroup, selectGroup], enableBGTap: true, delegate: nil)
        sheet.presentAt(viewController, animated: true)
        checkSnapshots(controller: viewController, perceptualPrecision: 0.98)
    }

    func testSheetAssemble_with_header_and_gridGroup() {
        let viewController = UIViewController()
        let sheet: PMActionSheet
        let header = PMActionSheetHeaderView(title: "Title", subtitle: "subTitle", leftItem: .right(IconProvider.crossSmall), rightItem: .left("Done"), leftItemHandler: nil, rightItemHandler: nil)
        let gridItems = [
            PMActionSheetItem(style: .grid(IconProvider.bug, "Item1"), handler: nil),
            PMActionSheetItem(style: .grid(IconProvider.star, "Item2"), handler: nil),
            PMActionSheetItem(style: .grid(IconProvider.fire, "Item3"), handler: nil)
        ]
        let gridGroup = PMActionSheetItemGroup(title: "Grid", items: gridItems, hasSeparator: false, style: .grid(2))
        sheet = PMActionSheet(headerView: header, itemGroups: [gridGroup], enableBGTap: true, delegate: nil)
        sheet.presentAt(viewController, animated: true)
        checkSnapshots(controller: viewController, perceptualPrecision: 0.98)
    }
}

#endif
