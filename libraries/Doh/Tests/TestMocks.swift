//
//  DohTests.swift
//  ProtonCore-Doh-Tests - Created on 4/19/21.
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
@testable import ProtonCore_Doh

final class MockData {
    static let testHost1 = "https://local.protoncore.tests"
}

final class DohMock: DoH, ServerConfig {
    var apiHost: String = "doh.query.text.protonpro"
    var defaultHost: String = MockData.testHost1
    var captchaHost: String = MockData.testHost1
    var humanVerificationV3Host: String = "https://verify.local.protoncore.tests"
    var accountHost: String = "https://account.local.protoncore.tests"
    var signupDomain: String = "local.protoncore.tests"
    var timeout: TimeInterval = 1
    
    private init() {}
    
    override private init(networkingEngine: DoHNetworkingEngine,
                          executor: DoHWorkExecutor?,
                          currentTimeProvider: (() -> Date)?) {
        if let executor = executor, let currentTimeProvider = currentTimeProvider {
            super.init(networkingEngine: networkingEngine, executor: executor, currentTimeProvider: currentTimeProvider)
        } else if let executor = executor {
            super.init(networkingEngine: networkingEngine, executor: executor)
        } else if let currentTimeProvider = currentTimeProvider {
            super.init(networkingEngine: networkingEngine, currentTimeProvider: currentTimeProvider)
        } else {
            super.init(networkingEngine: networkingEngine)
        }
        status = .on
    }
    
    static func mockWithUrlSession(currentTimeProvider: @escaping () -> Date = Date.init) -> DohMock {
        // we use a real url session because the network request stubing is done on the urlsession level with HTTPStubs
        DohMock(networkingEngine: URLSession.shared, executor: nil, currentTimeProvider: currentTimeProvider)
    }
    
    static func mockWithMockNetworkingEngine(data: Data?, response: URLResponse?, error: Error) -> DohMock {
        DohMock(networkingEngine: NetworkingEngineMock(data: data, response: response, error: error), executor: SynchronousDoHExecutor(), currentTimeProvider: nil)
    }
    
}

struct SynchronousDoHExecutor: DoHWorkExecutor {
    let internalQueue = DispatchQueue(label: "SynchronousDoHExecutor.queue")
    
    func execute(work: @escaping () -> Void) { internalQueue.async { work() } }
    
    static var instance: SynchronousDoHExecutor = SynchronousDoHExecutor()
}

struct DoHNetworkOperationMock: DoHNetworkOperation {
    let completionHandler: () -> Void
    func resume() { completionHandler() }
}

struct NetworkingEngineMock: DoHNetworkingEngine {
    
    let data: Data?
    let response: URLResponse?
    let error: Error
    
    func networkRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DoHNetworkOperation {
        DoHNetworkOperationMock { completionHandler(data, response, error) }
    }
}

let timeoutError = NSError(domain: "core.tests", code: NSURLErrorTimedOut, userInfo: nil)
let cancelledError = NSError(domain: "core.tests", code: NSURLErrorCancelled, userInfo: nil)

let testProxyDomains = ["https://proxy.domain.com", "https://proxy2.domain.com"]

func stubDoHProvidersSuccess() {
    let proxyDomains = testProxyDomains.map { $0.dropFirst(8) }
    let response = """
    {
    "Status":0,"TC":false,"RD":true,"RA":true,"AD":false,"CD":false,
    "Question":[{"name":"doh.query.text.protonpro.","type":16}],
    "Answer":[
      {"name":"doh.query.text.protonpro","type":16,"TTL":120,"data":"\(proxyDomains[0])"},
      {"name":"doh.query.text.protonpro","type":16,"TTL":120,"data":"\(proxyDomains[1])"}
    ]
    }
    """.data(using: String.Encoding.utf8)!
    stub(condition: isHost("dns.google.com")) { _ in HTTPStubsResponse(data: response, statusCode: 200, headers: [:]) }
    stub(condition: isHost("dns11.quad9.net")) { _ in HTTPStubsResponse(data: response, statusCode: 200, headers: [:]) }
}

func stubDoHProvidersTimeout(sleepInSeconds: UInt32 = 1) {
    let response = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
    stub(condition: isHost("dns.google.com")) { request in
        sleep(sleepInSeconds)
        return HTTPStubsResponse(data: response, statusCode: 400, headers: [:])
    }
    stub(condition: isHost("dns11.quad9.net")) { request in
        sleep(sleepInSeconds)
        return HTTPStubsResponse(data: response, statusCode: 400, headers: [:])
    }
}

func stubDoHProvidersBadResponse() {
    let response = "{ \"Code\": 1000 }".data(using: String.Encoding.utf8)!
    stub(condition: isHost("dns.google.com")) { request in
        return HTTPStubsResponse(data: response, statusCode: 400, headers: [:])
    }
    stub(condition: isHost("dns11.quad9.net")) { request in
        return HTTPStubsResponse(data: response, statusCode: 400, headers: [:])
    }
}
