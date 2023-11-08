//
//  ObservabilityEndpointTests.swift
//  ProtonCore-Observability-Unit-UnitTests - Created on 30.01.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
@testable import ProtonCoreObservability

final class ObservabilityEndpointTests: XCTestCase {
    var sut: ObservabilityEndpoint!

    override func setUp() {
        super.setUp()
        sut = ObservabilityEndpoint()
    }

    func test_path() {
        XCTAssertEqual(sut.path, "/data/v1/metrics")
    }

    func test_method() {
        XCTAssertEqual(sut.method, .post)
    }

    func test_headers() {
        XCTAssertEqual(sut.headers as? [String: Int], ["x-msg-priority": 6])
    }

    func test_isAuth() {
        XCTAssertFalse(sut.isAuth)
    }

    func test_authCredential() {
        XCTAssertNil(sut.authCredential)
    }

    func test_retryPolicy() {
        XCTAssertEqual(sut.retryPolicy, .background)
    }

    func test_nonDefaultTimeout() {
        XCTAssertNil(sut.nonDefaultTimeout)
    }

    func test_authRetry() {
        XCTAssertTrue(sut.authRetry)
    }
}
