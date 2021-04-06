//
//  ViewController.swift
//  ExampleMailApp - Created on 04/12/2020.
//
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

#if canImport(UIKit)
import UIKit
import ProtonCore_Doh
import ProtonCore_Services
import ProtonCore_Payments

class ViewController: UIViewController {
    @IBOutlet weak var envSegmentedControl: UISegmentedControl!

    private var testApi = PMAPIService(doh: BlackDoHMail.default, sessionUID: "testSessionUID")
    
    @IBAction func onEnvSegmentedControlTap(_ sender: UISegmentedControl) {
        testApi = PMAPIService(doh: currentEnv, sessionUID: "testSessionUID")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let plans: [AccountPlan] = [.mailPlus]
        if let viewController = segue.destination as? NewUserSubscriptionVC, segue.identifier == "NewUserSegue" {
            viewController.currentEnv = currentEnv
            viewController.accountPlans = plans
        } else if let viewController = segue.destination as? RegistrationSubscriptionVC, segue.identifier == "RegistrationSegue" {
            viewController.currentEnv = currentEnv
            viewController.accountPlans = plans
        } else if let viewController = segue.destination as? NewUserSubscriptionUIVC, segue.identifier == "NewUserUISegue" {
            viewController.currentEnv = currentEnv
            viewController.planTypes = .mail
        }
    }

    private var currentEnv: DoH & ServerConfig {
        switch envSegmentedControl.selectedSegmentIndex {
        case 0: return BlackDoHMail.default
        case 1: return OhmBlackDoHMail.default
        case 2: return ProdDoHMail.default
        default: return BlackDoHMail.default
        }
    }

}

#endif
