//
//  UIFoundationsSegmentedControlViewController.swift
//  ExampleApp - Created on 12.03.21.
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

import UIKit
import ProtonCoreUIFoundations

class UIFoundationsSegmentedControlViewController: UIFoundationsAppearanceStyleViewController {

    @IBOutlet weak var segmentedControl: PMSegmentedControl!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: "UIFoundationsSegmentedControlViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Segmented control"

        view.backgroundColor = ColorProvider.BackgroundNorm
        setupSegmnentedControl()
    }

    func setupSegmnentedControl() {
        segmentedControl.setImage(image: IconProvider.userCircle, withText: "Second", forSegmentAt: 1)
    }
}
