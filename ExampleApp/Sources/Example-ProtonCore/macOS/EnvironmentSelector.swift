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
import ProtonCoreDoh
import ProtonCoreObfuscatedConstants
import ProtonCoreEnvironment

protocol EnvironmentSelectorDelegate: AnyObject {
    func environmentChanged(to env: Environment)
}

final class EnvironmentSelector: NSView {

    weak var delegate: EnvironmentSelectorDelegate?

    @IBOutlet private var selector: NSSegmentedControl!
    @IBOutlet private var customDomainStackView: NSStackView!
    @IBOutlet private var customDomain: NSTextField!

    @IBAction private func environmentChanged(_ sender: Any!) {
        customDomainStackView.isHidden = selector.selectedSegment != 3
        delegate?.environmentChanged(to: currentEnvironment)
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

    var currentEnvironment: Environment {
        let env: Environment
        switch selector.selectedSegment {
        case 0:
            switch clientApp {
            case .mail:
                env = .mailProd
            case .vpn:
                env = .vpnProd
            case .drive:
                env = .driveProd
            case .calendar:
                env = .calendarProd
            case .pass:
                env = .passProd
            case .other:
                env = .mailProd
            }
        case 1: env = .black
        case 2: env = .blackPayment
        case 3:
            let customDomain = customDomain.stringValue
            env = .custom(customDomain)
        default: fatalError("Invalid index")
        }
        return env
    }

    func switchToCustomDomain(value: String) {
        customDomain.stringValue = value
        selector.setSelected(true, forSegment: 3)
        environmentChanged(self)
    }
}
