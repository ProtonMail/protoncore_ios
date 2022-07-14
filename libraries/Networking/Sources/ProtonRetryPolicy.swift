//
//  ProtonRetryPolicy.swift
//  Pods - Created on 13/07/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#if canImport(Alamofire)
import Alamofire
import Foundation

final public class ProtonRetryPolicy: RequestInterceptor {

    public enum RetryMode {
        case userInitiated
        case background
    }

    let mode: RetryMode
    let retryLimit: Int = 3
    let exponentialBackoffBase: UInt = 2
    let exponentialBackoffScale: Double = 0.5

    init(mode: RetryMode = .userInitiated) {
        self.mode = mode
    }

    public func retry(_ request: Alamofire.Request,
                      for session: Alamofire.Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        guard mode == .background else {
            completion(.doNotRetry)
            return
        }
        if request.retryCount < retryLimit {
            let delay = pow(Double(exponentialBackoffBase), Double(request.retryCount)) * exponentialBackoffScale
            completion(.retryWithDelay(delay))
        } else {
            completion(.doNotRetry)
        }
    }
}

#endif
