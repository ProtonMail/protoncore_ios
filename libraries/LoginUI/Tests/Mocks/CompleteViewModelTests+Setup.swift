//
//  CompleteViewModelTests+Setup.swift
//  ProtonCore-Login-Tests - Created on 08.04.21.
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

import ProtonCore_ObfuscatedConstants
import ProtonCore_Challenge
import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Login
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonCore_LoginUI

extension CompleteViewModelTests {
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

    func createViewModel(doh: DoH & ServerConfig, type minimumAccountType: AccountType) -> CompleteViewModel {
        let authDelegate = AuthManager()
        let serviceDelegate = AnonymousServiceManager()
        let api = PMAPIService(doh: doh, sessionUID: "test session ID")
        api.authDelegate = authDelegate
        api.serviceDelegate = serviceDelegate
        let login = LoginService(api: api, authManager: authDelegate, clientApp: .other(named: "CompleteVMTestAPP"), sessionId: "test session ID", minimumAccountType: minimumAccountType)
        let signupService = SignupService(api: api, challangeParametersProvider: PMChallenge(), clientApp: .mail)
        let viewModel = CompleteViewModel(signupService: signupService, loginService: login, initDisplaySteps: [])
        return viewModel
    }

    func mockCreateUserOK() {
        // Signup requests:
        // 1. GET auth/modulus
        // 2. GET users/available
        // 3. POST /users
        mock(filenames: ["UsersAvailableOK"], title: "User available mock", path: "/users/available")
        mock(filenames: ["ModulusOK"], title: "modulus mock", path: "/auth/modulus")
        mock(filenames: ["CreateUserOK", "UsersCustomDomainUserNoKeys", "CreateUserUsersKeys"], title: "1. post users, 2. get users, 3. get users with keys mock", path: "/users")

        // Login requests:
        // 1. GET auth/info
        // 2. GET auth
        // 3. GET users
        // 4. GET addresses
        // 5. POST addresses/setup
        // 6. GET auth/modulus
        // 7. POST keys/setup
        // 8. GET users
        // 9. GET addresses
        // 10. GET keys/salts
        mock(filenames: ["AuthInfoOnePasswordUser"], title: "auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthOnePasswordUser"], title: "users mock", path: "/auth")
        mock(filenames: ["CreateUserEmptyAdresses", "CreateUserAddressesCreated"], title: "1. empty addresses, 2. created addresses mock", path: "/addresses")
        mock(filenames: ["CreateUserAdressesSetup"], title: "addresses/setup mock", path: "/addresses/setup")
        mock(filenames: ["CreateUserKeysSetup"], title: "keys/setup mock", path: "/keys/setup")
        mock(filenames: ["CreateUserKeysSalts"], title: "keys/salts mock", path: "/keys/salts")
    }
    
    func mockCreateUserInvalidLoginCredentials() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["UsersAvailableOK"], title: "User available mock", path: "/users/available")
        mock(filenames: ["CreateUserOK"], title: "users put ok mock", path: "/users")
        // login
        mock(filenames: ["AuthInfoInvalidCredentials"], title: "Invalid credentials /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthInvalidCredentials"], title: "Invalid credentials /auth mock", path: "/auth")
    }

    func mockCreateUserNonExistingUser() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["UsersAvailableOK"], title: "User available mock", path: "/users/available")
        mock(filenames: ["CreateUserOK"], title: "users put ok mock", path: "/users")
        // login
        mock(filenames: ["AuthInfoNonExistentUser"], title: "Non existent user /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthNonExistentUser"], title: "Non existent user /auth mock", path: "/auth")
    }

    func mockCreateUser2FAError() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["UsersAvailableOK"], title: "User available mock", path: "/users/available")
        mock(filenames: ["CreateUserOK"], title: "users put ok mock", path: "/users")
        // login
        mock(filenames: ["AuthInfoOnePasswordUserWith2FA"], title: "One password user /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthOnePasswordUserWith2FA"], title: "One password user /auth mock", path: "/auth")
    }

    func mockCreateExternalUserOK() {
        // Signup external requests:
        // 0. GET /users/available
        // 1. GET auth/modulus
        // 2. POST /users/external
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        mock(filenames: ["ModulusOK"], title: "modulus mock", path: "/auth/modulus")
        mock(filenames: ["CreateExternalUserOK"], title: "users external put ok mock", path: "/users/external")

        // Login requests:
        // 1. GET auth/info
        // 2. GET auth
        // 3. GET users
        // 4. GET addresses
        // 5. GET auth/modulus
        // 6. POST keys/setup
        // 7. GET users
        // 8. GET addresses
        // 9. GET keys/salts
        mock(filenames: ["AuthInfoOnePasswordUser"], title: "auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthOnePasswordUser"], title: "users mock", path: "/auth")
        mock(filenames: ["UsersCustomDomainUserNoKeys", "CreateExtUserUsersKeys"], title: "1. get users mock, 2. get users with keys mock", path: "/users")
        mock(filenames: ["CreateExtUserAdresses", "CreateExtUserAdressesKeys"], title: "1. ext addresses mock, 2. ext addresses keys mock", path: "/addresses")
        mock(filenames: ["CreateExtUserKeysSetup"], title: "ext keys/setup mock", path: "/keys/setup")
        mock(filenames: ["CreateUserKeysSalts"], title: "keys/salts mock", path: "/keys/salts")
    }

    func mockCreateExternalUserInvalidLoginCredentials() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["CreateExternalUserOK"], title: "users external put ok mock", path: "/users/external")
        // login
        mock(filenames: ["AuthInfoInvalidCredentials"], title: "Invalid credentials /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthInvalidCredentials"], title: "Invalid credentials /auth mock", path: "/auth")
    }

    func mockCreateExternalUserNonExistingUser() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["CreateExternalUserOK"], title: "users external put ok mock", path: "/users/external")
        // login
        mock(filenames: ["AuthInfoNonExistentUser"], title: "Non existent user /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthNonExistentUser"], title: "Non existent user /auth mock", path: "/auth")
    }

    func mockCreateExternalUser2FAError() {
        mock(filenames: ["UsersAvailableOK"], title: "user is available", path: "/users/available")
        // signup
        mock(filenames: ["ModulusOK"], title: "Modulus ok mock", path: "/auth/modulus")
        mock(filenames: ["CreateExternalUserOK"], title: "users external put ok mock", path: "/users/external")
        // login
        mock(filenames: ["AuthInfoOnePasswordUserWith2FA"], title: "One password user /auth/info mock", path: "/auth/info")
        mock(filenames: ["AuthOnePasswordUserWith2FA"], title: "One password user /auth mock", path: "/auth")
    }

    private func mock(filenames: [String], title: String, path: String, statusCode: Int32 = 200, params: [String: String?]? = nil) {
        // get code stub
        var counter = 0
        
        // params
        let queryParams = params != nil ? containsQueryParams(params!) : { _ in true }
        guard filenames.count > 0 else {
            PMLog.debug("Wrong mock config!!!")
            return
        }
        weak var usersStub = stub(condition: pathEndsWith(path) && queryParams) { request in
            counter += 1
            let url: URL
            let filename = counter > filenames.count ? filenames[0] : filenames[counter - 1]
            url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json")!

            let headers = ["Content-Type": "application/json;charset=utf-8"]

            if path.hasSuffix("/auth") {
                let unmodified = { () -> HTTPStubsResponse in
                    return HTTPStubsResponse(data: try! Data(contentsOf: url), statusCode: statusCode, headers: headers)
                }

                let data = try! Data(contentsOf: url)
                var json = (try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String: Any]

                if json["Error"] != nil { // do not compute RSP with error response is being mocked
                    return unmodified()
                }

                guard let request = request.bodySteamAsJSON() as? [String: String], let clientEphemeral = request["ClientEphemeral"], let clientProof = request["ClientProof"], let serverProof = try? self.server!.verifyProofs(Data(base64Encoded: clientEphemeral), clientProofBytes: Data(base64Encoded: clientProof)) else {
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
                
                self.server = SrpNewServerFromSigned(ObfuscatedConstants.modulus, verifier, bits, nil)!
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
