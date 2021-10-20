//
//  CreateAddressViewController.swift
//  ProtonCore-Login - Created on 27.11.2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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
import ProtonCore_Log
import ProtonCore_Foundations
import ProtonCore_UIFoundations

protocol CreateAddressViewControllerDelegate: NavigationDelegate {
    func userDidFinishCreatingAddress(endLoading: @escaping () -> Void, data: LoginData)
    func userDidRequestTermsAndConditions()
}

final class CreateAddressViewController: UIViewController, AccessibleView {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: TitleLabel!
    @IBOutlet private weak var subtitleLabel: SubtitleLabel!
    @IBOutlet private weak var createButton: ProtonButton!
    @IBOutlet private weak var recoveryTitleLabel: UILabel!
    @IBOutlet private weak var recoveryInfoLabel: UILabel!
    @IBOutlet private weak var termsLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!

    // MARK: - Properties

    weak var delegate: CreateAddressViewControllerDelegate?
    var viewModel: CreateAddressViewModel!

    private let navigationBarAdjuster = NavigationBarAdjustingScrollViewDelegate()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
        generateAccessibilityIdentifiers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarAdjuster.setUp(for: scrollView, parent: parent)
        scrollView.adjust(forKeyboardVisibilityNotification: nil)
    }

    private func setupUI() {
        view.backgroundColor = ColorProvider.BackgroundNorm
        titleLabel.text = String(format: CoreString._ls_create_address_available, viewModel.address)
        subtitleLabel.text = CoreString._ls_create_address_info
        recoveryTitleLabel.text = CoreString._ls_create_address_recovery_title
        recoveryInfoLabel.text = viewModel.recoveryEmail
        createButton.setTitle(CoreString._ls_create_address_button_title, for: .normal)

        termsLabel.textColor = ColorProvider.TextWeak
        let termsText = NSMutableAttributedString(string: CoreString._ls_create_address_terms_full)
        let foregroundColor: UIColor = ColorProvider.InteractionNorm
        if termsText.setAttributes(textToFind: CoreString._ls_create_address_terms_link, attributes: [
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.underlineColor: UIColor.clear
        ]) {
            termsLabel.attributedText = termsText
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped))
            termsLabel.addGestureRecognizer(recognizer)
            termsLabel.isUserInteractionEnabled = true
        } else {
            PMLog.error("Cannot set Terms and Conditions as link. Wrong translation?")
        }

        recoveryTitleLabel.textColor = ColorProvider.TextNorm
        recoveryInfoLabel.textColor = ColorProvider.TextWeak

        setUpBackArrow(action: #selector(CreateAddressViewController.goBack(_:)))
    }

    private func setupBinding() {
        viewModel.isLoading.bind { [weak self] isLoading in
            self?.view.isUserInteractionEnabled = !isLoading
            self?.createButton.isSelected = isLoading
        }
        viewModel.error.bind { [weak self] message in
            self?.showError(message: message)
        }
        viewModel.finished.bind { [weak self] data in
            self?.delegate?.userDidFinishCreatingAddress(endLoading: { [weak self] in self?.viewModel.isLoading.value = false }, data: data)
        }
    }

    private func showError(message: String) {
        showBanner(message: message, position: PMBannerPosition.top)
    }

    // MARK: - Actions

    @IBAction private func createPressed(_ sender: Any) {
        PMBanner.dismissAll(on: self)
        viewModel.finish()
    }

    @objc private func goBack(_ sender: Any) {
        delegate?.userDidRequestGoBack()
    }

    @objc private func termsLabelTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.userDidRequestTermsAndConditions()
    }
}
