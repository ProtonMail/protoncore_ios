//
//  FeatureFlagsTests.swift
//  ProtonCore-FeatureFlags - Created on 29.09.23.
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

@testable import ProtonCoreFeatureFlags
import ProtonCoreUtilities
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import XCTest

enum TestFlagsType: String, FeatureFlagTypeProtocol {
    case blackFriday = "BlackFriday"
    case primaryVault = "PassRemovePrimaryVault"
    case notActivatedFlag = "ShouldNotAppear"
    case fakeFlag = "fakeFlag"
    case disabledFlag = "DisabledFlag"
}

final class FeatureFlagsTests: XCTestCase {
    var sut = FeatureFlagsRepository.shared

    private var featureFlagUserDefaults: UserDefaults!
    private let suiteName = "FeatureFlagsTests"
    override func setUp() {
        super.setUp()
        featureFlagUserDefaults = UserDefaults(suiteName: suiteName)!
        sut.setUserId(with: "")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(nil))
        sut.updateLocalDataSource(with: Atomic<LocalFeatureFlagsProtocol>(DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)))
    }

    override func tearDown() {
        super.tearDown()
        featureFlagUserDefaults.removePersistentDomain(forName: suiteName)
    }

    func test_updateLocalDataSource_updatesLocalDataSource() {
        // Given
        let userId = "userId"
        let featureFlags = FeatureFlags(flags: [.init(name: "flag", enabled: true, variant: nil)])
        featureFlagUserDefaults.setEncodableValue([userId: featureFlags], forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        let localDataSource = Atomic<LocalFeatureFlagsProtocol>(
            DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)
        )
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        sut.updateLocalDataSource(with: localDataSource)

        // Then
        XCTAssertEqual(sut.localDatasource.value.getFeatureFlags(userId: userId), featureFlags)
    }

    func test_updateRemoteDataSource_updatesRemoteDataSource() {
        // Given
        let remoteDataSource = DefaultRemoteDatasourceMock()
        XCTAssertNil(sut.remoteDataSource.value)

        // When
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(remoteDataSource))

        // Then
        XCTAssertNotNil(sut.remoteDataSource.value)
    }

    func test_setUserId_setsUserId() {
        // Given
        let userId = "userId"
        XCTAssertTrue(sut.userId.value.isEmpty)

        // When
        sut.setUserId(with: userId)

        // Then
        XCTAssertEqual(sut.userId.value, userId)
    }

    func test_setApiService_setsApiService() {
        // Given
        let apiService = APIServiceMock()
        XCTAssertNil(sut.remoteDataSource.value)

        // When
        sut.setApiService(with: apiService)

        // Then
        XCTAssertNotNil(sut.remoteDataSource.value)
    }

    // MARK: - isEnabled

    func test_isEnabled_returnsTrueIfFlagIsPresentAndEnabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday))
    }

    func test_isEnabled_returnsFalsIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag))
    }

    func test_isEnabled_returnsFalseIfFlagIsPresentAndDisabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag))
    }

    func test_isEnabledForUser_returnsTrueIfFlagIsPresentAndEnabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: userId, with: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_isEnabledForUser_returnsFalsIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: []
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: userId, with: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, for: userId))
    }

    func test_isEnabledForUser_returnsFalseIfFlagIsPresentAndDisabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "DisabledFlag",
                enabled: false,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: userId, with: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId))
    }

    // MARK: - fetchFlags

    func test_fetchFlags_withoutUserId_returnsFlagForUnauthSession() async throws {
        // Given
        XCTAssertTrue(sut.userId.value.isEmpty)
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = try await sut.localDatasource.value.getFeatureFlags(userId: "")
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlags_withUserId_returnsFlagForUserId() async throws {
        // Given
        let userId = "userId"
        sut.setUserId(with: userId)
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = try await sut.localDatasource.value.getFeatureFlags(userId: userId)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlagsForUserId_withUserId_returnsFlagForUserId() async throws {
        // Given
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }

        // When
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then
        let localFlags = try await sut.localDatasource.value.getFeatureFlags(userId: userId)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_isEnabledAlwaysReturnsSameValueForOneInstance() async throws {
        // Given
        let userId = "userId"
        let flagResponse1 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )
        let flagResponse2 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: false,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { count, _, _, _, _, _, _, _, _, _, _, completion in
            if count == 1 {
                completion(nil, .success(flagResponse1))
            } else {
                completion(nil, .success(flagResponse2))
            }
        }

        // When fetching the first time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is true is isEnabled returns true
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is false but isEnabled still returns the first returned value
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_isEnabledReturnsSameValueEventIfEmptyTheFirstTime() async throws {
        // Given
        let userId = "userId"
        let flagResponse1 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "DisabledFlag",
                enabled: true,
                variant: nil
            )]
        )
        let flagResponse2 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { count, _, _, _, _, _, _, _, _, _, _, completion in
            if count == 1 {
                completion(nil, .success(flagResponse1))
            } else {
                completion(nil, .success(flagResponse2))
            }
        }

        // When fetching the first time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is not returned and is isEnabled returns false
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_fetchingFlagsWhenUserDefaultAreEmptyShouldAlwaysReturnFalse() async throws {
        // Given
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }

        // Then BlackFriday flag is not returned and is isEnabled returns false
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching the first time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }
}
