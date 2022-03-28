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

@available(iOS 15, *)
class DohTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        HTTPStubs.setEnabled(true)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
    private func performConcurrentlySettingExpectations<T>(
        amount: Int = 20, _ work: @escaping (Int, CheckedContinuation<T, Never>) -> Void
    ) async -> [T] {
        await withTaskGroup(of: T.self) { group -> [T] in
            for index in 1...amount {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        work(index, continuation)
                    }
                }
            }
            var results = [T]()
            for await element in group {
                results.append(element)
            }
            return results
        }
    }
    
    // MARK: - getCurrentlyUsedHostUrl() tests
 
    func testDohGetCurrentlyUsedUrl_WhenThereWasNoFetchingOfProxyDomains_Single() {
        let doh = DohMock.mockWithUrlSession()
        let url = doh.getCurrentlyUsedHostUrl()
        XCTAssertEqual(url, MockData.testHost1)
    }

    func testDohGetCurrentlyUsedUrl_WhenThereWasNoFetchingOfProxyDomains_Concurrent() async {
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
        }
        XCTAssertTrue(urls.allSatisfy { $0 == MockData.testHost1 })
    }
    
    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingSuccess_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(testProxyDomains.contains(url))
    }

    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingSuccess_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(urls.allSatisfy(testProxyDomains.contains))
    }
    
    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingFailure_Single() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertEqual(url, MockData.testHost1)
    }

    func testDohGetCurrentlyUsedUrl_AfterProxyDomainFetchingFailure_Concurrent() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let urls = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { _ in
                continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
            }
        }
        XCTAssertTrue(urls.allSatisfy { $0 == MockData.testHost1 })
    }
    
    func testDohGetCurrentlyUsedUrl_AfterFirstProxyDomainFails_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let url = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { _ in
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { _ in
                    continuation.resume(returning: doh.getCurrentlyUsedHostUrl())
                }
            }
        }
        XCTAssertTrue(testProxyDomains.contains(url))
    }

    func testDohGetCurrentlyUsedUrl_AfterFirstProxyDomainFails_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let results: [(Bool, String, Bool?, String?)] = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                let firstCallShouldRetry = shouldRetry
                let firstCallHostUrl = doh.getCurrentlyUsedHostUrl()
                guard shouldRetry else {
                    continuation.resume(returning: (firstCallShouldRetry, firstCallHostUrl, nil, nil))
                    return
                }
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
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
                XCTAssertEqual(result.1, MockData.testHost1)
            }
            guard let secondCallShouldRetry = result.2, let secondCallHostUrl = result.3 else {
                continue
            }
            if secondCallShouldRetry {
                XCTAssertTrue(testProxyDomains.contains(secondCallHostUrl))
            } else {
                XCTAssertEqual(secondCallHostUrl, MockData.testHost1)
            }
        }
    }
    
    func testDohGetCurrentlyUsedUrl_After24hTimeOfUsingProxyDomain_Single() async {
        stubDoHProvidersSuccess()
        var date = Date(timeIntervalSince1970: 0)
        let doh = DohMock.mockWithUrlSession(currentTimeProvider: { date })
        let (hostBefore24h, hostAfter24h): (String, String) = await withCheckedContinuation { continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { _ in
                date = date.addingTimeInterval(24 * 60 * 60 - 1)
                let hostBefore24h = doh.getCurrentlyUsedHostUrl()
                date = date.addingTimeInterval(2)
                let hostAfter24h = doh.getCurrentlyUsedHostUrl()
                continuation.resume(returning: (hostBefore24h, hostAfter24h))
            }
            
        }
        XCTAssertTrue(testProxyDomains.contains(hostBefore24h))
        XCTAssertEqual(hostAfter24h, MockData.testHost1)
    }
    
    // MARK: - retry information tests
    
    func testDohShouldRetry_AfterProxyDomainFetchingSuccess_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        
        let shouldRetry = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(shouldRetry)
    }
    
    func testDohShouldRetry_AfterProxyDomainFetchingSuccess_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let retries = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(retries.allSatisfy { $0 })
    }
    
    func testDohShouldNotRetry_IfErrorIsNotHandledByDoH_Single() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let shouldRetry = await withCheckedContinuation { continuation in
            
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
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
                host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: cancelledError
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
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil, error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertFalse(shouldRetry)
    }
    
    func testDohShouldNotRetry_AfterProxyDomainFetchingFailure_Concurrent() async {
        stubDoHProvidersBadResponse()
        let doh = DohMock.mockWithUrlSession()
        let retries = await performConcurrentlySettingExpectations { _, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                continuation.resume(returning: shouldRetry)
            }
        }
        XCTAssertTrue(retries.allSatisfy { !$0 })
    }
    
    func testDohShouldNotRetry_IfSuccessfullyFetchedButAllRetriesToProxyDomainFailed_Single() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        
        XCTAssertEqual(doh.getCurrentlyUsedHostUrl(), MockData.testHost1)
        var testDomains = testProxyDomains
        
        let (retries, urls): ([Bool], [String]) = await withCheckedContinuation { continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                let firstShouldRetry = shouldRetry
                let firstUrl = doh.getCurrentlyUsedHostUrl()
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
                                                            sessionId: nil,
                                                            error: timeoutError) { shouldRetry in
                    let secondShouldRetry = shouldRetry
                    let secondUrl = doh.getCurrentlyUsedHostUrl()
                    doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
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
        XCTAssertEqual(urls[2], MockData.testHost1)
    }
    
    func testDohShouldNotRetry_IfSuccessfullyFetchedButAllRetriesToProxyDomainFailed_Concurrent() async {
        stubDoHProvidersSuccess()
        let doh = DohMock.mockWithUrlSession()
        let results: [Bool?] = await performConcurrentlySettingExpectations { index, continuation in
            doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                        error: timeoutError) { shouldRetry in
                guard shouldRetry else { continuation.resume(returning: nil); return }
                doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(), sessionId: nil,
                                                            error: timeoutError) { shouldRetry in
                    guard shouldRetry else { continuation.resume(returning: nil); return }
                    doh.handleErrorResolvingProxyDomainIfNeeded(host: doh.getCurrentlyUsedHostUrl(),
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
        _ = mock1.handleError(host: MockData.testHost1, error: timeoutError)
        let urlOld1 = mock1.getHostUrl()
        mock1.clearAll()
        let urlOld2 = mock1.getHostUrl()
        let (urlNew1, urlNew2): (String, String) = await withCheckedContinuation { continuation in
            mock2.handleErrorResolvingProxyDomainIfNeeded(host: MockData.testHost1, sessionId: nil,
                                                          error: timeoutError) { shouldRetry in
                let urlNew1 = mock2.getCurrentlyUsedHostUrl()
                mock2.clearCache()
                let urlNew2 = mock2.getCurrentlyUsedHostUrl()
                continuation.resume(returning: (urlNew1, urlNew2))
            }
        }
        XCTAssertNotEqual(urlOld1, MockData.testHost1)
        XCTAssertEqual(urlOld2, MockData.testHost1)
        XCTAssertNotEqual(urlNew1, MockData.testHost1)
        XCTAssertEqual(urlNew2, MockData.testHost1)
    }
    
}
