//
//  UIFoundationsActionBarViewController.swift
//  ExampleApp - Created on 30.07.20.
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
import ProtonCore_Log
import ProtonCore_UIFoundations

class UIFoundationsActionBarViewController: UIFoundationsAppearanceStyleViewController {
    
    @IBOutlet var tableView: UITableView!
    
    init() {
        super.init(nibName: "UIFoundationsActionBarViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ActionBar"
        // Sample 1
//        self.addActionBar()
        // Sample 2
//        self.addActionBar_2()
        // sample 3
        self.addActionBar_3()
    }
    
    private func addActionBar() {
        var actionbar: PMActionBar!
        let trashItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText) { (_) in
            PMLog.info("Click trash")
            actionbar.dismiss()
        }
        let labelItem = PMActionBarItem(text: "Reply all", alignment: .right)
        let replyItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText, selectedItemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground, selectedBgColor: ColorProvider.FloatyPressed, userInfo: ["value": 100]) { (item) in
            PMLog.info("click reply, \(item.userInfo ?? [:])")
            actionbar.dismiss()
        }
        
        let moreItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText) { (_) in
            PMLog.info("click more")
            actionbar.dismiss()
        }
        
        actionbar = PMActionBar(items: [trashItem, labelItem, replyItem, moreItem])
        actionbar.show(at: self)
    }

    private func addActionBar_2() {
        var actionbar: PMActionBar!
        let trashItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText) { (_) in
            PMLog.info("Click trash")
            actionbar.dismiss()
        }
        let labelItem = PMActionBarItem(text: "Reply all", alignment: .right)

        actionbar = PMActionBar(items: [trashItem, labelItem], width: .fit)
        actionbar.show(at: self)
    }
    
    private func addActionBar_3() {
        var actionbar: PMActionBar!
        let text = PMActionBarItem(text: "Attending", alignment: .center, itemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground)
        let yes = PMActionBarItem(text: "Yes", itemColor: ColorProvider.FloatyText, selectedItemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground, selectedBgColor: ColorProvider.FloatyPressed, isSelected: true, userInfo: nil, handler: { (_) in
            PMLog.info("Click yes")
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                actionbar.endSpinning(succeed: true)
            })
        }).setShouldSpin()
        let no = PMActionBarItem(text: "No", itemColor: ColorProvider.FloatyText, selectedItemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground, selectedBgColor: ColorProvider.FloatyPressed, userInfo: nil, handler: {_ in
            PMLog.info("Click no")
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                actionbar.endSpinning(succeed: false)
            })
        }).setShouldSpin()
        let maybe = PMActionBarItem(text: "Maybe", itemColor: ColorProvider.FloatyText, selectedItemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground, selectedBgColor: ColorProvider.FloatyPressed, userInfo: nil, handler: { (item) in
            PMLog.info("Click maybe")
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                actionbar.endSpinning(succeed: false, shouldRestore: false)
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                    actionbar.dismiss()
                })
            })
        }).setShouldSpin()
        
        actionbar = PMActionBar(items: [text, yes, no, maybe])
        actionbar.show(at: self)
    }
    
    private func addActionBar_4() {
        var actionbar: PMActionBar!
        let trashItem = PMActionBarItem(icon: UIImage(named: "trash")!, text: "Move to Inbox", itemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground) { (_) in
            PMLog.info("Click trash")
            actionbar.dismiss()
        }
        let separator = PMActionBarItem(width: 1, color: .red)
        let labelItem = PMActionBarItem(text: "Reply all", alignment: .right)
        let replyItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText, selectedItemColor: ColorProvider.FloatyText, backgroundColor: ColorProvider.FloatyBackground, selectedBgColor: ColorProvider.FloatyPressed, userInfo: ["value": 100]) { (item) in
            PMLog.info("click reply, \(item.userInfo ?? [:])")
            actionbar.dismiss()
        }
        
        let moreItem = PMActionBarItem(icon: UIImage(named: "trash")!, itemColor: ColorProvider.FloatyText) { (_) in
            PMLog.info("click more")
            actionbar.dismiss()
        }
        
        actionbar = PMActionBar(items: [trashItem, separator, labelItem, replyItem, moreItem])
        actionbar.show(at: self)
    }
}

extension UIFoundationsActionBarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
        }
        cell!.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        if row == 0 {
            self.addActionBar()
        } else if row == 1 {
            self.addActionBar_2()
        } else if row == 2 {
            self.addActionBar_3()
        } else if row == 3 {
            self.addActionBar_4()
        }
    }
}
