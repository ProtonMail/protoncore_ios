//
//  File.swift
//  ProtonCore
//
//  Created by Tiziano Bruni on 03/11/2025.
//

#if os(iOS)

import Combine
@testable import ProtonCorePaymentsV2
import StoreKitTest
import XCTest

final class ProtonPlansManagerTests: XCTestCase, @unchecked Sendable {

    private var mockRemoteManager: RemoteManagerProviding!
    private var sut: ProtonPlansManager!
    private var mockObserver = TransactionsObserver.shared

    override func setUp() async throws {

        mockRemoteManager = MockRemoteManager()

        mockObserver = TransactionsObserver.shared
        let configuration = TransactionsObserverConfiguration(remoteManager: mockRemoteManager)
        mockObserver.setConfiguration(configuration)
        try await mockObserver.start()

        sut = ProtonPlansManager(remoteManager: mockRemoteManager)

        try await super.setUp()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func test_build_purchase_options_no_optionsProvided() async throws {

        let mockUUID = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let options = try await sut.buildPurchaseOptions(nil)

        uuiTokenPresent(options, token: mockUUID)
        XCTAssert(options.count == 1)
    }

    func test_build_purchase_options_optionsProvided() async throws {

        let mockUUID = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"

        let providedOptions: Set<Product.PurchaseOption> = [.custom(key: "some key", value: "someValue"),
                                                            .custom(key: "some key 2", value: "someValue 2")]
        let options = try await sut.buildPurchaseOptions(providedOptions)
        let expectedLength = providedOptions.count + 1 // + 1 to account for the UUID property always added

        uuiTokenPresent(options, token: mockUUID)
        XCTAssert(options.count == expectedLength)
    }

    func uuiTokenPresent(_ options: Set<Product.PurchaseOption>, token: String) {
        let expectedUUID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
        return XCTAssertTrue(options.contains(.appAccountToken(expectedUUID!)))
    }
}
#endif
