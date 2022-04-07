//
//  SignupServiceTests+Setup.swift
//  ProtonCore-Login-Tests - Created on 05.04.21.
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
#if canImport(Crypto_VPN)
import Crypto_VPN
#elseif canImport(Crypto)
import Crypto
#endif
import OHHTTPStubs

import ProtonCore_TestingToolkit
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Services
@testable import ProtonCore_Login

extension SignupServiceTests {
    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
            PMLog.debug("\(request.url!) stubbed by \(descriptor.name!).")
        }
    }

    var apiService: APIService {
        return PMAPIService(doh: DohMock())
    }

    func mockValidationTokenOK() {
        mock(filename: "ValidationTokenOK", title: "Validation token request ok mock", path: "/users/code", method: isMethodPOST())
    }

    func mockValidationTokenError() {
        mock(filename: "ValidationTokenError", title: "Validation token request error mock", path: "/users/code", method: isMethodPOST())
    }

    func mockValidationTokenCheckOK() {
        mock(filename: "ValidationTokenCheckOK", title: "Validation token check ok mock", path: "/users/check", method: isMethodPUT())
    }

    func mockValidationTokenCheckError12087() {
        mock(filename: "ValidationTokenCheckError12087", title: "Validation token check error 12087 mock", path: "/users/check", method: isMethodPUT())
    }

    func mockValidationTokenCheckError2500() {
        mock(filename: "ValidationTokenCheckError2500", title: "Validation token check error 2500 mock", path: "/users/check", method: isMethodPUT())
    }

    func mockModulusOK() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
    }

    func mockModulusError() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusError", title: "Modulus error mock", path: "/auth/modulus")
    }

    func mockCreateUsernameAccountOK() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserOK", title: "users put ok mock", path: "/users", method: isMethodPOST())
    }

    func mockCreateUsernameAccountError() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError", title: "users put error mock", path: "/users", method: isMethodPOST())
    }

    func mockCreateUsernameAccountError12081() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError12081", title: "users put error 12081 mock", path: "/users", method: isMethodPOST())
    }

    func mockCreateUsernameAccountError2001() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError2001", title: "users put error 12081 mock", path: "/users", method: isMethodPOST())
    }
    
    func mockModulusErrorWithParseDomain(username: String, domain: String) {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(username)%40\(domain)")
        })
        mock(filename: "ModulusError", title: "Modulus error mock", path: "/auth/modulus")
    }
    
    func mockCreateInternalAccountOK(username: String, domain: String) {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(username)%40\(domain)")
        })
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserOK", title: "users put ok mock", path: "/users", method: isMethodPOST()) { request in
            let body = request.bodySteamAsJSON() as! [String: Any]
            return body["Username"] as! String == username && body["Domain"] as! String == domain
        }
    }

    func mockCreateInternalAccountError(username: String, domain: String) {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(username)%40\(domain)")
        })
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError", title: "users put error mock", path: "/users", method: isMethodPOST()) { request in
            let body = request.bodySteamAsJSON() as! [String: Any]
            return body["Username"] as! String == username && body["Domain"] as! String == domain
        }
    }

    func mockCreateInternalAccountError12081(username: String, domain: String) {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(username)%40\(domain)")
        })
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError12081", title: "users put error 12081 mock", path: "/users", method: isMethodPOST()) { request in
            let body = request.bodySteamAsJSON() as! [String: Any]
            return body["Username"] as! String == username && body["Domain"] as! String == domain
        }
    }

    func mockCreateInternalAccountError2001(username: String, domain: String) {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(username)%40\(domain)")
        })
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateUserError2001", title: "users put error 12081 mock", path: "/users", method: isMethodPOST()) { request in
            let body = request.bodySteamAsJSON() as! [String: Any]
            return body["Username"] as! String == username && body["Domain"] as! String == domain
        }
    }

    func mockCreateExternalUserOK() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateExternalUserOK", title: "users external put ok mock", path: "/users/external", method: isMethodPOST())
    }

    func mockCreateExternalUserError() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateExternalUserError", title: "users external put error mock", path: "/users/external", method: isMethodPOST())
    }

    func mockCreateExternalUserError2500() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateExternalUserError2500", title: "users external put error 2500 mock", path: "/users/external", method: isMethodPOST())
    }

    func mockCreateExternalUserError2001() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateExternalUserError2001", title: "users external put error 2001 mock", path: "/users/external", method: isMethodPOST())
    }

    func mockCreateExternalUserError12087() {
        mock(filename: "UsersAvailableOK", title: "user is available", path: "/users/available")
        mock(filename: "ModulusOK", title: "Modulus ok mock", path: "/auth/modulus")
        mock(filename: "CreateExternalUserError12087", title: "users external put error 12087 mock", path: "/users/external", method: isMethodPOST())
    }

    private func mock(filename: String, differentOnSecondRequestFilename: String? = nil, title: String, path: String, statusCode: Int32 = 200, params: [String: String?]? = nil, body: [String: String?]? = nil, method: @escaping HTTPStubsTestBlock = isMethodGET(), requestValidator: @escaping (URLRequest) -> Bool = { _ in true }) {
        
        let queryParams = params != nil ? containsQueryParams(params!) : { _ in true }
        weak var usersStub = stub(condition: pathEndsWith(path) && queryParams && method) { request in
            if requestValidator(request) == false {
                XCTFail("request has not passed the validator")
            }
            let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json")!
            let headers = ["Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
        }
        usersStub?.name = title
    }
}
