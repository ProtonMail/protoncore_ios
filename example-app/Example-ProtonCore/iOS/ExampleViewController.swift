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

import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Foundations
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_UIFoundations
import Sentry

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
        case 2:
            updateDohStatus(to: .forceAlternativeRouting)
            struct GenericRequest: Request { var path: String; var isAuth: Bool = false }
            let path = "/users/available?Name=oneverystrangeusername"
            let request = GenericRequest(path: path)
            let doh: DoH & ServerConfig = clientApp == .vpn ? ProdDoHVPN.default : ProdDoHMail.default
            var testApi: PMAPIService? = PMAPIService(doh: doh, sessionUID: "dummy request for enforcing alternative routing")
            testApi?.exec(route: request) { _ in
                PMLog.debug("Performed a dummy request to enforce alternative routing")
                testApi = nil
            }
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

// Crash reporting testing
extension ExampleViewController {

    @IBAction func crashWithFatalError(_ sender: Any) {
        let message = "Crashed with fatalError on \(Date()) in \(#function) in \(#file)"
        SentryLog.log(withMessage: message, andLevel: .error)
        fatalError("ExampleViewController.crashWithFatalError")
    }
    
    @IBAction func crashWithAssertion(_ sender: Any) {
        let message = "Crashed with assertion on \(Date()) in \(#function) in \(#file)"
        SentryLog.log(withMessage: message, andLevel: .error)
        assertionFailure("ExampleViewController.crashWithAssertion")
    }
    
    @IBAction func crashWithForceUnwrap(_ sender: Any) {
        let message = "Crashed with force unwrap on \(Date()) in \(#function) in \(#file)"
        SentryLog.log(withMessage: message, andLevel: .error)
        let kaboom: Int? = nil
        _ = kaboom!
    }
    
    @IBAction func crashWithSentryCrash(_ sender: Any) {
        let message = "Crashed with SentrySDK.crash on \(Date()) in \(#function) in \(#file)"
        SentryLog.log(withMessage: message, andLevel: .error)
        SentrySDK.crash()
    }
    
    @IBAction func noCrashJustEvent(_ sender: Any) {
        let message = "Didn't crash, just sent a test event on \(Date()) in \(#function) in \(#file)"
        let event = Event(level: .error)
        event.message = message
        SentrySDK.capture(event: event)
    }
}
