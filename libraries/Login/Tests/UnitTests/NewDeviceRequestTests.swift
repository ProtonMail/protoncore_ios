//
//  NewDeviceRequestTests.swift
//  ProtonCore-Login-Tests - Created on 30.09.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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
import ProtonCoreChallenge
#if canImport(ProtonCoreTestingToolkitUnitTestsPayments)
import ProtonCoreTestingToolkitTestData
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsPayments
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreServices
import ProtonCoreNetworking
@testable import ProtonCoreLogin

final class NewDeviceRequestTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        HTTPStubs.setEnabled(true)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
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

    let deviceName = "MyPhone 5"
    let activationToken = "-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----"

    var newDeviceResponse: String {
        return """
            {
                "Code": 1000,
                "AuthDevice": {
                    "ID": "r5H2qGDRiUQ4-7gm...5YLf215MEgZCdzOtLW5psxgB8oNc=",
                    "DeviceToken": "wfih0367aa7dc0359bf5c42d15a93e6c",
                    "ActivationAddressID": "-Bpgivr5H2qGDRiUQ4-7gm5...oFRykab4Z23EGEW1ka3GtQPF9xwx9-VUA==",
                    "State": 2,
                    "Name": "\(deviceName)",
                    "LocalizedClientName": "Proton Account for Web",
                    "Platform": "Web",
                    "CreateTime": 1715720090,
                    "ActivateTime": 1715720090,
                    "RejectTime": 1715720090,
                    "ActivationToken": "\(activationToken)",
                    "LastActivityTime": 1715720090
                }
            }
        """
    }

    func testNewDeviceResponse() {
        let expectation1 = self.expectation(description: "Success completion block called")

        stub(condition: isMethodPOST() && isPath("/api/auth/v4/devices")) { request in
            let body = self.newDeviceResponse.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        let sut = NewDeviceRequest(name: deviceName, activationToken: activationToken)

        let api = PMAPIService.createAPIService(doh: TestDoH.default as DoHInterface,
                                                sessionUID: "testSessionUID",
                                                challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        let testAuthDelegate = TestAuthDelegate()
        api.authDelegate = testAuthDelegate
        let testAPIServiceDelegate = TestAPIServiceDelegate()
        api.serviceDelegate = testAPIServiceDelegate

        api.perform(request: sut, response: NewDeviceResponse()) { [self] (_, response) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssertNil(response.error)

            if let authDevice = response.authDevice {
                XCTAssertEqual(authDevice.name, self.deviceName)
                XCTAssertEqual(authDevice.activationToken, self.activationToken)
            } else {
                XCTFail()
            }

            expectation1.fulfill()
        }

        waitForExpectations(timeout: 3) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}

#endif
