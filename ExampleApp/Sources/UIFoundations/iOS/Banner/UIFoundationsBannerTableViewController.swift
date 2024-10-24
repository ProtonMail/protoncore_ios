//
//  UIFoundationsBannerTableViewController.swift
//  ExampleApp - Created on 31.08.20.
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
import ProtonCoreLog
import ProtonCoreUIFoundations
import Foundation

class UIFoundationsBannerTableViewController: UIFoundationsAppearanceStyleTableViewController {
    private var samples: [String] = [
        "loading example, top",
        "infoBannerWithLeftIcon, Top",
        "simple text, Bottom",
        "long text, Bottom",
        "simple text and button, Bottom",
        "long textAndButton, Bottom",
        "attributed sample, top",
        "attributed sample2, top",
        "error without button",
        "error with button",
        "error with button icon",
        "success without button",
        "success with button",
        "success with button icon",
        "warning without button",
        "warning with button",
        "warning with button icon",
        "info without button",
        "info with button",
        "info with button icon",
        "Custom bottom padding banner"
    ]
    private var functions: [() -> Void] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.functions = [
            self.loadingExample_Top,
            self.infoBannerWithLeftIcon_Top,
            self.simpleText_Bottom,
            self.longText_Bottom,
            self.simpleTextAndButton_Bottom,
            self.longTextAndButton_Bottom,
            self.attributedSample_top,
            self.attributedSample2_top,
            self.errorNoButton,
            self.errorButton,
            self.errorButtonIcon,
            self.successNoButton,
            self.successButton,
            self.successButtonIcon,
            self.warningNoButton,
            self.warningButton,
            self.warningButtonIcon,
            self.infoNoButton,
            self.infoButton,
            self.infoButtonIcon,
            self.customBottomPaddingBanner
        ]
        view.backgroundColor = ColorProvider.BackgroundNorm
        tableView.backgroundColor = ColorProvider.BackgroundNorm
    }
}

extension UIFoundationsBannerTableViewController {
    private func loadingExample_Top() {
        let banner = PMBanner(message: "The message is sent", style: PMBannerNewStyle.info, dismissDuration: Double.infinity, userInfo: ["key": "example"])
        banner.addButton(text: "Undo") { [weak self] banner in
            banner.setup(isLoading: true)
            self?.scheduleTimerForLoadingExample()
        }
        banner.show(at: .top, on: self)
    }

    private func scheduleTimerForLoadingExample() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let banners = PMBanner.getBanners(in: self)
            let target = banners.first { $0.userInfo?["key"] as? String == "example" }
            target?.setup(isLoading: false)
        }
    }

    private func infoBannerWithLeftIcon_Top() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results. Also, let's make this message even longer to see how it behaves when it must break the line", style: PMBannerNewStyle.error, icon: UIImage(named: "times"))
        banner.show(at: .top, on: self)
    }

    private func simpleText_Bottom() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic", style: PMBannerNewStyle.info)
        banner.show(at: .bottom, on: self)
    }

    private func longText_Bottom() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results. Also, let's make this message even longer to see how it behaves when it must break the line", style: PMBannerNewStyle.info)
        banner.show(at: .bottom, on: self)
    }

    private func simpleTextAndButton_Bottom() {
        let banner = PMBanner(message: "Message is deleted", style: PMBannerNewStyle.info)
        banner.addButton(text: "Undo") { _ in
            PMLog.info("Click undo button")
        }
        banner.show(at: .bottom, on: self)
    }

    private func longTextAndButton_Bottom() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results. Also, let's make this message even longer to see how it behaves when it must break the line", style: PMBannerNewStyle.info)
        banner.addButton(text: "Undo") { _ in
            PMLog.info("Click undo button")
        }
        banner.show(at: .bottom, on: self)
    }

    private func attributedSample_top() {

        let foregroundColor: UIColor = ColorProvider.TextInverted
        let linkStr = NSAttributedString(string: "Apple link", attributes: [.link: URL(string: "https://apple.com/")!, .font: UIFont.systemFont(ofSize: 15)])
        let attr = NSMutableAttributedString(string: "Hello there ", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: foregroundColor
        ])
        attr.append(linkStr)
        let linkAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: foregroundColor,
            .underlineStyle: 1
        ]
        let banner = PMBanner(message: attr, style: PMBannerNewStyle.success, dismissDuration: Double.infinity)
        banner.addButton(icon: UIImage(named: "times")!) { [weak banner] _ in
            banner?.dismiss()
        }
        banner.add(linkAttributed: linkAttr) { (_, url) in
            PMLog.info("Click link: \(url.absoluteString)")
        }
        banner.show(at: .top, on: self)
    }

    private func attributedSample2_top() {
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        let foregroundColor: UIColor = ColorProvider.TextInverted

        let attr = NSMutableAttributedString(string: "Something wet wrong: email or password or both", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: foregroundColor,
            .paragraphStyle: para
        ])

        let banner = PMBanner(message: attr, style: PMBannerNewStyle.error)
        banner.show(at: .top, on: self)
    }

    private func errorNoButton() {
        let banner = PMBanner(message: "A COVID-19 vaccine could be available earlier than expected if ongoing clinical trials produce overwhelmingly positive results", style: PMBannerNewStyle.error)
        banner.show(at: .top, on: self)
    }

    private func errorButton() {
        let banner = PMBanner(message: "This account has been suspended due to a potential policy violation. If you believe this is in error, please contact us at abuse@protonmail.com", style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        banner.addButton(text: "OK") { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func errorButtonIcon() {
        let banner = PMBanner(message: "This account has been suspended due to a potential policy violation. If you believe this is in error, please contact us at abuse@protonmail.com", style: PMBannerNewStyle.error, dismissDuration: Double.infinity)
        banner.addButton(icon: IconProvider.arrowsRotate) { banner in
            banner.dismiss()
            PMLog.info("Click button")
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
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func successButtonIcon() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.success, dismissDuration: Double.infinity)
        banner.addButton(icon: IconProvider.arrowsRotate) { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func warningNoButton() {
        let banner = PMBanner(message: "Warning message", style: PMBannerNewStyle.warning)
        banner.show(at: .top, on: self)
    }

    private func warningButton() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.warning, dismissDuration: Double.infinity)
        banner.addButton(text: "Button") { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func warningButtonIcon() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.warning, dismissDuration: Double.infinity)
        banner.addButton(icon: IconProvider.arrowsRotate) { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func infoNoButton() {
        let banner = PMBanner(message: "Warning message", style: PMBannerNewStyle.info)
        banner.show(at: .top, on: self)
    }

    private func infoButton() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.info, dismissDuration: Double.infinity)
        banner.addButton(text: "Button") { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func infoButtonIcon() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.info, dismissDuration: Double.infinity)
        banner.addButton(icon: IconProvider.arrowsRotate) { banner in
            banner.dismiss()
            PMLog.info("Click button")
        }
        banner.show(at: .top, on: self)
    }

    private func customBottomPaddingBanner() {
        let banner = PMBanner(message: "Lorem ipsum dolor sit amet adipisic elit, consectetur sed", style: PMBannerNewStyle.warning, dismissDuration: 4)
        banner.show(at: .bottomCustom(.init(top: .infinity, left: 8, bottom: 100, right: 8)), on: self)
    }
}

extension UIFoundationsBannerTableViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PMHeaderView(title: "Banner sample", fontSize: 22, titleColor: ColorProvider.TextNorm, titleLeft: 40, titleBottom: 0, background: ColorProvider.BackgroundNorm)
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "bannerCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "bannerCell")
            cell?.backgroundColor = ColorProvider.BackgroundNorm
            cell?.textLabel?.textColor = ColorProvider.TextNorm
        }
        cell?.textLabel?.text = samples[indexPath.row]
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.functions[indexPath.row]()
    }
}
