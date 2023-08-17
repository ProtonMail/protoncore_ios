//
//  QuarkCommandsTests.swift
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

final class QuarkCommandsTests: XCTestCase {
    
    var dohMock: DohMock!
    
    override func setUp() {
        super.setUp()
        dohMock = DohMock()
        
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
            // ...
        }
    }

    func testCreateUserExternalOnlySuccess() {
        // mock response
        /*let sub = */stub(condition: isHost("test.quark.commands.url")) { request in
            #if SPM
            let bundle = Bundle.module
            #else
            let bundle = Bundle(for: type(of: self))
            #endif
            let url = bundle.url(forResource: "ExternalNoKeySucess", withExtension: "html")!
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
        }
        let expectation = self.expectation(description: "Success completion block called")

        // mock url
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }
        let quarkCommand = QuarkCommands(doh: dohMock)
        quarkCommand.createUser(externalEmail: "quarkcommand@test.quark.commands.url",
                                password: "123456789") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
        
    }
    
    func testCreateUserExternalOnlyFailed() {
        // mock response
        /*let sub = */stub(condition: isHost("test.quark.commands.url")) { request in
            #if SPM
            let bundle = Bundle.module
            #else
            let bundle = Bundle(for: type(of: self))
            #endif
            let url = bundle.url(forResource: "ExternalNoKeyFailed", withExtension: "html")!
            let headers = ["Content-Type": "application/xhtml+xml;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: 200, headers: headers)
        }
        let expectation = self.expectation(description: "Success completion block called")

        // mock url
        dohMock.getCurrentlyUsedHostUrlStub.bodyIs { _ in "https://test.quark.commands.url" }
        
        let quarkCommand = QuarkCommands(doh: dohMock)
        quarkCommand.createUser(externalEmail: "quarkcommand@test.quark.commands.url",
                                password: "123456789") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error as CreateAccountError):
                XCTAssertEqual(error.userFacingMessageInQuarkCommands,
                               CreateAccountError.cannotFindAccountDetailsInResponseBody.userFacingMessageInQuarkCommands)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

}
