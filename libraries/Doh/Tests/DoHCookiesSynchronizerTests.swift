//
//  DoHCookiesSynchronizerTests.swift
//  ProtonCore-Doh-Tests - Created on 24/03/22.
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
@testable import ProtonCore_Doh

@available(iOS 13.0, *)
class DoHCookiesSynchronizerTests: XCTestCase {
    
    var doh: DoH!
    var storage = HTTPCookieStorage.shared
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        stubDoHProvidersSuccess()
        doh = DohMock.mockWithUrlSession()
        storage.removeCookies(since: .distantPast)
    }

    override func tearDown() {
        super.tearDown()
        doh = nil
        HTTPStubs.removeAllStubs()
        storage.removeCookies(since: .distantPast)
    }
    
    var cookieHeader: [String: String] = [
        "Set-Cookie": "Session-Id=Best-Session-Eva111; Domain=\(MockData.testHostWithoutHTTP); Path=/; HttpOnly; Secure; Max-Age=7776000, Version=test; Path=/; Secure; Max-Age=7776000, Tag=test; Path=/; Secure; Max-Age=7776000"
    ]
    
    func testNothingIsBeingSetIfNoProxyDomains() {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        let synchronizer = DoHCookieSynchronizer(cookieStorage: storage, doh: doh)
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        synchronizer.synchronizeCookies(with: cookieHeader)
        XCTAssertTrue(storage.cookies?.isEmpty == true)
    }
    
    func testCookiesAreBeingProperlySetForProxyDomains() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        let synchronizer = DoHCookieSynchronizer(cookieStorage: storage, doh: doh)
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        synchronizer.synchronizeCookies(with: cookieHeader)
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.getDefaultHost())!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllCacheHostUrls()
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
    
    func testCookiesAreBeingProperlySetForProxyDomainsWhenUsingOtherMethod() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        let firstResponse = HTTPURLResponse(url: URL(string: doh.getCurrentlyUsedHostUrl())!, statusCode: 200, httpVersion: "1", headerFields: [:])
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, response: firstResponse, error: timeoutError
            ) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        let secondResponse = HTTPURLResponse(url: URL(string: doh.getCurrentlyUsedHostUrl())!, statusCode: 200, httpVersion: "1", headerFields: cookieHeader)
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, response: secondResponse, error: nil
            ) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.getDefaultHost())!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllCacheHostUrls()
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
}
