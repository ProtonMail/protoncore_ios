//
//  vc1.swift
//  ProtonMail - Created on 18.08.20.
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
import ProtonCore_UIFoundations

struct UIFoundationsTabbarHelper {
    static func setupTabbar() -> PMTabBarController {
        let board = UIStoryboard(name: "Example-UIFoundations", bundle: nil)
        let vc1 = board.instantiateViewController(withIdentifier: "vc1")
        let vc2 = board.instantiateViewController(withIdentifier: "vc2")
        let vc3 = board.instantiateViewController(withIdentifier: "vc3")
        let vc4 = board.instantiateViewController(withIdentifier: "vc4")
        
        let barVC =  try! PMTabBarBuilder()
            .setFloatingHeight(48)
            .addItem(PMTabBarItem(title: "Day" ), withController: vc1)
            .addItem(PMTabBarItem(title: "3 Day"), withController: vc2)
            .addItem(PMTabBarItem(title: "Month"), withController: vc3)
            .addItem(PMTabBarItem(icon: UIImage(named: "times")!), withController: vc4)
            .setSelectedIndex(2)
            .build()
        
        return barVC
    }
}

class UIFoundationsTabBarTemplateVC: UITableViewController {

    private lazy var darkModeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Dark", style: .plain, target: self, action: #selector(toggleDarkMode))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Doesn't like action bar
        // It not easy to calculate suitable bottom inset for every sub viewcontrollers.
        // So developer have to handle this by himself.
//        self.tableView.contentInset.bottom = 96
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationItem.rightBarButtonItem = darkModeButton
    }

    @objc func toggleDarkMode() {
        if #available(iOS 13.0, *) {
            view.window?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle == .dark ? .light : .dark
        }
    }
    
    deinit {
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    // MARK: - Appearance
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 12.0, *) {
            darkModeButton.title = traitCollection.userInterfaceStyle == .dark ? "Light" : "Dark"
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
            cell?.backgroundColor = .clear
        }
        cell!.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
}
