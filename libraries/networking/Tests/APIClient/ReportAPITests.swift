//
//  ReportAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 08/31/2021.
//
//  Copyright (c) 2019 Proton Technologies AG
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
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Authentication

@testable import ProtonCore_APIClient

class ReportAPITests: XCTestCase {
    
    var authCredential: AuthCredential?
    var api: Authenticator?
    
    private var testBundle: Bundle!
    func content(of name: String, ext: String) -> String {
        let url = testBundle.url(forResource: name, withExtension: ext)!
        let content = try! String.init(contentsOf: url)
        return content
    }
    
    override func setUp() {
        super.setUp()
        self.testBundle = Bundle(for: type(of: self))
        PMAPIService.noTrustKit = true
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
    func testUploadAndProgress() {
        
        let url = testBundle.url(forResource: "my_dogs", withExtension: "jpg")!
        let files: [String: URL] = ["my_dogs": url]
        
        let testApi = PMAPIService(doh: BlackDoHMail.default, sessionUID: "")
        testApi.doh.status = .off
        self.api = Authenticator(api: testApi)
        let manager = Authenticator(api: testApi)
        let anonymousService = AnonymousServiceManager()
        testApi.serviceDelegate = anonymousService
        // testApi.authDelegate = self
        let expect1 = expectation(description: "AuthInfo + Auth")
        let expect2 = expectation(description: "Progress is called")
        manager.authenticate(username: ObfuscatedConstants.blackAutotestv0Username,
                             password: ObfuscatedConstants.blackAutotestv0Password) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let firstCredential, _)):
                self.authCredential = AuthCredential(firstCredential)
                ///
                let bug = ReportBug.init(os: "Mac OS", osVersion: "10.15.7",
                                         client: "Web Mail", clientVersion: "iOS_1.12.0",
                                         clientType: 1, title: "[V4] [Web Mail] Bug [/archive] Sign up problem",
                                         description: "ignore this . test from feng", username: "feng100",
                                         email: "feng100@protonmail.ch", country: "US", ISP: "test", plan: "free")
                let route = ReportsBugs.init(bug)
                route.auth = self.authCredential
                testApi.upload(route: route, files: files) { progress in
                    expect2.fulfill()
                } complete: { (result: Result<ReportsBugsResponse, ResponseError>) in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        expect1.fulfill()
                    case .success(let response):
                        XCTAssertTrue(response.code == 1000)
                        expect1.fulfill()
                    }
                }
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect1.fulfill()
            default:
                XCTFail("Auth flow failed")
                expect1.fulfill()
            }
        }
        let result = XCTWaiter.wait(for: [expect1, expect2], timeout: 60)
        XCTAssertTrue( result == .completed )
    }
}
