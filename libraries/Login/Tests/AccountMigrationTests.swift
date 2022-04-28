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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif

import ProtonCore_TestingToolkit

import ProtonCore_Authentication
import ProtonCore_Authentication_KeyGeneration
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Login

final class AccountMigrationTests: XCTestCase {

    private func createStack(minimumAccountType: AccountType, credential: Credential = .dummy) -> (LoginService, APIServiceMock, AuthManager, AuthenticatorWithKeyGenerationMock) {
        let apiMock = APIServiceMock()
        let authManager = AuthManager()
        authManager.setCredential(auth: credential)
        let authenticatorMock = AuthenticatorWithKeyGenerationMock()
        let login = LoginService(api: apiMock, authManager: authManager, sessionId: "test session id", minimumAccountType: minimumAccountType, authenticator: authenticatorMock)
        return (login, apiMock, authManager, authenticatorMock)
    }

    func testAccountMigrationDoesntHappenWhenUsernameRequired() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .username)
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: nil, mailboxPassword: "test password") { result in
            guard case .success(.finished) = result else { XCTFail("login should succeed"); return }
        }
        XCTAssertTrue(authenticatorMock.getAddressesStub.wasNotCalled)
    }

    func testAccountMigrationReturnsProperlyFormattedDataForUsernameRequirement() {
        let (login, _, authManager, _) = createStack(minimumAccountType: .username)
        authManager.setCredential(auth: Credential.dummy.updated(scope: ["scope for \(#function)"]))
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: nil, mailboxPassword: "test password") { result in
            guard case .success(.finished(let loginData)) = result else { XCTFail("login should succeed"); return }
            switch loginData {
            case .userData:
                XCTFail()
            case .credential(let credential):
                XCTAssertEqual(Credential.dummy.UID, credential.UID)
                XCTAssertEqual(Credential.dummy.accessToken, credential.accessToken)
                XCTAssertEqual(Credential.dummy.refreshToken, credential.refreshToken)
                XCTAssertEqual(Credential.dummy.expiration, credential.expiration)
            }
        }
    }

    func testAccountMigrationDoesntHappenWhenInternalRequiredAndUserIsExternal() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        login.username = "username for \(#function)"
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: .dummy, mailboxPassword: "mailbox password for \(#function)") { result in
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
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in
            guard case .failure(.generic(message: "because we're in tests", _, _)) = result else { XCTFail("login should fail"); return }
        }
    }

    func testAccountMigrationFailsWhenNoAddresses() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success(.empty)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [Key(keyID: "test", privateKey: "test private")])
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in
            guard case .failure(.invalidState) = result else { XCTFail("login should fail"); return }
        }
    }

    func testAccountMigrationSetupsAccountKeysIfUserWithoutKeys() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy])) }
        let testUser = User.dummy.updated(name: "user for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { _ in }
        XCTAssertTrue(authenticatorMock.setupAccountKeysStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationCreatesInternalAddressIfUserWithoutKeysAndInternalAddressesButWithUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy.updated(type: .externalAddress)])) }
        let testUser = User.dummy.updated(name: "name for \(#function)", displayName: "displayName for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { _ in }
        XCTAssertTrue(authenticatorMock.createAddressStub.wasCalledExactlyOnce)
    }

    func testAccountMigrationFailsIfIfUserWithoutKeysAndAddressesAndUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .internal)
        authenticatorMock.getAddressesStub.bodyIs { _, _, completion in completion(.success([.dummy])) }
        let testUser = User.dummy.updated(name: "user for \(#function)")
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in
            guard case .failure(.invalidState) = result else { XCTFail("login should fail"); return }
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
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.salts, [testKeySalt])
            case .credential:
                XCTFail()
            }
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
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.salts, [testKeySalt])
            case .credential:
                XCTFail()
            }
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
        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in
            guard case .success(.finished(let loginData)) = result else { XCTFail("login should succeed"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.user, testUser)
                XCTAssertEqual(userData.salts, [])
                XCTAssertEqual(userData.addresses.count, 1)
                XCTAssertEqual(userData.addresses.firstExternal?.isExternal, true)
                XCTAssertEqual(userData.addresses.firstExternal?.keys, [])
                XCTAssertEqual(userData.scopes, [])
            case .credential:
                XCTFail()
            }
        }
        XCTAssertTrue(authenticatorMock.createAddressStub.wasNotCalled)
    }
    
    func testAccountMigrationCreatesExternalAndInternalAddressIfUserWithoutKeysAndInternalAddressesButWithUsername() {
        let (login, _, _, authenticatorMock) = createStack(minimumAccountType: .external)
        authenticatorMock.getAddressesStub.bodyIs { counter, _, completion in
            if counter == 1 {
                completion(.success([.dummy.updated(status: .enabled), .dummy.updated(status: .enabled, type: .externalAddress)]))
            } else {
                completion(.success([.dummy.updated(status: .enabled, hasKeys: 1, keys: [.dummy]), .dummy.updated(status: .enabled, type: .externalAddress)]))
            }
        }
        let base64Salt = "key salt for \(#function)".data(using: .utf8)!.base64EncodedString()
        let testKeySalt: KeySalt = .init(ID: "key id for \(#function)", keySalt: base64Salt)
        authenticatorMock.getKeySaltsStub.bodyIs { _, _, completion in completion(.success([testKeySalt])) }
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.user, testUser)
                XCTAssertEqual(userData.salts, [testKeySalt])
                XCTAssertEqual(userData.addresses.count, 2)
                XCTAssertEqual(userData.addresses.firstExternal?.keys, [])
                XCTAssertNotNil(userData.addresses.firstInternal?.keys)
                XCTAssertEqual(userData.scopes, [])
            case .credential:
                XCTFail()
            }
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 1)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 1)
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
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _ in XCTFail() }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, _ in XCTFail() }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.salts, [testKeySalt])
            case .credential:
                XCTFail()
            }
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
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, _ in XCTFail() }
        authenticatorMock.getUserInfoStub.bodyIs { _, _, _ in XCTFail() }
        let testUser = User.dummy.updated(name: "user for \(#function)", private: 0, keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.salts, [testKeySalt])
            case .credential:
                XCTFail()
            }
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
        authenticatorMock.createAddressKeyStub.bodyIs { _, _, _, _, _, _, completion in completion(.success(.dummy)) }
        let testUser = User.dummy.updated(name: "user for \(#function)", keys: [.dummy.updated(keyID: "key id for \(#function)", primary: 1)])
        authenticatorMock.getUserInfoStub.bodyIs { _, _, completion in completion(.success(testUser)) }

        // WHEN

        login.getAccountDataPerformingAccountMigrationIfNeeded(user: testUser, mailboxPassword: "mailbox password for \(#function)") { result in

        // THEN

            guard case .success(LoginStatus.finished(let loginData)) = result else { XCTFail("login should fail"); return }
            switch loginData {
            case .userData(let userData):
                XCTAssertEqual(userData.salts, [testKeySalt])
            case .credential:
                XCTFail()
            }
        }
        XCTAssertEqual(authenticatorMock.getAddressesStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.getKeySaltsStub.callCounter, 3)
        XCTAssertEqual(authenticatorMock.createAddressKeyStub.callCounter, 2)
        XCTAssertEqual(authenticatorMock.getUserInfoStub.callCounter, 2)
    }
}
