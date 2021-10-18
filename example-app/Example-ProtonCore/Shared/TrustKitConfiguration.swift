//
//  TrustKitConfiguration.swift
//  ExampleMailApp - Created on 26/08/2019.
//
//
//  Copyright (c) 2019 Proton Technologies AG
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
import TrustKit
import ProtonCore_Services
import ProtonCore_ObfuscatedConstants

protocol TrustKitUIDelegate: AnyObject {
    func onTrustKitValidationError(_ alert: UIAlertController)
}

final class TrustKitWrapper {
    typealias Delegate = TrustKitUIDelegate
    typealias Configuration = [String: Any]
    
    static private weak var delegate: Delegate?
    static private(set) var current: TrustKit?

    static func start(delegate: Delegate, customConfiguration: Configuration? = nil) {

        let config = ObfuscatedConstants.samplePinningConfiguration(hardfail: true)
        
        let instance: TrustKit = {
            #if !APP_EXTENSION
            return TrustKit(configuration: config)
            #else
            return TrustKit(configuration: config, sharedContainerIdentifier: Constants.App.APP_GROUP)
            #endif
        }()
        
        instance.pinningValidatorCallback = { validatorResult, hostName, policy in
            
            // THIS CODE CAME FROM EXAMPLE-NETWORKING
            
//            if validatorResult.evaluationResult != .success,
//                validatorResult.finalTrustDecision != .shouldAllowConnection
//            {
//                if hostName.contains(".compute.amazonaws.com") {
//                    let alert = UIAlertController(title: LocalString._cert_validation_failed_title, message: LocalString._cert_validation_hardfailed_message, preferredStyle: .alert)
//                    alert.addAction(.init(title: LocalString._general_cancel_button, style: .cancel, handler: { _ in /* nothing */ }))
//                    self.delegate?.onTrustKitValidationError(alert)
//                } else {
//                    let alert = UIAlertController(title: LocalString._cert_validation_failed_title, message: LocalString._cert_validation_failed_message, preferredStyle: .alert)
//                    alert.addAction(.init(title: LocalString._cert_validation_failed_continue, style: .destructive, handler: { _ in
//                        self.start(delegate: delegate, customConfiguration: self.configuration(hardfail: false))
//                    }))
//                    alert.addAction(.init(title: LocalString._general_cancel_button, style: .cancel, handler: { _ in /* nothing */ }))
//                    self.delegate?.onTrustKitValidationError(alert)
//                }
//            }
        }
        
        self.delegate = delegate
        self.current = instance
    }
}
