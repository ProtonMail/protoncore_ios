//
//  AppearanceStyleViewController.swift
//  ProtonMail - Created on 09.06.20.
//
//  Copyright (c) 2020 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit


class AppearanceStyleViewController: UIViewController {

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
    
    // MARK: - Appearance
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        darkModeButton.title = traitCollection.userInterfaceStyle == .dark ? "Light" : "Dark"
    }

}


class AppearanceStyleTableViewController: UITableViewController {

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
    
    // MARK: - Appearance
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        darkModeButton.title = traitCollection.userInterfaceStyle == .dark ? "Light" : "Dark"
    }

}
