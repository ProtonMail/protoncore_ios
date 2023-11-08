//
//  PaymentsTransactionsViewController.swift
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
import StoreKit
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreUIFoundations
import CoreGraphics

final class PaymentsTransactionsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var restoreCompletedTransactions: UIButton!

    private let paymentQueue = SKPaymentQueue.default()
    private var data: Set<SKPaymentTransaction> = []

    private var sortedData: [SKPaymentTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PaymentsTransactionsTableViewCell.self,
                           forCellReuseIdentifier: "PaymentsTransactionsViewController.cell")
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleTransactions(transactions: paymentQueue.transactions)
        addPaymentObserver()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removePaymentsObserver()
    }

    @IBAction func restorePreviousPurchases() {
        paymentQueue.restoreCompletedTransactions()
    }

    private func addPaymentObserver() {
        paymentQueue.add(self)
    }

    private func removePaymentsObserver() {
        paymentQueue.remove(self)
    }

    private func handleTransactions(transactions: [SKPaymentTransaction]) {
        transactions.forEach { data.insert($0) }
        sortedData = data.sorted { lhs, rhs in
            (lhs.transactionDate ?? .distantFuture) > (rhs.transactionDate ?? .distantFuture)
        }
        tableView.reloadData()
    }
}

extension PaymentsTransactionsViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        PMLog.debug(#function)
        handleTransactions(transactions: transactions)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        PMLog.debug(#function)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        PMLog.debug(#function)
        PMLog.debug("\(error)")
    }
}

extension PaymentsTransactionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentsTransactionsViewController.cell")
                as? PaymentsTransactionsTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "PaymentsTransactionsViewController.cell")
        }

        cell.setUp(with: sortedData[indexPath.row], in: paymentQueue)
        return cell
    }

}

final class PaymentsTransactionsTableViewCell: UITableViewCell {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return formatter
    }()

    private let label = UILabel()
    private let button = UIButton()

    private var transaction: SKPaymentTransaction?
    private var queue: SKPaymentQueue?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp(with transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        let date = transaction.transactionDate.map(PaymentsTransactionsTableViewCell.dateFormatter.string(from:))
        label.text = """
                     Id: \(transaction.transactionIdentifier ?? "-")
                     Date: \(date ?? "-")
                     State: \(transaction.transactionState.textual)
                     Product: \(transaction.payment.productIdentifier)
                     Original: \(transaction.original?.debugDescription ?? "-")
                     """
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        if transaction.transactionState != .failed {
            button.isHidden = false
            button.isUserInteractionEnabled = true
            button.setTitle("Finish transaction", for: .normal)
            button.tintColor = ColorProvider.BrandNorm
            button.addTarget(self,
                             action: #selector(PaymentsTransactionsTableViewCell.finishTransaction),
                             for: .touchUpInside)
        } else {
            button.isHidden = true
            button.setTitle("", for: .normal)
            button.removeTarget(self,
                                action: #selector(PaymentsTransactionsTableViewCell.finishTransaction),
                                for: .touchUpInside)
        }
        self.transaction = transaction
        self.queue = queue
    }

    @objc private func finishTransaction() {
        guard let queue = queue, let transaction = transaction else { return }
        queue.finishTransaction(transaction)
        button.setTitle("Transaction finished", for: .normal)
        button.isUserInteractionEnabled = false
    }
}

extension SKPaymentTransactionState {
    var textual: String {
        switch self {
        case .purchasing: return "purchasing"
        case .purchased: return "purchased"
        case .failed: return "failed"
        case .restored: return "restored"
        case .deferred: return "deferred"
        @unknown default: return "default"
        }
    }
}
