//
//  AppearanceStyleViewController.swift
//  ExampleApp - Created on 09.06.20.
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

import UIKit

class UIFoundationsAppearanceStyleViewController: UIViewController {

    private lazy var darkModeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Dark", style: .plain, target: self, action: #selector(toggleDarkMode))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = darkModeButton
    }

    @objc func toggleDarkMode() {
        view.window?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle == .dark ? .light : .dark
    }

    deinit  {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
    }

    // MARK: - Appearance

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        darkModeButton.title = traitCollection.userInterfaceStyle == .dark ? "Light" : "Dark"
    }

}

class UIFoundationsAppearanceStyleTableViewController: UITableViewController {

    private lazy var darkModeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Dark", style: .plain, target: self, action: #selector(toggleDarkMode))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = darkModeButton
    }

    @objc func toggleDarkMode() {
        view.window?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle == .dark ? .light : .dark
    }

    deinit {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
    }

    // MARK: - Appearance

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        darkModeButton.title = traitCollection.userInterfaceStyle == .dark ? "Light" : "Dark"
    }
}
