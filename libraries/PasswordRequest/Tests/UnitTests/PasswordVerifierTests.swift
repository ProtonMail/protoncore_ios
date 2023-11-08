//
//  PasswordVerifierTests.swift
//  ProtonCore-PasswordRequest-Unit-Tests - Created on 13.07.23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import XCTest
import ProtonCoreAuthentication
import ProtonCoreCryptoGoInterface
@testable import ProtonCorePasswordRequest
import ProtonCoreNetworking
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsServices)
import ProtonCoreTestingToolkitUnitTestsServices
import ProtonCoreTestingToolkitUnitTestsAuthentication
#else
import ProtonCoreTestingToolkit
#endif

final class PasswordVerifierTests: XCTestCase {
    var sut: PasswordVerifier!
    var apiService: APIServiceMock!
    var responseHandlerData: PMResponseHandlerData!
    var srpBuilder: SRPBuilderProtocolMock!

    override func setUp() {
        super.setUp()
        setupMocks()
        sut = .init(
            apiService: apiService,
            username: "username",
            endpoint: UnlockEndpoint(),
            responseHandlerData: responseHandlerData,
            srpBuilder: srpBuilder
        )
    }

    private func setupMocks() {
        apiService = .init()
        srpBuilder = .init()

        responseHandlerData = .init(
            method: .put,
            path: "path",
            authenticated: true,
            authRetry: true,
            authRetryRemains: 1,
            retryPolicy: .background,
            onDataTaskCreated: { _ in }
        )
    }

    // MARK: - Lock

    func test_lock_callsCorrectAPI() {
        // Given
        let expectation = XCTestExpectation(description: "")
        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            XCTAssertEqual(method, .put)
            XCTAssertEqual(path, "/users/lock")
            completion(nil, .success(.init()))
        }

        // When
        sut.lock { result in
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.3)
    }

    // MARK: - Call correct endpoint() {

    func test_verifyPassword_callsPassedEndpoint() {
        // Given
        let expectation = XCTestExpectation(description: "")
        struct TestEndpoint: Request {
            var path: String { "myPath" }
            var method: HTTPMethod { .get }
        }
        apiService.requestJSONStub.bodyIs { _, method, path, _, _, _, _, _, _, _, _, completion in
            XCTAssertEqual(method, .get)
            XCTAssertEqual(path, "myPath")
            completion(nil, .success(.init()))
        }

        sut = .init(
            apiService: apiService,
            username: "username",
            endpoint: TestEndpoint(),
            responseHandlerData: responseHandlerData,
            srpBuilder: srpBuilder
        )

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { _ in
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.3)
    }

    // MARK: - fetchAuthInfo

    func test_fetchAuthInfo_isSuccessful() {
        // Given
        let expectation = XCTestExpectation(description: "expect success")
        let authInfoResponse = AuthInfoResponse(modulus: "modulus", serverEphemeral: "serverEphemeral", version: 1, salt: "salt", srpSession: "srpSession")
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(authInfoResponse))
        }

        // When
        sut.fetchAuthInfo { result in
            switch result {
            case .success(let authInfo):
                XCTAssertEqual(authInfo, authInfoResponse)
            case .failure:
                XCTFail("Success expected")
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.3)
    }

    func test_fetchAuthInfo_failed() {
        // Given
        let expectation = XCTestExpectation(description: "expect failure")
        let responseError = ResponseError(httpCode: 1, responseCode: 123, userFacingMessage: "userFacingMessage", underlyingError: nil)
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(responseError as NSError))
        }

        // When
        sut.fetchAuthInfo { result in
            switch result {
            case .success:
                XCTFail("Success failure")
            case .failure(let error):
                XCTAssertEqual(error, .networkingError(responseError))
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.3)
    }

    // MARK: - verifyPassword

    func test_verifyPassword_callsSrpBuilder() {
        // When
        sut.verifyPassword(password: "", authInfo: .init()) { _ in }

        // Then
        XCTAssertTrue(srpBuilder.buildSRPStub.wasCalledExactlyOnce)
    }

    func test_verifyPassword_callsService_onSuccessfulPassword() {
        // When
        sut.verifyPassword(password: "", authInfo: .init()) { _ in }

        // Then
        XCTAssertTrue(apiService.requestJSONStub.wasCalledExactlyOnce)
    }

    func test_verifyPassword_failsOnBadPassword() {
        // Given
        apiService.requestDecodableStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .success(AuthInfoResponse()))
        }
        srpBuilder.buildSRPStub.bodyIs { _, _, _, _, _ in
            .failure(AuthErrors.wrongPassword)
        }
        sut = .init(
            apiService: apiService,
            username: "username",
            endpoint: UnlockEndpoint(),
            responseHandlerData: responseHandlerData,
            srpBuilder: srpBuilder
        )
        let expectation = XCTestExpectation(description: "expect failure")

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { response in
            expectation.fulfill()
            XCTAssertEqual(response, .failure(.wrongPassword))
        }

        // Then
        wait(for: [expectation], timeout: 0.3)
    }

    func test_verifyPassword_completeOnSuccessfulAPICall() {
        // Given
        let expectation = XCTestExpectation(description: "expect success")

        apiService.requestJSONStub.bodyIs { count, _, _, _, _, _, _, _, _, _, _, completion in
            expectation.fulfill()
            completion(nil, .success(.init()))
        }

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { _ in }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_verifyPassword_completeOnFailure_wrongPassword() {
        // Given
        let expectation = XCTestExpectation(description: "expects failure")
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            expectation.fulfill()
            completion(nil, .failure(.init(domain: "", code: 8002)))
        }

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error, .wrongPassword)
            }
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_verifyPassword_completesOnFailure() {
        // Given
        let expectation = XCTestExpectation(description: "expects failure")
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            completion(nil, .failure(.init(domain: "failure", code: 1234)))
        }

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure:
                break
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_verifyPassword_completeOnFailure_parsingError() {
        // Given
        let error: NSError = .init(domain: "", code: 1234)
        let expectation = XCTestExpectation(description: "expect success")
        apiService.requestJSONStub.bodyIs { _, _, _, _, _, _, _, _, _, _, _, completion in
            expectation.fulfill()
            completion(nil, .failure(error))
        }

        // When
        sut.verifyPassword(password: "", authInfo: .init()) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error, .parsingError(error))
            }
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }
}

extension AuthErrors: Equatable {
    public static func == (lhs: ProtonCoreNetworking.AuthErrors, rhs: ProtonCoreNetworking.AuthErrors) -> Bool {
        switch (lhs, rhs) {
        case (.wrongPassword, .wrongPassword): return true
        case (.parsingError, .parsingError): return true
        case (.networkingError, .networkingError): return true
        default: return false
        }
    }
}

extension SRPClientInfo: Equatable {
    public static func == (lhs: SRPClientInfo, rhs: SRPClientInfo) -> Bool {
        return lhs.expectedServerProof == rhs.expectedServerProof
            && lhs.clientEphemeral == rhs.clientEphemeral
            && lhs.clientProof == rhs.clientProof
    }
}

extension AuthInfoResponse: Equatable {
    public static func == (lhs: AuthInfoResponse, rhs: AuthInfoResponse) -> Bool {
        return lhs.modulus == rhs.modulus
        && lhs.salt == rhs.salt
        && lhs.serverEphemeral == rhs.serverEphemeral
        && lhs.srpSession == rhs.srpSession
    }
}
