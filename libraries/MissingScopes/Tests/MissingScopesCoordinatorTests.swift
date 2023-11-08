//
//  MissingScopesCoordinatorTests.swift
//  ProtonCore-MissingScopes-Unit-Tests - Created on 09.05.23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
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

#if os(iOS)

import XCTest
import ProtonCoreAuthentication
@testable import ProtonCoreMissingScopes
import ProtonCoreNetworking
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

final class MissingScopesCoordinatorTests: XCTestCase {
    var sut: MissingScopesCoordinator!
    var apiService: APIServiceMock!
    var responseHandlerData: PMResponseHandlerData!
    var authInfo: AuthInfoResponse!

    override func setUp() {
        super.setUp()
        setupMocks()
    }

    private func setupMocks() {
        apiService = APIServiceMock()
        responseHandlerData = .init(
            method: .put,
            path: "path",
            authenticated: true,
            authRetry: true,
            authRetryRemains: 1,
            retryPolicy: .background,
            onDataTaskCreated: { _ in }
        )
    }

    func test_didCloseVerifyPassword_completeWithClosedReason() {
        // Given
        let closedExpectation = XCTestExpectation(description: "verified expected")
        sut = MissingScopesCoordinator(
            apiService: apiService,
            username: "username",
            responseHandlerData: responseHandlerData,
            completion: { reason in
                switch reason {
                case .closed:
                    closedExpectation.fulfill()
                default:
                    XCTFail("expected closed reason")
                }
            }
        )

        // When
        sut.didCloseVerifyPassword()

        // Then
        wait(for: [closedExpectation], timeout: 0.1)
    }

    func test_didCloseWithError_completeWithClosedWithError() {
        // Given
        let closedWithErrorExpectation = XCTestExpectation(description: "verified expected")
        sut = MissingScopesCoordinator(
            apiService: apiService,
            username: "username",
            responseHandlerData: responseHandlerData,
            completion: { reason in
                switch reason {
                case .closedWithError(let code, let description):
                    closedWithErrorExpectation.fulfill()
                    XCTAssertEqual(code, 123)
                    XCTAssertEqual(description, "error")
                default:
                    XCTFail("expected closed reason")
                }
            }
        )

        // When
        sut.didCloseWithError(code: 123, description: "error")

        // Then
        wait(for: [closedWithErrorExpectation], timeout: 0.1)
    }
}

#endif
