
//
//  UIFoundationsColorsViewController.swift
//  ExampleApp - Created on 18/02/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import UIKit
import ProtonCore_UIFoundations

final class UIFoundationsDFSViewController: UIFoundationsAppearanceStyleViewController {

    let styles: [UIFont.TextStyle] = [.largeTitle, .title1, .title2, .title3, .headline,
                                      .body, .callout, .subheadline, .footnote, .caption1,
                                      .caption2]

    override func loadView() {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        view = table
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DFSSetting.enableDFS = true
        DFSSetting.limitToXXXLarge = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DFSSetting.enableDFS = false
        DFSSetting.limitToXXXLarge = false
    }
}

extension UIFoundationsDFSViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        styles.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Update prefer font size to see change"
        } else {
            let style = styles[indexPath.row - 1]
            let font = UIFont.adjustedFont(forTextStyle: style)
            cell.textLabel?.font = font
            let desc = style.rawValue
            let index = desc.index(desc.startIndex, offsetBy: 17)
            cell.textLabel?.text = String(desc[index...])
            cell.detailTextLabel?.text = "\(font.pointSize)pt"
        }

        return cell
    }
}
