//
//  ErrorResponseTests.swift
//  ProtonCore-Networking-Tests - Created on 9/17/18.
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

@testable import ProtonCore_Networking

class ErrorResponseTests: XCTestCase {
    
    let jsonDecoder: JSONDecoder = .decapitalisingFirstLetter
    
    func decodeErrorResponse(from: String) throws -> ErrorResponse {
        try JSONDecoder.decapitalisingFirstLetter.decode(ErrorResponse.self, from: from.data(using: .utf8)!)
    }

    func testDecodingErrorResponseWithOnlyCodeFails() {
        let response = """
        {"Code":12106}
        """
        XCTAssertThrowsError(try decodeErrorResponse(from: response))
    }
    
    func testDecodingErrorResponseWithOnlyErrorFails() {
        let response = """
        {"Error":"Username already used"}
        """
        XCTAssertThrowsError(try decodeErrorResponse(from: response))
    }
    
    func testDecodingErrorResponseWithCodeAndErrorSucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used"}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndDetailsSucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","Details":{"Suggestions":["kris691","kris582","kris628"]}}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndExceptionStringSucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","Exception":"<xml><xml><xml>"}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertEqual(errorResponse.errorDescription, "<xml><xml><xml>")
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndExceptionDictionarySucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","Exception":{"Suggestions":["kris691","kris582","kris628"]}}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertNil(errorResponse.errorDescription)
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndDetailsAndExceptionDictionarySucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","Details":{"Suggestions":["kris691","kris582","kris628"]},"Exception":{"Suggestions":["kris691","kris582","kris628"]}}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertNil(errorResponse.errorDescription)
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndErrorDescriptionSucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","ErrorDescription":"no idea"}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertEqual(errorResponse.errorDescription, "no idea")
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndErrorDescriptionDictionarySucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","ErrorDescription":{"Suggestions":["kris691","kris582","kris628"]}}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertNil(errorResponse.errorDescription)
    }
    
    func testDecodingErrorResponseWithCodeAndErrorAndDetailsAndErrorDescriptionSucceeds() throws {
        let response = """
        {"Code":12106,"Error":"Username already used","Details":{"Suggestions":["kris691","kris582","kris628"]},"ErrorDescription":"xml"}
        """
        let errorResponse = try decodeErrorResponse(from: response)
        XCTAssertEqual(errorResponse.code, 12106)
        XCTAssertEqual(errorResponse.error, "Username already used")
        XCTAssertEqual(errorResponse.errorDescription, "xml")
    }
}
