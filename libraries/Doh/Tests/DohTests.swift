//
//  DohTests.swift
//  ProtonCore-Doh-Tests - Created on 4/19/21.
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
import ProtonCore_TestingToolkit
@testable import ProtonCore_Doh

@available(iOS 15, *)
class DohTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
        stubProductionHosts()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
    func schemaDroppingUrlComparison(with first: String) -> (String) -> Bool {
        return { second in
            guard let firstHost = URL(string: first)?.host, let secondHost = URL(string: second)?.host else { return false }
            return firstHost == secondHost
        }
    }
    
    // MARK: - url tests prototypes
    
    func prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single<T>(testedUrl: @escaping (DoHInterface) -> String, returnedValue: @escaping (DoHInterface) -> T) -> T {
        let doh = DohMock.mockWithUrlSession()
        return returnedValue(doh)
    }
    
    func prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single(testedUrl: @escaping (DoHInterface) -> String) -> String {
        prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single(testedUrl: testedUrl, returnedValue: testedUrl)
    }
    
    func prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single<T>(testedUrl: @escaping (DoHInterface) -> String,
                                                                       returnedValue: @escaping (DoHInterface) -> T) async -> T {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: testedUrl(doh),
                requestHeaders: [DoHConstants.dohHostHeader: URL(string: testedUrl(doh))?.host ?? ""],
                sessionId: nil,
                error: timeoutError) { _ in
                continuation.resume(returning: returnedValue(doh))
            }
        }
        return url
    }
    
    func prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single(testedUrl: @escaping (DoHInterface) -> String) async -> String {
        await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single(testedUrl: testedUrl, returnedValue: testedUrl)
    }
    
    func prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single<T>(testedUrl: @escaping (DoHInterface) -> String,
                                                                       returnedValue: @escaping (DoHInterface) -> T) async -> T {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: testedUrl(doh),
                requestHeaders: [DoHConstants.dohHostHeader: URL(string: testedUrl(doh))?.host ?? ""],
                sessionId: nil, error: timeoutError
            ) { _ in
                continuation.resume(returning: returnedValue(doh))
            }
        }
        return url
    }

    func prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single(testedUrl: @escaping (DoHInterface) -> String) async -> String {
        await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single(testedUrl: testedUrl, returnedValue: testedUrl)
    }
    
    func prototypeTestForUrl_AfterFirstProxyDomainFails_Single<T>(testedUrl: @escaping (DoHInterface) -> String,
                                                                  returnedValue: @escaping (DoHInterface) -> T) async -> T {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let originalHost = testedUrl(doh)
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: originalHost,
                requestHeaders: [DoHConstants.dohHostHeader: URL(string: originalHost)?.host ?? ""],
                sessionId: nil,
                error: timeoutError) { _ in
                doh.handleErrorResolvingProxyDomainIfNeeded(
                    host: testedUrl(doh),
                    requestHeaders: [DoHConstants.dohHostHeader: URL(string: originalHost)?.host ?? ""],
                    sessionId: nil,
                    error: timeoutError) { _ in
                    continuation.resume(returning: returnedValue(doh))
                }
            }
        }
        return url
    }
    
    func prototypeTestForUrl_AfterFirstProxyDomainFails_Single(testedUrl: @escaping (DoHInterface) -> String) async -> String {
        await prototypeTestForUrl_AfterFirstProxyDomainFails_Single(testedUrl: testedUrl, returnedValue: testedUrl)
    }
    
    func prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single<T>(testedUrl: @escaping (DoHInterface) -> String,
                                                                      returnedValue: @escaping (DoHInterface) -> T) async -> (T, T) {
        stubDoHProvidersSuccess()
        var date = Date(timeIntervalSince1970: 0)
        let doh = DohMock.mockWithUrlSession(currentTimeProvider: { date })
        let (hostBefore24h, hostAfter24h): (T, T) = await withCheckedContinuation { continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: testedUrl(doh),
                requestHeaders: [DoHConstants.dohHostHeader: URL(string: testedUrl(doh))?.host ?? ""],
                sessionId: nil,
                error: timeoutError) { _ in
                date = date.addingTimeInterval(dohLifeTime - 1)
                let hostBefore24h = returnedValue(doh)
                date = date.addingTimeInterval(2)
                let hostAfter24h = returnedValue(doh)
                continuation.resume(returning: (hostBefore24h, hostAfter24h))
            }
            
        }
        return (hostBefore24h, hostAfter24h)
    }
    
    func prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single(testedUrl: @escaping (DoHInterface) -> String) async -> (String, String) {
        await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single(testedUrl: testedUrl, returnedValue: testedUrl)
    }
    
    // MARK: - getCurrentlyUsedHostUrl() tests
 
    func testDohGetCurrentlyUsedUrl_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let url = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getCurrentlyUsedHostUrl() }
        XCTAssertEqual(url, MockData.defaultHost.urlString)
    }

    func testDohGetCurrentlyUsedUrl_WhenThereWasNoFetchingOfProxyDomains_Concurrent() async {
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
        }
        XCTAssertTrue(urls.allSatisfy { $0 == MockData.defaultHost.urlString })
    }
    
    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingSuccess_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getCurrentlyUsedHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }

    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingSuccess_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                sessionId: nil,
                error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(urls.allSatisfy(testProxyDomains.contains))
    }
    
    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingFailure_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getCurrentlyUsedHostUrl() }
        XCTAssertEqual(url, MockData.defaultHost.urlString)
    }

    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingFailure_Concurrent() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                sessionId: nil,
                error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(urls.allSatisfy { $0 == MockData.defaultHost.urlString })
    }
    
    func testDohGetCurrentlyUsedUrl_AfterFirstProxyDomainFails_Single() async {
        let url = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getCurrentlyUsedHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }

    func testDohGetCurrentlyUsedUrl_AfterFirstProxyDomainFails_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let results: [(Bool, String, Bool?, String?)] = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                let firstCallShouldRetry = shouldRetry
                let firstCallHostUrl = doh.getCurrentlyUsedHostUrl()
                guard shouldRetry else {
                    continuation.resume(returning: (firstCallShouldRetry, firstCallHostUrl, nil, nil))
                    return
                }
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                            requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                            sessionId: nil,
                                                            error: timeoutError) { shouldRetry in
                    let secondCallShouldRetry = shouldRetry
                    let secondCallHostUrl = doh.getCurrentlyUsedHostUrl()
                    continuation.resume(returning: (firstCallShouldRetry, firstCallHostUrl,
                                                    secondCallShouldRetry, secondCallHostUrl))
                }
            }
        }
        for result in results {
            if result.0 {
                XCTAssertTrue(testProxyDomains.contains(result.1))
            } else {
                XCTAssertEqual(result.1, MockData.defaultHost.urlString)
            }
            guard let secondCallShouldRetry = result.2, let secondCallHostUrl = result.3 else {
                continue
            }
            if secondCallShouldRetry {
                XCTAssertTrue(testProxyDomains.contains(secondCallHostUrl))
            } else {
                XCTAssertEqual(secondCallHostUrl, MockData.defaultHost.urlString)
            }
        }
    }
    
    func testDohGetCurrentlyUsedUrl_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getCurrentlyUsedHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: hostBefore24h)))
        XCTAssertEqual(hostAfter24h, MockData.defaultHost.urlString)
    }
    
    // MARK: - getCaptchaHostUrl() tests
    
    func testDohGetCaptchaHostUrl_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let url = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getCaptchaHostUrl() }
        XCTAssertEqual(url, MockData.captchaHost.urlString)
    }
    
    func testDohGetCaptchaHostUrl_AfterProxyDomainFetchingSuccess_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getCaptchaHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetCaptchaHostUrl_AfterProxyDomainFetchingFailure_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getCaptchaHostUrl() }
        XCTAssertEqual(url, MockData.captchaHost.urlString)
    }
    
    func testDohGetCaptchaHostUrl_AfterFirstProxyDomainFails_Single() async {
        let url = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getCaptchaHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetCaptchaHostUrl_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getCaptchaHostUrl() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: hostBefore24h)))
        XCTAssertEqual(hostAfter24h, MockData.captchaHost.urlString)
    }
    
    // MARK: - getHumanVerificationV3Host() tests
    
    func testDohGetHumanVerificationV3Host_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let url = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getHumanVerificationV3Host() }
        XCTAssertEqual(url, MockData.humanVerificationV3Host.urlString)
    }
    
    func testDohGetHumanVerificationV3Host_AfterProxyDomainFetchingSuccess_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getHumanVerificationV3Host() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetHumanVerificationV3Host_AfterProxyDomainFetchingFailure_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getHumanVerificationV3Host() }
        XCTAssertEqual(url, MockData.humanVerificationV3Host.urlString)
    }
    
    func testDohGetHumanVerificationV3Host_AfterFirstProxyDomainFails_Single() async {
        let url = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getHumanVerificationV3Host() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetHumanVerificationV3Host_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getHumanVerificationV3Host() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: hostBefore24h)))
        XCTAssertEqual(hostAfter24h, MockData.humanVerificationV3Host.urlString)
    }
    
    // MARK: - getAccountHost() tests
    
    func testDohGetAccountHost_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let url = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getAccountHost() }
        XCTAssertEqual(url, MockData.accountHost.urlString)
    }
    
    func testDohGetAccountHost_AfterProxyDomainFetchingSuccess_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getAccountHost() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetAccountHost_AfterProxyDomainFetchingFailure_Single() async {
        let url = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getAccountHost() }
        XCTAssertEqual(url, MockData.accountHost.urlString)
    }
    
    func testDohGetAccountHost_AfterFirstProxyDomainFails_Single() async {
        let url = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getAccountHost() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDohGetAccountHost_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getAccountHost() }
        XCTAssertTrue(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: hostBefore24h)))
        XCTAssertEqual(hostAfter24h, MockData.accountHost.urlString)
    }
    
    // MARK: - multi-hosts tests
    
    func prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl(firstHost: @escaping (DoHInterface) -> String, secondHost: @escaping (DoHInterface) -> String) async {
        let doh = DohMock.mockWithUrlSession()
        stubDoHProvidersSuccess()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: firstHost(doh),
                requestHeaders: [DoHConstants.dohHostHeader: URL(string: firstHost(doh))?.host ?? ""],
                sessionId: nil, error: timeoutError) { _ in
                doh.handleErrorResolvingProxyDomainIfNeeded(
                    host: secondHost(doh),
                    requestHeaders: [DoHConstants.dohHostHeader: URL(string: secondHost(doh))?.host ?? ""],
                    sessionId: nil, error: nil) { _ in
                    continuation.resume(returning: secondHost(doh))
                }
            }
        }
        XCTAssertFalse(testProxyDomains.contains(where: schemaDroppingUrlComparison(with: url)))
    }
    
    func testDoh_ResolvingDefaultHostDoesntInfluenceOtherHosts_Single() async {
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCurrentlyUsedHostUrl() } secondHost: { $0.getCaptchaHostUrl() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCurrentlyUsedHostUrl() } secondHost: { $0.getAccountHost() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCurrentlyUsedHostUrl() } secondHost: { $0.getHumanVerificationV3Host() }
    }
    
    func testDoh_ResolvingCaptchaHostDoesntInfluenceOtherHosts_Single() async {
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCaptchaHostUrl() } secondHost: { $0.getCurrentlyUsedHostUrl() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCaptchaHostUrl() } secondHost: { $0.getAccountHost() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getCaptchaHostUrl() } secondHost: { $0.getHumanVerificationV3Host() }
    }
    
    func testDoh_ResolvingAccountHostDoesntInfluenceOtherHosts_Single() async {
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getAccountHost() } secondHost: { $0.getCaptchaHostUrl() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getAccountHost() } secondHost: { $0.getCurrentlyUsedHostUrl() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getAccountHost() } secondHost: { $0.getHumanVerificationV3Host() }
    }
    
    func testDoh_ResolvingHV3HostDoesntInfluenceOtherHosts_Single() async {
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getHumanVerificationV3Host() } secondHost: { $0.getCaptchaHostUrl() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getHumanVerificationV3Host() } secondHost: { $0.getAccountHost() }
        await prototypeTest_ResolvingDomainsForOneUrlDoesntInfluenceAnyOtherUrl { $0.getHumanVerificationV3Host() } secondHost: { $0.getCurrentlyUsedHostUrl() }
    }
    
    // MARK: - header tests
    
    func testDohGetCurrentlyUsedHeaders_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let headers = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getCurrentlyUsedHostUrl() } returnedValue: { $0.getCurrentlyUsedUrlHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetCurrentlyUsedHeaders_AfterProxyDomainFetchingSuccess_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getCurrentlyUsedHostUrl() } returnedValue: { $0.getCurrentlyUsedUrlHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.defaultHost.rawValue])
    }
    
    func testDohGetCurrentlyUsedHeaders_AfterProxyDomainFetchingFailure_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getCurrentlyUsedHostUrl() } returnedValue: { $0.getCurrentlyUsedUrlHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetCurrentlyUsedHeaders_AfterFirstProxyDomainFails_Single() async {
        let headers = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getCurrentlyUsedHostUrl() } returnedValue: { $0.getCurrentlyUsedUrlHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.defaultHost.rawValue])
    }
    
    func testDohGetCurrentlyUsedHeaders_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getCurrentlyUsedHostUrl() } returnedValue: { $0.getCurrentlyUsedUrlHeaders() }
        XCTAssertEqual(hostBefore24h, ["x-pm-doh-host": MockData.defaultHost.rawValue])
        XCTAssertEqual(hostAfter24h, [:])
    }
    
    func testDohGetCaptchaHeaders_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let headers = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getCaptchaHostUrl() } returnedValue: { $0.getCaptchaHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetCaptchaHeaders_AfterProxyDomainFetchingSuccess_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getCaptchaHostUrl() } returnedValue: { $0.getCaptchaHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.captchaHost.rawValue])
    }
    
    func testDohGetCaptchaHeaders_AfterProxyDomainFetchingFailure_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getCaptchaHostUrl() } returnedValue: { $0.getCaptchaHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetCaptchaHeaders_AfterFirstProxyDomainFails_Single() async {
        let headers = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getCaptchaHostUrl() } returnedValue: { $0.getCaptchaHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.captchaHost.rawValue])
    }
    
    func testDohGetCaptchaHeaders_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getCaptchaHostUrl() } returnedValue: { $0.getCaptchaHeaders() }
        XCTAssertEqual(hostBefore24h, ["x-pm-doh-host": MockData.captchaHost.rawValue])
        XCTAssertEqual(hostAfter24h, [:])
    }
    
    func testDohGetHumanVerificationV3Headers_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let headers = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getHumanVerificationV3Host() } returnedValue: { $0.getHumanVerificationV3Headers() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetHumanVerificationV3Headers_AfterProxyDomainFetchingSuccess_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getHumanVerificationV3Host() } returnedValue: { $0.getHumanVerificationV3Headers() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.humanVerificationV3Host.rawValue])
    }
    
    func testDohGetHumanVerificationV3Headers_AfterProxyDomainFetchingFailure_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getHumanVerificationV3Host() } returnedValue: { $0.getHumanVerificationV3Headers() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetHumanVerificationV3Headers_AfterFirstProxyDomainFails_Single() async {
        let headers = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getHumanVerificationV3Host() } returnedValue: { $0.getHumanVerificationV3Headers() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.humanVerificationV3Host.rawValue])
    }
    
    func testDohGetHumanVerificationV3Headers_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getHumanVerificationV3Host() } returnedValue: { $0.getHumanVerificationV3Headers() }
        XCTAssertEqual(hostBefore24h, ["x-pm-doh-host": MockData.humanVerificationV3Host.rawValue])
        XCTAssertEqual(hostAfter24h, [:])
    }
    
    func testDohGetAccountHeaders_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let headers = prototypeTestForUrl_WhenThereWasNoFetchingOfProxyDomains_Single { $0.getAccountHost() } returnedValue: { $0.getAccountHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetAccountHeaders_AfterProxyDomainFetchingSuccess_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingSuccess_Single { $0.getAccountHost() } returnedValue: { $0.getAccountHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.accountHost.rawValue])
    }
    
    func testDohGetAccountHeaders_AfterProxyDomainFetchingFailure_Single() async {
        let headers = await prototypeTestForUrl_AfterProxyDomainFetchingFailure_Single { $0.getAccountHost() } returnedValue: { $0.getAccountHeaders() }
        XCTAssertEqual(headers, [:])
    }
    
    func testDohGetAccountHeaders_AfterFirstProxyDomainFails_Single() async {
        let headers = await prototypeTestForUrl_AfterFirstProxyDomainFails_Single { $0.getAccountHost() } returnedValue: { $0.getAccountHeaders() }
        XCTAssertEqual(headers, ["x-pm-doh-host": MockData.accountHost.rawValue])
    }
    
    func testDohGetAccountHeaders_After24hTimeOfUsingProxyDomain_Single() async {
        let (hostBefore24h, hostAfter24h) = await prototypeTestForUrl_After24hTimeOfUsingProxyDomain_Single { $0.getAccountHost() } returnedValue: { $0.getAccountHeaders() }
        XCTAssertEqual(hostBefore24h, ["x-pm-doh-host": MockData.accountHost.rawValue])
        XCTAssertEqual(hostAfter24h, [:])
    }
    
    // MARK: - retry information tests
    
    func testDohShouldRetry_AfterProxyDomainFetchingSuccess_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        
        let shouldRetry = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil, error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(shouldRetry)
    }
    
    func testDohShouldRetry_AfterProxyDomainFetchingSuccess_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let retries = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil, error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(retries.allSatisfy { $0 })
    }
    
    func testDohShouldNotRetry_IfErrorIsNotHandledByDoH_Single() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let shouldRetry = await withCheckedContinuation { continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil,
                                                        error: cancelledError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertFalse(shouldRetry)
    }
    
    func testDohShouldNotRetry_IfErrorIsNotHandledByDoH_Concurrent() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let retries = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                sessionId: nil,
                error: cancelledError
            ) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(retries.filter { $0 }.isEmpty)
    }
    
    func testDohShouldNotRetry_AfterProxyDomainFetchingFailure_Single() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let shouldRetry = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                sessionId: nil,
                error: timeoutError
            ) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertFalse(shouldRetry)
    }
    
    func testDohShouldNotRetry_AfterProxyDomainFetchingFailure_Concurrent() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let retries = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(
                host: doh.getCurrentlyUsedHostUrl(),
                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                sessionId: nil,
                error: timeoutError
            ) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(retries.allSatisfy { !$0 })
    }
    
    func testDohShouldNotRetry_IfSuccessfullyFetchedButAllRetriesToProxyDomainFailed_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        
        XCTAssertEqual(doh.getCurrentlyUsedHostUrl(), MockData.defaultHost.urlString)
        var testDomains = testProxyDomains
        
        let (retries, urls): ([Bool], [String]) = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                let firstShouldRetry = shouldRetry
                let firstUrl = doh.getCurrentlyUsedHostUrl()
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                            requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                            sessionId: nil,
                                                            error: timeoutError) { shouldRetry in
                    let secondShouldRetry = shouldRetry
                    let secondUrl = doh.getCurrentlyUsedHostUrl()
                    doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                                sessionId: nil,
                                                                error: timeoutError) { shouldRetry in
                        let thirdShouldRetry = shouldRetry
                        let thirdUrl = doh.getCurrentlyUsedHostUrl()
                        continuation.resume(
                            returning: ([firstShouldRetry, secondShouldRetry, thirdShouldRetry],
                                        [firstUrl, secondUrl, thirdUrl])
                        )
                    }
                }
            }
        }
        XCTAssertTrue(retries[0])
        XCTAssertTrue(retries[1])
        XCTAssertFalse(retries[2])
        XCTAssertTrue(testDomains.contains(urls[0]))
        testDomains.removeAll { $0 == urls[0] }
        XCTAssertEqual(urls[1], testDomains[0])
        XCTAssertEqual(urls[2], MockData.defaultHost.urlString)
    }
    
    func testDohShouldNotRetry_IfSuccessfullyFetchedButAllRetriesToProxyDomainFailed_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let results: [Bool?] = await performConcurrentlySettingExpectations { index, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                        requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                        sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                guard shouldRetry else { continuation.resume(returning: nil); return }
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                            requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                            sessionId: nil,
                                                            error: timeoutError) { shouldRetry in
                    guard shouldRetry else { continuation.resume(returning: nil); return }
                    doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                                requestHeaders: doh.getCurrentlyUsedUrlHeaders(),
                                                                sessionId: nil,
                                                                error: timeoutError) { shouldRetry in
                        continuation.resume(returning: shouldRetry)
                    }
                }
            }
        }
        for result in results.compactMap({ $0 }) {
            XCTAssertFalse(result)
        }
    }
    
    // MARK: - deprecated API works
    
    @available(*, deprecated, message: "This test uses deprecated apis")
    func testGetHostUrlWorks() {
        let mock1 = DohMock.mockWithUrlSession()
        let mock2 = DohMock.mockWithUrlSession()
        XCTAssertEqual(mock1.getHostUrl(), mock2.getCurrentlyUsedHostUrl())
    }
    
    @available(*, deprecated, message: "This test uses deprecated apis")
    func testHandleErrorWorks() async {
        stubDoHProvidersSuccess()
        let mockOld = DohMock.mockWithUrlSession()
        let mockNew = DohMock.mockWithUrlSession()
        let shouldRetryOld1 = mockOld.handleError(host: mockOld.getHostUrl(), error: timeoutError)
        let urlOld1 = mockOld.getHostUrl()
        let shouldRetryOld2 = mockOld.handleError(host: mockOld.getHostUrl(), error: timeoutError)
        let urlOld2 = mockOld.getHostUrl()
        let (shouldRetryNew1, urlNew1, shouldRetryNew2, urlNew2): (Bool, String, Bool, String) = await withCheckedContinuation { continuation in
            mockNew.handleErrorResolvingProxyDomainIfNeeded(host: mockNew.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                            error: timeoutError) { shouldRetry1 in
                let url1 = mockNew.getCurrentlyUsedHostUrl()
                mockNew.handleErrorResolvingProxyDomainIfNeeded(host: url1,
                                                                sessionId: nil,
                                                                error: timeoutError) { shouldRetry2 in
                    let url2 = mockNew.getCurrentlyUsedHostUrl()
                    continuation.resume(returning: (shouldRetry1, url1, shouldRetry2, url2))
                }
                
            }
        }
        XCTAssertTrue(shouldRetryOld1)
        XCTAssertTrue(shouldRetryOld2)
        XCTAssertTrue(shouldRetryNew1)
        XCTAssertTrue(shouldRetryNew2)
        XCTAssertTrue(testProxyDomains.contains(urlOld1))
        XCTAssertTrue(testProxyDomains.contains(urlOld2))
        XCTAssertTrue(testProxyDomains.contains(urlNew1))
        XCTAssertTrue(testProxyDomains.contains(urlNew2))
    }
    
    @available(*, deprecated, message: "This test uses deprecated apis")
    func testClearAllWorks() async {
        stubDoHProvidersSuccess()
        let mock1 = DohMock.mockWithUrlSession()
        let mock2 = DohMock.mockWithUrlSession()
        _ = mock1.handleError(host: MockData.defaultHost.urlString, error: timeoutError)
        let urlOld1 = mock1.getHostUrl()
        mock1.clearAll()
        let urlOld2 = mock1.getHostUrl()
        let (urlNew1, urlNew2): (String, String) = await withCheckedContinuation { continuation in
            mock2.handleErrorResolvingProxyDomainIfNeeded(host: MockData.defaultHost.urlString, sessionId: nil,
                                                          error: timeoutError) { shouldRetry in
                let urlNew1 = mock2.getCurrentlyUsedHostUrl()
                mock2.clearCache()
                let urlNew2 = mock2.getCurrentlyUsedHostUrl()
                continuation.resume(returning: (urlNew1, urlNew2))
            }
        }
        XCTAssertNotEqual(urlOld1, MockData.defaultHost.urlString)
        XCTAssertEqual(urlOld2, MockData.defaultHost.urlString)
        XCTAssertNotEqual(urlNew1, MockData.defaultHost.urlString)
        XCTAssertEqual(urlNew2, MockData.defaultHost.urlString)
    }
    
}
