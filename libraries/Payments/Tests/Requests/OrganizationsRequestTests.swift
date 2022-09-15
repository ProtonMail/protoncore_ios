//
//  OrganizationsRequestTests.swift
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

import XCTest
import OHHTTPStubs
import ProtonCore_TestingToolkit
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Services
import ProtonCore_Networking
@testable import ProtonCore_Payments

final class OrganizationsRequestTests: XCTestCase {
    
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
        var appVersion: String { return "iOS_1.12.0" }
        var additionalHeaders: [String: String]?
        func onDohTroubleshot() {
            // swiftlint:disable no_print
            PMLog.info("\(#file): \(#function)")
        }
    }
    
    class TestAuthDelegate: AuthDelegate {
        var authCredential: AuthCredential? { testAuthCredential }
        func authCredential(sessionUID: String) -> AuthCredential? { testAuthCredential }
        func credential(sessionUID: String) -> Credential? { testAuthCredential.map(Credential.init) }
        func onLogout(sessionUID uid: String) { }
        func onUpdate(credential: Credential, sessionUID: String) { }
        func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) { }
        private var testAuthCredential: AuthCredential? {
            AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date().addingTimeInterval(60 * 60), userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
        }
    }
    
    var organizationsPaymentMethods: String {
        return """
            {
              "Organization" : {
                "VPNPlanName" : "Test VPN PlanName",
                "MaxCalendars" : 20,
                "BonusAddresses" : 0,
                "BonusVPN" : 0,
                "Theme" : null,
                "Name" : "Test user name",
                "BrokenSKL" : 0,
                "LoyaltyIncrementTime" : 1694510625,
                "Email" : null,
                "AssignedSpace" : 536870912000,
                "UsedCalendars" : 0,
                "UsedMembers" : 1,
                "UsedAddresses" : 0,
                "PlanName" : "bundle2022",
                "BonusDomains" : 0,
                "TwoFactorGracePeriod" : null,
                "UsedVPN" : 10,
                "DisplayName" : "Display test user name",
                "MaxDomains" : 3,
                "MaxMembers" : 1,
                "ToMigrate" : 0,
                "MaxSpace" : 536870912000,
                "LoyaltyCounter" : 0,
                "PlanFlags" : 7,
                "BonusSpace" : 0,
                "CreateTime" : 1662974625,
                "UsedSpace" : 501170,
                "MaxAddresses" : 15,
                "Flags" : 0,
                "UsedDomains" : 0,
                "BonusMembers" : 0,
                "HasKeys" : 0,
                "MaxVPN" : 10,
                "Features" : 1
              },
              "Code" : 1000
            }
        """
    }
    
    func testOrganizationsLog() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let expectation1 = self.expectation(description: "Success completion block called")
        let expectation2 = self.expectation(description: "Log callback")
        
        stub(condition: isMethodGET() && isPath("/api/core/v4/organizations")) { request in
            let body = self.organizationsPaymentMethods.data(using: String.Encoding.utf8)!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        queue.async {
            do {
                let api = PMAPIService(doh: TestDoH.default as DoHInterface, sessionUID: "testSessionUID")
                let testAuthDelegate = TestAuthDelegate()
                api.authDelegate = testAuthDelegate
                let testAPIServiceDelegate = TestAPIServiceDelegate()
                api.serviceDelegate = testAPIServiceDelegate
                let methodsAPI = OrganizationsRequest(api: api)
                PMLog.callback = { message, level in
                    switch level {
                    case .debug:
                        if message.contains("REQUEST") { return }
                        XCTAssertTrue(message.contains("maxDomains"))
                        XCTAssertTrue(message.contains("3"))
                        XCTAssertTrue(message.contains("maxMembers"))
                        XCTAssertTrue(message.contains("1"))
                        XCTAssertFalse(message.contains("name"))
                        XCTAssertFalse(message.contains("Test user name"))
                        XCTAssertFalse(message.contains("displayName"))
                        XCTAssertFalse(message.contains("Display test user name"))
                        XCTAssertFalse(message.contains("vPNPlanName"))
                        XCTAssertFalse(message.contains("Test VPN PlanName"))
                        expectation2.fulfill()
                    default:
                        break
                    }
                }
                _ = try methodsAPI.awaitResponse(responseObject: OrganizationsResponse())
                PMLog.callback = nil
                expectation1.fulfill()
            } catch (let error) {
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 3) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
