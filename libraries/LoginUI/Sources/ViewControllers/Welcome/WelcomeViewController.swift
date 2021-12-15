//
//  WelcomeViewController.swift
//  ProtonCore-Login - Created on 17.06.2021.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import ProtonCore_CoreTranslation
import ProtonCore_Foundations
import ProtonCore_UIFoundations
import func AVFoundation.AVMakeRect

public typealias WelcomeScreenVariant = ScreenVariant<WelcomeScreenTexts, WelcomeScreenCustomData>

public struct WelcomeScreenTexts {
    let headline: String
    let body: String

    public init(headline: String, body: String) {
        self.headline = headline
        self.body = body
    }
}

public struct WelcomeScreenCustomData {
    let topImage: UIImage
    let logo: UIImage
    let headline: String
    let body: String
    let brand: Brand

    public init(topImage: UIImage, logo: UIImage, headline: String, body: String, brand: Brand) {
        self.topImage = topImage
        self.logo = logo
        self.headline = headline
        self.body = body
        self.brand = brand
    }
}

protocol WelcomeViewControllerDelegate: AnyObject {
    func userWantsToLogIn(username: String?)
    func userWantsToSignUp()
}

final class WelcomeViewController: UIViewController, AccessibleView {

    private let variant: WelcomeScreenVariant
    private let username: String?
    private let signupAvailable: Bool
    private weak var delegate: WelcomeViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    init(variant: WelcomeScreenVariant,
         delegate: WelcomeViewControllerDelegate,
         username: String?,
         signupAvailable: Bool) {
        self.variant = variant
        self.delegate = delegate
        self.username = username
        self.signupAvailable = signupAvailable
        super.init(nibName: nil, bundle: nil)
        self.extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder: NSCoder) { fatalError("not designed to be created from IB") }

    override func loadView() {
        let loginAction = #selector(WelcomeViewController.loginActionWasPerformed)
        let signupAction = #selector(WelcomeViewController.signupActionWasPerformed)
        view = WelcomeView(variant: variant,
                           target: self,
                           loginAction: loginAction,
                           signupAction: signupAction,
                           signupAvailable: signupAvailable)
        generateAccessibilityIdentifiers()
    }

    @objc private func loginActionWasPerformed() {
        delegate?.userWantsToLogIn(username: username)
    }

    @objc private func signupActionWasPerformed() {
        delegate?.userWantsToSignUp()
    }
}

final class WelcomeView: UIView {

    private let loginButton = ProtonButton()
    private let signupButton = ProtonButton()
    private let signupAvailable: Bool
    private var topImageView: UIImageView?

    private var logoTopOffsetConstraint: NSLayoutConstraint?

    init(variant: WelcomeScreenVariant,
         target: UIViewController,
         loginAction: Selector,
         signupAction: Selector,
         signupAvailable: Bool) {
        self.signupAvailable = signupAvailable

        super.init(frame: .zero)

        setUpLayout(variant: variant)
        setUpInteractions(target: target, loginAction: loginAction, signupAction: signupAction)
    }

    required init?(coder: NSCoder) { fatalError("not designed to be created from IB") }

    private func setUpLayout(variant: WelcomeScreenVariant) {

        setUpMainView(for: variant)

        let topImage = topImage(for: variant)
        let logo = logo(for: variant)
        let headline = headline(for: variant)
        let body = body(for: variant)
        let footer = footer()

        setUpButtons()

        [topImage, logo, headline, body, loginButton, signupButton, footer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        topImage.contentMode = .scaleAspectFit
        logo.contentMode = .scaleAspectFit

        logoTopOffsetConstraint = logo.topAnchor.constraint(greaterThanOrEqualTo: topImage.topAnchor, constant: 0)
        logoTopOffsetConstraint?.isActive = false

        NSLayoutConstraint.activate([
            topImage.topAnchor.constraint(equalTo: topAnchor, constant: UIDevice.current.isSmallIphone ? -45 : 0),
            topImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            topImage.trailingAnchor.constraint(equalTo: trailingAnchor),

            logo.topAnchor.constraint(lessThanOrEqualTo: topImage.bottomAnchor, constant: 24),
            logo.centerXAnchor.constraint(equalTo: readableContentGuide.centerXAnchor),

            headline.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: UIDevice.current.isSmallIphone ? 10 : 36),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
            loginButton.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 32),
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            footer.topAnchor.constraint(greaterThanOrEqualTo: signupButton.bottomAnchor, constant: 16),
            footer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        NSLayoutConstraint.activate([headline, body, loginButton, signupButton, footer].flatMap { view in
            [
                view.centerXAnchor.constraint(equalTo: readableContentGuide.centerXAnchor),
                view.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: UIDevice.current.isSmallIphone ? 4 : 24),
                view.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: UIDevice.current.isSmallIphone ? -4 : -24)
            ]
        })
    }

    fileprivate func setUpMainView(for variant: WelcomeScreenVariant) {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }

        switch variant {
        case .mail: ColorProvider.brand = .proton
        case .calendar: ColorProvider.brand = .proton
        case .drive: ColorProvider.brand = .proton
        case .vpn: ColorProvider.brand = .vpn
        case .custom(let data): ColorProvider.brand = data.brand
        }

        backgroundColor = ProtonColorPallete.Welcome.Background
    }

    private func topImage(for variant: WelcomeScreenVariant) -> UIImageView {
        let topImage: UIImage
        switch variant {
        case .mail: topImage = image(named: "WelcomeTopImageForProton")
        case .calendar: topImage = image(named: "WelcomeTopImageForProton")
        case .drive: topImage = image(named: "WelcomeTopImageForProton")
        case .vpn: topImage = image(named: "WelcomeTopImageForVPN")
        case .custom(let data): topImage = data.topImage
        }
        let imageView = UIImageView(image: topImage)
        topImageView = imageView
        return imageView
    }

    private func logo(for variant: WelcomeScreenVariant) -> UIImageView {
        let logo: UIImage
        switch variant {
        case .mail: logo = image(named: "WelcomeMailLogo")
        case .calendar: logo = image(named: "WelcomeCalendarLogo")
        case .drive: logo = image(named: "WelcomeDriveLogo")
        case .vpn: logo = image(named: "WelcomeVPNLogo")
        case .custom(let data): logo = data.logo
        }
        return UIImageView(image: logo)
    }

    private func headline(for variant: WelcomeScreenVariant) -> UILabel {
        let headline = UILabel()
        let text: String
        switch variant {
        case .mail(let texts), .calendar(let texts), .drive(let texts), .vpn(let texts): text = texts.headline
        case .custom(let data): text = data.headline
        }
        headline.attributedText = NSAttributedString(string: text, attributes: .HeadlineWelcomeSmall)
        headline.textAlignment = .center
        headline.numberOfLines = 0
        return headline
    }

    private func body(for variant: WelcomeScreenVariant) -> UILabel {
        let body = UILabel()
        let text: String
        switch variant {
        case .mail(let texts), .calendar(let texts), .drive(let texts), .vpn(let texts): text = texts.body
        case .custom(let data): text = data.body
        }
        var attributes = PMFontAttributes.DefaultSmall
        let foregroundColor: UIColor = ColorProvider.TextWeak
        attributes[.foregroundColor] = foregroundColor
        body.attributedText = NSAttributedString(string: text, attributes: attributes)
        body.textAlignment = .center
        body.numberOfLines = 0
        return body
    }

    private func footer() -> UIView {
        let iconsNamesInOrder = [
            "WelcomeCalendarSmallLogo", "WelcomeVPNSmallLogo", "WelcomeDriveSmallLogo", "WelcomeMailSmallLogo"
        ]
        let iconsInFooter = UIStackView(
            arrangedSubviews: iconsNamesInOrder.map(image(named:)).map(UIImageView.init(image:))
        )
        iconsInFooter.tintColor = ColorProvider.TextWeak
        iconsInFooter.axis = .horizontal
        iconsInFooter.spacing = 32
        iconsInFooter.alignment = .center

        let font = UIFont.systemFont(ofSize: 11, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.07
        paragraphStyle.alignment = .center
        let foregroundColor: UIColor = ColorProvider.TextWeak
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
            .kern: 0.07,
            .paragraphStyle: paragraphStyle
        ]

        let label = UILabel()
        label.attributedText = NSAttributedString(string: CoreString._ls_welcome_footer, attributes: attributes)

        let footer = UIStackView(arrangedSubviews: [iconsInFooter, label])
        footer.axis = .vertical
        footer.spacing = 8
        footer.alignment = .center
        return footer
    }

    private func setUpButtons() {
        loginButton.setMode(mode: .solid)
        loginButton.setTitle(CoreString._ls_sign_in_button, for: .normal)
        signupButton.setMode(mode: .outlined)
        signupButton.setTitle(CoreString._ls_create_account_button, for: .normal)
        
        guard signupAvailable else {
            signupButton.isHidden = true
            return
        }

        var normal: PMFontAttributes = .DefaultSmall
        var disabled: PMFontAttributes = .DefaultSmallDisabled
        var highlighted: PMFontAttributes = .DefaultSmallWeek
        var selected: PMFontAttributes = .DefaultSmallWeek
        switch ColorProvider.brand {
        case .proton:
            break
        case .vpn:
            let normalForegroundColor: UIColor = ColorProvider.BrandNorm
            normal[.foregroundColor] = normalForegroundColor
            let disabledForegroundColor: UIColor = ColorProvider.BrandLighten40
            disabled[.foregroundColor] = disabledForegroundColor
            let highlightedForegroundColor: UIColor = ColorProvider.BrandDarken20
            highlighted[.foregroundColor] = highlightedForegroundColor
            let selectedForegroundColor: UIColor = ColorProvider.BrandDarken20
            selected[.foregroundColor] = selectedForegroundColor
        }
    }

    private func setUpInteractions(target: UIViewController, loginAction: Selector, signupAction: Selector) {
        loginButton.addTarget(target, action: loginAction, for: .touchUpInside)
        signupButton.addTarget(target, action: signupAction, for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let topImageView = topImageView, let image = topImageView.image else { return }
        
        let width = UIDevice.current.orientation.isPortrait ? topImageView.bounds.width : topImageView.bounds.height

        let scaleRect = CGRect(origin: topImageView.bounds.origin,
                               size: .init(width: width, height: .infinity))
        let imageHeight = AVMakeRect(aspectRatio: image.size, insideRect: scaleRect).height
        logoTopOffsetConstraint?.constant = imageHeight
        logoTopOffsetConstraint?.isActive = true
    }

}

private func image(named name: String) -> UIImage {
    guard let icon = UIImage(named: name, in: LoginAndSignup.bundle, compatibleWith: nil) else {
        assertionFailure("Asset not available, configuration error")
        return .init()
    }
    return icon
}
