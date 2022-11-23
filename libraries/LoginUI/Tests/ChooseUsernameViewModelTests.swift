//
//  ChooseUsernameViewModelTests.swift
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
@testable import ProtonCore_LoginUI

class ChooseUsernameViewModelTests: XCTestCase {

    var viewModel: ChooseUsernameViewModel!
    var loginMock: LoginMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        loginMock = LoginMock()
        let api = PMAPIService(doh: DohMock())
        let authDelegate = AuthHelper()
        let serviceDelegate = AnonymousServiceManager()
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        
        let data = CreateAddressData.init(email: "MockTest@gmail.com",
                                          credential: AuthCredential.dummy,
                                          user: User.dummy,
                                          mailboxPassword: "12345678")
        viewModel = ChooseUsernameViewModel.init(data: data, login: loginMock, appName: "")
    }

    func testCheckAvailableNameSucessed() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.updateAvailableDomainStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.finished.bind { username in
            expect.fulfill()
        }
        let testName = "valid"
        viewModel.checkAvailability(username: testName)
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testCheckAvailableNameFailed() {
        loginMock.checkAvailabilityForInternalAccountStub.bodyIs { _, _, completion in
            completion(.success)
        }
        loginMock.checkAvailabilityForInternalAccountStub.ensureWasCalled = true
        loginMock.updateAvailableDomainStub.ensureWasCalled = true
        let expect = expectation(description: "expectation1")
        viewModel.finished.bind { error in
            expect.fulfill()
        }
        let testName = "invalid"
        viewModel.checkAvailability(username: testName)
        waitForExpectations(timeout: 0.5) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}
