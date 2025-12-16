//
//  OCTransactionHandlerTests.swift
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

final class OCTransactionHandlerTests: XCTestCase, @unchecked Sendable {

    private var mockRemoteManager: RemoteManagerProviding!

    private let productsIds = ["iosvpn_bundle2022_12_usd_auto_renewing", "iosvpn_vpn2022_1_usd_auto_renewing"]
    private var subsComposer: PlansComposer!
    private var storeSession: SKTestSession!

    private var cancellable = Set<AnyCancellable>()

    private var sut: TransactionHandlerProviding!

    override func setUp() async throws {

        mockRemoteManager = MockRemoteManager()
        subsComposer = PlansComposer(remoteManager: mockRemoteManager)
        let url = Bundle.module.url(forResource: "StoreKit_mock", withExtension: "storekit")!
        do {
            storeSession = try SKTestSession(contentsOf: url)
        } catch {
            debugPrint(error)
        }

        sut = OCTransactionHandler(remoteManager: mockRemoteManager)

        try await super.setUp()
    }

    override func tearDown() {
        subsComposer = nil
        cancellable.removeAll()

        super.tearDown()
    }

    func test_transaction_state() async throws {

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

        let protonTransaction = TransactionStubber.convertStoreTestTransaction(transaction, price: composedPlan.product.price, currencyId: "USD", renewal: false)

        sut.transactionState.sink { state in
            debugPrint(state.localizedDescription ?? "")

            if state == .transactionProcessError {
                XCTFail()
            }

            debugPrint(state.localizedDescription ?? "")
            switch state {
            case .transactionCompleted:
                XCTAssert(true)
            default:
                debugPrint("Test in progress...")
            }

        }
        .store(in: &cancellable)

        _ = try await sut.processTransaction(protonTransaction, jwsRepresentation: "asdasd12d12d12d", plan: composedPlan)
    }

    func test_transaction_renewal_state() async throws {

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

        let protonTransaction = TransactionStubber.convertStoreTestTransaction(transaction, price: composedPlan.product.price, currencyId: "USD", renewal: true)

        sut.transactionState.sink { state in
            debugPrint(state.localizedDescription ?? "")

            if state == .transactionProcessError {
                XCTFail()
            }

            debugPrint(state.localizedDescription ?? "")
            switch state {
            case .transactionCompleted:
                XCTAssert(true)
            default:
                debugPrint("Test in progress...")
            }

        }
        .store(in: &cancellable)

        _ = try await sut.processTransaction(protonTransaction, jwsRepresentation: "asdasd12d12d12d", plan: composedPlan)
    }

    func test_UUID_fetched_when_not_provided() async throws {

        let mockUUID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let mockUUID2 = UUID(uuidString: "E621E1F8-C46C-495A-93FC-0C247A3E6E5F")!
        let positiveResult = try await sut.verifyTransactionUUIDs(appAccountToken: mockUUID)
        let negativeResult = try await sut.verifyTransactionUUIDs(appAccountToken: mockUUID2)

        XCTAssertTrue(positiveResult)
        XCTAssertFalse(negativeResult)
    }

    func test_UUID_provided_at_init() async throws {

        let mockUUID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let mockUUID2 = UUID(uuidString: "E621E1F8-C46C-495A-93FC-0C247A3E6E5F")!
        sut = OCTransactionHandler(remoteManager: mockRemoteManager,
                                   appAccountToken: mockUUID)
        let positiveResult = try await sut.verifyTransactionUUIDs(appAccountToken: mockUUID)
        let negativeResult = try await sut.verifyTransactionUUIDs(appAccountToken: mockUUID2)

        XCTAssertTrue(positiveResult)
        XCTAssertFalse(negativeResult)
    }
}
#endif
