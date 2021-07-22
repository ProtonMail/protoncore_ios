//
//  SignupViewController.swift
//  ProtonCore-Login - Created on 11/03/2021.
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

#if canImport(UIKit)
import UIKit
import ProtonCore_CoreTranslation
import ProtonCore_Foundations
import ProtonCore_UIFoundations

protocol SignupViewControllerDelegate: AnyObject {
    func validatedName(name: String, signupAccountType: SignupAccountType, deviceToken: String)
    func signupCloseButtonPressed()
    func signinButtonPressed()
}

enum SignupAccountType {
    case `internal`
    case external
}

class SignupViewController: UIViewController, AccessibleView, Focusable {

    weak var delegate: SignupViewControllerDelegate?
    var viewModel: SignupViewModel!
    var signupAccountType: SignupAccountType!
    var showOtherAccountButton = true
    var showCloseButton = true
    var domain: String? { didSet { configureDomainSuffix() } }

    // MARK: Outlets

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var createAccountTitleLabel: UILabel! {
        didSet {
            createAccountTitleLabel.text = CoreString._su_main_view_title
            createAccountTitleLabel.textColor = UIColorManager.TextNorm
        }
    }
    @IBOutlet weak var createAccountDescriptionLabel: UILabel! {
        didSet {
            createAccountDescriptionLabel.text = CoreString._su_main_view_desc
            createAccountDescriptionLabel.textColor = UIColorManager.TextWeak
        }
    }
    @IBOutlet weak var nameTextField: PMTextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.autocorrectionType = .no
            nameTextField.autocapitalizationType = .none
            nameTextField.spellCheckingType = .no
        }
    }
    @IBOutlet weak var otherAccountButton: ProtonButton! {
        didSet {
            otherAccountButton.setMode(mode: .text)
        }
    }
    @IBOutlet weak var nextButton: ProtonButton! {
        didSet {
            nextButton.setTitle(CoreString._su_next_button, for: .normal)
            nextButton.isEnabled = false
        }
    }
    @IBOutlet weak var signinButton: ProtonButton! {
        didSet {
            signinButton.setMode(mode: .text)
            signinButton.setTitle(CoreString._su_signin_button, for: .normal)
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!

    var focusNoMore: Bool = false
    private let navigationBarAdjuster = NavigationBarAdjustingScrollViewDelegate()

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColorManager.BackgroundNorm
        setupGestures()
        setupNotifications()
        otherAccountButton.isHidden = !showOtherAccountButton
        focusOnce(view: nameTextField, delay: .milliseconds(750))
        setUpCloseButton(showCloseButton: showCloseButton, action: #selector(SignupViewController.onCloseButtonTap(_:)))
        requestDomain()
        configureAccountType()
        generateAccessibilityIdentifiers()
        try? nameTextField.setUpChallenge(viewModel.challenge, type: .username)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarAdjuster.setUp(for: scrollView, shouldAdjustNavigationBar: showCloseButton, parent: parent)
        scrollView.adjust(forKeyboardVisibilityNotification: nil)
    }

    // MARK: Actions

    @IBAction func onOtherAccountButtonTap(_ sender: ProtonButton) {
        cancelFocus()
        PMBanner.dismissAll(on: self)
        let isFirstResponder = nameTextField.isFirstResponder
        if isFirstResponder { _ = nameTextField.resignFirstResponder() }
        contentView.fadeOut(withDuration: 0.5) { [self] in
            self.contentView.fadeIn(withDuration: 0.5)
            self.nameTextField.isError = false
            if self.signupAccountType == .internal {
                signupAccountType = .external
            } else {
                signupAccountType = .internal
            }
            configureAccountType()
            if isFirstResponder { _ = nameTextField.becomeFirstResponder() }
        }
    }

    @IBAction func onNextButtonTap(_ sender: ProtonButton) {
        cancelFocus()
        PMBanner.dismissAll(on: self)
        nextButton.isSelected = true
        nameTextField.isError = false
        lockUI()
        viewModel.generateDeviceToken { result in
            switch result {
            case .success(let deviceToken):
                if self.signupAccountType == .internal {
                    self.checkUsername(userName: self.nameTextField.value, deviceToken: deviceToken)
                } else {
                    self.requestValidationToken(email: self.nameTextField.value, deviceToken: deviceToken)
                }
            case .failure(let error):
                self.unlockUI()
                self.nextButton.isSelected = false
                self.showError(error: error)
            }
        }
    }

    @IBAction func onSignInButtonTap(_ sender: ProtonButton) {
        cancelFocus()
        PMBanner.dismissAll(on: self)
        delegate?.signinButtonPressed()
    }

    @objc func onCloseButtonTap(_ sender: UIButton) {
        cancelFocus()
        delegate?.signupCloseButtonPressed()
    }

    // MARK: Private methods

    private func requestDomain() {
        viewModel.updateAvailableDomain { _ in
            self.domain = "@\(self.viewModel.signUpDomain)"
        }
    }

    private func configureAccountType() {
        nameTextField.value = ""
        if signupAccountType == .internal {
            nameTextField.title = CoreString._su_username_field_title
            nameTextField.keyboardType = .default
            nameTextField.textContentType = .username
        } else {
            nameTextField.title = CoreString._su_email_field_title
            nameTextField.keyboardType = .emailAddress
            nameTextField.textContentType = .emailAddress
        }
        let title = signupAccountType == .internal ? CoreString._su_email_address_button : CoreString._su_proton_address_button
        otherAccountButton.setTitle(title, for: .normal)
        configureDomainSuffix()
    }

    private func configureDomainSuffix() {
        if signupAccountType == .internal {
            nameTextField.suffix = domain ?? "@\(viewModel.signUpDomain)"
        } else {
            nameTextField.suffix = nil
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        if nameTextField.isFirstResponder {
            _ = nameTextField.resignFirstResponder()
        }
    }

    private func validateNextButton() {
        if signupAccountType == .internal {
        nextButton.isEnabled = viewModel.isUserNameValid(name: nameTextField.value)
        } else {
            nextButton.isEnabled = viewModel.isEmailValid(email: nameTextField.value)
        }
    }

    private func checkUsername(userName: String, deviceToken: String) {
        viewModel.checkUserName(username: userName) { result in
            self.nextButton.isSelected = false
            switch result {
            case .success:
                self.delegate?.validatedName(name: userName, signupAccountType: self.signupAccountType, deviceToken: deviceToken)
            case .failure(let error):
                self.unlockUI()
                switch error {
                case .generic(let message):
                    self.showError(message: message)
                case .notAvailable(let message):
                    self.nameTextField.isError = true
                    self.showError(message: message)
                }
            }
        }
    }

    private func showError(message: String) {
        showBanner(message: message, position: PMBannerPosition.top)
    }

    private func requestValidationToken(email: String, deviceToken: String) {
        viewModel?.requestValidationToken(email: email, completion: { result in
            self.nextButton.isSelected = false
            switch result {
            case .success:
                self.delegate?.validatedName(name: email, signupAccountType: self.signupAccountType, deviceToken: deviceToken)
            case .failure(let error):
                self.unlockUI()
                self.showError(error: error)
                self.nameTextField.isError = true
            }
        })
    }

    // MARK: - Keyboard

    private func setupNotifications() {
        NotificationCenter.default
            .setupKeyboardNotifications(target: self, show: #selector(keyboardWillShow), hide: #selector(keyboardWillHide))
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        adjust(scrollView, notification: notification, topView: nameTextField, bottomView: signinButton)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        adjust(scrollView, notification: notification, topView: createAccountTitleLabel, bottomView: signinButton)
    }
}

extension SignupViewController: PMTextFieldDelegate {
    func didChangeValue(_ textField: PMTextField, value: String) {
        validateNextButton()
    }

    func didEndEditing(textField: PMTextField) {
        validateNextButton()
    }

    func textFieldShouldReturn(_ textField: PMTextField) -> Bool {
        _ = nameTextField.resignFirstResponder()
        return true
    }

    func didBeginEditing(textField: PMTextField) {

    }
}

// MARK: - Additional errors handling

extension SignupViewController: SignUpErrorCapable {
    var bannerPosition: PMBannerPosition { .top }
}

#endif
