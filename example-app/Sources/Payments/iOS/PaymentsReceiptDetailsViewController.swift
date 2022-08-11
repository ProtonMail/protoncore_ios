//
//  PaymentsReceiptDetailsViewController.swift
//  Example-Payments — Created on 13/08/2021.
// 
//  Copyright (c) 2020 Proton Technologies AG
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
import TPInAppReceipt
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_UIFoundations
import CoreGraphics
import Foundation

final class PaymentsReceiptDetailsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var receiptLabel: UILabel!
    private var receipt: InAppReceipt?
    var testApi: PMAPIService!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptUrl)
        else {
            setupNoReceiptView()
            return
        }
        setupReceiptView(receipt)
    }

    private func setupReceiptView(_ receiptData: Data) {
        guard let receipt = try? InAppReceipt(receiptData: receiptData) else {
            setupCorruptedReceiptView()
            return
        }
        self.receipt = receipt
        title = "Receipt details"
        
        receiptLabel.text = "\(receipt.bundleIdentifier) \(receipt.appVersion)"

        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
    }
    
    @IBAction private func shareReceiptTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now = Date()
        let fileName = "receipt_\(formatter.string(from: now)).txt"
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString()
        else { return }
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("/\(fileName)")
        do {
            try receipt.write(to: file, atomically: true, encoding: .utf8)
            let activityViewController = UIActivityViewController(activityItems: [file],
                                                                  applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {}
    }

    @IBAction private func validateReceiptTapped() {
        guard let receipt = receipt else { return }
        let request = SessionFactory.createSessionRequest(parameters: ["receipt-data": receipt.base64],
                                                          urlString: "https://sandbox.itunes.apple.com/verifyReceipt",
                                                          method: .post,
                                                          timeout: 30.0,
                                                          retryPolicy: .userInitiated)
        try! testApi.getSession()?.request(with: request) { task, response, error in
            DispatchQueue.main.async {
                let controller = UIViewController()
                controller.view.backgroundColor = .black
                controller.title = "Apple API response"
                let scrollView = UIScrollView()
                scrollView.translatesAutoresizingMaskIntoConstraints = false
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.text = "\(String(describing: response))"
                controller.view.addSubview(scrollView)
                scrollView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalTo: scrollView.readableContentGuide.widthAnchor),
                    label.topAnchor.constraint(equalTo: scrollView.readableContentGuide.topAnchor),
                    label.bottomAnchor.constraint(equalTo: scrollView.readableContentGuide.bottomAnchor),

                    scrollView.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
                    scrollView.heightAnchor.constraint(equalTo: controller.view.heightAnchor),
                    scrollView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
                    scrollView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor)
                ])
                self.present(DarkModeAwareNavigationViewController(rootViewController: controller), animated: true, completion: nil)
            }
        }
    }

    private func setupNoReceiptView() {
        title = "No receipt found!"
    }

    private func setupCorruptedReceiptView() {
        title = "Corrupted receipt data"
    }
}

extension PaymentsReceiptDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        receipt?.purchases.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReceiptDetailsViewController.cell")
        guard let receipt = receipt else { return cell }
        let purchase = receipt.purchases.sorted { $0.originalPurchaseDate > $1.originalPurchaseDate } [indexPath.row]
        cell.textLabel?.text = "\(purchase.productIdentifier) \n \(purchase.originalPurchaseDate!)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = "\(purchase)"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        return cell
    }

}
