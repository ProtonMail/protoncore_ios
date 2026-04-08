//
//  ReceiptRequestManagerMocks.swift
//  ProtonCore-PaymentsV2Test - Created on 07/04/2026.
//
//  Copyright (c) 2024 Proton Technologies AG
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

import Foundation
import StoreKit

// MARK: - Mock Wrapper to Replace SKReceiptRefreshRequest

final class MockReceiptRefreshRequest: SKReceiptRefreshRequest {

    enum MockResult {
        case success
        case failure(Error)
    }

    /// Random delay
    let delay: UInt64
    let result: MockResult

    init(delayRange: ClosedRange<UInt64> = 20...200,
         result: MockResult = .success) {
        self.delay = UInt64.random(in: delayRange)
        self.result = result
        super.init()
    }

    override func start() {
        Task {
            try? await Task.sleep(nanoseconds: delay * 1_000_000)

            switch result {
            case .success:
                await MainActor.run {
                    self.delegate?.requestDidFinish?(self)
                }
            case .failure(let error):
                await MainActor.run {
                    self.delegate?.request?(self, didFailWithError: error)
                }
            }
        }
    }
}

final class SafeReceiptRefreshRequestMocked: NSObject, SKRequestDelegate {

    private var continuation: CheckedContinuation<Void, Error>?
    private var done = false
    private let queue = DispatchQueue(label: "test.safe.request")

    var request: MockReceiptRefreshRequest!

    func begin(with result: MockReceiptRefreshRequest.MockResult) async throws {
        request = MockReceiptRefreshRequest(result: result)
        request.delegate = self

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            queue.sync { continuation = cont }
            request.start()
        }
    }

    func cancel() {
        let cont = queue.sync { () -> CheckedContinuation<Void, Error>? in
            if done { return nil }
            done = true
            return continuation
        }
        cont?.resume(throwing: CancellationError())
    }

    // MARK: Delegate callbacks

    func requestDidFinish(_ request: SKRequest) {
        let cont = queue.sync { () -> CheckedContinuation<Void, Error>? in
            if done { return nil }
            done = true
            return continuation
        }
        cont?.resume()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        let cont = queue.sync { () -> CheckedContinuation<Void, Error>? in
            if done { return nil }
            done = true
            return continuation
        }
        cont?.resume(throwing: error)
    }
}
