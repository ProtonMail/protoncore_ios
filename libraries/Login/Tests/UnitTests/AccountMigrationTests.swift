//
//  AccountMigrationTests.swift
//  ProtonCore-Login-Unit-Tests - Created on 28/05/2021.
//
//  Copyright (c) 2022 Proton Technologies AG
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import XCTest

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDataModel
import ProtonCoreTestingToolkitUnitTestsNetworking
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreFeatureSwitch
@testable import ProtonCoreLogin

final class AccountMigrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    private func createStack(minimumAccountType: AccountType, credential: Credential = .dummy.updated(UID: "test session ID")) -> (LoginService, APIServiceMock, AuthHelper, AuthenticatorWithKeyGenerationMock) {
        let apiMock = APIServiceMock()
        apiMock.sessionUIDStub.fixture = "test session ID"
        let authManager = AuthHelper(credential: credential)
        let authenticatorMock = AuthenticatorWithKeyGenerationMock()
        apiMock.authDelegateStub.fixture = authManager
        let login = LoginService(api: apiMock, clientApp: .other(named: "core"), minimumAccountType: minimumAccountType, authenticator: authenticatorMock)
        return (login, apiMock, authManager, authenticatorMock)
    }

    func testAccountMigrationDoesntHappenWhenUsernameRequired() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .username)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success(.empty)) }
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: .dummy.updated(name: "test user"),
                                                               mailboxPassword: "test password",
                                                               passwordMode: .one) { result in
            guard case .success(.finished) = result else { XCTFail("login should succeed"); return }
        }
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasCalled)
        XCTAssertTrue(authenticatorMock.setupAccountKeysStub.wasNotCalled)
        XCTAssertTrue(authenticatorMock.createAddressStub.wasNotCalled)
        XCTAssertTrue(authenticatorMock.createAddressKeyStub.wasNotCalled)
        XCTAssertTrue(authenticatorMock.setUsernameStub.wasNotCalled)
    }

    func testAccountMigrationReturnsProperlyFormattedDataForUsernameRequirement() {
        let (login, _, authManager, authenticatorMock) = createStack(minimumAccountType: .username)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success(.empty)) }
        authManager.onUpdate(credential: .dummy.updated(UID: login.sessionId, scopes: ["scope for \(#function)"]),
                             sessionUID: login.sessionId)
        var credential: Credential?
        let expectation = XCTestExpectation()
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: .dummy.updated(name: "test user"),
                                                               mailboxPassword: "test password",
                                                               passwordMode: .one) { result in
            guard case .success(.finished(let loginData)) = result else { XCTFail("login should succeed"); return }
            credential = loginData.getCredential
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(login.sessionId, credential?.UID)
        XCTAssertEqual(Credential.dummy.accessToken, credential?.accessToken)
        XCTAssertEqual(Credential.dummy.refreshToken, credential?.refreshToken)
    }

    func testAccountMigrationDoesHappenWhenInternalRequiredAndUserIsExternal_CapC() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        login.username = "username for \(#function)"
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: .dummy,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .success(.chooseInternalUsernameAndCreateInternalAddress(let createAddressData)) = result
            else { XCTFail("login should succeed"); return }
            XCTAssertEqual(createAddressData.email, "username for \(#function)")
            XCTAssertEqual(createAddressData.user, .dummy)
            XCTAssertEqual(createAddressData.mailboxPassword, "mailbox password for \(#function)")
        }
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasNotCalled)
    }

    func testAccountMigrationFailsWhenFetchingAddressesFails() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.failure(.notImplementedYet("because we're in tests"))) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [Key(keyID: "test", privateKey: "test private")])
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .failure(.generic(message: "because we're in tests", _, _)) = result else { XCTFail("login should fail"); return }
        }
    }

    func testAccountMigrationFailsWhenFetchingAddressesFailsBecauseApiIsBlocked() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        let responseError = ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: nil,
                                          underlyingError: .protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: "test message"))
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.failure(.apiMightBeBlocked(message: "test message", originalError: responseError))) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [Key(keyID: "test", privateKey: "test private")])
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .failure(.apiMightBeBlocked(message: "test message", let originalError)) = result else { XCTFail("login should fail"); return }
            XCTAssertEqual(responseError, originalError as? ResponseError)
        }
    }

    func testAccountMigrationFailsWhenNoAddresses() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success(.empty)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [Key(keyID: "test", privateKey: "test private")])
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .failure(.invalidState) = result else { XCTFail("login should fail"); return }
        }
    }

    func testAccountMigrationSetupsAccountKeysIfUserWithoutKeys() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy])) }
        let testUser = User.dummy.updated(name: "user for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { _ in }
        XCTAssertTrue(authenticatorMock.setupAccountKeysStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationSetupsAccountKeysOnlyIfUserWithoutKeysAndExternalAddressWithoutKeys() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy.updated(type: .externalAddress)])) }
        let testUser = User.dummy
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { _ in }
        XCTAssertTrue(authenticatorMock.setupAccountKeysStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationCreatesInternalAddressIfUserWithoutKeysAndInternalAddressesButWithUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy.updated(type: .externalAddress)])) }
        let testUser = User.dummy.updated(name: "name for \(#function)", displayName: "displayName for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { _ in }
        XCTAssertTrue(authenticatorMock.createAddressStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationFailsIfIfUserWithoutKeysAndAddressesAndUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy])) }
        let testUser = User.dummy.updated(name: "user for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .failure(.invalidState) = result else { XCTFail("login should fail"); return }
        }
    }

    func testAccountMigrationFailsIfIfUserWithoutKeysAndAddressesAndUsername_CapC() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy])) }
        let testUser = User.dummy.updated(name: "user for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) {  result in
            guard case .failure(.externalAccountsNotSupported) = result
            else { XCTFail("login should failed"); return }
        }
    }

    func testAccountMigrationCreatesAddressKeyForSingleAddressWithoutKey() {

        // This tests the whole flow of creating address keys alongside the migration
        // The expected calls to authenticator are:
        // 1. getAddresses -> initial setup
        // 2. getKeySalts -> address key creation step 1
        // 3. createAddressKey -> address key creation step 2
        // 4. getUserInfo -> address key creation step 3
        // 5. getAddresses -> refresh of data
        // 6. getKeySalts -> finalizing the flow

        // GIVEN

        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy])]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(loginData.salts, [testKeySalt])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 1)
    }

    func testAccountMigrationCreatesAddressKeysForTwoAddressesWithoutKeys() {

        // This tests the whole flow of creating address keys alongside the migration
        // The expected calls to authenticator are:
        // 1. getAddresses -> initial setup
        // 2. getKeySalts -> address key #1 creation step 1
        // 3. createAddressKey -> address key #1 creation step 2
        // 4. getUserInfo -> address key #1 creation step 3
        // 5. getAddresses -> refresh of data
        // 6. getKeySalts -> address key #2 creation step 1
        // 7. createAddressKey -> address key #2 creation step 2
        // 8. getUserInfo -> address key #2 creation step 3
        // 9. getAddresses -> second refresh of data
        // 10. getKeySalts -> finalizing the flow

        // GIVEN

        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled), .dummy.updated(status: .enabled)]))
            } else if counter == 2 {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .enabled)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy])]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(loginData.salts, [testKeySalt])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 2)
    }

    func testAccountMigrationCreatesExternalAddressIfUserWithoutKeysAndInternalAddressesButWithUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy.updated(type: .externalAddress)])) }
        let testUser = User.dummy.updated(name: "name for \(#function)", displayName: "displayName for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in
            guard case .success(.finished(let userData)) = result else { XCTFail("login should succeed"); return }
            XCTAssertEqual(userData.user, testUser)
            XCTAssertEqual(userData.salts, [])
            XCTAssertEqual(userData.addresses.count, 1)
            XCTAssertEqual(userData.addresses.firstExternal?.isExternal, true)
            XCTAssertEqual(userData.addresses.firstExternal?.keys, [])
            XCTAssertEqual(userData.scopes, [])
        }
        XCTAssertTrue(authenticatorMock.createAddressStub.wasNotCalled)
    }

    func testAccountMigrationCreatesExternalAddressIfUserWithoutAddressKeys() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        let userKey = Key.dummy.updated(keyID: "user key id for \(#function)", primary: 1)
        let addressKey = Key.dummy.updated(keyID: "address key id for \(#function)", primary: 1)
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt = KeySalt(ID: "user key id for \(#function)", keySalt: base64Salt)

        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled, type: .externalAddress)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, type: .externalAddress, hasKeys: 1, keys: [addressKey])]))
            }
        }
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, completion in completion(.success(addressKey)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [userKey])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.user, testUser)
            XCTAssertEqual(userData.salts, [testKeySalt])
            XCTAssertEqual(userData.addresses.count, 1)
            XCTAssertNotNil(userData.addresses.firstExternal?.keys)
            XCTAssertEqual(userData.addresses.firstExternal?.keys, [addressKey])
            XCTAssertEqual(userData.scopes, [])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 1)
    }

    func testAccountMigrationGeneratesUserAndAddressKeysIfUserKeysAndAccountRequiredIsInternal() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .username)

        let userKey = Key.dummy.updated(keyID: "user key id for \(#function)", primary: 1)
        let addressKey = Key.dummy.updated(keyID: "address key id for \(#function)", primary: 1)
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt = KeySalt(ID: "user key id for \(#function)", keySalt: base64Salt)

        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled, type: .externalAddress)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, type: .externalAddress, hasKeys: 1, keys: [addressKey])]))
            }
        }

        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.setupAccountKeysStub.bodyIs { _, _, _, _, completion in completion(.success(())) }
        authenticatorMock.getUserInfoStub.bodyIs { counter, _, completion in
            completion(.success(.dummy.updated(keys: [userKey])))
        }

        // WHEN
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: .dummy,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.user, .dummy.updated(keys: [userKey]))
            XCTAssertEqual(userData.salts, [testKeySalt])
            XCTAssertEqual(userData.addresses.count, 1)
            XCTAssertNotNil(userData.addresses.firstExternal?.keys)
            XCTAssertEqual(userData.addresses.firstExternal?.keys, [addressKey])
            XCTAssertEqual(userData.scopes, [])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.setupAccountKeysStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 1)
    }

    func testAccountMigrationWithExistingExternalAddressKeys() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        let userKey = Key.dummy.updated(keyID: "user key id for \(#function)", primary: 1)
        let addressKey = Key.dummy.updated(keyID: "address key id for \(#function)", primary: 1)
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt = KeySalt(ID: "user key id for \(#function)", keySalt: base64Salt)

        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            completion(.success([.dummy.updated(status: .enabled, type: .externalAddress, hasKeys: 1, keys: [addressKey])]))
        }
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [userKey])

        // WHEN
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.user, testUser)
            XCTAssertEqual(userData.salts, [testKeySalt])
            XCTAssertEqual(userData.addresses.count, 1)
            XCTAssertNotNil(userData.addresses.firstExternal?.keys)
            XCTAssertEqual(userData.addresses.firstExternal?.keys, [addressKey])
            XCTAssertEqual(userData.scopes, [])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 1)
    }

    func testAccountMigrationDoesntTryCreatingAddressKeysForDisabledAddress() {

        // This tests the whole flow of creating address keys alongside the migration
        // The expected calls to authenticator are:
        // 1. getAddresses
        // 2. getKeySalts
        // NO createAddressKey call happens

        // GIVEN

        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .disabled)]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, _ in XCTFail() }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, _ in XCTFail() }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.salts, [testKeySalt])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 0)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 0)
    }

    func testAccountMigrationDoesntTryCreatingAddressKeysForNonPrivateUser() {

        // This tests the whole flow of creating address keys alongside the migration
        // The expected calls to authenticator are:
        // 1. getAddresses
        // 2. getKeySalts
        // NO createAddressKey call happens

        // GIVEN

        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy])]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, _ in XCTFail() }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, _ in XCTFail() }
        let testUser = User.dummy.updated(name: "user for \(#function)", private: 0, keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.salts, [testKeySalt])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 0)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 0)
    }

    func testAccountMigrationDoesntTryCreatingAddressKeysForDisabledAddressEvenIfItCreatesForOtherAddress() {

        // This tests the whole flow of creating address keys alongside the migration
        // The expected calls to authenticator are:
        // 1. getAddresses -> initial setup
        // 2. getKeySalts -> address key #1 creation step 1
        // 3. createAddressKey -> address key #1 creation step 2
        // 4. getUserInfo -> address key #1 creation step 3
        // 5. getAddresses -> refresh of data
        // 6. getKeySalts -> address key #2 creation step 1
        // 7. createAddressKey -> address key #2 creation step 2
        // 8. getUserInfo -> address key #2 creation step 3
        // 9. getAddresses -> second refresh of data
        // 10. getKeySalts -> finalizing the flow

        // GIVEN

        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled), .dummy.updated(status: .disabled), .dummy.updated(status: .enabled)]))
            } else if counter == 2 {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .disabled), .dummy.updated(status: .enabled)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .disabled), .dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy])]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .one) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.salts, [testKeySalt])
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 2)
    }

    // MARK: - two password mode

    private func performMigrationForTwoPasswordModeAccount(minimumAccountType: AccountType,
                                                           addressType: Address.AddressType,
                                                           saltsEmpty: Bool,
                                                           passphrasesEmpty: Bool) -> AuthenticatorWithKeyGenerationMock {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: minimumAccountType)
        let userKey = Key.dummy.updated(keyID: "user key id for \(#function)", primary: 1)
        let addressKey = Key.dummy.updated(keyID: "address key id for \(#function)", primary: 1)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            completion(.success([.dummy.updated(status: .enabled, type: addressType, hasKeys: 1, keys: [addressKey])]))
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt = KeySalt(ID: "user key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [userKey])

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser,
                                                               mailboxPassword: "mailbox password for \(#function)",
                                                               passwordMode: .two) { result in

            // THEN
            guard case .success(LoginStatus.finished(let userData)) = result else { XCTFail("login should not fail"); return }
            XCTAssertEqual(userData.user, testUser)
            XCTAssertEqual(userData.addresses.count, 1)
            XCTAssertNotNil(userData.addresses.first?.keys)
            XCTAssertEqual(userData.addresses.first?.keys, [addressKey])
            XCTAssertEqual(userData.scopes, [])

            if saltsEmpty {
                XCTAssertEqual(userData.salts, [])
            } else {
                XCTAssertEqual(userData.salts, [testKeySalt])
            }
            XCTAssertEqual(userData.passphrases.isEmpty, passphrasesEmpty)
        }

        return authenticatorMock
    }

    func testAccountMigrationReturnsEarlyIfTwoPasswordModeAndUsernameAccountRequirement() {
        let authenticatorMock = performMigrationForTwoPasswordModeAccount(
            minimumAccountType: .username, addressType: .externalAddress, saltsEmpty: true, passphrasesEmpty: true
        )
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasCalledExactlyOnce)
        XCTAssertTrue(authenticatorMock.getKeySaltsStub.wasNotCalled)
    }

    func testAccountMigrationDoesNotReturnsEarlyIfTwoPasswordModeAndExternalAccountRequirement() {
        let authenticatorMock = performMigrationForTwoPasswordModeAccount(
            minimumAccountType: .external, addressType: .externalAddress, saltsEmpty: false, passphrasesEmpty: false
        )
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasCalledExactlyOnce)
        XCTAssertTrue(authenticatorMock.getKeySaltsStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationDoesNotReturnsEarlyIfTwoPasswordModeAndInternalAccountRequirement() {
        let authenticatorMock = performMigrationForTwoPasswordModeAccount(
            minimumAccountType: .internal, addressType: .protonDomain, saltsEmpty: false, passphrasesEmpty: false
        )
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasCalledExactlyOnce)
        XCTAssertTrue(authenticatorMock.getKeySaltsStub.wasCalledExactlyOnce)
    }
}
