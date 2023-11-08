//
//  MissingScopesHandlerTests.swift
//  ProtonCore-MissingScopes-Unit-Tests - Created on 26.04.23.
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

#if os(iOS)

@testable import ProtonCoreMissingScopes
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import XCTest

final class MissingScopesHandlerTests: XCTestCase {
    var sut: MissingScopesHandler!
    var apiService: APIServiceMock!
    var coordinator: MissingScopesCoordinatorMock!
    var responseHandlerData: PMResponseHandlerData!

    override func setUp() {
        super.setUp()
        coordinator = MissingScopesCoordinatorMock()
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
        sut = MissingScopesHandler(
            apiService: apiService,
            queue: .immediateExecutor,
            missingScopesCoordinator: coordinator
        )
    }

    // MARK: - onMissingScopesHandling

    func test_onMissingScopesHandling_callsShowAskPassword() {
        // When
        sut.onMissingScopesHandling(
            username: "username",
            responseHandlerData: responseHandlerData) { _ in }

        // Then
        XCTAssertTrue(coordinator.showAskPasswordCalled)
    }
}

class MissingScopesCoordinatorMock: MissingScopesCoordinatorDelegate {
    var showAskPasswordCalled = false
    func showAskPassword() {
        showAskPasswordCalled = true
    }
}

#endif
