//
//  SnapshotTestCase.swift
//  ProtonCore-TestingToolkit - Created on 14/10/2022.
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

import XCTest
import SnapshotTesting

open class SnapshotTestCase: XCTestCase {
    let reRecordEverything = false

    @available(iOS 13, *)
    public func checkSnapshots(controller: UIViewController,
                               size: CGSize = CGSize(width: 750, height: 1334),
                               traits: UITraitCollection = .iPhoneSe(.portrait),
                               name: String = #function,
                               record: Bool = false,
                               file: StaticString = #filePath,
                               line: UInt = #line) {

        [UIUserInterfaceStyle.light, .dark].forEach {

        assertSnapshot(matching: controller,
                       as: .image(on: .iPhoneSe,
                                  traits: .init(userInterfaceStyle: $0)),
                       named: "\($0)",
                       record: reRecordEverything || record,
                       file: file,
                       testName: "\(name)",
                       line: line)
        }
    }
}

@available(iOS 12.0, *)
extension UIUserInterfaceStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unspecified: return "unspecified"
        case .light: return "light"
        case .dark: return "dark"
        @unknown default:
            fatalError()
        }
    }
}
