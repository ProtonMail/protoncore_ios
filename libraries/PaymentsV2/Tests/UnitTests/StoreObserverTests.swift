//
//  StoreObserverTests.swift
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
import XCTest

final class StoreObserverTests: XCTestCase, @unchecked Sendable {

    private var urlSessionConfig: URLSessionConfiguration!
    private var mockRemoteManager: MockedRemoteManager!

    private var sut: TransactionsObserver!
    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        sut = TransactionsObserver.shared
        mockRemoteManager = MockedRemoteManager()
        let plansMockResponse = Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        mockRemoteManager.setupURLSessionMock(withMockResponse: plansMockResponse)

        sut = TransactionsObserver.shared
        let configuration = TransactionsObserverConfiguration(sessionID: "asdasd12d",
                                                              authToken: "12d12",
                                                              appVersion: "V200",
                                                              doh: PaymentsDoH(),
                                                              atlasSecret: "qwdn12od")
        sut.setConfiguration(configuration)
    }

    override func tearDown() {
        super.tearDown()

        mockRemoteManager.destroy()
        mockRemoteManager = nil
        sut = nil
        cancellable = nil
    }

    func test_start_observer() async throws {
        cancellable = sut.$isON
            .dropFirst()
            .sink { state in
                XCTAssertTrue(state)
            }

        try await sut.start()
    }

    func test_stop_observer() async throws {
        cancellable = sut.$isON
            .dropFirst()
            .sink { state in
                XCTAssertFalse(state)
            }

        sut.stop()
    }
}
#endif
