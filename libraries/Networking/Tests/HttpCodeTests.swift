//
//  HttpCodeTests.swift
//  ProtonCore-Networking-Tests - Created on 9/07/22.
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
//

import XCTest

import OHHTTPStubs
@testable import ProtonCore_Networking

@available(iOS 13.0.0, *)
class HttpCodeTests: XCTestCase {
    
    struct TestResponse: APIDecodableResponse, Equatable {
        var code: Int?
        var error: String?
        var details: HumanVerificationDetails?
    }
    
    let jsonDecoder: JSONDecoder = .decapitalisingFirstLetter
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in }
    }
    
    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
    func defaultRequest() async -> (URLSessionDataTask?, Result<TestResponse, SessionResponseError>) {
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://www.example.com/error", method: .post, timeout: 30, retryPolicy: .background)
        return await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }
    }
    
    func setupstub(httpCode: Int32, code: Int? = 1000, error: String? = nil, details: Bool = false) {
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            var ret: [String: Any] = [:]
            if let code = code {
                ret["Code"] = code
            }
            if let error = error {
                ret["Error"] = error
            }
            
            if details {
                ret["Details"] = ["HumanVerificationToken": "token", "Title": "human check"]
            }
            return HTTPStubsResponse(jsonObject: ret, statusCode: httpCode, headers: ["Content-Type": "application/json"])
        }
    }
    
    // MARK: - 2xx tests
    
    // 200    OK    Successful request 
    func testHTTP200CODE1000() async throws {
        setupstub(httpCode: 200)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }
    
    func testHTTP200CODE9001() async throws {
        setupstub(httpCode: 200, code: 9001, details: true)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response.code, 9001)
        let details = try XCTUnwrap(response.details)
        XCTAssertEqual(details.token, "token")
        XCTAssertEqual(details.title, "human check")
        XCTAssertEqual(details.methods, nil)
    }
    
    func testHTTP200Details() async throws {
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            let ret: [String: Any] = ["Code": 1000,
                                      "Error": "error",
                                      "Details": ["test": "usless"]]
            return HTTPStubsResponse(jsonObject: ret, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response.code, 1000)
        XCTAssertNil(response.details!.title)
        XCTAssertNil(response.details!.token)
        XCTAssertNil(response.details!.methods)
    }
    
    // 201    CREATED    Display success
    func testHTTP201CODE1000() async throws {
        setupstub(httpCode: 201)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 201)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }

    // 204    NO CONTENT    Display success
    func testHTTP204CODE1000() async throws {
        setupstub(httpCode: 204)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 204)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }

    // MARK: - 4xx tests
    
    // 400    BAD REQUEST
    func testHTTP400() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 400, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 400)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }

    // 401    UNAUTHORIZED
    func testHTTP401() async throws {
        let msg = "Hold requests, refresh oauth"
        setupstub(httpCode: 401, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 403    FORBIDDEN
    func testHTTP403() async throws {
        let msg = "Ask for re-authentication for scopes"
        setupstub(httpCode: 403, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 403)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 404    NOT FOUND
    func testHTTP404() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 400, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 400)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 409    CONFLICT
    func testHTTP409() async throws {
        let msg = "username already existing or invoice already being processed."
        setupstub(httpCode: 400, code:33101, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 400)
        XCTAssertEqual(response, TestResponse(code: 33101, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 410    GONE
    func testHTTP410() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 410, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 410)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 422    UNPROCESSABLE ENTITY
    func testHTTP422() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 422, code:2001, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 422)
        XCTAssertEqual(response, TestResponse(code: 2001, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 408    REQUEST TIMEOUT
    func testHTTP408() async throws {
        let exceptionCheck = self.expectation(description: "Success completion block called")
        var exceptionCount: Int = 0
        let msg = " Display connection error, retry request"
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            let ret: [String: Any] = ["Code": 80023, "Error": msg]
            XCTAssertTrue(exceptionCount < 2)
            exceptionCount += 1
            if exceptionCount == 2 {
                exceptionCheck.fulfill()
            }
            return HTTPStubsResponse(jsonObject: ret, statusCode: 408, headers: ["Content-Type": "application/json", "Retry-After": "5"])
        }
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://www.example.com/error", method: .post, timeout: 30, retryPolicy: .background )
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 408)
        let response = try XCTUnwrap(result.1.get())
        wait(for: [exceptionCheck], timeout: 10)
        XCTAssertEqual(response, TestResponse(code: 80023, error: msg))
        XCTAssertEqual(msg, response.error)
        XCTAssertEqual(exceptionCount, 2)
    }
    
    // 429    TOO MANY REQUESTS
    func testHTTP429() async throws {
        let exceptionCheck = self.expectation(description: "Success completion block called")
        let msg = "Retry after time in header    User jailed for too many attempts/requests"
        var exceptionCount: Int = 0
        let start = CFAbsoluteTimeGetCurrent()
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            let ret: [String: Any] = ["Code": 2001, "Error": msg]
            XCTAssertTrue(exceptionCount < 4)
            exceptionCount += 1
            if exceptionCount == 4 {
                exceptionCheck.fulfill()
            }
            return HTTPStubsResponse(jsonObject: ret, statusCode: 429, headers: ["Content-Type": "application/json", "Retry-After": "5"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://www.example.com/error", method: .post, timeout: 30, retryPolicy: .background )
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 429)
        let response = try XCTUnwrap(result.1.get())
        wait(for: [exceptionCheck], timeout: 30)
        XCTAssertEqual(response, TestResponse(code: 2001, error: msg))
        XCTAssertEqual(msg, response.error)
        XCTAssertEqual(exceptionCount, 4)
        XCTAssertTrue((CFAbsoluteTimeGetCurrent() - start) > 15)
    }

    // MARK: - 5xx tests
    
    // 500    INTERNAL SERVER ERROR
    func testHTTP500() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 500, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 500)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 501    NOT IMPLEMENTED
    func testHTTP501() async throws {
        let msg = "Display error text"
        setupstub(httpCode: 501, code:nil, error: msg)
        let result = await defaultRequest()
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 501)
        XCTAssertEqual(response, TestResponse(code: nil, error: msg))
        XCTAssertEqual(msg, response.error)
    }
    
    // 502    BAD GATEWAY
    func testHTTP502() async throws {
        let exceptionCheck = self.expectation(description: "Success completion block called")
        let msg = "Retry then Display connection error"
        var exceptionCount: Int = 0
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            let ret: [String: Any] = ["Code": 50022, "Error": msg]
            XCTAssertTrue(exceptionCount < 2)
            exceptionCount += 1
            if exceptionCount == 2 {
                exceptionCheck.fulfill()
            }
            return HTTPStubsResponse(jsonObject: ret, statusCode: 502, headers: ["Content-Type": "application/json", "Retry-After": "2"])
        }
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://www.example.com/error", method: .post, timeout: 30, retryPolicy: .background )
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 502)
        let response = try XCTUnwrap(result.1.get())
        wait(for: [exceptionCheck], timeout: 30)
        XCTAssertEqual(response, TestResponse(code: 50022, error: msg))
        XCTAssertEqual(msg, response.error)
        XCTAssertEqual(exceptionCount, 2)
    }
    
    // 503    SERVICE UNAVAILABLE
    func testHTTP503() async throws {
        let exceptionCheck = self.expectation(description: "Success completion block called")
        let msg = "Display error text, retry if retry-after is present"
        var exceptionCount: Int = 0
        let start = CFAbsoluteTimeGetCurrent()
        stub(condition: isHost("www.example.com") && isPath("/error")) { request in
            let ret: [String: Any] = ["Code": 10022, "Error": msg]
            XCTAssertTrue(exceptionCount < 4)
            exceptionCount += 1
            if exceptionCount == 4 {
                exceptionCheck.fulfill()
            }
            return HTTPStubsResponse(jsonObject: ret, statusCode: 503, headers: ["Content-Type": "application/json", "Retry-After": "6"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://www.example.com/error", method: .post, timeout: 30, retryPolicy: .background )
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 503)
        let response = try XCTUnwrap(result.1.get())
        wait(for: [exceptionCheck], timeout: 30)
        XCTAssertEqual(response, TestResponse(code: 10022, error: msg))
        XCTAssertEqual(msg, response.error)
        XCTAssertEqual(exceptionCount, 4)
        XCTAssertTrue((CFAbsoluteTimeGetCurrent() - start) > 18) // 3 times retry * 6 = 18 + (3 * random)
    }
}
