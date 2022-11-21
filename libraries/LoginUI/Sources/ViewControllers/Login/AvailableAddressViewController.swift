//
//  AvailableAddressViewController.swift
//  ProtonCore-Login - Created on 15.11.2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import UIKit
import ProtonCore_CoreTranslation
import ProtonCore_Foundations
import ProtonCore_UIFoundations
import ProtonCore_Login

protocol AvailableAddressViewControllerDelegate: AnyObject {
    func availableAddressDidGoBack()
    func availableAddressDidPressClaimButton(createAddressData: CreateAddressData)
    func availableAddressDidPressOwnAddressButton(createAddressData: CreateAddressData)
}

final class AvailableAddressViewController: UIViewController, AccessibleView {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: TitleLabel!
    @IBOutlet private weak var subtitleLabel: SubtitleLabel!
    @IBOutlet private weak var addressTextField: PMTextField!
    @IBOutlet private weak var claimButton: ProtonButton!
    @IBOutlet private weak var ownAddressButton: ProtonButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var brandImage: UIImageView!

    // MARK: - Properties

    weak var delegate: AvailableAddressViewControllerDelegate?
    var createAddressData: CreateAddressData!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { darkModeAwarePreferredStatusBarStyle() }

    private let navigationBarAdjuster = NavigationBarAdjustingScrollViewDelegate()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        generateAccessibilityIdentifiers()
    }

    private func setupUI() {
        if let image = LoginUIImages.brandLogo {
            brandImage.image = image
            brandImage.isHidden = false
        }
        view.backgroundColor = ColorProvider.BackgroundNorm
        titleLabel.text = CoreString._ls_available_addresss_creen_title
        titleLabel.textColor = ColorProvider.TextNorm
        subtitleLabel.text = CoreString._ls_available_addresss_creen_info
        subtitleLabel.textColor = ColorProvider.TextWeak
        addressTextField.title = ""
        claimButton.setTitle(CoreString._ls_available_addresss_button_claim, for: .normal)
        ownAddressButton.setTitle(CoreString._ls_available_addresss_button_own_address, for: .normal)
        ownAddressButton.setMode(mode: .text)
        
        addressTextField.isEnabled = false
        addressTextField.isUserInteractionEnabled = false
        addressTextField.textAlignment = .center
        
        addressTextField.value = createAddressData.email
        addressTextField.textContentType = .username
        addressTextField.autocapitalizationType = .none
        addressTextField.autocorrectionType = .no

        setUpBackArrow(action: #selector(AvailableAddressViewController.goBack(_:)))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarAdjuster.setUp(for: scrollView, parent: parent)
        scrollView.adjust(forKeyboardVisibilityNotification: nil)
    }

    // MARK: - Actions

    @IBAction private func claimButtonPressed(_ sender: Any) {
        delegate?.availableAddressDidPressClaimButton(createAddressData: createAddressData)
    }

    @IBAction private func ownAddressButtonPressed(_ sender: Any) {
        delegate?.availableAddressDidPressOwnAddressButton(createAddressData: createAddressData)
    }

    @objc private func goBack(_ sender: Any) {
        delegate?.availableAddressDidGoBack()
    }
}
