//
//  HumanVerifyV3ViewModelTests.swift
//  ProtonCore-HumanVerification-Tests - Created on 18/11/21.
//
//  Copyright (c) 2020 Proton Technologies AG
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
import ProtonCore_Services
import ProtonCore_Networking
import WebKit
@testable import ProtonCore_HumanVerification

class HumanVerifyV3ViewModelTests: XCTestCase {
    
    var model: HumanVerifyV3ViewModel?
    
    override func setUp() {
        super.setUp()
        let apiService = PMAPIService(doh: try! DohMock())
        model = HumanVerifyV3ViewModel(api: apiService, startToken: nil, methods: [.captcha, .email, .sms])
    }
    
    enum TokenType: String {
        case captcha
        case email
        case sms
    }
    
    func successBody(token: String, type: TokenType) -> String {
        return """
            {"type":"\(MessageType.human_verification_success.rawValue)","payload":{"token":"\(token)","type":"\(type.rawValue)"}}
        """
    }
    
    func notificationBody(text: String, type: NotificationType) -> String {
        return """
            {"type":"\(MessageType.notification.rawValue)","payload":{"type":"\(type.rawValue)","text":"\(text)"}}
        """
    }
    
    // MARK: Test getURL
    
    func testGetURL() {
        let url = model?.getURL
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
        XCTAssertEqual(getParamValue(components: components, item: "token"), "")
        XCTAssertEqual(getParamValue(components: components, item: "methods"), "captcha,email,sms")
        XCTAssertNotNil(getParamValue(components: components, item: "theme"))
        XCTAssertNotNil(getParamValue(components: components, item: "locale"))
        XCTAssertNotNil(getParamValue(components: components, item: "defaultCountry"))
        XCTAssertEqual(getParamValue(components: components, item: "embed"), "true")
    }
    
    // MARK: Test interpretMessage
    
    func testInterpretSuccessCaptchaMessage() {
        let expectation = self.expectation(description: "expectation1")
        let testBody = successBody(token: "testToken", type: .captcha)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        model?.interpretMessage(message: message, notificationMessage: { _, _ in
            XCTFail()
        }, errorHandler: { error in
            XCTFail()
        }, completeHandler: { method in
            XCTAssertEqual(method, .captcha)
            let tokenType = model?.getToken()
            XCTAssertEqual(tokenType?.destination, nil)
            XCTAssertEqual(tokenType?.verifyMethod, .captcha)
            XCTAssertEqual(tokenType?.token, "testToken")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testInterpretSuccessEmailMessage() {
        let expectation = self.expectation(description: "expectation1")
        let testBody = successBody(token: "test@test.ch:123456", type: .email)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        model?.interpretMessage(message: message, notificationMessage: { _, _ in
            XCTFail()
        }, errorHandler: { error in
            XCTFail()
        }, completeHandler: { method in
            XCTAssertEqual(method, .email)
            let tokenType = model?.getToken()
            XCTAssertEqual(tokenType?.destination, nil)
            XCTAssertEqual(tokenType?.verifyMethod, .email)
            XCTAssertEqual(tokenType?.token, "test@test.ch:123456")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testInterpretSuccessSmsMessage() {
        let expectation = self.expectation(description: "expectation1")
        let testBody = successBody(token: "+41000000000:123456", type: .sms)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        model?.interpretMessage(message: message, notificationMessage: { _, _ in
            XCTFail()
        }, errorHandler: { error in
            XCTFail()
        }, completeHandler: { method in
            XCTAssertEqual(method, .sms)
            let tokenType = model?.getToken()
            XCTAssertEqual(tokenType?.destination, nil)
            XCTAssertEqual(tokenType?.verifyMethod, .sms)
            XCTAssertEqual(tokenType?.token, "+41000000000:123456")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testInterpretErrorSmsMessage() {
        let expectation1 = self.expectation(description: "expectation1")
        let expectation2 = self.expectation(description: "expectation2")
        let testBody = successBody(token: "+41000000000:123456", type: .sms)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        model?.onVerificationCodeBlock = { verificationCodeBlock in
            verificationCodeBlock(false, testResponseError, nil)
        }
        model?.interpretMessage(message: message, notificationMessage: { _, _ in
            XCTFail()
        }, errorHandler: { error in
            XCTAssertEqual(error, testResponseError)
            expectation1.fulfill()
        }, completeHandler: { method in
            XCTAssertEqual(method, .sms)
            let tokenType = model?.getToken()
            XCTAssertEqual(tokenType?.destination, nil)
            XCTAssertEqual(tokenType?.verifyMethod, .sms)
            XCTAssertEqual(tokenType?.token, "+41000000000:123456")
            expectation2.fulfill()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testInterpretNotificationSuccess() {
        let expectation = self.expectation(description: "expectation1")
        let testBody = notificationBody(text: "test", type: .success)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        model?.interpretMessage(message: message, notificationMessage: { type, message in
            XCTAssertEqual(type, .success)
            XCTAssertEqual(message, "test")
            expectation.fulfill()
        }, errorHandler: { error in
            XCTFail()
        }, completeHandler: { method in
            XCTFail()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    func testInterpretNotificationError() {
        let expectation = self.expectation(description: "expectation1")
        let testBody = notificationBody(text: "Error X", type: .error)
        let message = WKScriptMessageMock(name: "iOS", body: testBody)
        model?.interpretMessage(message: message, notificationMessage: { type, message in
            XCTAssertEqual(type, .error)
            XCTAssertEqual(message, "Error X")
            expectation.fulfill()
        }, completeHandler: { method in
            XCTFail()
        })
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
    
    // MARK: Private methods
    
    private func getParamValue(components: URLComponents?, item: String) -> String? {
        for component in components!.queryItems! where component.name == item {
            return component.value
        }
        return nil
    }
}
