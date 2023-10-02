//
//  SubscriptionTypePickerViewController.swift
//  ExampleAppSPM - Created on 28/9/23.
//
//  Copyright (c) 2023 Proton Technologies AG
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

import Foundation
import UIKit
import ProtonCoreSettings

public enum SubscriptionType: Int {
    case none = 0
    case iap = 1
    case external = 2
}

protocol SubscriptionTypePickerViewControllerDelegate: AnyObject {
    func typeDidChange(to: SubscriptionType)
}

final class SubscriptionTypePickerViewController: UIViewController, PMContainerReloading {

    weak var containerReloader: PMContainerReloader?
    weak var delegate: SubscriptionTypePickerViewControllerDelegate?

    let label = UILabel()
    let typeSelector = UISegmentedControl(items: ["None", "IAP", "External"])
    let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Subscription type"
        [label, typeSelector]
            .forEach {
                stack.addArrangedSubview($0)
            }

        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        typeSelector.selectedSegmentIndex = 0
        typeSelector.addTarget(self, action: #selector(typeChanged), for: .valueChanged)

    }

    @objc
    func typeChanged() {
        let type = SubscriptionType(rawValue: typeSelector.selectedSegmentIndex) ?? .none

        delegate?.typeDidChange(to: type)
    }
}
