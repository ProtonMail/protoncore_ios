//
//  AccountSwitcherViewController.swift
//  CoreExample - Created on 06/10/2021.
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
import ProtonCore_AccountSwitcher
import ProtonCore_Foundations

class AccountSwitcherViewController: UIViewController, AccessibleView {

    @IBOutlet var switcherComponentButton: UIButton!
    @IBOutlet var switcherScreenButton: UIButton!

    private var list: [AccountSwitcher.AccountData] = [
        .init(userID: "userID_a", name: "", mail: "ooo@pm.me", isSignin: true, unread: 100),
        .init(userID: "userID_b", name: "QA 👍", mail: "user_b_with_super_long_address@pm.me", isSignin: false, unread: 0),
        .init(userID: "userID_c", name: "W W", mail: "user_c@protonmail.com", isSignin: true, unread: 1000),
        .init(userID: "userID_c", name: "", mail: "user_c@protonmail.com", isSignin: true, unread: 1000),
        .init(userID: "userID_c", name: "😂 a", mail: "user_c@protonmail.com", isSignin: true, unread: 1000)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        generateAccessibilityIdentifiers()
    }

    @IBAction func clickBtn(_ sender: UIButton) {
        let origin = CGPoint(x: sender.frame.origin.x,
                             y: sender.frame.origin.y)
        let switcher = try! AccountSwitcher(accounts: self.list,
                                            origin: origin)
        switcher.present(on: self, delegate: self)
    }

    @IBAction func clickBtn2(_ sender: UIButton) {
        let vc = AccountManagerVC.instance()
        let vm = AccountManagerViewModel(accounts: self.list,
                                         uiDelegate: vc)
        vm.set(delegate: self)
        guard let nav = vc.navigationController else {return}
        self.present(nav, animated: true, completion: nil)
    }
}

extension AccountSwitcherViewController: AccountSwitchDelegate {
    
    func switchTo(userID: String) {
        print("Want to switch to \(userID)")
    }

    func signinAccount(for mail: String, userID: String?) {
        if mail == "" {
            print("Show signin view")
        } else {
            print("Show signin view for \(mail)")
        }
    }

    func signoutAccount(userID: String, viewModel: AccountManagerVMDataSource) {
        guard let idx = self.list.firstIndex(where: {$0.userID == userID}) else {return}
        let oldData = self.list[idx]
        let data: AccountSwitcher.AccountData = .init(userID: oldData.userID, name: oldData.name, mail: oldData.mail, isSignin: false, unread: oldData.unread)
        self.list[idx] = data
        viewModel.updateAccountList(list: self.list)
    }

    func removeAccount(userID: String, viewModel: AccountManagerVMDataSource) {
        self.list = self.list.filter({$0.userID != userID})
        viewModel.updateAccountList(list: self.list)
    }
    
    func switcherWillAppear() {
        print("switcherWillAppear")
    }
    
    func switcherWillDisappear() {
        print("switcherWillDisappear")
    }
    
    func accountManagerWillAppear() {
        print("accountManagerWillAppear")
    }
    
    func accountManagerWillDisappear() {
        print("accountManagerWillDisappear")
    }
}
