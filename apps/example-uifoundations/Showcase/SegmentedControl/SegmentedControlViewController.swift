//
//  CountryPickerViewController.swift
//  ProtonMail - Created on 12.03.21.
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import ProtonCore_UIFoundations

class SegmentedControlViewController: AppearanceStyleViewController {

    @IBOutlet weak var segmentedControl: PMSegmentedControl!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: "SegmentedControlViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Segmented control"

        view.backgroundColor = UIColorManager.BackgroundNorm
        setupSegmnentedControl()
    }
    
    func setupSegmnentedControl() {
        if let image = UIImage(named: "ForgotUsernameIcon") {
            segmentedControl.setImage(image: image, withText: "Second", forSegmentAt: 1)
        }
    }
}
