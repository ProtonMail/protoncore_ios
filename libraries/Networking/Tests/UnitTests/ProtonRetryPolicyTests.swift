//
//  ProtonRetryPolicyTests.swift
//  ProtonCore-Networking-Tests - Created on 8/18/22.
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

#if canImport(Alamofire)
import Alamofire

import XCTest

@testable import ProtonCoreNetworking

class ProtonRetryPolicyTests: XCTestCase {

    func testRetryLimit() {
        let sut = ProtonRetryPolicy(mode: .background, retryLimit: 2)

        let e = expectation(description: "test \(500) retry limit")
        e.assertForOverFulfill = true
        e.expectedFulfillmentCount = 1
        sut.retry(statusCode: 500,
                  retryCount: 1,
                  headers: nil) { retryResult in
            if case .retryWithDelay = retryResult {
                e.fulfill()
            }
        }
        sut.retry(statusCode: 500,
                  retryCount: 2,
                  headers: nil) { retryResult in
            if case .retryWithDelay = retryResult {
                e.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testUserInitiated() {
        let sut = ProtonRetryPolicy(mode: .userInitiated)
        [503, 429, 408, 502].forEach { statusCode in
            let e = expectation(description: "test \(statusCode) userInitiated")
            sut.retry(statusCode: statusCode,
                      retryCount: 0,
                      headers: nil) { retryResult in
                if case .doNotRetry = retryResult {
                    e.fulfill()
                }
            }
            waitForExpectations(timeout: 1)
        }
    }

    func test429And503WithRetryAfterHeader() {
        let headers = HTTPHeaders(["Retry-After": "5"])
        let sut = ProtonRetryPolicy(mode: .background)
        [503, 429].forEach { statusCode in
            let e = expectation(description: "test \(statusCode) with retry")
            sut.retry(statusCode: statusCode,
                      retryCount: 0,
                      headers: headers) { retryResult in
                if case .retryWithDelay(let delay) = retryResult,
                   delay >= 5 {
                    e.fulfill()
                }
            }
            waitForExpectations(timeout: 1)
        }
    }

    func test429And503WithoutRetryAfterHeader() {
        let sut = ProtonRetryPolicy(mode: .background)
        [503, 429].forEach { statusCode in
            let e = expectation(description: "test \(statusCode) without retry header")
            sut.retry(statusCode: statusCode,
                      retryCount: 0,
                      headers: nil) { retryResult in
                if case .retryWithDelay(let delay) = retryResult,
                   delay < 1 {
                    e.fulfill()
                }
            }
            waitForExpectations(timeout: 1)
        }
    }

    func test408And502RetryOnce() {
        let sut = ProtonRetryPolicy(mode: .background)
        [502, 408].forEach { statusCode in
            let e = expectation(description: "test \(statusCode) retry once")
            sut.retry(statusCode: statusCode,
                      retryCount: 0,
                      headers: nil) { retryResult in
                if case .retryWithDelay(let delay) = retryResult,
                   delay < 1 {
                    e.fulfill()
                }
            }
            waitForExpectations(timeout: 1)
        }
    }

    func test408And502DoNotRetryMoreThanOnce() {
        let sut = ProtonRetryPolicy(mode: .background)
        [502, 408].forEach { statusCode in
            let e = expectation(description: "test \(statusCode) do not retry more than once")
            sut.retry(statusCode: statusCode,
                      retryCount: 1,
                      headers: nil) { retryResult in
                if case .doNotRetry = retryResult {
                    e.fulfill()
                }
            }
            waitForExpectations(timeout: 1)
        }
    }
}

#endif
