//
//  EnvironmentSelector.swift
//  ExampleApp - Created on 22/11/2021.
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

import AppKit
import ProtonCore_Doh
import ProtonCore_ObfuscatedConstants

protocol EnvironmentSelectorDelegate: AnyObject {
    func environmentChanged(to doH: DoH & ServerConfig)
}

final class EnvironmentSelector: NSView {
    
    weak var delegate: EnvironmentSelectorDelegate?
    
    @IBOutlet private var selector: NSSegmentedControl!
    @IBOutlet private var customDomainStackView: NSStackView!
    @IBOutlet private var customDomain: NSTextField!
    
    @IBAction private func environmentChanged(_ sender: Any!) {
        customDomainStackView.isHidden = selector.selectedSegment != 3
        delegate?.environmentChanged(to: currentDoh)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        var objects: NSArray?
        guard Bundle.main.loadNibNamed(
            "EnvironmentSelector", owner: self, topLevelObjects: &objects
        ), let view = objects?.first(where: { $0 is NSStackView }) as? NSStackView else {
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
    }
    
    var currentDoh: DoH & ServerConfig {
        let doh: DoH & ServerConfig
        switch selector.selectedSegment {
        case 0: doh = ProdDoHMail.default
        case 1: doh = BlackDoHMail.default
        case 2: doh = PaymentsBlackDevDoHMail.default
        case 3:
            let customDomain = customDomain.stringValue
            doh = CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
            doh.status = dohStatus
        default: fatalError("Invalid index")
        }
        return doh
    }
}
