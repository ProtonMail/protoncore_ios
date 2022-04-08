//
//  ButtonsViewController.swift
//  ExampleApp - Created on 25.05.20.
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
import ProtonCore_UIFoundations

class UIFoundationsButtonsViewController: UIFoundationsAppearanceStyleViewController {

    @IBOutlet weak var buttonSolid: ProtonButton!
    @IBOutlet weak var buttonSolidDisabled: ProtonButton!
    @IBOutlet weak var buttonOutlined: ProtonButton!
    @IBOutlet weak var buttonOutlinedDisabled: ProtonButton!
    @IBOutlet weak var buttonText: ProtonButton!
    @IBOutlet weak var buttonTextDisabled: ProtonButton!
    @IBOutlet weak var buttonTextFieldChevron: ProtonButton!
    @IBOutlet weak var buttonTextFieldChevronDisabled: ProtonButton!
    @IBOutlet weak var buttonChevron: ProtonButton!
    
    var brandButton: UIBarButtonItem?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: "UIFoundationsButtonsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buttons"
        
        ColorProvider.brand = .proton
        
        brandButton = UIBarButtonItem(title: "VPN", style: .plain, target: self, action: #selector(brandAction))
        guard let darkLightButton = navigationItem.rightBarButtonItem else { return }
        navigationItem.rightBarButtonItems = [darkLightButton, brandButton!]

        view.backgroundColor = ColorProvider.BackgroundNorm
        setupButtons()
    }
    
    func setupButtons() {
        buttonSolid.setMode(mode: .solid)
        buttonSolid.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        buttonSolidDisabled.setMode(mode: .solid)
        buttonSolidDisabled.isEnabled = false
        
        buttonOutlined.setMode(mode: .outlined)
        buttonOutlined.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        buttonOutlinedDisabled.setMode(mode: .outlined)
        buttonOutlinedDisabled.isEnabled = false
        
        buttonText.setMode(mode: .text)
        buttonText.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        buttonTextDisabled.setMode(mode: .text)
        buttonTextDisabled.isEnabled = false
        
        buttonTextFieldChevron.setMode(mode: .image(type: .textWithChevron))
        buttonTextFieldChevron.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        buttonTextFieldChevronDisabled.setMode(mode: .image(type: .textWithChevron))
        buttonTextFieldChevronDisabled.isEnabled = false
        
        buttonChevron.setMode(mode: .image(type: .chevron))
        buttonChevron.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(sender: ProtonButton!) {
        sender.isSelected = true
        sender.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sender.isSelected = false
            sender.isUserInteractionEnabled = true
        }
    }
    
    @objc func brandAction(sender: UIBarButtonItem!) {
        switch ColorProvider.brand {
        case .proton:
            ColorProvider.brand = .vpn
            brandButton?.title = "Proton"
            
        case .vpn:
            ColorProvider.brand = .proton
            brandButton?.title = "VPN"
        }
        setupButtons()
    }
}

