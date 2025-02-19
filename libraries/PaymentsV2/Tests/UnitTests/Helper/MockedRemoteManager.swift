//
//  MockedRemoteManager.swift
//  ProtonCore-PaymentsV2Test - Created on 15/10/2024.
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
@testable import ProtonCorePaymentsV2

final class MockedRemoteManager: @unchecked Sendable {

    public var paymentsAPI: PaymentsAPIs!
    private var urlSessionConfig: URLSessionConfiguration!
    public var remoteManager: RemoteManager!
    let doh: PaymentsDoH

    init() {
        doh = PaymentsDoH()
        paymentsAPI = PaymentsAPIs(doh: doh)
        URLProtocol.registerClass(MockURLProtocol.self)

        urlSessionConfig = URLSessionConfiguration.ephemeral
        urlSessionConfig.protocolClasses = [MockURLProtocol.self]

        remoteManager = RemoteManager(sessionID: "adasd12d21d", authToken: "dasdawd12e", appVersion: "@VPN3.3.2")
        remoteManager?.setSession(URLSession(configuration: urlSessionConfig))
    }

    public func destroy() {
        paymentsAPI = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
        remoteManager = nil
        urlSessionConfig = nil
    }

    public func setupURLSessionMock(withMockResponse mock: [String: Any]? = nil,
                                    urlPath: String? = nil,
                                    responseStatusCode: Int = 200) {
        let requestURLPath = urlPath != nil ? urlPath : doh.defaultPath
        var responseData: Data = Data()
        if let mock = mock {
            guard let data = try? JSONSerialization.data(withJSONObject: mock) else {
                assertionFailure("Unable to converto mock response to data")
                return
            }
            responseData = data
        } else {
            let defaultMock: [String: Any] = [
                "Code": 1000
            ]

            guard let data = try? JSONSerialization.data(withJSONObject: defaultMock) else {
                assertionFailure("Unable to converto mock response to data")
                return
            }

            responseData = data
        }

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: requestURLPath!)!,
                                           statusCode: responseStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, responseData)
        }

        remoteManager.setSession(URLSession(configuration: urlSessionConfig))
    }
}
