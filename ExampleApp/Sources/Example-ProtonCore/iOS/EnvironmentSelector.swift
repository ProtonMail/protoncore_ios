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
import ProtonCoreDoh
import ProtonCoreObfuscatedConstants
import ProtonCoreEnvironment

protocol EnvironmentSelectorDelegate: AnyObject {
    func environmentChanged(to env: Environment)
}

final class EnvironmentSelector: UIView {

    weak var delegate: EnvironmentSelectorDelegate?

    @IBOutlet private var selector: UISegmentedControl!
    @IBOutlet private var customDomain: UITextField!

    private static let paymentsIndex = 2
    private static let customDomainIndex = 4

    @IBAction private func environmentChanged(_ sender: Any!) {
        customDomain.isHidden = selector.selectedSegmentIndex != EnvironmentSelector.customDomainIndex
        delegate?.environmentChanged(to: currentEnvironment)
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
    }

    var currentEnvironment: Environment {
        let env: Environment
        switch selector.selectedSegmentIndex {
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
        case EnvironmentSelector.paymentsIndex: env = .blackPayment
        case 3: env = .custom(ObfuscatedConstants.fosseyBlackSignupDomain)
        case EnvironmentSelector.customDomainIndex:
            guard let customDomain = customDomain.text else {
                fatalError("Misconfiguration, no value in custom domain")
            }
            env = .custom(customDomain)
        default: fatalError("Invalid index")
        }
        return env
    }

    func switchToCustomDomain(value: String) {
        customDomain.text = value
        selector.selectedSegmentIndex = EnvironmentSelector.customDomainIndex
        environmentChanged(self)
    }
}
