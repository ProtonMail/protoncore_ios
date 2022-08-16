//
//  SessionTests.swift
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

extension Result {
    
    var error: Failure? {
        guard case .failure(let errorObject) = self else { return nil }
        return errorObject
    }
}

@available(iOS 13.0.0, *)
class SessionTests: XCTestCase {
    
    final class TestError: NSError {
        init(message: String) { super.init(domain: "SessionTests", code: 0, userInfo: [NSLocalizedDescriptionKey: message]) }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
    
    struct TestResponse: SessionDecodableResponse, Equatable {
        let code: Int
    }
    
    let jsonDecoder: JSONDecoder = .decapitalisingFirstLetter

    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        HTTPStubs.onStubActivation { request, descriptor, response in
            // ...
        }
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
// MARK: - General tests
    
    func testHeaderUpdate() {
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.setValue(header: "a", "a_v")
        request.updateHeader()
    }
    
    func testSessionDoesNotFollowRedirects() async throws {
        stub(condition: isHost("proton.unittests") && isPath("/redirect")) { _ in
                .init(jsonObject: [:], statusCode: 301, headers: ["Location": "https://proton.unittests/other_endpoint"])
        }
        stub(condition: isHost("proton.unittests") && isPath("/other_endpoint")) { _ in
                .init(jsonObject: [:], statusCode: 404, headers: [:])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://proton.unittests/redirect", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) {
                continuation.resume(returning: ($0, $1))
            }
        }
        let httpCode = try XCTUnwrap((result.0?.response as? HTTPURLResponse)?.statusCode)
        XCTAssertEqual(httpCode, 301)
    }

// MARK: - Session request JSON API tests
    
    func testRequestJSONAPI_ReturnsDictOnSuccess_200() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["Code": "1000"], statusCode: 200, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, result in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get() as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, ["Code": "1000"])
    }
    
    func testRequestJSONAPI_ReturnsDictOnSuccess_401() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["test": "dummy"], statusCode: 401, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, result in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get() as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, ["test": "dummy"])
    }
    
    func testRequestJSONAPI_ReturnsErrorOnFailure_DecodingFailure() async throws {
        
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: [["Wrongly": "formatted"]], statusCode: 404, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, result in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.1.error)
        guard case .responseBodyIsNotAJSONDictionary(let data) = error else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: [["Wrongly": "formatted"]]))
    }
    
    func testRequestJSONAPI_ReturnsErrorOnFailure_NetworkFailure() async throws {
        
        stub(condition: isHost("example.com")) { _ in .init(error: TestError(message: #function)) }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, result in
                continuation.resume(returning: (task, result))
            }
        }

        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.1.error)
        guard case .networkingEngineError = error else { XCTFail(); return }
        let underlyingError = try XCTUnwrap(error.underlyingError)
        XCTAssertEqual(underlyingError.messageForTheUser, #function)
    }

// MARK: - Session request Codable API tests
    
    func testRequestCodableAPI_ReturnsObjectOnSuccess_200() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["Code": 1000], statusCode: 200, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }
    
    func testRequestCodableAPI_ReturnsObjectOnSuccess_401() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["Code": 1000], statusCode: 401, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }
    
    func testRequestCodableAPI_ReturnsErrorOnFailure_DecodingFailure() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["Error": "test error message"], statusCode: 404, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.1.error)
        guard case .responseBodyIsNotADecodableObject(let data) = error else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: ["Error": "test error message"]))
    }
    
    func testRequestCodableAPI_ReturnsErrorOnFailure_NetworkFailure() async throws {
        stub(condition: isHost("example.com")) { _ in .init(error: TestError(message: #function)) }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request, jsonDecoder: jsonDecoder) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            }
        }

        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.1.error)
        guard case .networkingEngineError = error else { XCTFail(); return }
        let underlyingError = try XCTUnwrap(error.underlyingError)
        XCTAssertEqual(underlyingError.localizedDescription, #function)
    }
    
// MARK: - Session request deprecated API tests
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testRequestDeprecatedAPI_ReturnsDictOnSuccess_200() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["Code": "1000"], statusCode: 200, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1 as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, ["Code": "1000"])
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testRequestDeprecatedAPI_ReturnsDictOnSuccess_401() async throws {
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: ["test": "dummy"], statusCode: 401, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1 as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, ["test": "dummy"])
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testRequestDeprecatedAPI_ReturnsErrorOnFailure_DecodingFailure() async throws {
        
        stub(condition: isHost("example.com")) { _ in
            .init(jsonObject: [["Wrongly": "formatted"]], statusCode: 404, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.2)
        guard case .responseBodyIsNotAJSONDictionary(let data) = error as? SessionResponseError else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: [["Wrongly": "formatted"]]))
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testRequestDeprecatedAPI_ReturnsErrorOnFailure_NetworkFailure() async throws {
        
        stub(condition: isHost("example.com")) { _ in .init(error: TestError(message: #function)) }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.request(with: request) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }

        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.2)
        XCTAssertEqual(error.localizedDescription, #function)
    }

// MARK: - Session upload keypacket signature JSON API tests
    
    func testUploadKeypacketSignatureJSONAPI_ReturnsDictOnSuccess_200() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "1"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, result in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get() as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, ["data": "1"])
    }
    
    func testUploadKeypacketSignatureJSONAPI_ReturnsDictOnSuccess_401() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "1"], statusCode: 401, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, result in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get() as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, ["data": "1"])
    }
    
    func testUploadKeypacketSignatureJSONAPI_ReturnsErrorOnFailure_DecodingFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            .init(jsonObject: [["Wrongly": "formatted"]], statusCode: 404, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, result in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.1.error)
        guard case .responseBodyIsNotAJSONDictionary(let data) = error else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: [["Wrongly": "formatted"]]))
    }
    
    func testUploadKeypacketSignatureJSONAPI_ReturnsErrorOnFailure_NetworkFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(error: TestError(message: #function))
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, result in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.1.error)
        guard case .networkingEngineError(let underlyingError) = error else { XCTFail(); return }
        XCTAssertEqual(underlyingError.localizedDescription, #function)
    }

// MARK: - Session upload keypacket signature Codable API tests
    
    func testUploadKeypacketSignatureCodableAPI_ReturnsDictOnSuccess_200() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["Code": 1000], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign, jsonDecoder: .decapitalisingFirstLetter) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }
    
    func testUploadKeypacketSignatureCodableAPI_ReturnsDictOnSuccess_401() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["Code": 1000], statusCode: 401, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign, jsonDecoder: .decapitalisingFirstLetter) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1.get())
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, TestResponse(code: 1000))
    }
    
    func testUploadKeypacketSignatureCodableAPI_ReturnsErrorOnCodingFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["Error": "test error message"], statusCode: 404, headers: nil)
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign, jsonDecoder: .decapitalisingFirstLetter) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.1.error)
        guard case .responseBodyIsNotADecodableObject(let data) = error else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: ["Error": "test error message"]))
    }
    
    func testUploadKeypacketSignatureCodableAPI_ReturnsErrorOnNetworkFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(error: TestError(message: #function))
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign, jsonDecoder: .decapitalisingFirstLetter) { (task, result: Result<TestResponse, SessionResponseError>) in
                continuation.resume(returning: (task, result))
            } uploadProgress: { _ in
            }
        }
        
        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.1.error)
        guard case .networkingEngineError(let underlyingError) = error else { XCTFail(); return }
        XCTAssertEqual(underlyingError.localizedDescription, #function)
    }

// MARK: - Session upload keypacket signature deprecated API tests
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testUploadKeypacketSignatureDeprecatedAPI_ReturnsDictOnSuccess_200() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "1"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1 as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 200)
        XCTAssertEqual(response, ["data": "1"])
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testUploadKeypacketSignatureDeprecatedAPI_ReturnsDictOnSuccess_401() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "1"], statusCode: 401, headers: ["Content-Type": "application/json"])
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .background)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }
        
        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        let response = try XCTUnwrap(result.1 as? [String: String])
        XCTAssertEqual(httpURLResponse.statusCode, 401)
        XCTAssertEqual(response, ["data": "1"])
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testUploadKeypacketSignatureDeprecatedAPI_ReturnsErrorOnFailure_DecodingFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            .init(jsonObject: [["Wrongly": "formatted"]], statusCode: 404, headers: nil)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }

        let httpURLResponse = try XCTUnwrap(result.0?.response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.statusCode, 404)
        let error = try XCTUnwrap(result.2)
        guard case .responseBodyIsNotAJSONDictionary(let data) = error as? SessionResponseError else { XCTFail(); return }
        XCTAssertEqual(data, try JSONSerialization.data(withJSONObject: [["Wrongly": "formatted"]]))
    }
    
    @available(*, deprecated, message: "this tests deprecated api")
    func testUploadKeypacketSignatureDeprecatedAPI_ReturnsErrorOnFailure_NetworkFailure() async throws {
        stub(condition: isHost("www.example.com") && isPath("/upload")) { request in
            return HTTPStubsResponse(error: TestError(message: #function))
        }
        
        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: ["test": "test"], urlString: "https://www.example.com/upload", method: .post, timeout: 30, retryPolicy: .userInitiated)
        
        let key: Data = "this is a test key".data(using: .utf8)!
        let data: Data = "this is a test data".data(using: .utf8)!
        let sign: Data? = "this is a test sign".data(using: .utf8)
        
        let result = await withCheckedContinuation { continuation in
            session.upload(with: request, keyPacket: key, dataPacket: data, signature: sign) { task, response, error in
                continuation.resume(returning: (task, response, error))
            }
        }
        
        XCTAssertNil(result.0?.response)
        let error = try XCTUnwrap(result.2)
        XCTAssertEqual(error.localizedDescription, #function)
    }
    
// MARK: - Session download API tests

    func testProvidesHTTPURLResponseWithHeadersWhenDownloadingFiles() async throws {
        let dummyHeaders: [String: String] = [
            "dummyKey": "dummyValue"
        ]
        stub(condition: isHost("example.com")) { _ in
                .init(data: Data(), statusCode: 200, headers: dummyHeaders)
        }

        let session = AlamofireSession()
        let request = AlamofireRequest(parameters: nil, urlString: "https://example.com", method: .get, timeout: 30, retryPolicy: .userInitiated)
        let result = await withCheckedContinuation { continuation in
            session.download(with: request, destinationDirectoryURL: URL(string: "unwritable")!) { continuation.resume(returning: ($0, $1, $2)) }
        }

        let response = try XCTUnwrap(result.0)
        let httpURLResponse = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(httpURLResponse.headers["dummyKey"], "dummyValue")
    }
}
