//
//  ButtonsViewController.swift
//  ProtonMail - Created on 25.05.20.
//
//  Copyright (c) 2020 Proton Technologies AG
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
//

import UIKit
import ProtonCore_UIFoundations

class ButtonsViewController: AppearanceStyleViewController {

    @IBOutlet weak var buttonSolid: ProtonButton!
    @IBOutlet weak var buttonSolidDisabled: ProtonButton!
    @IBOutlet weak var buttonOutlined: ProtonButton!
    @IBOutlet weak var buttonOutlinedDisabled: ProtonButton!
    @IBOutlet weak var buttonText: ProtonButton!
    @IBOutlet weak var buttonTextDisabled: ProtonButton!
    
    var brandButton: UIBarButtonItem?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: "ButtonsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buttons"
        
        UIColorManager.brand = .proton
        
        brandButton = UIBarButtonItem(title: "VPN", style: .plain, target: self, action: #selector(brandAction))
        guard let darkLightButton = navigationItem.rightBarButtonItem else { return }
        navigationItem.rightBarButtonItems = [darkLightButton, brandButton!]

        view.backgroundColor = UIColorManager.BackgroundNorm
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
    }
    
    @objc func buttonAction(sender: ProtonButton!) {
        sender.isSelected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sender.isSelected = false
        }
    }
    
    @objc func brandAction(sender: UIBarButtonItem!) {
        switch UIColorManager.brand {
        case .proton:
            UIColorManager.brand = .vpn
            brandButton?.title = "Proton"
            
        case .vpn:
            UIColorManager.brand = .proton
            brandButton?.title = "VPN"
        }
        setupButtons()
    }
}

