//
//  EnvironmentSelector.swift
//  ExampleApp - Created on 11/12/2021.
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
import ProtonCore_Doh
import ProtonCore_ObfuscatedConstants
import Sentry

protocol EnvironmentSelectorDelegate: AnyObject {
    func environmentChanged(to doH: DoH & ServerConfig)
}

final class EnvironmentSelector: UIView {
    
    weak var delegate: EnvironmentSelectorDelegate?
    
    @IBOutlet private var selector: UISegmentedControl!
    @IBOutlet private var customDomain: UITextField!
    
    private static let paymentsIndex = 2
    private static let customDomainIndex = 4
    
    @IBAction private func environmentChanged(_ sender: Any!) {
        customDomain.isHidden = selector.selectedSegmentIndex != EnvironmentSelector.customDomainIndex
        delegate?.environmentChanged(to: currentDoh)
        ensureEnvironmentSwitchWillBeSentAlongsideCrashReport()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        guard let objects = Bundle.main.loadNibNamed(
            "EnvironmentSelector", owner: self, options: nil
        ), let view = objects.first(where: { $0 is UIStackView }) as? UIStackView else {
            assertionFailure("EnvironmentSelector decoding failed")
            return nil
        }
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        ensureEnvironmentSwitchWillBeSentAlongsideCrashReport()
    }
    
    private func ensureEnvironmentSwitchWillBeSentAlongsideCrashReport() {
        let breadcrumb = Breadcrumb(level: .debug, category: "environment")
        breadcrumb.message = currentDoh.getCurrentlyUsedHostUrl()
        SentrySDK.addBreadcrumb(crumb: breadcrumb)
    }
    
    var currentDoh: DoH & ServerConfig {
        let doh: DoH & ServerConfig
        switch selector.selectedSegmentIndex {
        case 0:
            if clientApp == .vpn {
                doh = ProdDoHVPN.default
            } else {
                doh = ProdDoHMail.default
            }
        case 1: doh = BlackDoH.default
        case EnvironmentSelector.paymentsIndex: doh = PaymentsBlackDoH.default
        case 3: doh = FosseyBlackDoH.default
        case EnvironmentSelector.customDomainIndex:
            guard let customDomain = customDomain.text else {
                fatalError("Misconfiguration, no value in custom domain")
            }
            doh = CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                humanVerificationV3Host: "https://verify.\(customDomain)",
                accountHost: "https://account.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
            doh.status = dohStatus
        default: fatalError("Invalid index")
        }
        return doh
    }
    
    func switchToCustomDomain(value: String) {
        customDomain.text = value
        selector.selectedSegmentIndex = EnvironmentSelector.customDomainIndex
        environmentChanged(self)
    }
}
