//
//  AuthFlowTests.swift
//  ProtonCore-Authentication-Tests - Created on 19/02/2020.
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

import ProtonCore_APIClient
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_Authentication

class AuthFlowTests: XCTestCase, AuthDelegate {
    
    override class func setUp() {
        super.setUp()
        PMAPIService.noTrustKit = true
    }
    
    var authCredential: AuthCredential?
    var api: Authenticator?
    
    func getToken(bySessionUID uid: String) -> AuthCredential? {
        return self.authCredential
    }
    func onLogout(sessionUID uid: String) {
        XCTAssertFalse(uid.isEmpty)
    }
    func onUpdate(auth: Credential) {
        self.authCredential = AuthCredential(auth)
    }
    func onRefresh(bySessionUID uid: String, complete:  @escaping (Credential?, AuthErrors?) -> Void) {
        
        guard let api = api, let auth = authCredential else {
            return complete(nil, nil)
        }
       
        api.refreshCredential(Credential(auth)) { result in
            switch result {
            case Result.success(let stage):
                guard case Authenticator.Status.updatedCredential(let updatedCredential) = stage else {
                    return complete(nil, nil)
                }
                XCTAssertEqual(updatedCredential.UID, auth.sessionID)
                XCTAssertNotEqual(updatedCredential.accessToken, auth.accessToken)
                XCTAssertNotEqual(updatedCredential.refreshToken, auth.refreshToken)
                XCTAssertNotEqual(updatedCredential.expiration, auth.expiration)
                complete(updatedCredential, nil)
            case .failure(let error):
                complete(nil, error)
            }
        }
    }
    func onForceUpgrade() { }
    
    func testAutoAuthRefresh() {
        let testApi = PMAPIService(doh: BlackDoHMail.default, sessionUID: ObfuscatedConstants.testSessionId)
        testApi.doh.status = .off
        api = Authenticator(api: testApi)
        let manager = Authenticator(api: testApi)
        let anonymousService = AnonymousServiceManager()
        anonymousService.appVersion = ObfuscatedConstants.driveAppVersion
        testApi.serviceDelegate = anonymousService
        testApi.authDelegate = self
        let expect = expectation(description: "AuthInfo + Auth")
        ///
        manager.authenticate(username: TestUser.blackTestUser0.username, password: TestUser.blackTestUser0.password) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let firstCredential, _)):
                self.authCredential = AuthCredential(firstCredential)
                ///
                manager.getAddresses { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        expect.fulfill()
                    case .success(let addresses):
                        XCTAssertFalse(addresses.isEmpty)
                        let route = ExpireToken(uid: firstCredential.UID)
                        testApi.exec(route: route) { (result1: Result<ExpireTokenResponse, ResponseError>) in
                            manager.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                    expect.fulfill()
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    manager.closeSession( Credential( self.authCredential!)) { result2 in
                                        switch result2 {
                                        case .success(let response):
                                            XCTAssertEqual(response.code, 1000)
                                            XCTAssert(true)
                                            manager.getAddresses { result in
                                                switch result {
                                                case .failure(let error):
                                                    if error.code == -1011 && error.underlyingError.code == -1011 {
                                                        let errstr = error.localizedDescription
                                                        XCTAssertEqual(errstr, "Request failed: client error (422)")
                                                    } else {
                                                        XCTAssertEqual(error.underlyingError.code, 422)
                                                        XCTAssertEqual(error.code, 422)
                                                    }
                                                    expect.fulfill()
                                                case .success(let addresses):
                                                    XCTAssertFalse(addresses.isEmpty)
                                                    expect.fulfill()
                                                }
                                            }
                                        case .failure:
                                            XCTFail("Auth flow failed")
                                            expect.fulfill()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            default:
                XCTFail("Auth flow failed")
                expect.fulfill()
            }
        }
        let result = XCTWaiter.wait(for: [expect], timeout: 60)
        XCTAssertTrue( result == .completed )
    }
    
    func testAutoAuthRefreshRaceConditaion() {
        let blueApi = PMAPIService(doh: BlackDoHMail.default, sessionUID: ObfuscatedConstants.testSessionId)
        api = Authenticator(api: blueApi)
        let manager = Authenticator(api: blueApi)
        let anonymousService = AnonymousServiceManager()
        anonymousService.appVersion = ObfuscatedConstants.driveAppVersion
        blueApi.serviceDelegate = anonymousService
        blueApi.authDelegate = self
        let expect0 = expectation(description: "AuthInfo + Auth")
        let expect1 = expectation(description: "AuthInfo + Auth")
        let expect2 = expectation(description: "AuthInfo + Auth")
        ///
        manager.authenticate(username: TestUser.blackTestUser0.username, password: TestUser.blackTestUser0.password) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let firstCredential, _)):
                self.authCredential = AuthCredential(firstCredential)
                expect0.fulfill()
                ///
                manager.getAddresses { result in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let addresses):
                        XCTAssertFalse(addresses.isEmpty)
                        let route = ExpireToken(uid: firstCredential.UID)
                        blueApi.exec(route: route) { (result1: Result<ExpireTokenResponse, ResponseError>) in
              
                            manager.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    expect1.fulfill()
                                }
                            }
                            
                            manager.getAddresses { result in
                                switch result {
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                case .success(let addresses):
                                    XCTAssertFalse(addresses.isEmpty)
                                    expect2.fulfill()
                                }
                            }
                        }
                    }
                }
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expect0.fulfill()
                expect1.fulfill()
                expect2.fulfill()
            default:
                XCTFail("Auth flow failed")
                expect0.fulfill()
                expect1.fulfill()
                expect2.fulfill()
            }
        }
        let result = XCTWaiter.wait(for: [expect0, expect1, expect2], timeout: 60)
        XCTAssertTrue( result == .completed )
    }

}
