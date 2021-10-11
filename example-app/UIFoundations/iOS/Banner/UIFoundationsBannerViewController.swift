//
//  UIFoundationsBannerViewController.swift
//  ProtonMail - Created on 31.08.20.
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

class UIFoundationsBannerViewController: UIFoundationsAppearanceStyleViewController {

    @IBAction func textField(_ sender: Any) {
    }
    @IBOutlet private var table: UITableView!
    private var samples: [String] = [
        "basic sample 1, top",
        "basic sample 2, bottom",
        "basic sample 3, top",
        "basic sample 4, top",
        "error without button",
        "error with button",
        "success without button",
        "success with button",
        "warning without button",
        "warning with button",
        "Custom bottom padding banner"
    ]
    private var functions: [()->()] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.functions = [
            self.basicSample1,
            self.basicSample2,
            self.basicSample3,
            self.basicSample4,
            self.errorNoButton,
            self.errorButton,
            self.successNoButton,
            self.successButton,
            self.warningNoButton,
            self.warningButton,
            self.customBottomPaddingBanner
        ]
        
    }
}

extension UIFoundationsBannerViewController {
    private func basicSample1() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results. Also, let's make this message even longer to see how it behaves when it must break the line", style: PMBannerStyle.error, icon: UIImage(named: "times"))
        banner.show(at: .top, on: self)
    }
    
    private func basicSample2() {
        
        let banner = PMBanner(message: "Delete a mail", style: PMBannerStyle.info)
        banner.addButton(text: "Undo") { (_) in
            print("Click undo button")
        }
        banner.show(at: .bottom, on: self)
    }
    
    private func basicSample3() {
        
        let linkStr = NSAttributedString(string: "Apple link", attributes: [.link: URL(string: "http://apple.com/")!, .font: UIFont.systemFont(ofSize: 15)])
        let attr = NSMutableAttributedString(string: "Hello there ", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.white
        ])
        attr.append(linkStr)
        let linkAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .underlineStyle: 1
        ]
        let banner = PMBanner(message: attr, style: PMBannerStyle.success)
        banner.addButton(icon: UIImage(named: "times")!, handler: nil)
        banner.add(linkAttributed: linkAttr) { (_, url) in
            print("Click link: \(url.absoluteString)")
        }
        banner.show(at: .top, on: self)
    }
    
    private func basicSample4() {
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        
        let attr = NSMutableAttributedString(string: "Something wet wrong: email or password or both", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.white,
            .paragraphStyle: para
        ])
        
        let banner = PMBanner(message: attr, style: PMBannerStyle.error)
        banner.show(at: .top, on: self)
    }
    
    private func errorNoButton() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results", style: PMBannerNewStyle.error)
        banner.show(at: .top, on: self)
    }
    
    private func errorButton() {
//        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results", style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        let banner = PMBanner(message: "This account has been suspended due to a potential policy violation. If you believe this is in error, please contact us at abuse@protonmail.com", style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        banner.addButton(text: "OK") { _ in
            banner.dismiss()
            print("Click button")
        }
        banner.show(at: .top, on: self)
    }
    
    private func successNoButton() {
        let banner = PMBanner(message: "Success message", style: PMBannerNewStyle.success)
        banner.show(at: .top, on: self)
    }
    
    private func successButton() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.success, dismissDuration: Double.infinity)
        banner.addButton(text: "Button") { _ in
            banner.dismiss()
            print("Click button")
        }
        banner.show(at: .top, on: self)
    }
    
    private func warningNoButton() {
        let banner = PMBanner(message: "Warning message", style: PMBannerNewStyle.warning)
        banner.show(at: .top, on: self)
    }
    
    private func warningButton() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.warning, dismissDuration: Double.infinity)
        banner.addButton(text: "Button") { _ in
            banner.dismiss()
            print("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func customBottomPaddingBanner() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.warning, dismissDuration: 4)
        banner.show(at: .bottomCustom(.init(top: .infinity, left: 8, bottom: 100, right: 8)), on: self)
    }
}

extension UIFoundationsBannerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PMHeaderView(title: "Banner sample", fontSize: 22, titleColor: .darkText, titleLeft: 40, titleBottom: 0, background: .white)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "bannerCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "bannerCell")
        }
        cell?.textLabel?.text = samples[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.functions[indexPath.row]()
    }
}

extension UIFoundationsBannerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
