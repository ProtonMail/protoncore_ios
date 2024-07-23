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
import ProtonCoreNetworking
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsNetworking
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

    private var localDataSource: LocalFeatureFlagsDataSourceProtocol!
    private var overrideLocalDataSource: Atomic<OverrideFeatureFlagDataSourceProtocol>!
    private var featureFlagUserDefaults: UserDefaults!
    private let suiteName = "FeatureFlagsTests"

    override func setUp() {
        super.setUp()
        featureFlagUserDefaults = UserDefaults(suiteName: suiteName)!
        localDataSource = DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)
        overrideLocalDataSource = Atomic<OverrideFeatureFlagDataSourceProtocol>(OverrideLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults))
        sut = .init(localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>(localDataSource),
                    remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(nil))
        sut.overrideLocalDataSource = overrideLocalDataSource
    }

    override func tearDown() {
        super.tearDown()
        featureFlagUserDefaults.removePersistentDomain(forName: suiteName)
        localDataSource = nil
        overrideLocalDataSource = nil
        sut = nil
    }

    func test_updateLocalDataSource_updatesLocalDataSource() {
        // Given
        let userId = "userId"
        let featureFlags = FeatureFlags(flags: [.init(name: "flag", enabled: true, variant: nil)])
        featureFlagUserDefaults.setEncodableValue([userId: featureFlags], forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        let localDataSource = Atomic<LocalFeatureFlagsDataSourceProtocol>(
            DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)
        )

        let remoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        remoteFeatureFlagsDataSourceMock.userID = userId
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(remoteFeatureFlagsDataSourceMock))

        // When
        sut.updateLocalDataSource(localDataSource)

        // Then
        XCTAssertEqual(sut.localDataSource.value.getFeatureFlags(userId: userId, reloadFromLocalDataSource: false), featureFlags)
    }

    func test_updateRemoteDataSource_updatesRemoteDataSource() {
        // Given
        let remoteDataSource = DefaultRemoteFeatureFlagsDataSourceMock()
        XCTAssertNil(sut.remoteDataSource.value)

        // When
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(remoteDataSource))

        // Then
        XCTAssertNotNil(sut.remoteDataSource.value)
    }

    func test_setApiService_setsApiService() {
        // Given
        let apiService = APIServiceMock()
        XCTAssertNil(sut.remoteDataSource.value)

        // When
        sut.setApiService(apiService)

        // Then
        XCTAssertNotNil(sut.remoteDataSource.value)
    }

    // MARK: - Set user id

    func test_userIdIsInitializedWithUserDefaultValue() {
        // Given
        let userId = "newUserId"
        let featureFlagUserDefaults = UserDefaults(suiteName: #function)!
        featureFlagUserDefaults.set(userId, forKey: DefaultLocalFeatureFlagsDatasource.userIdKey)
        sut = .init(localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>(DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)),
                    remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(nil)
        )

        // When accessing userId
        _ = sut.userId

        // Then
        XCTAssertEqual(sut.userId, userId)
        featureFlagUserDefaults.removePersistentDomain(forName: #function)
    }

    func test_setUserId_saveUserIdInUserDefault() {
        // Given
        let userId = "userId"

        // When
        sut.setUserId(userId)

        // Then
        XCTAssertEqual(sut.localDataSource.value.userIdForActiveSession, userId)
    }

    func test_userIdIsEmptyByDefault() {
        // When
        _ = sut.userId

        // Then
        XCTAssertTrue(sut.userId.isEmpty)
    }

    // MARK: - isEnabled

    func test_isEnabled_returnsTrueIfFlagIsPresentAndEnabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday))
    }

    func test_isEnabled_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

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
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_isEnabledForUser_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: []
        )

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId))
    }

    // MARK: - isEnabled with reload value

    func test_isEnabled_reloadFromLocalDataSource_returnsTrueIfFlagIsPresentAndEnabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, reloadValue: true))
    }

    func test_isEnabled_reloadFromLocalDataSource_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, reloadValue: true))
    }

    func test_isEnabled_reloadFromLocalDataSource_returnsFalseIfFlagIsPresentAndDisabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, reloadValue: true))
    }

    func test_isEnabledForUser_reloadFromLocalDataSource_returnsTrueIfFlagIsPresentAndEnabled() {
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, reloadValue: true))
    }

    func test_isEnabledForUser_reloadFromLocalDataSource_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        let userId = "userId"
        let flagResponse = FeatureFlagResponse(
            code: 1000,
            toggles: []
        )

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, for: userId, reloadValue: true))
    }

    func test_isEnabledForUser_reloadFromLocalDataSource_returnsFalseIfFlagIsPresentAndDisabled() {
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        Task {
            try await sut.fetchFlags()
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId, reloadValue: true))
    }

    // MARK: - fetchFlags

    func test_fetchFlags_withoutUserIdSet_returnsFlagForUnauthSession() async throws {
        // Given
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(DefaultRemoteFeatureFlagsDataSourceMock()))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = sut.localDataSource.value.getFeatureFlags(userId: "", reloadFromLocalDataSource: true)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlags_withUserIdSet_returnsFlagForUserId_empty() async throws {
        // Given
        let userId = "userId"
        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = sut.localDataSource.value.getFeatureFlags(userId: userId, reloadFromLocalDataSource: true)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlagsForUserId_withUserIdSet_returnsFlagForUserId() async throws {
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        try await sut.fetchFlags()

        // Then
        let localFlags = sut.localDataSource.value.getFeatureFlags(userId: userId, reloadFromLocalDataSource: true)
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When fetching the first time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse1
        try await sut.fetchFlags()

        // Then BlackFriday flag is true is isEnabled returns true
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse2
        try await sut.fetchFlags()

        // Then BlackFriday flag is false but isEnabled still returns the first returned value
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_isEnabledReturnsSameValueEvenIfEmptyTheFirstTime() async throws {
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When fetching the first time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse1
        try await sut.fetchFlags()

        // Then BlackFriday flag is not returned and is isEnabled returns false
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse2
        try await sut.fetchFlags()

        // Then BlackFriday flag is returned and true, but isEnabled still returns
        // the first-returned value (false)
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // Then BlackFriday flag is not returned and is isEnabled returns false
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching the first time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse
        try await sut.fetchFlags()

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
    }

    func test_fetchFlags_removesFlagsNotPresentInResponseFromLocalDataSource() async throws {
        // Given
        let userId = "userId"
        let flagResponse1 = FeatureFlagResponse(
            code: 1000,
            toggles: [
                .init(
                    name: "BlackFriday",
                    enabled: true,
                    variant: nil
                ),
                .init(
                    name: "ShouldNotAppear",
                    enabled: true,
                    variant: nil
                )
            ]
        )

        let flagResponse2 = FeatureFlagResponse(
            code: 1000,
            toggles: [.init(
                name: "BlackFriday",
                enabled: true,
                variant: nil
            )]
        )

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        sut.setUserId(userId)

        // When flags are fetched the first time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse1
        try await sut.fetchFlags()

        // Then 2 flags should be returned
        let localFlags1 = sut.localDataSource.value.getFeatureFlags(
            userId: userId,
            reloadFromLocalDataSource: true)
        XCTAssertEqual(localFlags1?.flagsCount, 2)
        XCTAssertTrue(sut.isEnabled(TestFlagsType.notActivatedFlag, reloadValue: true))

        // When fetched the second time
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse2
        try await sut.fetchFlags()

        // Then only one flag should be returned, and the deleted FF should
        // no longer be in the local data source.
        let localFlags2 = sut.localDataSource.value.getFeatureFlags(
            userId: userId,
            reloadFromLocalDataSource: true)
        XCTAssertEqual(localFlags2?.flagsCount, 1)
        XCTAssertFalse(sut.isEnabled(TestFlagsType.notActivatedFlag, reloadValue: true))
    }

    // MARK: - Reset

    func test_resetFlagsForUserId_resetsFlagsForUserId() async throws {
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId1
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse1
        try await sut.fetchFlags()

        defaultRemoteFeatureFlagsDataSourceMock.userID = userId2
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse2
        try await sut.fetchFlags()

        // Then
        let flags = sut.localDataSource.value.getFeatureFlags(userId: userId1, reloadFromLocalDataSource: true)
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

        let defaultRemoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        defaultRemoteFeatureFlagsDataSourceMock.userID = userId
        defaultRemoteFeatureFlagsDataSourceMock.featureFlagResponse = flagResponse

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(defaultRemoteFeatureFlagsDataSourceMock))

        // When
        try await sut.fetchFlags()

        // Then
        let flags = sut.localDataSource.value.getFeatureFlags(userId: userId, reloadFromLocalDataSource: true)
        XCTAssertEqual(flags, FeatureFlags(flags: flagResponse.toggles))

        // When
        sut.resetFlags()

        // Then
        let emptyFlags: [String: FeatureFlags]? = featureFlagUserDefaults.decodableValue(forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        XCTAssertNil(emptyFlags)
    }

    func test_clearUserId_clearsUserId() {
        // Given
        let userId = "userId"
        localDataSource.setUserIdForActiveSession(userId)
        XCTAssertEqual(localDataSource.userIdForActiveSession, userId)
        sut = .init(localDataSource: Atomic<LocalFeatureFlagsDataSourceProtocol>(localDataSource),
                    remoteDataSource: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(nil))
        XCTAssertEqual(sut.userId, userId)

        // When
        sut.clearUserId()

        // Then
        XCTAssertNil(localDataSource.userIdForActiveSession)
    }

    // MARK: Override Feature Flag

    typealias TestFlag = (any FeatureFlagTypeProtocol, Bool)

    private func populateLocalDataSource(flags: [TestFlag], for userId: String) -> Atomic<LocalFeatureFlagsDataSourceProtocol> {

        var flagsArray: [FeatureFlag] = []

        flags.forEach { flag in
            flagsArray.append(FeatureFlag(name: flag.0.rawValue, enabled: flag.1, variant: nil))
        }

        let featureFlags = FeatureFlags(flags: flagsArray)
        featureFlagUserDefaults.setEncodableValue([userId: featureFlags], forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        let localDataSource = Atomic<LocalFeatureFlagsDataSourceProtocol>(
            DefaultLocalFeatureFlagsDatasource(userDefaults: featureFlagUserDefaults)
        )

        let remoteFeatureFlagsDataSourceMock = DefaultRemoteFeatureFlagsDataSourceMock()
        remoteFeatureFlagsDataSourceMock.userID = userId
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsDataSourceProtocol?>(remoteFeatureFlagsDataSourceMock))

        return localDataSource
    }

    func test_default_status_for_overridden_flag() {
        // Given
        let userId = "userId"

        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.fakeFlag, true)], for: userId)

        // When
        sut.updateLocalDataSource(localDataSource)

        // Then
        XCTAssertNil(sut.overrideLocalDataSource.value.getFeatureFlags())
    }

    func test_override_feature_flag() {
        // Given
        let userId = "userId"
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.blackFriday, true)], for: userId)

        // When
        sut.updateLocalDataSource(localDataSource)
        sut.setFlagOverride(TestFlagsType.blackFriday, false)

        // Then
        XCTAssertTrue(sut.overrideLocalDataSource.value.getFeatureFlags()?.getFlag(for: TestFlagsType.blackFriday) != nil)
    }

    func test_override_flag_not_provided_by_Unleash() {

        // When
        sut.setFlagOverride(TestFlagsType.disabledFlag, true)
        sut.setFlagOverride(TestFlagsType.notActivatedFlag, false)

        // Then
        XCTAssertTrue(sut.isEnabled(TestFlagsType.disabledFlag))
        XCTAssertFalse(sut.isEnabled(TestFlagsType.notActivatedFlag))
    }
    
    func test_override_flag_not_provided_by_Unleash_for_a_given_userId() {
        // Given
        let userId = "userId"

        // When
        sut.setUserId(userId)
        sut.setFlagOverride(TestFlagsType.disabledFlag, true)
        sut.setFlagOverride(TestFlagsType.notActivatedFlag, false)

        // Then
        XCTAssertTrue(sut.isEnabled(TestFlagsType.disabledFlag))
        XCTAssertFalse(sut.isEnabled(TestFlagsType.notActivatedFlag))
    }

    func test_remove_overridden_feature_flag() {
        // Given
        let userId = "userId"
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.blackFriday, true)], for: userId)

        // When
        sut.updateLocalDataSource(localDataSource)
        sut.setFlagOverride(TestFlagsType.blackFriday, true)
        sut.resetFlagOverride(TestFlagsType.blackFriday)

        // Then
        XCTAssertTrue(sut.overrideLocalDataSource.value.getFeatureFlags()?.getFlag(for: TestFlagsType.blackFriday) == nil)
    }

    func test_clean_overridden_feature_flags() {
        // Given
        let userId = "userId"
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.blackFriday, true), TestFlag(TestFlagsType.notActivatedFlag, true)], for: userId)

        sut.updateLocalDataSource(localDataSource)
        sut.setFlagOverride(TestFlagsType.blackFriday, false)
        sut.setFlagOverride(TestFlagsType.notActivatedFlag, false)

        // When
        sut.resetOverrides()

        // Then
        let emptyFlags: [String: FeatureFlags]? = featureFlagUserDefaults.decodableValue(forKey: OverrideLocalFeatureFlagsDatasource.overrideFeatureFlagsKey)
        XCTAssertNil(emptyFlags?[userId])
    }

    func test_override_feature_flag_return_overridden_value() {
        // Given
        let userId = "userId"
        let defaultValue = true
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.blackFriday, defaultValue)], for: userId)

        // When
        sut.setUserId(userId)
        sut.updateLocalDataSource(localDataSource)
        sut.setFlagOverride(TestFlagsType.blackFriday, false)

        // Then
        XCTAssertEqual(sut.isEnabled(TestFlagsType.blackFriday), !defaultValue)
    }

    func test_remove_override_feature_flag() {
        // Given
        let userId = "userId"
        let defaultValue = true
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.blackFriday, defaultValue)], for: userId)

        // When
        sut.setUserId(userId)
        sut.updateLocalDataSource(localDataSource)
        sut.setFlagOverride(TestFlagsType.blackFriday, false)
        sut.resetFlagOverride(TestFlagsType.blackFriday)

        // Then
        XCTAssertEqual(sut.isEnabled(TestFlagsType.blackFriday), defaultValue)
    }
    
    func test_remove_unexistent_overridden_feature_flag() {
        // Given
        let expectedCount = 1
        
        // When
        sut.setFlagOverride(TestFlagsType.notActivatedFlag, true)
        sut.resetFlagOverride(TestFlagsType.blackFriday)
       
        // Then
        XCTAssertEqual(sut.overrideLocalDataSource.value.getFeatureFlags()?.flagsCount, expectedCount)
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday))
    }
    
    func test_sync_overridden_flags_after_setting_userId() {
        // Given
        let userId = "userId"
        let expectedFlagValue = false
        let localDataSource = populateLocalDataSource(flags: [TestFlag(TestFlagsType.fakeFlag, true)], for: userId)

        // When
        sut.setFlagOverride(TestFlagsType.blackFriday, expectedFlagValue)
        sut.setUserId(userId)
        sut.updateLocalDataSource(localDataSource)
    
        // Then
        XCTAssertEqual(sut.isEnabled(TestFlagsType.blackFriday), expectedFlagValue)
    }
    
    func test_override_add_flag() {
        // Given
        let expectedCount = 1
        let expectedValue = false

        // When
        sut.setFlagOverride(TestFlagsType.blackFriday, expectedValue)
    
        // Then
        XCTAssertEqual(sut.overrideLocalDataSource.value.getFeatureFlags()?.flagsCount, expectedCount)
        XCTAssertEqual(sut.isEnabled(TestFlagsType.blackFriday), expectedValue)
    }
    
    func test_override_replace_existing_flag() {
        // Given
        let expectedCount = 2
        let expectedValue = true

        // When
        sut.setFlagOverride(TestFlagsType.fakeFlag, false)
        sut.setFlagOverride(TestFlagsType.blackFriday, false)
        sut.setFlagOverride(TestFlagsType.blackFriday, true)
    
        // Then
        XCTAssertEqual(sut.isEnabled(TestFlagsType.blackFriday), expectedValue)
        XCTAssertEqual(sut.overrideLocalDataSource.value.getFeatureFlags()?.flagsCount, expectedCount)
    }
}
