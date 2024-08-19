//
//  QuarkPaymentsCommandsTests.swift
//  ProtonCore-QuarkCommands-Tests - Created on 07/13/2022.
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

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
#if canImport(ProtonCoreTestingToolkitUnitTestsDoh)
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif
@testable import ProtonCoreQuarkCommands

final class QuarkPaymentsCommandsTests: XCTestCase {

    var dohMock: DohMock!

    override func setUp() {
        super.setUp()
        dohMock = DohMock()

        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
        }
    }

    func testCreateUserSuccess() {
        // mock response
        stub(condition: isHost("test.quark.commands.url")) { request in
            let bundle = Bundle.module
            let url = bundle.url(forResource: "PaymentsSeedSubscriber", withExtension: "html")!
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)

        }
        // mock url
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }

        let quarkCommand = Quark().baseUrl(dohMock)

        let user = User(name: "quarkcommand@test.quark.commands.url", password: "123456789")
        do {
            // Act
            let newUser = try quarkCommand.seedNewSubscriber(user: user, plan: .mail2022)

            // Assert
            XCTAssertNotNil(newUser.id, "User id should come from the response")
        } catch {
            XCTFail("seedUserWithCreditCard method threw an unexpected error: \(error)")
        }
    }

    func testCreateUserWithChargebeeSuccess() {
        // mock response
        stub(condition: isHost("test.quark.commands.url")) { request in
            let bundle = Bundle.module
            let url = bundle.url(forResource: "ChargebeePaymentsSeedSubscriber", withExtension: "html")!
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)

        }
        // mock url
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }

        let quarkCommand = Quark().baseUrl(dohMock)

        let user = User(name: "quarkcommand@test.quark.commands.url", password: "123456789")
        do {
            // Act
            let newUser = try quarkCommand.newSeedNewSubscriber(user: user, plan: .mail2022, cycle: 1)

            // Assert
            XCTAssertNotNil(newUser.id, "User id should come from the response")
        } catch {
            XCTFail("seedUserWithCreditCard method threw an unexpected error: \(error)")
        }
    }
}
