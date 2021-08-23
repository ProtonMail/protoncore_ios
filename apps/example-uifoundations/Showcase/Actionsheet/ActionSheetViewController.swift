//
//  ActionSheetViewController.swift
//  ProtonMail - Created on 27.07.20.
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

class ActionSheetViewController: AppearanceStyleViewController {
    
    init() {
        super.init(nibName: "ActionSheetViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showSample1(_ sender: Any) {
        var sheet: PMActionSheet!
        let left = PMActionSheetPlainItem(title: nil, icon: UIImage(named: "times")) { (_) -> (Void) in
            sheet.dismiss(animated: true)
        }
        let header = PMActionSheetHeaderView(title: "Dora Motorized 4 Wheeler for ksdfi", subtitle: "1 message | 0:04 PM", leftItem: left, rightItem: nil, hasSeparator: false)
        
        let grid1 = PMActionSheetPlainItem(title: "Grid 1", icon: UIImage(named: "times")) { (_) -> (Void) in
            print("click grid 1")
            sheet.dismiss(animated: true)
        }
        let grid2 = PMActionSheetPlainItem(title: "Grid 2", icon: UIImage(named: "times")) { (_) -> (Void) in
            print("click grid 2")
        }
        
        let gridGroup = PMActionSheetItemGroup(items: [grid1, grid2, grid2, grid1], style: .grid)
        
        let item1 = PMActionSheetPlainItem(title: "indentationLevel: 2", icon: UIImage(named: "times"), indentationLevel: 2) { (_) -> (Void) in
            print("click item 1")
        }
        let item2 = PMActionSheetPlainItem(title: "no indentationLevel", icon: UIImage(named: "times")) { (_) -> (Void) in
            print("click item 2")
        }
        let item3 = PMActionSheetPlainItem(title: "no icon", icon: nil) { (_) -> (Void) in
            print("click item 3")
        }
        let item4 = PMActionSheetPlainItem(title: "no icon, centered", icon: nil, alignment: .center) { (_) -> (Void) in
            print("click item 3")
        }
        let item5 = PMActionSheetPlainItem(title: "no icon, checkmark, centered", icon: nil, markType: .checkMark, alignment: .center) { (_) -> (Void) in
            print("click item 3")
        }
        let item6 = PMActionSheetPlainItem(title: "as above but indentationLevel: 2", icon: nil, markType: .checkMark, alignment: .center, indentationLevel: 2) { (_) -> (Void) in
            print("click item 3")
        }
        let itemGroup = PMActionSheetItemGroup(items: [item1, item2, item3, item4, item5, item6], style: .clickable)
        sheet = PMActionSheet(headerView: header, itemGroups: [gridGroup, itemGroup])
        sheet.eventsListener = self
        sheet.presentAt(self, animated: true)
    }
    
    @IBAction func showSample2(_ sender: Any) {
        var sheet: PMActionSheet!
        let left = PMActionSheetPlainItem(title: nil, icon: UIImage(named: "times")) { (_) -> (Void) in
            sheet.dismiss(animated: true)
        }
        
        let right = PMActionSheetPlainItem(title: "Done", icon: nil, textColor: .blue, iconColor: nil) { (_) -> (Void) in
            guard let groups = sheet.itemGroups else {return}
            print("Click Done button")
            print("Groups data are \(groups)")
            sheet.dismiss(animated: true)
        }
        
        let header = PMActionSheetHeaderView(title: "Label as", subtitle: nil, leftItem: left, rightItem: right, hasSeparator: false)
        
        let toggle1 = PMActionSheetToggleItem(title: "Send to archive?", icon: nil)
        let toggleGroup = PMActionSheetItemGroup(items: [toggle1], style: .toggle)
        
        let item1 = PMActionSheetPlainItem(title: "item1", icon: UIImage(named: "times")) { (_) -> (Void) in
            print("click item 1")
        }
        let item2 = PMActionSheetPlainItem(title: "item2", icon: UIImage(named: "times")) { (_) -> (Void) in
            print("click item 2")
        }
        let item3 = PMActionSheetPlainItem(title: "item3", icon: UIImage(named: "times"), markType: .dash) { (_) -> (Void) in
            print("click item 3")
        }
        let itemGroup = PMActionSheetItemGroup(items: [item1, item2, item1, item2, item1, item2, item1, item2, item3],
                                               style: .multiSelection)
        
        
        let addItem = PMActionSheetPlainItem(title: "New label", icon: UIImage(named: "times"), textColor: .gray) { (_) -> (Void) in
            print("User want to create new label")
        }
        let addGroup = PMActionSheetItemGroup(items: [addItem], style: .clickable)
        
        sheet = PMActionSheet(headerView: header, itemGroups: [toggleGroup, itemGroup, addGroup])
        sheet.presentAt(self, animated: true)
    }
    
    @IBAction func showSample3(_ sender: Any) {
        var sheet: PMActionSheet!
        let item1 = PMActionSheetPlainItem(title: "item1", icon: nil, isOn: true) { (_) -> (Void) in
            print("click item 1")
        }
        let item2 = PMActionSheetPlainItem(title: "item2", icon: nil) { (_) -> (Void) in
            print("click item 2")
        }
        let itemGroup = PMActionSheetItemGroup(items: [item1, item2], style: .singleSelection)
        
        let cancel = PMActionSheetPlainItem(title: "Cancel", icon: nil, textColor: .red, alignment: .center, hasSeparator: false, handler: nil)
        let cancelGrop = PMActionSheetItemGroup(items: [cancel], style: .clickable)
        sheet = PMActionSheet(headerView: nil, itemGroups: [itemGroup, cancelGrop], showDragBar: false)
        sheet.presentAt(self, animated: true)
    }
    
}

extension ActionSheetViewController: PMActionSheetEventsListener {
    func didDismiss() {
        print("did dismiss")
    }
    
    func willPresent() {
        print("will present")
    }
    
    func willDismiss() {
        print("will dismiss")
    }
    
    
}
