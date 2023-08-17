//
//  LoginServiceTests+Setup.swift
//  ProtonCore-Login-Tests - Created on 11.01.2021.
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
import ProtonCoreAuthentication
import ProtonCoreCryptoGoInterface
import ProtonCoreObfuscatedConstants
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
import ProtonCoreTestingToolkitUnitTestsDoh
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreChallenge
import ProtonCoreDoh
import ProtonCoreLog
import ProtonCoreServices
@testable import ProtonCoreLogin

extension LoginServiceTests {
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

    var apiService: (APIService, AuthHelper) {
        let authDelegate = AuthHelper()
        let api = PMAPIService.createAPIServiceWithoutSession(doh: DohMock() as DoHInterface, challengeParametersProvider: .forAPIService(clientApp: .other(named: "core"), challenge: .init()))
        api.authDelegate = authDelegate
        return (api, authDelegate)
    }

    func mockInvalidCredentialsLogin() {
        mock(filename: "AuthInfoInvalidCredentials", title: "Invalid credentials /auth/info mock", path: "/auth/info")
        mock(filename: "AuthInvalidCredentials", title: "Invalid credentials /auth mock", path: "/auth/v4")
    }

    func mockAuthExtAccountsNotSupportedLoginError5099() {
        mock(filename: "AuthInfoInvalidCredentials", title: "Invalid credentials /auth/info mock", path: "/auth/info")
        mock(filename: "AuthExtAccountsNotSupportedError5099", title: "Auth external accounts not supported mock", path: "/auth/v4")
    }
    
    func mockAuthExtAccountsNotSupportedLoginError5098() {
        mock(filename: "AuthInfoInvalidCredentials", title: "Invalid credentials /auth/info mock", path: "/auth/info")
        mock(filename: "AuthExtAccountsNotSupportedError5098", title: "Auth external accounts not supported mock", path: "/auth/v4")
    }
    
    func mockNonExistentUserLogin() {
        mock(filename: "AuthInfoNonExistentUser", title: "Non existent user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthNonExistentUser", title: "Non existent user /auth mock", path: "/auth/v4")
    }

    func mockOnePasswordUserLogin() {
        mock(filename: "AuthInfoOnePasswordUser", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthOnePasswordUser", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersOnePasswordUser", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUser", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUser", title: "One password user /keys/salts mock", path: "/keys/salts")
    }

    func mockSSOUserLogin() {
        mock(filename: "AuthInfoUserWithSSO", title: "sso user /auth/info mock", path: "/auth/info")
    }
    
    func mockOnePasswordWith2FAUserLogin() {
        mock(filename: "AuthInfoOnePasswordUserWith2FA", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthOnePasswordUserWith2FA", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersOnePasswordUserWith2FA", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUserWith2FA", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUserWith2FA", title: "One password user /keys/salts mock", path: "/keys/salts")
        mock(filename: "2FaOnePasswordUserWith2FAOK", title: "One password user /keys/salts mock", path: "/auth/v4/2fa")
    }

    func mockOnePasswordWith2FAUserLoginWrong2FA() {
        mock(filename: "AuthInfoOnePasswordUserWith2FA", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthOnePasswordUserWith2FA", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersOnePasswordUserWith2FA", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUserWith2FA", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUserWith2FA", title: "One password user /keys/salts mock", path: "/keys/salts")
        mock(filename: "2FaOnePasswordUserWith2FAError", title: "One password user /keys/salts mock", path: "/auth/v4/2fa")
    }

    func mockUsernameOnlyUser() {
        mock(filename: "AuthInfoOnePasswordUser", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthOnePasswordUser", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersUsernameOnlyUser", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesUsernameOnlyUser", title: "One password user /addresses mock", path: "/addresses")
    }

    func mockUsernameAccountNotAvailable() {
        mock(filename: "UsersAvailableError", title: "User not available mock", path: "/users/available")
    }
    
    func mockInternalAccountNotAvailable(encodedEmail: String) {
        mock(filename: "UsersAvailableError", title: "User not available mock", path: "/users/available")
    }
    
    func mockInternalAccountError12087() {
        mock(filename: "ValidationTokenCheckError12087", title: "Error 12087 mock", path: "/users/available")
    }

    func mockEmailNotAvailable() {
        mock(filename: "UsersAvailableError", title: "User not available mock", path: "/users/availableExternal")
    }
    
    func mockExternalUser() {
        mock(filename: "AuthInfoOnePasswordUser", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthOnePasswordUser", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersExternalUser", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUser", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUser", title: "One password user /keys/salts mock", path: "/keys/salts")
    }

    func mockUsernameAccountAvailable() {
        mock(filename: "UsersAvailableOK", title: "User available mock", path: "/users/available")
    }
    
    func mockInternalAccountAvailable(encodedEmail: String) {
        mock(filename: "UsersAvailableOK", title: "User available mock", path: "/users/available", requestValidator: { request in
            request.url!.absoluteString.contains("?ParseDomain=1&Name=\(encodedEmail)")
        })
    }
    
    func mockEmailAvailable() {
        mock(filename: "UsersAvailableOK", title: "User available mock", path: "/users/availableExternal")
    }

    func mockLogoutError() {
        mock(filename: "LogoutError", title: "Logout error mock", path: "/auth/v4", statusCode: 401)
    }

    func mockTwoPasswordWith2FAUserLoginFail() {
        mock(filename: "AuthInfoOnePasswordUser", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthTwoPasswordUser", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersOnePasswordUser", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUser", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUser", title: "One password user /keys/salts mock", path: "/keys/salts")
    }

    func mockTwoPasswordWith2FAUserLogin() {
        mock(filename: "AuthInfoOnePasswordUserWith2FA", title: "One password user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthTwoPasswordUserWith2FA", title: "One password user /auth mock", path: "/auth/v4")
        mock(filename: "UsersOnePasswordUserWith2FA", title: "One password user user /users mock", path: "/users")
        mock(filename: "AddressesOnePasswordUserWith2FA", title: "One password user /addresses mock", path: "/addresses")
        mock(filename: "SaltsOnePasswordUserWith2FA", title: "One password user /keys/salts mock", path: "/keys/salts")
        mock(filename: "2FaOnePasswordUserWith2FAOK", title: "One password user /keys/salts mock", path: "/auth/v4/2fa")
    }

    func mockUserWithSoleCustomDomainAddress() {
        mock(filename: "AuthInfoCustomDomainUser", title: "Custom domain user /auth/info mock", path: "/auth/info")
        mock(filename: "AuthCustomDomainUser", title: "Custom domain user /auth mock", path: "/auth/v4")
        mock(filename: "UsersCustomDomainUserNoKeys",
             differentOnSecondRequestFilename: "UsersCustomDomainUserWithKeys",
             title: "Custom domain user /users mock",
             path: "/users")
        mock(filename: "AddressesCustomDomainUser", title: "Custom domain user /addresses mock", path: "/addresses")
        mock(filename: "AuthModulusCustomDomainUser", title: "Custom domain user /auth/modulus mock", path: "/auth/modulus")
        mock(filename: "KeysSetupCustomDomainUser", title: "Custom domain user /keys/setup mock", path: "/keys/setup")
        mock(filename: "SaltsCustomDomainUser", title: "Custom domain user /keys/salts mock", path: "/keys/salts")
    }

    func mockLogout() {
        HTTPStubs.removeAllStubs()
        mock(filename: "LogoutOK", title: "Logout error mock", path: "/auth/v4")
    }

    func mockAvailableDomainsSignupOK() {
        mock(filename: "AvailableDomainsSignupOK", title: "Available domains ok mock", path: "/domains/available", params: ["Type": "signup"])
    }

    func mockAvailableDomainsLoginOK() {
        mock(filename: "AvailableDomainsLoginOK", title: "Available domains ok mock", path: "/domains/available", params: ["Type": "login"])
    }

    func mockAvailableDomainsSignupError() {
        mock(filename: "AvailableDomainsSignupError", title: "Available domains error 401 mock", path: "/domains/available", params: ["Type": "signup"])
    }

    private func mock(filename: String, differentOnSecondRequestFilename: String? = nil,
                      title: String, path: String, statusCode: Int32 = 200, params: [String: String?]? = nil,
                      requestValidator: @escaping (URLRequest) -> Bool = { _ in true }) {
        // get code stub
        var counter = 0
        
        // params
        let queryParams = params != nil ? containsQueryParams(params!) : { _ in true }
        weak var usersStub = stub(condition: pathEndsWith(path) && queryParams) { request in
            if requestValidator(request) == false {
                XCTFail("request has not passed the validator")
            }
            counter += 1
            #if SPM
            let bundle = Bundle.module
            #else
            let bundle = Bundle(for: type(of: self))
            #endif
            let url: URL
            if counter > 1, let differentOnSecondRequestFilename = differentOnSecondRequestFilename {
                url = bundle.url(forResource: differentOnSecondRequestFilename, withExtension: "json")!
            } else {
                url = bundle.url(forResource: filename, withExtension: "json")!
            }

            let headers = ["Content-Type": "application/json;charset=utf-8"]

            if path.hasSuffix("/auth/v4") {
                let unmodified = { () -> HTTPStubsResponse in
                    return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
                }

                let data = try! Data(contentsOf: url)
                var json = (try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String: Any]

                if json["Error"] != nil { // do not compute RSP with error response is being mocked
                    return unmodified()
                }

                guard let request = request.bodySteamAsJSON() as? [String: String], let clientEphemeral = request["ClientEphemeral"], let clientProof = request["ClientProof"] else {
                    return unmodified()
                }

                guard let serverProof = try? self.server!.verifyProofs(Data(base64Encoded: clientEphemeral), clientProofBytes: Data(base64Encoded: clientProof)) else {
                    return unmodified()
                }
                
                json["ServerProof"] = serverProof.base64EncodedString()
                let response = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.fragmentsAllowed)
                return HTTPStubsResponse(data: response, statusCode: statusCode, headers: headers)
            }

            if path.hasSuffix("/auth/info") {
                let data = try! Data(contentsOf: url)
                self.authInfoRequestData = (try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: Any]
                self.authInfoRequestData?["Modulus"] = ObfuscatedConstants.modulus
                self.authInfoRequestData?["Salt"] = ObfuscatedConstants.srpAuthSalt
                
                guard let verifier = Data(base64Encoded: ObfuscatedConstants.srpAuthVerifier), !verifier.isEmpty else {
                    return HTTPStubsResponse(data: data, statusCode: statusCode, headers: headers)
                }

                let bits = 2048
                
                self.server = CryptoGo.SrpNewServerFromSigned(ObfuscatedConstants.modulus, verifier, bits, nil)!
                let challenge = try! self.server!.generateChallenge() // this is the serverEphemeral
                
                self.authInfoRequestData?["Modulus"] = ObfuscatedConstants.modulus
                self.authInfoRequestData?["ServerEphemeral"] = challenge.base64EncodedString()
                
                let response = try! JSONSerialization.data(withJSONObject: self.authInfoRequestData!, options: JSONSerialization.WritingOptions.fragmentsAllowed)
                
                return HTTPStubsResponse(data: response, statusCode: statusCode, headers: headers)
            }

            return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
        }
        usersStub?.name = title
    }
}

#endif
