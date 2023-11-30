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
        sut.updateLocalDataSource(localDataSource)

        // Then
        XCTAssertEqual(sut.localDatasource.value.getFeatureFlags(userId: userId, reloadFromUserDefaults: false), featureFlags)
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
        sut.setApiService(apiService)

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
            try await sut.fetchFlags(for: .unauth)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday))
    }

    func test_isEnabled_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: .unauth)
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
            try await sut.fetchFlags(for: .unauth)
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
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
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

        let apiService = APIServiceMock()
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(flagResponse))
        }

        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
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
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId))
    }

    // MARK: - isEnabled with reload value

    func test_isEnabled_reloadFromUserDefaults_returnsTrueIfFlagIsPresentAndEnabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: .unauth)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, reloadingValue: true))
    }

    func test_isEnabled_reloadFromUserDefaults_returnsFalseIfFlagIsNotPresent() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: .unauth)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, reloadingValue: true))
    }

    func test_isEnabled_reloadFromUserDefaults_returnsFalseIfFlagIsPresentAndDisabled() {
        // Given
        let expectation = XCTestExpectation(description: "fetch flags")
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        Task {
            try await sut.fetchFlags(for: .unauth)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, reloadingValue: true))
    }

    func test_isEnabledForUser_reloadFromUserDefaults_returnsTrueIfFlagIsPresentAndEnabled() {
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
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId, reloadingValue: true))
    }

    func test_isEnabledForUser_reloadFromUserDefaults_returnsFalseIfFlagIsNotPresent() {
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
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.fakeFlag, for: userId, reloadingValue: true))
    }

    func test_isEnabledForUser_reloadFromUserDefaults_returnsFalseIfFlagIsPresentAndDisabled() {
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
            try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertFalse(sut.isEnabled(TestFlagsType.disabledFlag, for: userId, reloadingValue: true))
    }

    // MARK: - fetchFlags

    func test_fetchFlags_withoutUserId_returnsFlagForUnauthSession() async throws {
        // Given
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags(for: .unauth)

        // Then
        let localFlags = sut.localDatasource.value.getFeatureFlags(userId: "", reloadFromUserDefaults: true)
        XCTAssertEqual(localFlags?.isEmpty, false)
    }

    func test_fetchFlags_withUserId_returnsFlagForUserId() async throws {
        // Given
        let userId = "userId"
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol?>(DefaultRemoteDatasourceMock()))

        // When
        try await sut.fetchFlags(for: .auth(userId: userId))

        // Then
        let localFlags = sut.localDatasource.value.getFeatureFlags(userId: userId, reloadFromUserDefaults: true)
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
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

        // Then
        let localFlags = sut.localDatasource.value.getFeatureFlags(userId: userId, reloadFromUserDefaults: true)
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
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

        // Then BlackFriday flag is true is isEnabled returns true
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

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
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

        // Then BlackFriday flag is not returned and is isEnabled returns false
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))

        // When fetching a second time
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

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
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

        // Then BlackFriday flag is returned and true, but isEnabled still returns the first returned value
        XCTAssertFalse(sut.isEnabled(TestFlagsType.blackFriday, for: userId))
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
        try await sut.fetchFlags(for: .auth(userId: userId1), using: apiService)
        try await sut.fetchFlags(for: .auth(userId: userId2), using: apiService)

        // Then
        let flags = sut.localDatasource.value.getFeatureFlags(userId: userId1, reloadFromUserDefaults: true)
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
        try await sut.fetchFlags(for: .auth(userId: userId), using: apiService)

        // Then
        let flags = sut.localDatasource.value.getFeatureFlags(userId: userId, reloadFromUserDefaults: true)
        XCTAssertEqual(flags, FeatureFlags(flags: flagResponse.toggles))

        // When
        sut.resetFlags()

        // Then
        let emptyFlags: [String: FeatureFlags]? = featureFlagUserDefaults.decodableValue(forKey: DefaultLocalFeatureFlagsDatasource.featureFlagsKey)
        XCTAssertNil(emptyFlags)
    }
}
