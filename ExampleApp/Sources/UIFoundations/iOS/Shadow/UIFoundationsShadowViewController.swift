//
//  UIFoundationsShadowViewController.swift
//  ExampleApp - Created on 2021/11/29.
//  
//  Copyright (c) 2021 Proton Technologies AG
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

import UIKit
import ProtonCoreUIFoundations

class UIFoundationsShadowViewController: UIFoundationsAppearanceStyleViewController {

    @IBOutlet var shadowNorm: UILabel!
    @IBOutlet var shadowRaised: UILabel!
    @IBOutlet var shadowLifted: UILabel!

    @IBOutlet var shadowNormBox: UIView!
    @IBOutlet var shadowRaisedBox: UIView!
    @IBOutlet var shadowLiftedBox: UIView!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        applyShadows()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadows()
    }
    
    func applyShadows() {
        self.shadowNormBox.apply(shadows: .shadowNorm)
        self.shadowRaisedBox.apply(shadows: .shadowRaised)
        self.shadowLiftedBox.apply(shadows: .shadowLifted)
    }
}
