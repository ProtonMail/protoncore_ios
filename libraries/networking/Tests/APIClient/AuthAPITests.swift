//
//  UserAPITests.swift
//  ProtonCore-APIClient-Tests - Created on 9/17/18.
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

import OHHTTPStubs
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services
@testable import ProtonCore_APIClient

class AuthAPITests: XCTestCase {
    
    class DoHMail: DoH, ServerConfig {
        var signupDomain: String = ObfuscatedConstants.testLiveSignupDomain
        /// defind your default host
        var defaultHost: String = ObfuscatedConstants.testLiveDefaultHost
        /// defind your default captcha host
        var captchaHost: String = ObfuscatedConstants.testLiveCaptchaHost
        /// defind your query host
        var apiHost: String = ObfuscatedConstants.testLiveApiHost
        /// singleton
        static let `default` = try! DoHMail()
        
        override init() throws {
            
        }
    }

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

    func testAuthInfo() {
        stub(condition: isHost(ObfuscatedConstants.testLiveDefaultHostWithoutHttps) && isMethodPOST() && isPath("/auth/info")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let body = request.ohhttpStubs_httpBody!
            do {
                let dict = try JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
                if let value = dict["Username"] as? String {
                    if value == "ok" {
                        let ok = "{\"Code\":1000,\"Modulus\":\"-----BEGIN PGP SIGNED MESSAGE-----\\nHash: SHA256\\n\\nG3q3Mjx9qo2dJsZKSuyiLIFUDKhHHUjdtCuxZGUrs0oGHDYSKNnL83w62ho2NSxRnFuzaI4htsIsDyeUV4Me4PUpw22xt6RLIuyGvx6lcJDaxtARF/SoS0CMpWmcITGe9B+1imOcjN4xYjct9ATwHaQwTWb03YMMLTSsbYcaE0mJ9rOVnanaT0XQIyAve6I5vWfTkDUrtZQMQFM1rWe3PuW9BZQMEJ/FITYDzZWcnBEEUrvQwKFXHgiu1SmkPMzx6SJjNkebCkhZJhKfeSo2NuYlYIi/uff6dRTmhPqtQXWzTcYQov0P5u7i5b5as98kwtg2LK2/Ooeu5m9IoAYYqg==\\n-----BEGIN PGP SIGNATURE-----\\nVersion: ProtonMail\\nComment: https://protonmail.com\\n\\nwl4EARYIABAFAlwB1j0JEDUFhcTpUY8mAACvlAEA+Psf6LHuQSrXI0vlPuue\\nFkiHEvkyJJaY3xLvnM63JjIBAOumYlk2+D5Y6apeLWD1mHbM9MTmWZtDrI/2\\n1tOfGMkB\\n=oj+8\\n-----END PGP SIGNATURE-----\\n\",\"ServerEphemeral\":\"RXrpmW8TixDVQw3OJg0QfC5dscIcZ/Bp+rRPMLhCK9dNJLidBj9MmiZRkVdQxVx+5NDgvDyt0IzwkVnRrTjLUHvftHMgdzAG5wD9yZch5zKB1YlDy3ZirHqlWjWD5luKrOwlxAvzBPUZGKfnSb4laKRNTwwQnUPat+rVZHerGckWK1OdoG2vPaQZiPvaXxQZnSZ099ATE5Jcv/iUBXFhNpLPWXQ5r/phGFDDwy6sWLOUPHDDIjsVII6mnDL9G2p+/RonYcy05rwEWxmSzGGwW3kaC9IglpGxD+MR/dOv2ToGFnxOJQUSKZ6ZGzEg913fL0b+4afbq+rrDZgKUNl9VQ==\",\"Version\":4,\"Salt\":\"0cNmaaFTYxDdFA==\",\"SRPSession\":\"b7953c6a26d97a8f7a673afb79e6e9ce\"}"
                        let body = ok.data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
                    } else if value == "InvalidCharacters" {
                        let body = "{ \"Code\": 12102, \"Error\": \"Invalid characters\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
                    } else if value == "StartSpecialCharacter" {
                        let body = "{ \"Code\": 12103, \"Error\": \"Username start with special character\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
                    } else if value == "EndSpecialCharacter" {
                        let body = "{ \"Code\": 12104, \"Error\": \"Username end with special character\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
                    } else if value == "UsernameToolong" {
                        let body = "{ \"Code\": 12105, \"Error\": \"Username too long\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
                    } else if value == "UsernameAlreadyUsed" {
                        let body = "{ \"Code\": 12106, \"Error\": \"Username already used\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                        let headers = [ "Content-Type": "application/json;charset=utf-8"]
                        return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
                    }
                    
                }
            } catch {
                
            }
            let dbody = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 400, headers: [:])
        }
        
        let api = PMAPIService(doh: DoHMail.default, sessionUID: "testSessionUID")
        let expectation1 = self.expectation(description: "Success completion block called")
        let authInfoOK = AuthAPI.Router.info(username: "ok")// unittest100
        api.exec(route: authInfoOK) { (task, response: AuthInfoResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            XCTAssertTrue(response.srpSession != nil)
            XCTAssertTrue(response.srpSession! == "b7953c6a26d97a8f7a673afb79e6e9ce")
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "Success completion block called")
        let authInfoOK1 = AuthAPI.Router.info(username: "ok")// unittest100
        api.exec(route: authInfoOK1) { (task, result: Result<AuthInfoRes, ResponseError>) in
            expectation2.fulfill()
        }

        // TODO:: finish up other possiblities
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
    
    func testAuthModulus() {
        stub(condition: isHost(ObfuscatedConstants.testLiveDefaultHostWithoutHttps) && isMethodGET() && isPath("/auth/modulus")) { request in
            let ok = "{\"Code\": 1000, \"Modulus\": \"-----BEGIN PGP SIGNED MESSAGE-----.*-----END PGP SIGNATURE-----\", \"ModulusID\": \"Oq_JB_IkrOx5WlpxzlRPocN3_NhJ80V7DGav77eRtSDkOtLxW2jfI3nUpEqANGpboOyN-GuzEFXadlpxgVp7_g==\" }"
            let body = ok.data(using: String.Encoding.utf8)!
            let headers = [ "Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        let api = PMAPIService(doh: DoHMail.default, sessionUID: "testSessionUID")
        let expectation1 = self.expectation(description: "Success completion block called")
        let authModulusOK = AuthAPI.Router.modulus
        api.exec(route: authModulusOK) { (task, response: AuthModulusResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            XCTAssertTrue(response.ModulusID != nil)
            XCTAssertTrue(response.ModulusID! == "Oq_JB_IkrOx5WlpxzlRPocN3_NhJ80V7DGav77eRtSDkOtLxW2jfI3nUpEqANGpboOyN-GuzEFXadlpxgVp7_g==")
            expectation1.fulfill()
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }

    func testAuth() {
        stub(condition: isHost(ObfuscatedConstants.testLiveDefaultHostWithoutHttps) && isMethodPOST() && isPath("/auth")) { request in
            let ok = "{ \"Code\": 1000,\"AccessToken\": \"abcDecryptedTokenAndNoSaltAndNoPrivateKey123\",\"ExpiresIn\": 360000,\"TokenType\": \"Bearer\",\"Scope\": \"full other_scopes\",\"UID\": \"6f3c4f52cf499c2066e6c5669a293177c1f43755\",\"UserID\":\"-Bpgivr5H2qGDRiUQ4-7gm5YLf215MEgZCdzOtLW5psxgB8oNc8OnoFRykab4Z23EGEW1ka3GtQPF9xwx9-VUA==\",\"RefreshToken\": \"aafe30367aa7dc09bf5c42d15a93e6c57270fe6f\",\"EventID\":\"ACXDmTaBub14w==\",\"ServerProof\": \"<base64_encoded_proof>\", \"PasswordMode\": 2, \"2FA\": { \"Enabled\" : 3, \"U2F\" : { \"Chwallenge\": \"a43lengthStringAndUnique\", \"RegisteredKeys\":[{ \"Versio\":\"U2F_V2\", \"KeyHandle\":\"<aKeyHandle>\" }] } } }"
            let body = ok.data(using: String.Encoding.utf8)!
            let headers = [ "Content-Type": "application/json;charset=utf-8"]
            return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
        }

        let api = PMAPIService(doh: DoHMail.default, sessionUID: "testSessionUID")
        let expectation1 = self.expectation(description: "Success completion block called")
        let authOK = AuthAPI.Router.auth(username: "ok", ephemeral: "", proof: "", session: "")
        api.exec(route: authOK) { (task, response: AuthResponse) in
            XCTAssertEqual(response.responseCode, 1000)
            XCTAssert(response.error == nil)
            expectation1.fulfill()
        }
        self.waitForExpectations(timeout: 30) { (expectationError) -> Void in
            XCTAssertNil(expectationError)
        }
    }
}
