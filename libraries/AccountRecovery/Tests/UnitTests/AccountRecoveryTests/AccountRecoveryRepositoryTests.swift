//
//  AccountRecoveryRepositoryTests.swift
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

import XCTest
@testable import ProtonCoreAccountRecovery
@testable import ProtonCoreDataModel
@testable import ProtonCoreAuthentication
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif

final class AccountRecoveryRepositoryTests: XCTestCase {

    var sut: AccountRecoveryRepository!
    var apiMock: APIServiceMock!

    override func setUp() {
        super.setUp()
        apiMock = APIServiceMock()
        sut = AccountRecoveryRepository(apiService: apiMock)
    }

    func testFetchingRecoveryStateWithDisabledFeatureSwitch() async throws {
        // Given
        let user = User(ID: "5cigpml2LD_iUk_3DkV29oojTt3eA==",
                        name: "Jane Doe",
                        usedSpace: 1,
                        currency: "EUR",
                        credit: 0,
                        maxSpace: 2,
                        maxUpload: 3,
                        role: 2,
                        private: 1,
                        subscribed: .drive,
                        services: 5,
                        delinquent: 0,
                        orgPrivateKey: nil,
                        email: "jdoe@protonmail.com",
                        displayName: "Jane D",
                        keys: [],
                        accountRecovery: nil)
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, decodableCompletion  in
            if path == "/users" {
                decodableCompletion(nil, .success(AuthService.UserResponse(user: user)))
            } else {
                XCTFail("Unexpected request")
            }
        }

        // When
        let (username, email, recovery) = try await sut.fetchRecoveryState()

        // Then
        XCTAssertEqual("Jane Doe", username)
        XCTAssertEqual("jdoe@protonmail.com", email)
        XCTAssertNil(recovery)
    }

    func testFetchingRecoveryStateThrowingError() async throws {
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, decodableCompletion  in
            if path == "/users" {
                decodableCompletion(nil, .failure(NSError(domain: "test domain", code: 666)))
            } else {
                XCTFail("Unexpected request")
            }
        }

        // We can't XCTAssertThrowsError async, so we use this workaround
        do {
            // When
            _ = try await sut.fetchRecoveryState()
            XCTFail("Should have thrown")
        } catch {
            // Success!
        }
    }

    func testFetchingRecoveryState() async throws {
        // Given
        let recovery = User.AccountRecovery(state: .none,
                                            reason: User.RecoveryReason.none,
                                            startTime: .zero,
                                            endTime: .zero,
                                            UID: "5cigpml2LD_iUk_3DkV29oojTt3eA==")
        let user = User(ID: "5cigpml2LD_iUk_3DkV29oojTt3eA==",
                        name: "Jane Doe",
                        usedSpace: 1,
                        currency: "EUR",
                        credit: 0,
                        maxSpace: 2,
                        maxUpload: 3,
                        role: 2,
                        private: 1,
                        subscribed: .drive,
                        services: 5,
                        delinquent: 0,
                        orgPrivateKey: nil,
                        email: "jdoe@protonmail.com",
                        displayName: "Jane D",
                        keys: [],
                        accountRecovery: recovery)
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, decodableCompletion  in
            if path == "/users" {
                decodableCompletion(nil, .success(AuthService.UserResponse(user: user)))
            } else {
                XCTFail("Unexpected request")
            }
        }

        // When
        let (username, email, accountRecovery) = try await sut.fetchRecoveryState()

        // Then
        XCTAssertEqual("Jane Doe", username)
        XCTAssertEqual("jdoe@protonmail.com", email)
        XCTAssertEqual(.none, try XCTUnwrap(accountRecovery?.state))
    }

    func testAccountRecoveryStatus() async {
        // Given
        let recovery = User.AccountRecovery(state: .none,
                                            reason: User.RecoveryReason.none,
                                            startTime: .zero,
                                            endTime: .zero,
                                            UID: "5cigpml2LD_iUk_3DkV29oojTt3eA==")
        let user = User(ID: "5cigpml2LD_iUk_3DkV29oojTt3eA==",
                        name: nil,
                        usedSpace: 1,
                        currency: "EUR",
                        credit: 0,
                        maxSpace: 2,
                        maxUpload: 3,
                        role: 2,
                        private: 1,
                        subscribed: .drive,
                        services: 5,
                        delinquent: 0,
                        orgPrivateKey: nil,
                        email: "jdoe@protonmail.com",
                        displayName: "Jane D",
                        keys: [],
                        accountRecovery: recovery)
        apiMock.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, decodableCompletion  in
            if path == "/users" {
                decodableCompletion(nil, .success(AuthService.UserResponse(user: user)))
            } else {
                XCTFail("Unexpected request")
            }
        }

        let status = await sut.accountRecoveryStatus()

        XCTAssertEqual(recovery, status)
    }
}
