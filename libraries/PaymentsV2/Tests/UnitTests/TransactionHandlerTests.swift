//
//  TransactionHandlerTests.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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

#if os(iOS)

import Combine
@testable import ProtonCorePaymentsV2
import StoreKitTest
import XCTest

final class TransactionHandlerTests: XCTestCase, @unchecked Sendable {

    private var urlSessionConfig: URLSessionConfiguration!
    private var mockRemoteManager: MockedRemoteManager!

    private let productsIds = ["iosvpn_bundle2022_12_usd_auto_renewing", "iosvpn_vpn2022_1_usd_auto_renewing"]
    private var subsComposer: PlansComposer!
    private var storeSession: SKTestSession!

    private var cancellable = Set<AnyCancellable>()

    private var sut: TransactionHandlerProviding!

    override func setUp() async throws {

        mockRemoteManager = MockedRemoteManager()

        guard let remoteManager = mockRemoteManager.remoteManager, let paymentsAPIs = mockRemoteManager.paymentsAPI else {
            XCTFail("MockRemoteManager returned nil remoteManager or paymentsAPIs")
            return
        }

        subsComposer = PlansComposer(remoteManager: remoteManager,
                                     paymentsAPIs: paymentsAPIs)
        let url = Bundle.module.url(forResource: "StoreKit_mock", withExtension: "storekit")!
        do {
            storeSession = try SKTestSession(contentsOf: url)
        } catch {
            debugPrint(error)
        }

        sut = TransactionHandler(remoteManager: remoteManager,
                                 paymentsAPIs: paymentsAPIs,
                                 receiptManger: MockStoreKitReceiptManager(receipt: "asdpoasmdpo12dp1o2mdpoasmdpoasmdcpaoscmapsomc"))

        try await super.setUp()
    }

    override func tearDown() async throws {
        subsComposer = nil
        cancellable.removeAll()
        mockRemoteManager.destroy()
        mockRemoteManager = nil
        storeSession = nil

        try await super.tearDown()
    }

    func test_transaction_state() async throws {
        // Fetch Proton plans
        mockRemoteManager.setupURLSessionMock(withMockResponse: ResponseStubber.remoteResponseFor(transactionState: .fetchProtonPlans))

        _ = try await subsComposer.fetchProtonPlans()
        _ = try await subsComposer.getStoreProducts(["iosvpn_bundle2022_12_usd_auto_renewing", "iosvpn_vpn2022_1_usd_auto_renewing"])

        try storeSession.buyProduct(productIdentifier: productsIds[0])

        // extract store receipt logic behind interface and mock it for testing

        guard let transaction = storeSession.allTransactions().first else {
            XCTFail("No transaction found")
            return
        }
        guard let composedPlan = subsComposer.matchPlanToStoreProduct(transaction.productIdentifier) else {
            XCTFail("No plan found")
            return
        }

        let protonTransaction = convertStoreTestTransaction(transaction, price: composedPlan.product.price, currencyId: "USD")

        sut.transactionState.sink { [weak self] state in
            guard let self = self else {
                XCTFail()
                return
            }
            debugPrint(state.localizedDescription ?? "")

            if state == .transactionProcessError {
                XCTFail()
            }

            self.mockRemoteManager.setupURLSessionMock(withMockResponse: ResponseStubber.remoteResponseFor(transactionState: state))

            debugPrint(state.localizedDescription ?? "")
            switch state {
            case .transactionCompleted:
                XCTAssert(true)
            default:
                debugPrint("Test in progress...")
            }

        }
        .store(in: &cancellable)

        _ = try await sut.processTransaction(protonTransaction, plan: composedPlan)
    }

    private func convertStoreTestTransaction(_ transaction: SKTestTransaction, price: Decimal, currencyId: String) -> ProtonTransaction {
        ProtonTransaction(id: UInt64(transaction.identifier),
                          originalID: UInt64(transaction.originalTransactionIdentifier),
                          productID: transaction.productIdentifier,
                          price: price,
                          currencyIdentifier: currencyId)
    }
}
#endif
