//
//  ExampleViewController.swift
//  CoreExample - Created on 06/10/2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import UIKit

import ProtonCore_Foundations
import ProtonCore_Services
import ProtonCore_UIFoundations

final class ExampleViewController: UIViewController, AccessibleView {
    
    @IBOutlet var targetLabel: UILabel!
    
    @IBOutlet var accountDeletionButton: UIButton!
    @IBOutlet var accountSwitcherButton: UIButton!
    @IBOutlet var featuresButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var networkingButton: UIButton!
    @IBOutlet var paymentsButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var uiFoundationButton: UIButton!
    @IBOutlet var alternativeRoutingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var trustKitSegmentedControl: UISegmentedControl!
    @IBOutlet var scenarioPicker: UIPickerView!
    @IBOutlet var scenarioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ColorProvider.brand = clientApp == .vpn ? .vpn : .proton
        if #available(iOS 13.0, *) {
            if clientApp == .vpn {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            }
        }

        TrustKitWrapper.start(delegate: self)
        PMAPIService.noTrustKit = true
        PMAPIService.trustKit = TrustKitWrapper.current
        
        targetLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        generateAccessibilityIdentifiers()
    }
    
    @IBAction private func alternativeRoutingSetupChanged(_ sender: Any?) {
        switch alternativeRoutingSegmentedControl.selectedSegmentIndex {
        case 0: updateDohStatus(to: .off)
        case 1: updateDohStatus(to: .on)
        default: return
        }
    }
    
    @IBAction func trustKitSetupChanged(_ sender: UISegmentedControl) {
        switch trustKitSegmentedControl.selectedSegmentIndex {
        case 0: PMAPIService.noTrustKit = true
        case 1: PMAPIService.noTrustKit = false
        default: return
        }
    }
}

extension ExampleViewController: TrustKitUIDelegate {
    func onTrustKitValidationError(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}
