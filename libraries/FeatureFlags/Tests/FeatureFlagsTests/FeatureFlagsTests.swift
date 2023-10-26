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
import XCTest

enum TestFlagsType: String, FeatureFlagTypeProtocol {
    case blackFriday = "BlackFriday"
    case primaryVault = "PassRemovePrimaryVault"
    case notActivatedFlag = "ShouldNotAppear"
}

enum TestUpdatedFlagsType: String, FeatureFlagTypeProtocol {
    case editEmail = "EditEmailAddress"
    case accountRecovery = "SignedInAccountRecovery"
    case pageSizeSettings = "WebMailPageSizeSetting"
}

enum FeatureFlagsElementFactory {
    static let configuration1 = FeatureFlagsConfiguration(userId: "user", currentBUFlags: TestFlagsType.self)
    static let configuration2 = FeatureFlagsConfiguration(userId: "user2", currentBUFlags: TestUpdatedFlagsType.self)
}

final class FeatureFlagsTests: XCTestCase {
    let localDataSource = DefaultLocalFeatureFlagsDatasource()
    let remoteDataSource = DefaultRemoteDatasourceMock()
    var sut = FeatureFlagsRepository.shared

    override func setUp() {
        super.setUp()
        sut.updateLocalDataSource(with: Atomic<LocalFeatureFlagsProtocol>(localDataSource))
        sut.updateRemoteDataSource(with: Atomic<RemoteFeatureFlagsProtocol>(remoteDataSource))
    }

    func test_isEnabled_returnsTrueIfFlagisPresentAndEnabled() async throws {
        // Given
        sut.updateConfiguration(with: Atomic<FeatureFlagsConfiguration>(FeatureFlagsElementFactory.configuration1))

        // When
        try await sut.fetchFlags()

        // Then
        XCTAssertTrue(sut.isEnabled(TestFlagsType.blackFriday))
    }

    func test_isEnabled_returnsTrueIfFlagisPresentAndDisabled() async throws {
        // Given
        sut.updateConfiguration(with: Atomic<FeatureFlagsConfiguration>(FeatureFlagsElementFactory.configuration1))

        // When
        try await sut.fetchFlags()

        // Then
        XCTAssertFalse(sut.isEnabled(TestFlagsType.primaryVault))
    }

    func test_isEnabled_returnsTrueIfFlagisNotPresent() async throws {
        // Given
        sut.updateConfiguration(with: Atomic<FeatureFlagsConfiguration>(FeatureFlagsElementFactory.configuration1))

        // When
        try await sut.fetchFlags()

        // Then
        XCTAssertFalse(sut.isEnabled(TestUpdatedFlagsType.accountRecovery))
    }

    func testResetAllFlags() {
        sut.resetFlags()
        let flagsUser1 = localDataSource.getFeatureFlags(userId: FeatureFlagsElementFactory.configuration2.userId)
        let flagsUser2 = localDataSource.getFeatureFlags(userId: FeatureFlagsElementFactory.configuration1.userId)
        XCTAssertNil(flagsUser1)
        XCTAssertNil(flagsUser2)
    }
}
