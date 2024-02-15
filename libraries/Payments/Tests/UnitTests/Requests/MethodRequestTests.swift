//
//  MethodRequestTests.swift
//  ProtonCore-Payments-Tests - Created on 12/09/2022.
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

#if os(iOS)

import XCTest
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitTestData
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreServices
import ProtonCoreNetworking
@testable import ProtonCorePayments

final class V4MethodRequestTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        HTTPStubs.setEnabled(true)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
        PMLog.callback = nil
    }

    class TestAPIServiceDelegate: APIServiceDelegate {
        var locale: String { return "en_US" }
        func isReachable() -> Bool { return true }
        var userAgent: String? { return "" }
        func onUpdate(serverTime: Int64) { }
        var appVersion: String { return "ios-mail@4.2.0-dev" }
        var additionalHeaders: [String: String]?
        func onDohTroubleshot() {
            // swiftlint:disable:next no_print
            PMLog.info("\(#file): \(#function)")
        }
    }

    class TestAuthDelegate: AuthDelegate {
        func onSessionObtaining(credential: Credential) {}
        func onAdditionalCredentialsInfoObtained(sessionUID: String, password: String?, salt: String?, privateKey: String?) {}
        weak var authSessionInvalidatedDelegateForLoginAndSignup: AuthSessionInvalidatedDelegate?

        var authCredential: AuthCredential? { testAuthCredential }
        func authCredential(sessionUID: String) -> AuthCredential? { testAuthCredential }
        func credential(sessionUID: String) -> Credential? { testAuthCredential.map(Credential.init) }
        func onAuthenticatedSessionInvalidated(sessionUID uid: String) { }
        func onUpdate(credential: Credential, sessionUID: String) { }
        func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) { }
        func onUnauthenticatedSessionInvalidated(sessionUID: String) { }
        private var testAuthCredential: AuthCredential? {
            AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        }
    }

    var responsePaymentMethods: String {
        return """
            {
              "Code" : 1000,
              "PaymentMethods" : [
                {
                  "ID" : "ID_ABC_123",
                  "Type" : "card",
                  "Order" : 500,
                  "Details" : {
                    "ExpMonth" : "12",
                    "Brand" : "Visa",
                    "ExpYear" : "2100",
                    "ZIP" : "000",
                    "ThreeDSSupport" : false,
                    "Country" : "US",
                    "Name" : "Test Name",
                    "Last4" : "0000"
                  }
                }
              ]
            }
        """
    }

    func testPaymentMethodsLog() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let expectation1 = self.expectation(description: "Success completion block called")
        let expectation2 = self.expectation(description: "Log callback")

        stub(condition: isMethodGET() && isPath("/api/payments/v4/methods")) { request in
            let body = self.responsePaymentMethods.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        queue.async {
            do {
                let api = PMAPIService.createAPIService(doh: TestDoH.default as DoHInterface,
                                                        sessionUID: "testSessionUID",
                                                        challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
                let testAuthDelegate = TestAuthDelegate()
                api.authDelegate = testAuthDelegate
                let testAPIServiceDelegate = TestAPIServiceDelegate()
                api.serviceDelegate = testAPIServiceDelegate
                let methodsAPI = V4MethodRequest(api: api)
                PMLog.callback = { message, level in
                    switch level {
                    case .debug:
                        if message.contains("REQUEST") { return }
                        if message.contains("Payment request") { return }
                        XCTAssertTrue(message.contains("type"))
                        XCTAssertTrue(message.contains("card"))
                        XCTAssertFalse(message.contains("details"))
                        XCTAssertFalse(message.contains("brand"))
                        XCTAssertFalse(message.contains("card1"))
                        XCTAssertFalse(message.contains("name"))
                        XCTAssertFalse(message.contains("test Name"))
                        XCTAssertFalse(message.contains("last4"))
                        XCTAssertFalse(message.contains("0000"))
                        expectation2.fulfill()
                    default:
                        break
                    }
                }
                _ = try methodsAPI.awaitResponse(responseObject: MethodResponse())
                PMLog.callback = nil
                expectation1.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 3) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}

final class V5MethodRequestTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        HTTPStubs.setEnabled(true)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
        PMLog.callback = nil
    }

    class TestAPIServiceDelegate: APIServiceDelegate {
        var locale: String { return "en_US" }
        func isReachable() -> Bool { return true }
        var userAgent: String? { return "" }
        func onUpdate(serverTime: Int64) { }
        var appVersion: String { return "ios-mail@4.2.0-dev" }
        var additionalHeaders: [String: String]?
        func onDohTroubleshot() {
            // swiftlint:disable:next no_print
            PMLog.info("\(#file): \(#function)")
        }
    }

    class TestAuthDelegate: AuthDelegate {
        func onSessionObtaining(credential: Credential) {}
        func onAdditionalCredentialsInfoObtained(sessionUID: String, password: String?, salt: String?, privateKey: String?) {}
        weak var authSessionInvalidatedDelegateForLoginAndSignup: AuthSessionInvalidatedDelegate?

        var authCredential: AuthCredential? { testAuthCredential }
        func authCredential(sessionUID: String) -> AuthCredential? { testAuthCredential }
        func credential(sessionUID: String) -> Credential? { testAuthCredential.map(Credential.init) }
        func onAuthenticatedSessionInvalidated(sessionUID uid: String) { }
        func onUpdate(credential: Credential, sessionUID: String) { }
        func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) { }
        func onUnauthenticatedSessionInvalidated(sessionUID: String) { }
        private var testAuthCredential: AuthCredential? {
            AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        }
    }

    var responsePaymentMethods: String {
        return """
            {
              "Code" : 1000,
              "PaymentMethods" : [
                {
                  "ID" : "ID_ABC_123",
                  "Type" : "card",
                  "Order" : 500,
                  "Details" : {
                    "ExpMonth" : "12",
                    "Brand" : "Visa",
                    "ExpYear" : "2100",
                    "ZIP" : "000",
                    "ThreeDSSupport" : false,
                    "Country" : "US",
                    "Name" : "Test Name",
                    "Last4" : "0000"
                  }
                }
              ]
            }
        """
    }

    func testPaymentMethodsLog() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let expectation1 = self.expectation(description: "Success completion block called")
        let expectation2 = self.expectation(description: "Log callback")

        stub(condition: isMethodGET() && isPath("/api/payments/v5/methods")) { request in
            let body = self.responsePaymentMethods.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        queue.async {
            do {
                let api = PMAPIService.createAPIService(doh: TestDoH.default as DoHInterface,
                                                        sessionUID: "testSessionUID",
                                                        challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
                let testAuthDelegate = TestAuthDelegate()
                api.authDelegate = testAuthDelegate
                let testAPIServiceDelegate = TestAPIServiceDelegate()
                api.serviceDelegate = testAPIServiceDelegate
                let methodsAPI = V5MethodRequest(api: api)
                PMLog.callback = { message, level in
                    switch level {
                    case .debug:
                        if message.contains("REQUEST") { return }
                        if message.contains("Payment request") { return }
                        XCTAssertTrue(message.contains("type"))
                        XCTAssertTrue(message.contains("card"))
                        XCTAssertFalse(message.contains("details"))
                        XCTAssertFalse(message.contains("brand"))
                        XCTAssertFalse(message.contains("card1"))
                        XCTAssertFalse(message.contains("name"))
                        XCTAssertFalse(message.contains("test Name"))
                        XCTAssertFalse(message.contains("last4"))
                        XCTAssertFalse(message.contains("0000"))
                        expectation2.fulfill()
                    default:
                        break
                    }
                }
                _ = try methodsAPI.awaitResponse(responseObject: MethodResponse())
                PMLog.callback = nil
                expectation1.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 3) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
#endif
