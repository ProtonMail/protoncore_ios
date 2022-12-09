//
//  HumanCheckHelperTests.swift
//  ProtonCore-HumanVerification-Tests - Created on 29/10/20.
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
import ProtonCore_TestingToolkit

import ProtonCore_Doh
import ProtonCore_Services
import ProtonCore_Networking
@testable import ProtonCore_HumanVerification

class HumanCheckHelperTests: XCTestCase {
    
    func testHumanCheckHelperClose() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectationDelegateEnd = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        
        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        delegate.onHumanVerifyEndStub.bodyIs { _, _ in expectationDelegateEnd.fulfill() }
        
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock())
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        // also test pass in v2. work as v3
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, clientApp: .mail, responseDelegate: delegate)
        // triger close from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            humanCheckHelper.humanCheckCoordinator?.delegate?.close()
        }
        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha),
                                                                                   VerifyMethod(predefinedMethod: .email)], startToken: ""),
                                       currentURL: nil) { reason in
            switch reason {
            case .verification:
                XCTFail()
            case .close:
                expectation1.fulfill()
            case .closeWithError:
                XCTFail()
            }
        }
        
        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)
        wait(for: [expectationDelegateStart, expectation1, expectationDelegateEnd], timeout: 3, enforceOrder: true)
    }
    
    func testHumanCheckHelperFinalToken() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectationDelegateEnd = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        let expectation2 = self.expectation(description: "Success send code completion block called")
        
        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        delegate.onHumanVerifyEndStub.bodyIs { _, _ in expectationDelegateEnd.fulfill() }
        
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock())
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl,
                                                clientApp: .mail, responseDelegate: delegate)
        // triger finalToken from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.methods = [VerifyMethod(predefinedMethod: .email)]
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.finalToken(method: VerifyMethod(predefinedMethod: .email), token: "666666", complete: { result, error, _ in
                XCTAssertEqual(result, true)
                XCTAssertEqual(error, nil)
                expectation1.fulfill()
            })
        }
        
        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "email" as String)
                XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "666666" as String)
                // send final result to backend and trigger verificationCodeBlock
                verificationCodeBlock?(true, nil, nil)
                expectation2.fulfill()
            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }
        
        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)
        
        wait(for: [expectationDelegateStart, expectation1, expectationDelegateEnd, expectation2], timeout: 3, enforceOrder: true)
    }
    
    func testHumanCheckHelperFinalError() {
        let expectationDelegateStart = self.expectation(description: "Delegate call")
        let expectation1 = self.expectation(description: "Success send code completion block called")
        let expectation2 = self.expectation(description: "Success send code completion block called")
        
        let delegate = HumanVerifyResponseDelegateMock()
        delegate.onHumanVerifyStartStub.bodyIs { _ in expectationDelegateStart.fulfill() }
        
        let apiService = PMAPIService.createAPIServiceWithoutSession(doh: DohMock())
        let humanUrl = URL(string: "https://proton.me/support/human-verification")!
        let humanCheckHelper = HumanCheckHelper(apiService: apiService, supportURL: humanUrl, clientApp: .mail, responseDelegate: delegate)
        // triger finalToken from view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.methods = [VerifyMethod(predefinedMethod: .email)]
            humanCheckHelper.humanCheckCoordinator?.humanVerifyViewModel.finalToken(method: VerifyMethod(predefinedMethod: .email), token: "111111", complete: { result, error, _ in
                XCTAssertEqual(result, false)
                XCTAssert(error != nil)
                XCTAssertEqual(error?.underlyingError?.code, 123)
                XCTAssertEqual(error?.underlyingError?.domain, "test")
                expectation1.fulfill()
            })
        }
        
        humanCheckHelper.onHumanVerify(parameters: HumanVerifyParameters(methods: [VerifyMethod(predefinedMethod: .captcha), VerifyMethod(predefinedMethod: .email)], startToken: ""), currentURL: nil) { reason in
            switch reason {
            case .verification(let header, let verificationCodeBlock):
                XCTAssertEqual(header["x-pm-human-verification-token-type"] as! String, "email" as String)
                XCTAssertEqual(header["x-pm-human-verification-token"] as! String, "111111" as String)
                // send final result to backend and trigger verificationCodeBlock
                let testError = NSError(domain: "test", code: 123, userInfo: nil)
                verificationCodeBlock?(false, ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: nil, underlyingError: testError), nil)
                expectation2.fulfill()
            case .close:
                XCTFail()
            case .closeWithError:
                XCTFail()
            }
        }
        
        XCTAssertEqual(humanCheckHelper.getSupportURL(), URL(string: "https://proton.me/support/human-verification")!)
        
        wait(for: [expectationDelegateStart, expectation1, expectation2], timeout: 3, enforceOrder: true)
    }
}
