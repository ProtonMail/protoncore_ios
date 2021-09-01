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

class TestAPITests: XCTestCase {
    
    class DoHMail: DoH, ServerConfig {
        var signupDomain: String = ObfuscatedConstants.blueSignupDomain
        /// defind your default host
        var defaultHost: String = ObfuscatedConstants.blueDefaultHost
        /// defind your default captcha host
        var captchaHost: String = ObfuscatedConstants.blueCaptchaHost
        /// defind your query host
        var apiHost: String = ObfuscatedConstants.blueApiHost
        var defaultPath: String = ObfuscatedConstants.blueDefaultPath
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
        
        /*let sub = */stub(condition: isHost(ObfuscatedConstants.testLiveDefaultHostWithoutHttps) && isMethodGET() && isPath("/users/available")) { request in
            var dict = [String: Any]()
            if let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value!
                    }
                }
            }
            let value = dict["Name"] as! String
            if value == "ok" {
                let body = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 200, headers: headers)
            } else if value == "InvalidCharacters" {
                let body = "{ \"Code\": 12102, \"Error\": \"Invalid characters\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
            } else if value == "StartSpecialCharacter" {
                let body = "{ \"Code\": 12103, \"Error\": \"Username start with special character\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
            } else if value == "EndSpecialCharacter" {
                let body = "{ \"Code\": 12104, \"Error\": \"Username end with special character\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
            } else if value == "UsernameToolong" {
                let body = "{ \"Code\": 12105, \"Error\": \"Username too long\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
            } else if value == "UsernameAlreadyUsed" {
                let body = "{ \"Code\": 12106, \"Error\": \"Username already used\", \"Details\": {} }".data(using: String.Encoding.utf8)!
                let headers = ["Content-Type": "application/json;charset=utf-8"]
                return HTTPStubsResponse(data: body, statusCode: 400, headers: headers)
            }
            
            let dbody = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
            return HTTPStubsResponse(data: dbody, statusCode: 400, headers: [:])
        }
        
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
}
