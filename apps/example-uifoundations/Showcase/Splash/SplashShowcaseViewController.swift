//
//  SplashShowcaseViewController.swift
//  Showcase
//
//  Created by Krzysztof Siejkowski on 18/06/2021.
//

import UIKit
import ProtonCore_UIFoundations

final class SplashShowcaseViewController: AppearanceStyleViewController {

    private func button(title: String, action: Selector) -> UIButton {
        let button = UIButton(frame: .zero)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(ColorProvider.TextNorm, for: .normal)
        return button
    }

    override func loadView() {
        let buttons = [
            button(title: "Mail splash", action: #selector(SplashShowcaseViewController.showMailSplash)),
            button(title: "Drive splash", action: #selector(SplashShowcaseViewController.showDriveSplash)),
            button(title: "Calendar splash", action: #selector(SplashShowcaseViewController.showCalendarSplash)),
            button(title: "VPN splash", action: #selector(SplashShowcaseViewController.showVPNSplash))
        ]
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.backgroundColor = ColorProvider.BackgroundNorm
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 64
        let container = UIView()
        container.addSubview(stack)
        container.backgroundColor = ColorProvider.BackgroundNorm
        view = container
        stack.centerInSuperview()
    }

    fileprivate func present(splash: SplashScreenIBVariant) {
        let splash = SplashViewController(variant: splash)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SplashShowcaseViewController.back))
        gesture.numberOfTapsRequired = 1
        splash.view.addGestureRecognizer(gesture)
        navigationController?.present(splash, animated: true, completion: nil)
    }

    @objc private func back() {
        navigationController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func showMailSplash() {
        present(splash: .mail)
    }

    @objc private func showDriveSplash() {
        present(splash: .drive)
    }

    @objc private func showCalendarSplash() {
        present(splash: .calendar)
    }

    @objc private func showVPNSplash() {
        present(splash: .vpn)
    }

}
