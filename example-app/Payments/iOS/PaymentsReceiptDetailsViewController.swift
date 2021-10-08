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

final class PaymentsReceiptDetailsViewController: UITableViewController {

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

        tableView.tableHeaderView = createHeaderView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
    }

    private func createHeaderView() -> UIStackView? {
        guard let receipt = receipt else { return nil }
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "\(receipt.bundleIdentifier) \(receipt.appVersion)"

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(PaymentsReceiptDetailsViewController.validateReceiptTapped), for: .touchUpInside)
        button.setTitle("Validate receipt using Apple API", for: .normal)

        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.frame.size.height = stackView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0)).height
        return stackView
    }

    @objc private func validateReceiptTapped() {
        guard let receipt = receipt else { return }
        let request = SessionRequest(parameters: ["receipt-data": receipt.base64],
                       urlString: "https://sandbox.itunes.apple.com/verifyReceipt",
                       method: .post, timeout: 30.0)
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
                    label.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor),
                    label.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                    label.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

                    scrollView.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
                    scrollView.heightAnchor.constraint(equalTo: controller.view.heightAnchor),
                    scrollView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
                    scrollView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor)
                ])
                self.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
            }
        }
    }

    private func setupNoReceiptView() {
        tableView.isHidden = true
        title = "No receipt found!"
    }

    private func setupCorruptedReceiptView() {
        tableView.isHidden = true
        title = "Corrupted receipt data"
    }
}

extension PaymentsReceiptDetailsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        receipt?.purchases.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
