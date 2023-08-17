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
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
@testable import ProtonCoreDoh

@available(iOS 13.0, *)
class DoHCookiesSynchronizerTests: XCTestCase {
    
    var doh: DoH!
    var storage = HTTPCookieStorage.shared
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        stubProductionHosts()
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
    
    func cookieHeader(domain: String) -> [String: String] { [
        "Set-Cookie": "Session-Id=Best-Session-Eva111; Domain=\(domain); Path=/; HttpOnly; Secure; Max-Age=7776000, Version=test; Path=/; Secure; Max-Age=7776000, Tag=test; Path=/; Secure; Max-Age=7776000"
    ] }
    
    func testNothingIsBeingSetIfNoProxyDomains_SynchronizerAPI() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        let synchronizer = DoHCookieSynchronizer(cookieStorage: storage, doh: doh)
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        await synchronizer.synchronizeCookies(for: .mailAPI, with: cookieHeader(domain: ProductionHosts.mailAPI.rawValue))
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        for proxyHost in testProxyHosts {
            await synchronizer.synchronizeCookies(for: .mailAPI, with: cookieHeader(domain: proxyHost))
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
    }
    
    func testNothingIsBeingSetIfNoProxyDomains_DOHAPI() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        await doh.synchronizeCookies(with: HTTPURLResponse(url: ProductionHosts.mailAPI.url, statusCode: 200, httpVersion: nil, headerFields: cookieHeader(domain: ProductionHosts.mailAPI.rawValue)), requestHeaders: doh.getCurrentlyUsedUrlHeaders())
        XCTAssertTrue(storage.cookies?.isEmpty == true)

        let testProxyURLs = testProxyDomains.compactMap(URL.init(string:))
        XCTAssertEqual(
            testProxyURLs.count, testProxyDomains.count,
            "One of the test proxy domains in \(testProxyDomains) isn't a valid URL."
        )

        for (host, domain) in zip(testProxyHosts, testProxyURLs) {
            await doh.synchronizeCookies(
                with: HTTPURLResponse(
                    url: domain,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: cookieHeader(domain: host)
                ),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders()
            )
        }

        zip(testProxyHosts, testProxyDomains.map(URL.init(string:)).map { $0! })
            .forEach { host, domain in
            }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
    }
    
    func testCookiesAreBeingProperlySetForProxyDomains_SynchronizerAPI() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        let synchronizer = DoHCookieSynchronizer(cookieStorage: storage, doh: doh)
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), requestHeaders: [:], sessionId: nil, error: timeoutError) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        await synchronizer.synchronizeCookies(for: .mailAPI, with: cookieHeader(domain: ProductionHosts.mailAPI.rawValue))
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.config.defaultHost)!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllProxyDomainUrls(for: .mailAPI)
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain, proxying: .mailAPI))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
    
    func testCookiesAreBeingProperlySetForProxyDomainsWhenOriginatingFromProductionDomain() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), requestHeaders: [:], sessionId: nil, error: timeoutError) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        await doh.synchronizeCookies(with: HTTPURLResponse(url: ProductionHosts.mailAPI.url, statusCode: 200, httpVersion: nil, headerFields: cookieHeader(domain: ProductionHosts.mailAPI.rawValue)),
                               requestHeaders: doh.getCurrentlyUsedUrlHeaders())
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.config.defaultHost)!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllProxyDomainUrls(for: .mailAPI)
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain, proxying: .mailAPI))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
    
    func testCookiesAreBeingProperlySetForProxyDomainsWhenOriginatingFromProxyDomain() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), requestHeaders: [:], sessionId: nil, error: timeoutError) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        await doh.synchronizeCookies(
            with: HTTPURLResponse(
                url: URL(string: testProxyDomains[0])!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: cookieHeader(domain: ProductionHosts.mailAPI.rawValue)
            ),
            requestHeaders: doh.getCurrentlyUsedUrlHeaders()
        )
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.config.defaultHost)!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllProxyDomainUrls(for: .mailAPI)
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain, proxying: .mailAPI))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
    
    func testCookiesAreNotBeingSetForProxyDomainsWhenNoHeaders() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        let firstResponse = HTTPURLResponse(url: URL(string: doh.getCurrentlyUsedHostUrl())!, statusCode: 200, httpVersion: "1", headerFields: [:])
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(), requestHeaders: [:], sessionId: nil, response: firstResponse, error: timeoutError
            ) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(storage.cookies?.isEmpty == true)
    }
    
    func testCookiesAreBeingProperlySetForProxyDomainsWhenUsingOtherMethodWhenOriginatedFromProductionHost() async {
        XCTAssertTrue(storage.cookies?.isEmpty == true)
        doh.setUpCookieSynchronization(storage: storage)
        let secondResponse = HTTPURLResponse(url: URL(string: doh.getCurrentlyUsedHostUrl())!, statusCode: 200, httpVersion: "1", headerFields: cookieHeader(domain: ProductionHosts.mailAPI.rawValue))
        _ = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainAndSynchronizingCookiesIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(), requestHeaders: [:], sessionId: nil, response: secondResponse, error: timeoutError
            ) { _ in
                continuation.resume(returning: self.doh.getCurrentlyUsedHostUrl())
            }
        }
        guard let cookies = storage.cookies else { XCTFail(); return }
        XCTAssertEqual(cookies.count, 9)
        guard let cookiesForHost = storage.cookies(for: URL(string: doh.config.defaultHost)!) else {
            XCTFail()
            return
        }
        XCTAssertEqual(cookiesForHost.count, 3)
        XCTAssertTrue(cookiesForHost.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        let domains = doh.fetchAllProxyDomainUrls(for: .mailAPI)
        XCTAssertEqual(domains.count, 2)
        for domain in domains {
            guard let cookiesForDomain = storage.cookies(for: URL(string: doh.hostUrl(for: domain, proxying: .mailAPI))!) else {
                XCTFail()
                return
            }
            XCTAssertEqual(cookiesForDomain.count, 3)
            XCTAssertTrue(cookiesForDomain.contains(where: { $0.name == "Session-Id" && $0.value == "Best-Session-Eva111" }))
        }
    }
}
