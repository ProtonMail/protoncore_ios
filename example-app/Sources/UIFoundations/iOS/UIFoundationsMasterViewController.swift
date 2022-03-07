//
//  MasterViewController.swift
//  ProtonMail - Created on 25.05.20.
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

class UIFoundationsMasterViewController: UIFoundationsAppearanceStyleTableViewController {
    
    private var rows = [(title: String, viewController: UIViewController)]()
    private var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows.append((title: "Buttons", viewController: UIFoundationsButtonsViewController()))
        rows.append((title: "Action sheet", viewController: UIFoundationsActionSheetViewController()))
        rows.append((title: "ActionBar", viewController: UIFoundationsActionBarViewController()))
        rows.append((title: "Tabbar Controller", viewController: UIFoundationsTabbarHelper.setupTabbar()))
        rows.append((title: "Banner", viewController: UIFoundationsBannerViewController()))
        rows.append((title: "Text field", viewController: UIFoundationsTextFieldViewController()))
        rows.append((title: "Cell", viewController: UIFoundationsCellViewController()))
        rows.append((title: "Segmented control", viewController: UIFoundationsSegmentedControlViewController()))
        rows.append((title: "CountryPicker ViewController", viewController: UIFoundationsCountryPickerViewController()))
        #if canImport(ProtonCore_CoreTranslation_V5)
        rows.append((title: "Splash and welcome view", viewController: UIFoundationsSplashShowcaseViewController()))
        #endif
        rows.append((title: "Shadow", viewController: UIFoundationsShadowViewController()))
        rows.append((title: "Colors", viewController: UIFoundationsColorsViewController()))
        rows.append((title: "Icons", viewController: UIFoundationsIconsViewController()))
    }

    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailNavController = segue.destination as? UINavigationController else {
            fatalError("Something went wrong with the segue")
        }
        
        let detailViewController = rows[selectedRow].viewController
        detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        detailNavController.setViewControllers([detailViewController], animated: false)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let title = rows[indexPath.row].title
        cell.textLabel!.text = title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRow = indexPath.row
        return indexPath
    }
}
