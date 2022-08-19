//
//  ProtonRetryPolicy.swift
//  ProtonCore-Networking - Created on 7/14/22.
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

#if canImport(Alamofire)
import Alamofire
import Foundation

public final class ProtonRetryPolicy: RequestInterceptor {

    public enum RetryMode {
        case userInitiated
        case background
    }

    let mode: RetryMode
    let retryLimit: Int = 3
    let exponentialBackoffBase: Int = 2
    let exponentialBackoffScale: Double = 0.5

    init(mode: RetryMode = .userInitiated) {
        self.mode = mode
    }

    public func retry(_ request: Alamofire.Request,
                      for session: Alamofire.Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        if let response = request.response,
           [408, 502].contains(response.statusCode),
           request.retryCount < 1 {
            completion(.retryWithDelay(delayWithJitter(retryCount: request.retryCount)))
            return
        }
        guard mode == .background else {
            completion(.doNotRetry)
            return
        }
        if let response = request.response,
           [503, 429].contains(response.statusCode),
           let retryAfterHeader = response.headers.first(where: { header in header.name == "Retry-After" }),
           let delay = Double(retryAfterHeader.value), // assuming the value is in seconds
           delay > 0 {
            completion(.retryWithDelay(delay.withJitter()))
            return
        }
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        completion(.retryWithDelay(delayWithJitter(retryCount: request.retryCount)))
    }

    private func delayWithJitter(retryCount: Int) -> Double {
        let delay = pow(Double(exponentialBackoffBase), Double(retryCount)) * exponentialBackoffScale
        return delay.withJitter()
    }
}

private extension Double {
    func withJitter() -> Double {
        self + Double.random(in: 0..<(self / 2))
    }
}

#endif
