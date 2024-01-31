//
//  AlertBoxCellSnapshotTests.swift
//  ProtonCore-PaymentsUI-Tests - Created on 25.01.24.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import UIKit
import XCTest
import ProtonCoreDataModel
import ProtonCoreFeatureFlags
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitUnitTestsFeatureFlag
#else
import ProtonCoreTestingToolkit
#endif
import SnapshotTesting
import ProtonCoreUIFoundations
@testable import ProtonCorePaymentsUI

@available(iOS 13, *)
final class AlertBoxCellSnapshotTests: XCTestCase {
    let perceptualPrecision: Float = 0.98
    let traits: UITraitCollection = .iPhoneSe(.portrait)
    let maxSpace: Int64 = 2000
    let usedSpaceSuccess: Int64 = 100
    let usedSpaceWarning: Int64 = 1100

    func testAlertBoxCell() {
        let view = AlertBoxCell(frame: .zero)
        view.configure(with: AlertBoxViewModel())
        snapshot(view: view.contentView)
    }

    private func snapshot(view: UIView) {
        let imageSize = CGSize(width: 320, height: 250)
        let viewController = WrapperViewController(existingView: view)
        assertSnapshot(matching: viewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .light)),
                                  perceptualPrecision: perceptualPrecision,
                                  size: imageSize),
                       record: false,
                       file: #filePath,
                       testName: "\(name)-Light",
                       line: #line)

        assertSnapshot(matching: viewController,
                       as: .image(on: ViewImageConfig(safeArea: .zero, size: imageSize, traits: traits.updated(to: .dark)),
                                  perceptualPrecision: perceptualPrecision,
                                  size: imageSize),
                       record: false,
                       file: #filePath,
                       testName: "\(name)-dark",
                       line: #line)
    }
}

class WrapperViewController: UIViewController {
    var customView: UIView!

    init(existingView: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.customView = existingView
        self.view.backgroundColor = .systemBackground
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(customView)

        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

#endif
