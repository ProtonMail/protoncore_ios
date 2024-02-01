//
//  AccountRecoveryViewModelTests.swift
//  ProtonCore-AccountRecovery-Unit-Tests - Created on 16/7/23.
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
@testable import ProtonCoreAccountRecovery
@testable import ProtonCoreDataModel
import ProtonCoreAuthentication
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

private enum Fixtures {
    // We fix the start time for all tests, so the comparisons further down
    // will have some coarse accuracy
    static let currentTimeInterval = Date().timeIntervalSince1970
    static let username = "janedoe"
    static let email = "janedoe@protonmail.com"
    static let uid = "5cigpml2LD_iUk_3DkV29oojTt3eA=="
    static let gracePeriodInfo: RecoveryInfo = (username, email,
                                                AccountRecovery(state: .grace,
                                                                     reason: nil,
                                                                     startTime: currentTimeInterval - 3600 * 2,
                                                                     endTime: currentTimeInterval + 3600 * 70,
                                                                     UID: uid))
    static let defaultStateInfo: RecoveryInfo = (username, email,
                                                 AccountRecovery(state: .none,
                                                                      reason: nil,
                                                                      startTime: .zero,
                                                                      endTime: .zero,
                                                                      UID: uid))
    static let insecureStateInfo: RecoveryInfo = (username, email,
                                                  AccountRecovery(state: .insecure,
                                                                       reason: nil,
                                                                       startTime: currentTimeInterval - 3600 * 2,
                                                                       endTime: currentTimeInterval + 3600 * 70,
                                                                       UID: uid))

    static let cancelledStateInfo: RecoveryInfo = (username, email,
                                                   AccountRecovery(state: .cancelled,
                                                                        reason: .cancelled,
                                                                        startTime: .zero,
                                                                        endTime: .zero,
                                                                        UID: uid))
    static let expiredStateInfo: RecoveryInfo = (username, email,
                                                 AccountRecovery(state: .expired,
                                                                      reason: nil,
                                                                      startTime: currentTimeInterval - 3600 * 2,
                                                                      endTime: currentTimeInterval + 3600 * 70,
                                                                      UID: uid))
}

final class AccountRecoveryViewModelTests: XCTestCase {

    @MainActor
    func testFieldPopulationWithAccountRecoveryInactive() {
        // Given
        let sut = AccountRecoveryView.ViewModel()
        XCTAssertFalse(sut.isLoaded)
        let recoveryInfo = Fixtures.defaultStateInfo

        // When
        sut.populateWithAccountRecoveryInfo(recoveryInfo)

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.none, sut.state)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testFieldPopulationWithAccountRecoveryStarted() {
        // Given
        let sut = AccountRecoveryView.ViewModel()
        XCTAssertFalse(sut.isLoaded)
        let recoveryInfo = Fixtures.gracePeriodInfo

        // When
        sut.populateWithAccountRecoveryInfo(recoveryInfo)

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.grace, sut.state)
        XCTAssertEqual(3600 * 70, sut.remainingTime, accuracy: 60)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testFieldPopulationWithAccountRecoveryUnsecured() {
        // Given
        let sut = AccountRecoveryView.ViewModel()
        XCTAssertFalse(sut.isLoaded)
        let recoveryInfo = Fixtures.insecureStateInfo

        // When
        sut.populateWithAccountRecoveryInfo(recoveryInfo)

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.insecure, sut.state)
        XCTAssertEqual(3600 * 70, sut.remainingTime, accuracy: 60)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testFieldPopulationWithAccountRecoveryCancelled() {
        // Given
        let sut = AccountRecoveryView.ViewModel()
        XCTAssertFalse(sut.isLoaded)
        let recoveryInfo = Fixtures.cancelledStateInfo

        // When
        sut.populateWithAccountRecoveryInfo(recoveryInfo)

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.cancelled, sut.state)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testFieldPopulationWithAccountRecoveryExpired() {
        // Given
        let sut = AccountRecoveryView.ViewModel()
        XCTAssertFalse(sut.isLoaded)
        let recoveryInfo = Fixtures.expiredStateInfo

        // When
        sut.populateWithAccountRecoveryInfo(recoveryInfo)

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.expired, sut.state)
        XCTAssertEqual(3600 * 70, sut.remainingTime, accuracy: 60)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testDataLoading() async {
        // Given
        let repositoryMock = AccountRecoveryRepositoryMock()
        repositoryMock.returnedInfo = Fixtures.gracePeriodInfo

        // When
        let sut = AccountRecoveryView.ViewModel(accountRepository: repositoryMock)

        let expectation = XCTestExpectation(description: "wait for data load")

        let listener = sut.$isLoaded.sink { loaded in
            if loaded { expectation.fulfill() }
        }

        await fulfillment(of: [expectation])

        // Then
        XCTAssertEqual("janedoe@protonmail.com", sut.email)
        XCTAssertEqual(.grace, sut.state)
        XCTAssertEqual(.none, sut.reason)
        XCTAssertEqual(3600 * 70, sut.remainingTime, accuracy: 60)
        XCTAssert(sut.isLoaded)
    }

    @MainActor
    func testDataLoadingWhenThrowing() async {
        // This test checks that when there is an error fetching the data
        // (in this case, because the mock is not pre-loaded with returnedInfo)
        // the viewModel isLoaded remains false

        // Given
        let repositoryMock = AccountRecoveryRepositoryMock()

        // When
        let sut = AccountRecoveryView.ViewModel(accountRepository: repositoryMock)

        let expectation = XCTestExpectation(description: "wait for data load")
        expectation.isInverted = true

        let listener = sut.$isLoaded.sink { loaded in
            if loaded { expectation.fulfill() }
        }

        await fulfillment(of: [expectation], timeout: 5)

        // Then
        XCTAssertFalse(sut.isLoaded)
    }

    func testDataLoadingWhenPasswordIsVerified() async {
        // Given
        let repositoryMock = AccountRecoveryRepositoryMock()
        repositoryMock.returnedInfo = Fixtures.gracePeriodInfo
        let sut = AccountRecoveryView.ViewModel(accountRepository: repositoryMock)
        var expectation = XCTestExpectation(description: "wait for data load")
        let listener = sut.$isLoaded.sink { loaded in
            if loaded { expectation.fulfill() }
        }
        await fulfillment(of: [expectation], timeout: 5)

        repositoryMock.returnedInfo = Fixtures.cancelledStateInfo
        expectation = XCTestExpectation(description: "wait for second load")

        // When
        sut.userUnlocked()
        await fulfillment(of: [expectation], timeout: 5)

        // Then
        XCTAssert(sut.isLoaded)
        XCTAssertEqual(.cancelled, sut.state)
        XCTAssertEqual(.cancelled, sut.reason)
    }

    func testDataLoadingWhenPasswordIsDismissed() async {
        // Given
        let repositoryMock = AccountRecoveryRepositoryMock()
        repositoryMock.returnedInfo = Fixtures.gracePeriodInfo
        let sut = AccountRecoveryView.ViewModel(accountRepository: repositoryMock)
        var expectation = XCTestExpectation(description: "wait for data load")
        let listener = sut.$isLoaded.sink { loaded in
            if loaded { expectation.fulfill() }
        }
        await fulfillment(of: [expectation], timeout: 5)
        repositoryMock.returnedInfo = Fixtures.cancelledStateInfo

        expectation = XCTestExpectation(description: "wait for second load")

        // When
        sut.didCloseVerifyPassword()
        await fulfillment(of: [expectation], timeout: 5)

        // Then
        XCTAssert(sut.isLoaded)
        XCTAssertEqual(.cancelled, sut.state)
        XCTAssertEqual(.cancelled, sut.reason)
    }
}

private class AccountRecoveryRepositoryMock: AccountRecoveryRepositoryProtocol {
    var accountRecoveryDatasource: AccountRecoveryDatasourceProtocol
    var authService: AuthService
    var wasDataFetchCalled = false

    public var returnedInfo: RecoveryInfo? {
        didSet {
            wasDataFetchCalled = false
        }
    }

    init(){
        let apiMock = APIServiceMock()
        accountRecoveryDatasource = AccountRecoveryDatasource(apiService: apiMock)
        authService = AuthService(api: apiMock)
    }

    func fetchRecoveryState() async throws -> RecoveryInfo {
        wasDataFetchCalled = true
        guard let returnedInfo else {
            throw NSError(domain: "test domain", code: 666)
        }

        return returnedInfo
    }

    func accountRecoveryStatus() async -> ProtonCoreDataModel.AccountRecovery? {
        returnedInfo?.recovery
    }
}
#endif
