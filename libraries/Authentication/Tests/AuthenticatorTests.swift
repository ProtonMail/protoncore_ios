//
//  AuthenticatorTests.swift
//  ProtonCore-Authentication-Tests - Created on 19/02/2020.
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

import ProtonCoreAPIClient
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreCryptoPatchedGoImplementation)
import ProtonCoreCryptoPatchedGoImplementation
#elseif canImport(ProtonCoreCryptoGoImplementation)
import ProtonCoreCryptoGoImplementation
#elseif canImport(ProtonCoreCryptoSearchGoImplementation)
import ProtonCoreCryptoSearchGoImplementation
#elseif canImport(ProtonCoreCryptoVPNPatchedGoImplementation)
import ProtonCoreCryptoVPNPatchedGoImplementation
#else
import ProtonCoreCryptoGoImplementation
#endif
import ProtonCoreDoh
import ProtonCoreNetworking
@testable import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsAuthentication)
import ProtonCoreTestingToolkitUnitTestsAuthentication
import ProtonCoreTestingToolkitUnitTestsServices
#else
import ProtonCoreTestingToolkit
#endif
import ProtonCoreDataModel
@testable import ProtonCoreAuthentication

class AuthenticatorTests: XCTestCase {

    enum TestCodingKeys: CodingKey { case code }
    let decodingError = DecodingError.keyNotFound(TestCodingKeys.code, .init(codingPath: [TestCodingKeys.code], debugDescription: "Test decoding error"))

    let apiBlockedError = NSError.protonMailError(APIErrorCode.potentiallyBlocked, localizedDescription: SRTranslations._core_api_might_be_blocked_message.l10n)
    lazy var apiBlockedResponseError = ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: apiBlockedError.localizedDescription, underlyingError: apiBlockedError)

    var apiService: APIServiceMock!
    var srpAuthMock: SrpAuthMock!

    static let exampleServerProof = "1234"
    let timeout = 1.0
    static let emptyReponse: [String: Any] = [:]

    override class func setUp() {
        super.setUp()
        injectDefaultCryptoImplementation()
    }

    override func setUp() {
        apiService = APIServiceMock()
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in completion(.wrongConfigurationNoDelegate) }
        srpAuthMock = SrpAuthMock()
        super.setUp()
    }

    let authInfoResponse = AuthInfoResponse(
        modulus: "test",
        serverEphemeral: "test",
        version: 0,
        salt: "test",
        srpSession: "test"
    )

    var srpProofs: SrpProofsMock {
        let srpProofs = SrpProofsMock()
        srpProofs.clientProof = Data()
        srpProofs.clientEphemeral = Data()
        srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
        return srpProofs
    }

    let fido2: Fido2 = .init(authenticationOptions: .init(
        publicKey: .init(timeout: 600,
                         challenge: Data(repeating: 22, count: 22),
                         userVerification: "discouraged",
                         rpId: "proton.me",
                         allowCredentials: [
                            .init(id: Data(repeating: 33, count: 12),
                                  type: "public-key")
                         ]
                        )
    ),
                             registeredKeys: [
                                .init(attestationFormat: "packed",
                                      credentialID: Data(repeating: 1, count: 5), name: "My Yubi key")
                             ]
    )

    struct Response: Codable {
        public var code: Int
    }

    func authRouteResponse(twoFA: AuthInfoResponse.TwoFA) -> AuthService.AuthRouteResponse {
        return AuthService.AuthRouteResponse(accessToken: "accessToken", tokenType: "tokenType", refreshToken: "refreshToken", scopes: ["Scope"], UID: "UID", userID: "userID", eventID: "eventID", serverProof: AuthenticatorTests.exampleServerProof, passwordMode: PasswordMode.one, _2FA: twoFA)
    }

    // MARK: Authenticate with SSO

    func test_authenticate_withSSO_success() {
        // Given
        let sut = Authenticator(api: apiService)
        let expectation = XCTestExpectation(description: "success expected")
        let authRouteResponse = AuthService.AuthRouteResponse(accessToken: "", tokenType: "", refreshToken: "refreshToken", scopes: .empty, UID: "", userID: "", eventID: "", serverProof: "", passwordMode: .one, _2FA: .init(enabled: .off))

        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(authRouteResponse))
        }

        // When
        sut.authenticate(idpEmail: "test@protonhub.org", responseToken: .init(token: "token", uid: "uid")) { result in
            switch result {
            case .success(.newCredential(let credentials, .one)):
                XCTAssertEqual(credentials.refreshToken, "refreshToken")
                XCTAssertEqual(credentials.scopes, .empty)
                XCTAssertEqual(credentials.userName, "test@protonhub.org")
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
    }

    func test_authenticate_withSSO_fails() {
        // Given
        let sut = Authenticator(api: apiService)
        let expectation = XCTestExpectation(description: "success expected")
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.badResponse()))
        }

        // When
        sut.authenticate(idpEmail: "test@protonhub.org", responseToken: .init(token: "token", uid: "uid")) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
    }

    // MARK: Authenticate

    func testAuthenticateSuccessNewCredential() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                let twoFA = AuthInfoResponse.TwoFA(enabled: .off)
                completion(nil, .success(self.authRouteResponse(twoFA: twoFA)))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        let username = "username"
        manager.authenticate(username: username, password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, let passwordMode)):
                let twoFA = AuthInfoResponse.TwoFA(enabled: .off)
                let authRouteResponse = self.authRouteResponse(twoFA: twoFA)
                XCTAssertEqual(credential.UID, authRouteResponse.UID)
                XCTAssertEqual(credential.accessToken, authRouteResponse.accessToken)
                XCTAssertEqual(credential.refreshToken, authRouteResponse.refreshToken)
                XCTAssertEqual(credential.userName, username)
                XCTAssertEqual(credential.userID, authRouteResponse.userID)
                XCTAssertEqual(credential.scopes, authRouteResponse.scopes)
                XCTAssertEqual(passwordMode, PasswordMode.one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateSuccess2FAOn() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                let twoFA = AuthInfoResponse.TwoFA(enabled: .totp)
                completion(nil, .success(self.authRouteResponse(twoFA: twoFA)))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        let username = "username"
        manager.authenticate(username: username, password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.askTOTP(let context)):
                let twoFA = AuthInfoResponse.TwoFA(enabled: .totp)
                let authRouteResponse = self.authRouteResponse(twoFA: twoFA)
                XCTAssertEqual(context.credential.UID, authRouteResponse.UID)
                XCTAssertEqual(context.credential.accessToken, authRouteResponse.accessToken)
                XCTAssertEqual(context.credential.refreshToken, authRouteResponse.refreshToken)
                XCTAssertEqual(context.credential.userName, username)
                XCTAssertEqual(context.credential.userID, authRouteResponse.userID)
                XCTAssertEqual(context.credential.scopes, authRouteResponse.scopes)
                XCTAssertEqual(context.passwordMode, PasswordMode.one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateSuccess2FAWebAuthn() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                let twoFA = AuthInfoResponse.TwoFA(enabled: .webAuthn,
                                                   fido2: self.fido2)
                completion(nil, .success(self.authRouteResponse(twoFA: twoFA)))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.notImplementedYet(let string)):
                XCTAssertEqual("WebAuthn not implemented yet", string)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateSuccess2FAWebAuthnWithFF() {
        withFeatureFlags([.fidoKeys]) {
            let manager = Authenticator(api: self.apiService)
            let expect = self.expectation(description: "AuthInfo + Auth")
            apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
                if path.contains("/auth/info") {
                    completion(nil, .success(self.authInfoResponse))
                } else if path.contains("/auth/v4") {
                    let pk = PublicKey(timeout: 100,
                                             challenge: Data([65, 66, 67]),
                                             userVerification: "check",
                                             rpId: "proton.me",
                                             allowCredentials: [
                                                AllowedCredential(id: Data([97, 98, 99]),
                                                                        type: "public")
                                             ])
                    let fido2 = Fido2(authenticationOptions: AuthenticationOptions(publicKey: pk),
                                            registeredKeys: [
                                                RegisteredKey(attestationFormat: "packed",
                                                                    credentialID: Data([100, 101, 102]),
                                                                    name: "My Key")
                                            ])
                    let twoFA = AuthInfoResponse.TwoFA(enabled: .webAuthn, fido2: fido2)
                    completion(nil, .success(self.authRouteResponse(twoFA: twoFA)))
                } else {
                    XCTFail()
                    completion(nil, .success(AuthenticatorTests.emptyReponse))
                }
            }
            srpAuthMock.generateProofsStub.bodyIs { _, _  in
                return self.srpProofs
            }

            manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
                switch result {
                case let .success(Authenticator.Status.askFIDO2(context, authenticationOptions)):
                    let twoFA = AuthInfoResponse.TwoFA(enabled: .webAuthn)
                    let authRouteResponse = self.authRouteResponse(twoFA: twoFA)
                    XCTAssertEqual(context.credential.UID, authRouteResponse.UID)
                    XCTAssertEqual(authenticationOptions.challenge, Data([65, 66, 67]))
                    XCTAssertEqual(authenticationOptions.publicKey.timeout, 100)
                    XCTAssertEqual(authenticationOptions.publicKey.userVerification, "check")
                    XCTAssertEqual(authenticationOptions.relyingPartyIdentifier, "proton.me")
                    XCTAssertEqual(authenticationOptions.allowedCredentialIds.count, 1)
                    XCTAssertEqual(authenticationOptions.allowedCredentialIds[0], Data([97, 98, 99]))
                    XCTAssertEqual(authenticationOptions.publicKey.allowCredentials[0].type, "public")

                default:
                    XCTFail("Wrong result")
                }
                expect.fulfill()
            }
            waitForExpectations(timeout: timeout) { (error) in
                XCTAssertNil(error, String(describing: error))
            }
        }
    }

    func testAuthenticateSuccessTryingToAuthenticateInContextOfUnauthSession() {
        let manager = Authenticator(api: apiService)
        let unauthSessionCredentials = AuthCredential(sessionID: "test session",
                                                      accessToken: "test access token",
                                                      refreshToken: "test refresh token",
                                                      userName: "",
                                                      userID: "",
                                                      privateKey: nil,
                                                      passwordKeySalt: nil)
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: unauthSessionCredentials))
        }
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .success(self.authRouteResponse(twoFA: AuthInfoResponse.TwoFA(enabled: .off))))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in self.srpProofs }

        let username = "username"
        manager.authenticate(username: username, password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, _)):
                let authRouteResponse = self.authRouteResponse(twoFA: AuthInfoResponse.TwoFA(enabled: .off))
                XCTAssertEqual(credential.UID, authRouteResponse.UID)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateSuccessTryingToReauthenticateInContextOfAuthenticatedUser() {
        let manager = Authenticator(api: apiService)
        let username = "username"
        let authSessionCredentials = AuthCredential(sessionID: "test session",
                                                    accessToken: "test access token",
                                                    refreshToken: "test refresh token",
                                                    userName: "username",
                                                    userID: "test userID",
                                                    privateKey: nil,
                                                    passwordKeySalt: nil)
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: authSessionCredentials))
        }
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .success(self.authRouteResponse(twoFA: AuthInfoResponse.TwoFA(enabled: .off))))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in self.srpProofs }

        manager.authenticate(username: username, password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, _)):
                let authRouteResponse = self.authRouteResponse(twoFA: AuthInfoResponse.TwoFA(enabled: .off))
                XCTAssertEqual(credential.UID, authRouteResponse.UID)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorTryingToAuthenticateInContextOfDifferentAlreadyAuthenticatedUser() {
        let manager = Authenticator(api: apiService)
        let username = "username"
        let authSessionCredentials = AuthCredential(sessionID: "test session",
                                                    accessToken: "test access token",
                                                    refreshToken: "test refresh token",
                                                    userName: "different user",
                                                    userID: "test userID",
                                                    privateKey: nil,
                                                    passwordKeySalt: nil)
        let authDelegateMock = AuthDelegateMock()
        apiService.authDelegateStub.fixture = authDelegateMock
        apiService.fetchAuthCredentialsStub.bodyIs { _, completion in
            completion(.found(credentials: authSessionCredentials))
        }
        apiService.acquireSessionIfNeededStub.bodyIs { _, completion in
            completion(.success(.sessionUnavailableAndNotFetched))
        }

        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .success(self.authRouteResponse(twoFA: AuthInfoResponse.TwoFA(enabled: .off))))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in self.srpProofs }

        manager.authenticate(username: username, password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
        XCTAssertTrue(authDelegateMock.onAuthenticatedSessionInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(authDelegateMock.onUnauthenticatedSessionInvalidatedStub.wasCalledExactlyOnce)
        XCTAssertTrue(apiService.acquireSessionIfNeededStub.wasCalledExactlyOnce)
    }

    func testAuthenticateErrorUserInfoNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        let testResponseError = ResponseError(httpCode: 123, responseCode: 567, userFacingMessage: "testError", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorSrpAuth() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.authenticate(username: "username", password: "password", challenge: nil) { result in
            switch result {
            case .failure(let error):
                if case .emptyServerSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthException() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            // throw exception here
            throw AuthErrors.notImplementedYet("generateProofs error")
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.parsingError(let error)):
                let resp = error as? AuthErrors
                if case .notImplementedYet(let message) = resp {
                    XCTAssertEqual("generateProofs error", message)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyClientProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")

        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = nil
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
            return srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyClientEphemeral() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")

        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = nil
            srpProofs.expectedServerProof = Data(base64Encoded: AuthenticatorTests.exampleServerProof)
            return srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyExpectedServerProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")

        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = nil
            return srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorEmptyClientSrpAuthEmptyExpectedServerProofParse() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")

        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = SrpProofsMock()
            srpProofs.clientProof = Data()
            srpProofs.clientEphemeral = Data()
            srpProofs.expectedServerProof = Data(base64Encoded: "Wrong data")
            return srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .emptyClientSrpAuth = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorAuthNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorAPIMightBeBlocked() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorAuthPerseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            return self.srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testAuthenticateErrorWrongServerProof() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "AuthInfo + Auth")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/info") {
                completion(nil, .success(self.authInfoResponse))
            } else if path.contains("/auth/v4") {
                let twoFA = AuthInfoResponse.TwoFA(enabled: .off)
                completion(nil, .success(self.authRouteResponse(twoFA: twoFA)))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }
        srpAuthMock.generateProofsStub.bodyIs { _, _  in
            let srpProofs = self.srpProofs
            srpProofs.expectedServerProof = Data(base64Encoded: "1239")
            return srpProofs
        }

        manager.authenticate(username: "username", password: "password", challenge: nil, srpAuth: srpAuthMock) { result in
            switch result {
            case .failure(let error):
                if case .wrongServerProof = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail()
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: Confirm2FA

    func testConfirm2FASucess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        let response = AuthService.TwoFAResponse(scopes: ["Scope"])
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/2fa") {
                completion(nil, .success(response))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope1", "Scope2"])
        let context = TOTPContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .success(Authenticator.Status.newCredential(let credential, let passwordMode)):
                XCTAssertEqual(credential.UID, testCredential.UID)
                XCTAssertEqual(credential.accessToken, testCredential.accessToken)
                XCTAssertEqual(credential.refreshToken, testCredential.refreshToken)
                XCTAssertEqual(credential.userName, testCredential.userName)
                XCTAssertEqual(credential.userID, testCredential.userID)
                XCTAssertEqual(credential.scopes.count, 1)
                XCTAssertEqual(credential.scopes, response.scopes)
                XCTAssertEqual(passwordMode, .one)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testConfirm2FAErrorResponseParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/2fa") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        let context = TOTPContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testConfirm2FAErrorResponseNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/2fa") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        let context = TOTPContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testConfirm2FAApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "2fa")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/2fa") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        let context = TOTPContext(credential: testCredential, passwordMode: .one)
        manager.confirm2FA("code", context: context) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(self.apiBlockedResponseError, originalError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: refreshCredential

    func testRefreshCredentialSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        let refreshResponse = RefreshResponse(accessToken: "accessToken",
                                              tokenType: "tokenType",
                                              scopes: ["Scope"],
                                              refreshToken: "refreshToken")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/refresh") {
                completion(nil, .success(refreshResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .success(Authenticator.Status.updatedCredential(let updatedCredential)):
                XCTAssertEqual(updatedCredential.UID, testCredential.UID)
                XCTAssertEqual(updatedCredential.accessToken, refreshResponse.accessToken)
                XCTAssertEqual(updatedCredential.refreshToken, refreshResponse.refreshToken)

                XCTAssertEqual(updatedCredential.userName, testCredential.userName)
                XCTAssertEqual(updatedCredential.userID, testCredential.userID)
                XCTAssertEqual(updatedCredential.scopes, refreshResponse.scopes)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRefreshCredentialErrorResponseParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/refresh") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRefreshCredentialErrorNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/refresh") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testRefreshCredentialApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "refreshCredential")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/refresh") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.refreshCredential(testCredential) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(self.apiBlockedResponseError, originalError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: checkAvailable

    func testCheckAvailableWithinDomainSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        let domain = "proton.test"
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?ParseDomain=1&Name=") {
                XCTAssertTrue(path.contains("\(userName)%40\(domain)"))
                let userAvailableResponse = AuthService.UserAvailableResponse()
                completion(nil, .success(userAvailableResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.checkAvailableUsernameWithinDomain(userName, domain: domain) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCheckAvailableWithinDomainErrorUsernameAlreadyUsed() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        let domain = "proton.test"
        let nsError = NSError(domain: "ProtonCore-Networking", code: 2500, userInfo: ["NSLocalizedDescription": "Username already used"])
        let testResponseError = ResponseError(httpCode: 409, responseCode: 2500, userFacingMessage: "Username already used", underlyingError: nsError)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?ParseDomain=1&Name=") {
                XCTAssertTrue(path.contains(userName))
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.checkAvailableUsernameWithinDomain(userName, domain: domain) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCheckAvailableWithoutDomainSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?Name=") {
                XCTAssertTrue(path.contains(userName))
                let userAvailableResponse = AuthService.UserAvailableResponse()
                completion(nil, .success(userAvailableResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.checkAvailableUsernameWithoutSpecifyingDomain(userName) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCheckAvailableWithoutDomainAvailableErrorUsernameAlreadyUsed() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "checkAvailable")
        let userName = "userName"
        let nsError = NSError(domain: "ProtonCore-Networking", code: 2500, userInfo: ["NSLocalizedDescription": "Username already used"])
        let testResponseError = ResponseError(httpCode: 409, responseCode: 2500, userFacingMessage: "Username already used", underlyingError: nsError)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users" + "/available?Name=") {
                XCTAssertTrue(path.contains(userName))
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.checkAvailableUsernameWithoutSpecifyingDomain(userName) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: setUsername

    func testSetUsernameSuccess() {
        let manager = Authenticator(api: apiService)
        let expect1 = expectation(description: "setUsername")
        let expect2 = expectation(description: "setUsername without credentials")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/settings/username") {
                let setUsernameResponse = AuthService.SetUsernameResponse()
                completion(nil, .success(setUsernameResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.setUsername(testCredential, username: "username") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect1.fulfill()
        }

        manager.setUsername(nil, username: "username") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect2.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "setUsername")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/settings/username") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.setUsername(nil, username: "username") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testSetUsernameApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "setUsername")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/settings/username") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.setUsername(nil, username: "username") { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: createAddress

    func testCreateAddressSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        let key = Key(keyID: "keyID", privateKey: "privateKey")
        let testAddress = Address(addressID: "addressID", domainID: "domainID", email: "email@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName", signature: "signature", hasKeys: 100, keys: [key])
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                let response = AuthService.CreateAddressEndpointResponse(address: testAddress)
                completion(nil, .success(response))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", signature: "signature") { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testAddress)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateAddressParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", signature: "signature") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateAddressNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", signature: "signature") { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateAddressApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createAddress")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses/setup") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.createAddress(testCredential, domain: "domain", displayName: "displayName", signature: "signature") { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: createUser without domain

    func testCreateUserSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertNil((parameters as! [String: Any])["Domain"])
                let response = Response(code: 1000)
                completion(nil, .success(response.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: nil)
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateUserNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertNil((parameters as! [String: Any])["Domain"])
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: nil)
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateUserApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertNil((parameters as! [String: Any])["Domain"])
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: nil)
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: createUser

    func testCreateUserWithDomainSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertEqual((parameters as! [String: Any])["Domain"] as! String, "proton.test")
                let response = Response(code: 1000)
                completion(nil, .success(response.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: "proton.test")
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateUserWithDomainNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertEqual((parameters as! [String: Any])["Domain"] as! String, "proton.test")
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: "proton.test")
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateUserWithDomainApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createUser")
        apiService.requestJSONStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                XCTAssertEqual((parameters as! [String: Any])["Domain"] as! String, "proton.test")
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let userParameters = UserParameters(userName: "userName", email: "email@email.ch", phone: "1234", modulusID: "modulusID", salt: "salt", verifer: "verifer", productPrefix: "mail", domain: "proton.test")
        manager.createUser(userParameters: userParameters) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: createExternalUser

    func testCreateExternalUserSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createExternalUser")
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users/external") {
                let response = Response(code: 1000)
                completion(nil, .success(response.toSuccessfulResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let externalUserParameters = ExternalUserParameters(email: "email@email.ch", modulusID: "modulusID", salt: "salt", verifer: "verifer", challenge: [["challenge": "challenge"]], verifyToken: "verifyToken", tokenType: "test", productPrefix: "mail")
        manager.createExternalUser(externalUserParameters: externalUserParameters) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateExternalUserNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createExternalUser")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users/external") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let externalUserParameters = ExternalUserParameters(email: "email@email.ch", modulusID: "modulusID", salt: "salt", verifer: "verifer", challenge: [["challenge": "challenge"]], verifyToken: "verifyToken", tokenType: "test", productPrefix: "mail")
        manager.createExternalUser(externalUserParameters: externalUserParameters) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCreateExternalUserApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "createExternalUser")
        apiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users/external") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let externalUserParameters = ExternalUserParameters(email: "email@email.ch", modulusID: "modulusID", salt: "salt", verifer: "verifer", challenge: [["challenge": "challenge"]], verifyToken: "verifyToken", tokenType: "test", productPrefix: "mail")
        manager.createExternalUser(externalUserParameters: externalUserParameters) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: getUserInfo

    func testGetUserInfoSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        let key = Key(keyID: "keyID", privateKey: "privateKey")
        let testUser = User(
            ID: "ID",
            name: "name",
            usedSpace: 1000,
            usedBaseSpace: 1000,
            usedDriveSpace: 0,
            currency: "USD",
            credit: 0,
            maxSpace: 1000000,
            maxBaseSpace: 500000,
            maxDriveSpace: 500000,
            maxUpload: 100000,
            role: 1,
            private: 2,
            subscribed: [.mail, .drive],
            services: 4,
            delinquent: 0,
            orgPrivateKey: "orgPrivateKey",
            email: "email@email.ch",
            displayName: "displayName",
            keys: [key]
        )
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                let userResponse = AuthService.UserResponse(user: testUser)
                completion(nil, .success(userResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user, testUser)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetUserInfoParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetUserInfoNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetUserInfoApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getUserInfo")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/users") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let credential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getUserInfo(credential) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: getAddresses

    func testGetAddressesSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        let key1 = Key(keyID: "keyID", privateKey: "privateKey")
        let key2 = Key(keyID: "keyID2", privateKey: "privateKey2")
        let testAddress1 = Address(addressID: "addressID", domainID: "domainID", email: "email@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName", signature: "signature", hasKeys: 100, keys: [key1])
        let testAddress2 = Address(addressID: "addressID2", domainID: "domainID2", email: "email2@email.ch", send: .active, receive: .active, status: .enabled, type: .externalAddress, order: 1, displayName: "displayName2", signature: "signature2", hasKeys: 100, keys: [key1, key2])
        let testAddresses = [testAddress1, testAddress2]
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                let response = AuthService.AddressesResponse(addresses: testAddresses)
                completion(nil, .success(response))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testAddresses)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetAddressesParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetAddressesNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetAddressesApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getAddresses")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/addresses") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getAddresses(testCredential) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: getKeySalts

    func testGetKeySaltsSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        let keySalt1 = KeySalt(ID: "ID1", keySalt: "keySalt1")
        let keySalt2 = KeySalt(ID: "ID2", keySalt: "keySalt2")
        let testKeySalts = [keySalt1, keySalt2]
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                let response = AuthService.KeySaltsResponse(keySalts: testKeySalts)
                completion(nil, .success(response))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .success(let address):
                XCTAssertEqual(address, testKeySalts)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetKeySaltsParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetKeySaltsNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetKeySaltsApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getKeySalts")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/keys/salts") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.getKeySalts(testCredential) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: fork session
    func testForkSessionSuccess() async throws {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testSelector = "test selector"
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        let manager = Authenticator(api: apiService)

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
                let params = parameters as? [String: Any],
                let childClientID = params["ChildClientID"] as? String,
                let independence = params["Independent"] as? Int,
                childClientID == testClientId,
                independence == (testIndependence ? 1 : 0) {
                completion(nil, .success(AuthService.ForkSessionResponse(selector: testSelector)))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        let response = try await withCheckedThrowingContinuation { continuation in
            manager.forkSession(testCredential,
                                useCase: .forChildClientID(testClientId, independent: testIndependence),
                                completion: continuation.resume(with:))
        }

        // then
        XCTAssertEqual(response.selector, testSelector)
    }

    func testForkSessionError() async {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        let manager = Authenticator(api: apiService)

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
                let params = parameters as? [String: Any],
                let childClientID = params["ChildClientID"] as? String,
                let independence = params["Independent"] as? Int,
                childClientID == testClientId,
                independence == (testIndependence ? 1 : 0) {
                completion(nil, .failure(.badResponse()))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                manager.forkSession(testCredential,
                                    useCase: .forChildClientID(testClientId, independent: testIndependence),
                                    completion: continuation.resume(with:))
            }
            XCTFail()
        } catch {
            // then
            guard case .networkingError(let responseError) = error as? AuthErrors,
                    let underlyingError = responseError.underlyingError else {
                XCTFail()
                return
            }
            XCTAssertEqual(underlyingError, .badResponse())
        }
    }

    // MARK: fork and obtain child session
    func testObtainChildSessionSuccess() async throws {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testSelector = "test selector"
        let testCredential = Credential(
            UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"]
        )
        let manager = Authenticator(api: apiService)

        let refreshResponse = RefreshResponse(accessToken: "active accessToken",
                                              tokenType: "active tokenType",
                                              scopes: ["active scope"],
                                              refreshToken: "active refreshToken")

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
                let params = parameters as? [String: Any],
                let childClientID = params["ChildClientID"] as? String,
                let independence = params["Independent"] as? Int,
                childClientID == testClientId,
                independence == (testIndependence ? 1 : 0) {
                completion(nil, .success(AuthService.ForkSessionResponse(selector: testSelector)))
            } else if path.contains("/auth/v4/sessions/forks/\(testSelector)") {
                completion(nil, .success(AuthService.ChildSessionResponse(
                    UID: "test UID", refreshToken: "inactive refresh token", accessToken: "inactive access token", userID: "test user ID", scopes: ["inactive scope"]
                )))
            } else if path.contains("/auth/v4/refresh") {
                completion(nil, .success(refreshResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        let response = try await withCheckedThrowingContinuation { continuation in
            manager.performForkingAndObtainChildSession(testCredential,
                                                        useCase: .forChildClientID(testClientId, independent: testIndependence),
                                                        completion: continuation.resume(with:))
        }

        // then
        XCTAssertEqual(response.UID, "test UID")
        XCTAssertEqual(response.accessToken, refreshResponse.accessToken)
        XCTAssertEqual(response.refreshToken, refreshResponse.refreshToken)
        XCTAssertEqual(response.userID, "test user ID")
        XCTAssertEqual(response.userName, "userName")
        XCTAssertEqual(response.scopes, refreshResponse.scopes)
    }

    func testObtainChildSessionFailureOnForking() async {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testCredential = Credential(
            UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"]
        )
        let manager = Authenticator(api: apiService)

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
               let params = parameters as? [String: Any],
               let childClientID = params["ChildClientID"] as? String,
               let independence = params["Independent"] as? Int,
               childClientID == testClientId,
               independence == (testIndependence ? 1 : 0) {
                completion(nil, .failure(.badResponse()))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                manager.performForkingAndObtainChildSession(testCredential,
                                                            useCase: .forChildClientID(testClientId, independent: testIndependence),
                                                            completion: continuation.resume(with:))
            }
            XCTFail()
        } catch {
            // then
            guard case .networkingError(let responseError) = error as? AuthErrors,
                    let underlyingError = responseError.underlyingError else {
                XCTFail()
                return
            }
            XCTAssertEqual(underlyingError, .badResponse())
        }
    }

    func testObtainChildSessionFailureOnSelectorExchange() async {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testSelector = "test selector"
        let testCredential = Credential(
            UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"]
        )
        let manager = Authenticator(api: apiService)

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
                let params = parameters as? [String: Any],
                let childClientID = params["ChildClientID"] as? String,
                let independence = params["Independent"] as? Int,
                childClientID == testClientId,
                independence == (testIndependence ? 1 : 0) {
                completion(nil, .success(AuthService.ForkSessionResponse(selector: testSelector)))
            } else if path.contains("/auth/v4/sessions/forks/\(testSelector)") {
                completion(nil, .failure(.badResponse()))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                manager.performForkingAndObtainChildSession(testCredential,
                                                            useCase: .forChildClientID(testClientId, independent: testIndependence),
                                                            completion: continuation.resume(with:))
            }
            XCTFail()
        } catch {
            // then
            guard case .networkingError(let responseError) = error as? AuthErrors,
                    let underlyingError = responseError.underlyingError else {
                XCTFail()
                return
            }
            XCTAssertEqual(underlyingError, .badResponse())
        }
    }

    func testObtainChildSessionFailureOnRefresh() async {
        // given
        let testClientId = "test child client ID"
        let testIndependence = false
        let testSelector = "test selector"
        let testCredential = Credential(
            UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"]
        )
        let manager = Authenticator(api: apiService)

        apiService.requestDecodableStub.bodyIs { _, _, path, parameters, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4/sessions/forks"),
                let params = parameters as? [String: Any],
                let childClientID = params["ChildClientID"] as? String,
                let independence = params["Independent"] as? Int,
                childClientID == testClientId,
                independence == (testIndependence ? 1 : 0) {
                completion(nil, .success(AuthService.ForkSessionResponse(selector: testSelector)))
            } else if path.contains("/auth/v4/sessions/forks/\(testSelector)") {
                completion(nil, .success(AuthService.ChildSessionResponse(
                    UID: "test UID", refreshToken: "inactive refresh token", accessToken: "inactive access token", userID: "test user ID", scopes: ["inactive scope"]
                )))
            } else if path.contains("/auth/v4/refresh") {
                completion(nil, .failure(.badResponse()))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        // when
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                manager.performForkingAndObtainChildSession(testCredential,
                                                            useCase: .forChildClientID(testClientId, independent: testIndependence),
                                                            completion: continuation.resume(with:))
            }
            XCTFail()
        } catch {
            // then
            guard case .networkingError(let responseError) = error as? AuthErrors,
                    let underlyingError = responseError.underlyingError else {
                XCTFail()
                return
            }
            XCTAssertEqual(underlyingError, .badResponse())
        }
    }

    // MARK: closeSession

    func testCloseSessionSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "closeSession")
        let testResponse = AuthService.EndSessionResponse(code: 1000)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4") {
                completion(nil, .success(testResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.closeSession(testCredential) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, testResponse)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCloseSessionNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "closeSession")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.closeSession(testCredential) { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testCloseSessionApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "closeSession")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/v4") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        let testCredential = Credential(UID: "UID", accessToken: "accessToken", refreshToken: "refreshToken", userName: "userName", userID: "userID", scopes: ["Scope"])
        manager.closeSession(testCredential) { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    // MARK: getRandomSRPModulus

    func testGetRandomSRPModulusSuccess() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        let modulusEndpointResponse = AuthService.ModulusEndpointResponse(modulus: "modulus", modulusID: "modulusID")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion(nil, .success(modulusEndpointResponse))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.getRandomSRPModulus { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, modulusEndpointResponse)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetRandomSRPModulusParseError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion(nil, .failure(self.decodingError as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.getRandomSRPModulus { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                XCTAssertEqual(responseError.underlyingError?.localizedDescription, "The data couldn’t be read because it is missing.")
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetRandomSRPModulusNetworkingError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        let testResponseError = ResponseError(httpCode: 12399, responseCode: 56789, userFacingMessage: "testErrorX", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion(nil, .failure(AuthErrors.networkingError(testResponseError) as NSError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.getRandomSRPModulus { result in
            switch result {
            case .failure(AuthErrors.networkingError(let responseError)):
                let resp = responseError.underlyingError as? AuthErrors
                if case .networkingError(let error) = resp {
                    XCTAssertEqual(testResponseError, error)
                } else {
                    XCTFail("Wrong error response")
                }
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }

    func testGetRandomSRPModulusApiMightBeBlockedError() {
        let manager = Authenticator(api: apiService)
        let expect = expectation(description: "getRandomSRPModulus")
        apiService.requestDecodableStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/auth/modulus") {
                completion(nil, .failure(self.apiBlockedError))
            } else {
                XCTFail()
                completion(nil, .success(AuthenticatorTests.emptyReponse))
            }
        }

        manager.getRandomSRPModulus { result in
            switch result {
            case .failure(.apiMightBeBlocked(let message, let originalError)):
                XCTAssertEqual(message, SRTranslations._core_api_might_be_blocked_message.l10n)
                XCTAssertEqual(originalError, self.apiBlockedResponseError)
            default:
                XCTFail("Wrong result")
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout) { (error) in
            XCTAssertNil(error, String(describing: error))
        }
    }
}

