//
//  CreateAddressViewModelTests.swift
//  ProtonCore-Login-Tests - Created on 11/17/22.
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

// swiftlint:disable xctfail_message

import XCTest

import ProtonCore_Authentication
import ProtonCore_Challenge
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_TestingToolkit
import ProtonCore_Utilities
import ProtonCore_Networking
import ProtonCore_DataModel
import ProtonCore_CoreTranslation
import ProtonCore_ObfuscatedConstants
import ProtonCore_Doh
@testable import ProtonCore_LoginUI

class CreateAddressViewModelTests: XCTestCase {

    var viewModel: CreateAddressViewModel!
    var loginMock: LoginMock!
    var api: PMAPIService!
    
    let key1 = Key(keyID: "keyID1", privateKey: "privateKey")
    let key2 = Key(keyID: "keyID2", privateKey: "privateKey")
    let credential = AuthCredential(LoginTestUser.credential)
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        loginMock = LoginMock()
        api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface)
        let authDelegate = AuthHelper()
        let serviceDelegate = AnonymousServiceManager()
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
    }
    
    func testSetUsernameUsernameAlreadyUsed() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.failure(AvailabilityError.notAvailable(message: "Username already used")))
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        let failureExpectation = expectation(description: "failureExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTFail("loginData should not be called in this case")
        } loginError: { loginError in
            XCTAssertEqual(loginError.2.originalError as? AvailabilityError, AvailabilityError.notAvailable(message: "Username already used"))
            failureExpectation.fulfill()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameUsernameAlreadySet() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.failure(SetUsernameError.alreadySet(message: "Username already set")))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            let address = self.getAddress(keys: [self.key1])
            result(.success(address))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        loginMock.finishLoginFlowStub.bodyIs { _, _, result in
            result(.success(LoginStatus.finished(self.getLoginData(userData: self.getUserData()))))
        }
        loginMock.finishLoginFlowStub.ensureWasCalled = true
        let successfulExpectation = expectation(description: "successfulExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTAssertEqual(loginData, self.getLoginData(userData: self.getUserData()))
            successfulExpectation.fulfill()
        } loginError: { loginError in
            XCTFail()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testSetUsernameSetUsernameGenericError() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.failure(SetUsernameError.generic(message: "test error", code: 100, originalError: NSError(domain: "error domain", code: 1))))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        let failureExpectation = expectation(description: "failureExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTFail()
        } loginError: { loginError in
            XCTAssertEqual(loginError.0, "test error")
            XCTAssertEqual(loginError.1, 100)
            if case .setUsernameError(.generic) = loginError.2 {} else { XCTFail() }
            failureExpectation.fulfill()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameCreateAddressAlreadyHaveInternalOrCustomDomainAddress() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            let address = self.getAddress(keys: [self.key1])
            result(.failure(.alreadyHaveInternalOrCustomDomainAddress(address)))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        loginMock.finishLoginFlowStub.bodyIs { _, _, result in
            result(.success(LoginStatus.finished(self.getLoginData(userData: self.getUserData()))))
        }
        loginMock.finishLoginFlowStub.ensureWasCalled = true
        let successfulExpectation = expectation(description: "successfulExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTAssertEqual(loginData, self.getLoginData(userData: self.getUserData()))
            successfulExpectation.fulfill()
        } loginError: { loginError in
            XCTFail()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameCreateAddressCannotCreateInternalAddress() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            let address = self.getAddress(keys: [self.key1])
            result(.failure(CreateAddressError.cannotCreateInternalAddress(alreadyExistingAddress: (address))))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        let failureExpectation = expectation(description: "failureExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTFail()
        } loginError: { loginError in
            XCTAssertEqual(loginError.0, "The operation couldn’t be completed. (ProtonCore_Login.CreateAddressError error 1.)")
            XCTAssertEqual(loginError.1, 1)
            failureExpectation.fulfill()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameCreateAddressGenericError() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            result(.failure(CreateAddressError.generic(message: "test error", code: 100, originalError: NSError(domain: "error domain", code: 1))))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        let failureExpectation = expectation(description: "failureExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTFail()
        } loginError: { loginError in
            XCTAssertEqual(loginError.0, "test error")
            XCTAssertEqual(loginError.1, 100)
            failureExpectation.fulfill()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameCreateAddressApiMightBeBlockedError() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            result(.failure(CreateAddressError.apiMightBeBlocked(
                message: CoreString._net_api_might_be_blocked_message,
                originalError: NSError.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: CoreString._net_api_might_be_blocked_message))
            ))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        let failureExpectation = expectation(description: "failureExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTFail()
        } loginError: { loginError in
            XCTAssertEqual(loginError.0, CoreString._net_api_might_be_blocked_message)
            XCTAssertEqual(loginError.1, APIErrorCode.potentiallyBlocked)
            failureExpectation.fulfill()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameSuccess() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.setUsernameStub.bodyIs { _, _, completion in
            completion(.success(()))
        }
        loginMock.setUsernameStub.ensureWasCalled = true
        loginMock.createAddressStub.bodyIs { _, result in
            let address = self.getAddress(keys: [self.key1])
            result(.success(address))
        }
        loginMock.createAddressStub.ensureWasCalled = true
        loginMock.finishLoginFlowStub.bodyIs { _, _, result in
            result(.success(LoginStatus.finished(self.getLoginData(userData: self.getUserData()))))
        }
        loginMock.finishLoginFlowStub.ensureWasCalled = true
        let successfulExpectation = expectation(description: "successfulExpectation")
        createCreateAddressViewModel(username: "test") { loginData in
            XCTAssertEqual(loginData, self.getLoginData(userData: self.getUserData()))
            successfulExpectation.fulfill()
        } loginError: { loginError in
            XCTFail()
        }

        viewModel.finish(username: "test")
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}

extension CreateAddressViewModelTests {
    func createCreateAddressViewModel(
        username: String?,
        loginData: ((LoginData) -> Void)? = nil,
        loginError: (((String, Int, CreateAddressViewModel.PossibleErrors)) -> Void)? = nil) {
        let data = CreateAddressData(email: "test@spam.la", credential: AuthCredential(LoginTestUser.credential), user: LoginTestUser.user, mailboxPassword: "123")
        viewModel = CreateAddressViewModel(data: data, login: loginMock, defaultUsername: username)
        viewModel.finished.bind { data in
            loginData?(data)
        }
        viewModel.error.bind { messageWithCode in
            loginError?(messageWithCode)
        }
    }

    func getAddress(keys: [Key]) -> Address {
        return Address(addressID: "addressID", domainID: "domainID", email: "email@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName", signature: "signature", hasKeys: 100, keys: keys)
    }

    func getUser(keys: [Key]) -> User {
        return User(ID: "ID", name: "name", usedSpace: 1000, currency: "USD", credit: 0, maxSpace: 1000000, maxUpload: 100000, role: 1, private: 2, subscribed: 3, services: 4, delinquent: 0, orgPrivateKey: "orgPrivateKey", email: "email@email.ch", displayName: "displayName", keys: keys)
    }

    func getUserData() -> UserData {
        return UserData(credential: credential, user: self.getUser(keys: [self.key1]), salts: [], passphrases: [:], addresses: [], scopes: [])
    }

    func getLoginData(userData: UserData) -> LoginData {
        return LoginData.userData(userData)
    }
}

extension LoginData: Equatable {
    public static func == (lhs: LoginData, rhs: LoginData) -> Bool {
        switch (lhs, rhs) {
        case let (.credential(credential1), .credential(credential2)):
            return credential1 == credential2
        case let (.userData(userData1), .userData(userData2)):
            return userData1 == userData2
        default:
            return false
        }
    }
}

extension UserData: Equatable {
    public static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.credential == rhs.credential &&
        lhs.user == rhs.user &&
        lhs.salts == rhs.salts &&
        lhs.passphrases == rhs.passphrases &&
        lhs.addresses == rhs.addresses &&
        lhs.scopes == rhs.scopes
    }
}
