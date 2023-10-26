//
//  APIService+ErrorTests.swift
//  ProtonCore-Services-Tests - Created on 16/01/23.
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
import ProtonCoreNetworking
@testable import ProtonCoreServices

final class APIServiceErrorTests: XCTestCase {
    
    func testIsApiIsBlockedError_ResponseCode_isTrue() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.potentiallyBlocked, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertTrue(testError.isApiIsBlockedError)
    }
    
    func testIsApiIsBlockedError_HttpCode_isTrue() {
        let testError = ResponseError(httpCode: APIErrorCode.potentiallyBlocked, responseCode: nil, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertTrue(testError.isApiIsBlockedError)
    }
    
    func testIsApiIsBlockedError_UnderlyingErrorCode_isTrue() {
        let testError = ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: "test message", underlyingError: NSError(domain: "", code: APIErrorCode.potentiallyBlocked, localizedDescription: "test message"))
        XCTAssertTrue(testError.isApiIsBlockedError)
    }
    
    func testIsApiIsBlockedError_UnderlyingErrorCode_withNoResponseCode_isFalse() {
        let testError = ResponseError(httpCode: nil, responseCode: nil, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isApiIsBlockedError)
    }
    
    func testIsApiIsBlockedError_UnderlyingErrorCode_withResponseCode_isFalse() {
        let testError = ResponseError(httpCode: nil, responseCode: 123, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isApiIsBlockedError)
    }
    
    func testIsAppVersionTooOldForExternalAccountsError_isTrue() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.appVersionTooOldForExternalAccounts, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertTrue(testError.isAppVersionTooOldForExternalAccountsError)
    }
    
    func testIsAppVersionTooOldForExternalAccountsError_withNoResponseCode_isFalse() {
        let testError = ResponseError(httpCode: 401, responseCode: nil, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isAppVersionTooOldForExternalAccountsError)
    }
    
    func testIsAppVersionTooOldForExternalAccountsError_withResponseCode_isFalse() {
        let testError = ResponseError(httpCode: 401, responseCode: 123, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isAppVersionTooOldForExternalAccountsError)
    }
    
    func testIsAppVersionNotSupportedForExternalAccountsError_isTrue() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.appVersionNotSupportedForExternalAccounts, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertTrue(testError.isAppVersionNotSupportedForExternalAccountsError)
    }
    
    func testIsAppVersionNotSupportedForExternalAccountsError_withNoResponseCode_isFalse() {
        let testError = ResponseError(httpCode: 401, responseCode: nil, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isAppVersionNotSupportedForExternalAccountsError)
    }
    
    func testIsAppVersionNotSupportedForExternalAccountsError_withResponseCode_isFalse() {
        let testError = ResponseError(httpCode: 401, responseCode: 123, userFacingMessage: "test message", underlyingError: nil)
        XCTAssertFalse(testError.isAppVersionNotSupportedForExternalAccountsError)
    }
    
    func testResponseError_ApiMightBeBlocked() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.potentiallyBlocked, userFacingMessage: "test message", underlyingError: nil)
        guard case .apiMightBeBlocked(let message, let error) = AuthErrors.from(testError) else {
            XCTFail("ResponseError.apiMightBeBlocked error is expected here ")
            return
        }
        XCTAssertEqual(message, "test message")
        XCTAssertEqual(error.code, APIErrorCode.potentiallyBlocked)
        XCTAssertEqual(error.localizedDescription, "test message")
    }
    
    func testResponseError_IsAppVersionTooOldForExternalAccountsError() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.appVersionTooOldForExternalAccounts, userFacingMessage: "test message", underlyingError: nil)
        guard case .externalAccountsNotSupported(let message, let title, let error) = AuthErrors.from(testError) else {
            XCTFail("ResponseError.externalAccountsNotSupported error is expected here ")
            return
        }
        XCTAssertEqual(message, "test message")
        XCTAssertEqual(title, "Update required")
        XCTAssertEqual(error.code, APIErrorCode.appVersionTooOldForExternalAccounts)
        XCTAssertEqual(error.localizedDescription, "test message")
    }
    
    func testResponseError_IsAppVersionNotSupportedForExternalAccountsError() {
        let testError = ResponseError(httpCode: 401, responseCode: APIErrorCode.appVersionNotSupportedForExternalAccounts, userFacingMessage: "test message", underlyingError: nil)
        guard case .externalAccountsNotSupported(let message, let title, let error) = AuthErrors.from(testError) else {
            XCTFail("ResponseError.externalAccountsNotSupported error is expected here ")
            return
        }
        XCTAssertEqual(message, "test message")
        XCTAssertEqual(title, "Proton address required")
        XCTAssertEqual(error.code, APIErrorCode.appVersionNotSupportedForExternalAccounts)
        XCTAssertEqual(error.localizedDescription, "test message")
    }
    
    func testResponseError_NetworkingError() {
        let testError = ResponseError(httpCode: 401, responseCode: 123, userFacingMessage: "test message", underlyingError: nil)
        guard case .networkingError(let error) = AuthErrors.from(testError) else {
            XCTFail("ResponseError.networkingError error is expected here ")
            return
        }
        XCTAssertEqual(error.code, 123)
        XCTAssertEqual(error.localizedDescription, "test message")
    }
    
    func testResponseError_CarriesResponseDict() throws {
        let originalResponseDict: [String: Any] = ["string": "test string", "number": 24]
        let underlyingError = NSError(domain: "tests",
                                      code: 42,
                                      responseDictionary: originalResponseDict,
                                      localizedDescription: "test localizedDescription")
        let testError = ResponseError(httpCode: 200,
                                      responseCode: 1000,
                                      userFacingMessage: "test facing message",
                                      underlyingError: underlyingError)
        let passedResponseDict = try XCTUnwrap(testError.responseDictionary)
        XCTAssertTrue((passedResponseDict as NSDictionary).isEqual(to: originalResponseDict))
    }
    
    func testResponseError_RemovesResponseDictFromUnderlyingError() throws {
        let underlyingError = NSError(domain: "tests",
                                      code: 42,
                                      responseDictionary: ["string": "test string", "number": 24],
                                      localizedDescription: "test localizedDescription")
        let testError = ResponseError(httpCode: 200,
                                      responseCode: 1000,
                                      userFacingMessage: "test facing message",
                                      underlyingError: underlyingError)
        let passedUnderlyingError = try XCTUnwrap(testError.underlyingError)
        XCTAssertNotNil(underlyingError.userInfo[ResponseError.responseDictionaryUserInfoKey])
        XCTAssertNil(passedUnderlyingError.userInfo[ResponseError.responseDictionaryUserInfoKey])
    }
    
    func testResponseError_DoesNotIncludeResponseDictWhenPrinted() throws {
        let testString = "test string"
        let testNumber = 24
        let underlyingError = NSError(domain: "tests",
                                      code: 42,
                                      responseDictionary: ["string": "test string", "number": 24],
                                      localizedDescription: "test localizedDescription")
        let testError = ResponseError(httpCode: 200,
                                      responseCode: 1000,
                                      userFacingMessage: nil,
                                      underlyingError: underlyingError)
        let interpolatedError = "\(testError)"
        let errorDescription = testError.localizedDescription
        let errorUserFacingMessage = testError.userFacingMessage ?? ""
        let stringDescribingError = String(describing: testError)
        XCTAssertFalse(interpolatedError.contains(testString))
        XCTAssertFalse(interpolatedError.contains("\(testNumber)"))
        XCTAssertFalse(errorDescription.contains(testString))
        XCTAssertFalse(errorDescription.contains("\(testNumber)"))
        XCTAssertFalse(errorUserFacingMessage.contains(testString))
        XCTAssertFalse(errorUserFacingMessage.contains("\(testNumber)"))
        XCTAssertFalse(stringDescribingError.contains(testString))
        XCTAssertFalse(stringDescribingError.contains("\(testNumber)"))
    }
}
