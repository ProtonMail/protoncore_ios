//
//  FeatureSwitchViewController.swift
//  ExampleApp-V5 - Created on 09/22/22.
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

import UIKit
import ProtonCore_FeatureSwitch

/// #1 define you feature switch  -- first version.
extension Feature {
    // default featue is false.
    public static var myFirstFeature = Feature.init(name: "myFirstFeature")
    // set a feature to true.
    public static var mySecondFeature = Feature.init(name: "myThirdFeature", isEnable: true)
}

/// feature switch dev example file
class FeatureSwitchViewController: UIViewController {

    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var thirdSwitch: UISwitch!
    @IBOutlet weak var secondSwitch: UISwitch!
    @IBOutlet weak var firstSwitch: UISwitch!
    
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var debugTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// #2 think this is the appDelegate function you can start FeatureFactory and fetch configs.
        FeatureFactory.shared.setup(env: "") // this env will change to the real environment later.
        ///  load from UserShared.
        /// FeatureFactory.shared.fetchFeature(local: FeatureProvider)
        /// FeatureFactory.shared.fetchFeature(remote: FeatureProvider)
        
        /// #3 you are all set now to use the myFirstFeature,mySecondFeature, myThirdFeature in your logic
    
        firstSwitch.isHidden = true
        secondSwitch.isHidden = true
        thirdSwitch.isHidden = true
        
        firstButton.isHidden = true
        secondButton.isHidden = true
        thirdButton.isHidden = true
        
        let checkOne = FeatureFactory.shared.isEnabled(.myFirstFeature)
        let checkTwo = FeatureFactory.shared.isEnabled(.mySecondFeature)
        
        debugTextView.text = """
        firstSwitch is \(checkOne ? "on" : "off").
        secondSwitch is \(checkTwo ? "on" : "off").
        """
        // FeatureFactory.shared.reload()
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if sender == firstSwitch {
            FeatureFactory.shared.setEnabled(&.myFirstFeature, isEnable: sender.isOn)
        } else if sender == secondSwitch {
            FeatureFactory.shared.setEnabled(&.mySecondFeature, isEnable: sender.isOn)
        }
        
        let checkOne = FeatureFactory.shared.isEnabled(.myFirstFeature)
        let checkTwo = FeatureFactory.shared.isEnabled(.mySecondFeature)
        
        firstButton.isHidden = !checkOne
        secondButton.isHidden = !checkTwo
        thirdButton.isHidden = true
        
        debugTextView.text = """
        firstSwitch is \(checkOne ? "on" : "off") by default.
        secondSwitch is \(checkTwo ? "on" : "off") by default. can change only when defined DEBUG_CORE_INTERNAL
        """
    }
    
}
