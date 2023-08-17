//
//  SettingsRandomViewController.swift
//  SampleApp
//
//  Created by Aaron Huánuco on 25/11/20.
//

import UIKit
import ProtonCoreSettings

final class SettingsRandomViewController: UIViewController, PMContainerReloading {
    weak var containerReloader: PMContainerReloader?
    private var height: NSLayoutConstraint?
    let stack = UIStackView()
    let button = UIButton(ButtonStyles.main)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        view.translatesAutoresizingMaskIntoConstraints = false
        button.setSizeContraint(height: 44, width: 180)
        view.addSubview(stack)
        stack.centerInSuperview()

        button.setTitle("Change Height", for: .normal)
        button.addTarget(self, action: #selector(toggleValue), for: .touchUpInside)
        stack.addArrangedSubview(button)

        let (height, _) = view.setContraintsWithConstraints(height: 120, width: nil)
        self.height = height
    }

    @objc private func toggleValue() {
        self.height?.constant = self.height?.constant == 120 ? 50 : 120
        containerReloader?.reload()
    }
}
