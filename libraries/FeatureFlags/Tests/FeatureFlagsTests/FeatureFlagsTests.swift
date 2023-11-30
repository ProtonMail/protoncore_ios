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
    var sut: FeatureFlagsRepository!

    private var featureFlagUserDefaults: UserDefaults!
    private let suiteName = "FeatureFlagsTests"

    override func setUp() {
        super.setUp()
        featureFlagUserDefaults = UserDefaults(suiteName: suiteName)!
        sut = .init(userId: Atomic<String>(""), localDatasource: Atomic<LocalFeatureFlagsProtocol>(DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)),
                    remoteDatasource: Atomic<RemoteFeatureFlagsProtocol?>(nil))
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
        XCTAssertEqual(sut.localDatasource.value.getStaticFeatureFlags(userId: userId), featureFlags)
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

    func test_setApiService_setsApiService() {
        // Given
        let apiService = APIServiceMock()
        XCTAssertNil(sut.remoteDataSource.value)

        // When
        sut.setApiService(with: apiService)

        // Then
        XCTAssertNotNil(sut.remoteDataSource.value)
    }

    // MARK: - isStaticFlagEnabled

    func test_isStaticFlagEnabled_returnsTrueIfFlagIsPresentAndEnabled() {
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
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabled_returnsFalsIfFlagIsNotPresent() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabled_returnsFalseIfFlagIsPresentAndDisabled() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabledForUser_returnsTrueIfFlagIsPresentAndEnabled() {
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
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabledForUser_returnsFalsIfFlagIsNotPresent() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, for: userId, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabledForUser_returnsFalseIfFlagIsPresentAndDisabled() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId, isFlagValueDynamic: false))
    }

    // MARK: - isDynamicFlagEnabled

    func test_isDynamicFlagEnabled_returnsTrueIfFlagIsPresentAndEnabled() {
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
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, isFlagValueDynamic: true))
    }

    func test_isDynamicFlagEnabled_returnsFalsIfFlagIsNotPresent() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, isFlagValueDynamic: true))
    }

    func test_isDynamicFlagEnabled_returnsFalseIfFlagIsPresentAndDisabled() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, isFlagValueDynamic: true))
    }

    func test_isDynamicFlagEnabledForUser_returnsTrueIfFlagIsPresentAndEnabled() {
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
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: true))
    }

    func test_isDynamicFlagEnabledForUser_returnsFalsIfFlagIsNotPresent() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, for: userId, isFlagValueDynamic: true))
    }

    func test_isDynamicFlagEnabledForUser_returnsFalseIfFlagIsPresentAndDisabled() {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId, isFlagValueDynamic: true))
    }

    // MARK: - fetchFlags

    func test_fetchFlags_withoutUserId_returnsFlagForUnauthSession() async throws {
        // Given
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = try await sut.localDatasource.value.getDynamicFeatureFlags(userId: "")
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlags_withUserId_returnsFlagForUserId() async throws {
        // Given
        let userId = "userId"
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags(for: userId)

        // Then
        let localFlags = try await sut.localDatasource.value.getDynamicFeatureFlags(userId: userId)
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
        let localFlags = try await sut.localDatasource.value.getDynamicFeatureFlags(userId: userId)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_isStaticFlagEnabledAlwaysReturnsSameValueForOneInstance() async throws {
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
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))

        // When fetching a second time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is false but isEnabled still returns the first returned value
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))
    }

    func test_isStaticFlagEnabledReturnsSameValueEventIfEmptyTheFirstTime() async throws {
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))

        // When fetching a second time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))
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
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))

        // When fetching the first time
        try await sut.fetchFlags(for: userId, with: apiService)

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId, isFlagValueDynamic: false))
    }

    func test_resetFlagsForUserId_resetsFlagsForuserId() async throws {
        // Given
        let userId1 = "userId1"
        let flagResponse1 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let userId2 = "userId2"
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

        // When
        try await sut.fetchFlags(for: userId1, with: apiService)
        try await sut.fetchFlags(for: userId2, with: apiService)

        // Then
        let flags = try await sut.localDatasource.value.getDynamicFeatureFlags(userId: userId1)
        XCTAssertEqual(flags, FeatureFlags(flags: flagResponse1.toggles))

        // When
        sut.resetFlags(for: userId1)

        // Then
        let emptyFlags: [String: FeatureFlags]? = featureFlagUserDefaults.decodableValue(forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        XCTAssertNil(emptyFlags?[userId1])
        XCTAssertNotNil(emptyFlags?[userId2])
    }

    func test_resetFlags_resetsFlags() async throws {
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
        let flags = try await sut.localDatasource.value.getDynamicFeatureFlags(userId: userId)
        XCTAssertEqual(flags, FeatureFlags(flags: flagResponse.toggles))

        // When
        sut.resetFlags()

        // Then
        let emptyFlags: [String: FeatureFlags]? = featureFlagUserDefaults.decodableValue(forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        XCTAssertNil(emptyFlags)
    }
}
