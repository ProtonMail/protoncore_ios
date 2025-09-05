//
//  LokiApiClient.swift
//  ProtonCore-Performance - Created on 13.06.2024.
//
// Copyright (c) 2025. Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Foundation
import CryptoKit
import XCTest
import Security
import os.log

public enum LokiPushError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case certificateNotFound
    case certificateLoadError(OSStatus)
    case invalidCertificateData
}

public protocol LokiClientProtocol {
    func pushToLoki(entry: String, lokiEndpoint: String) async throws
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public class LokiClient: LokiClientProtocol {

    private let logger = Logger(subsystem: "ProtonCore", category: "Performance.LokiClient")

    public init(){
        self.session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
    }

    public static let shared = LokiClient()

    private let session: URLSession

    public func pushToLoki(entry: String, lokiEndpoint: String) async throws {
        guard let url = URL(string: lokiEndpoint) else {
            throw LokiPushError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = entry.data(using: .utf8)

        do {
            let (_, response) = try await session.data(for: request, delegate: nil)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LokiPushError.invalidResponse
            }

            if httpResponse.statusCode >= 400 {
                throw LokiPushError.httpError(statusCode: httpResponse.statusCode)
            }
        } catch let error as LokiPushError {
            throw error
        } catch {
            throw LokiPushError.httpError(statusCode: 0)
        }
    }

    // Helper function to load the PKCS#12 file with a passphrase
    private func loadIdentity() throws -> SecIdentity {
        guard !MeasurementConfig.lokiCertificate.isEmpty else {
            throw LokiPushError.certificateNotFound
        }

        let testBundle = Bundle(for: type(of: self))
        guard let certFileURL = testBundle.url(forResource: MeasurementConfig.lokiCertificate, withExtension: "p12") else {
            throw LokiPushError.certificateNotFound
        }

        let p12Data: Data
        do {
            p12Data = try Data(contentsOf: certFileURL)
        } catch {
            throw LokiPushError.invalidCertificateData
        }

        let options: [String: Any] = [kSecImportExportPassphrase as String: MeasurementConfig.lokiCertificatePassphrase]
        var items: CFArray?

        let securityError = SecPKCS12Import(p12Data as NSData, options as NSDictionary, &items)
        guard securityError == errSecSuccess else {
            throw LokiPushError.certificateLoadError(securityError)
        }

        guard let itemsArray = items as? NSArray,
              let firstItem = itemsArray.firstObject as? NSDictionary,
              let identityRef = firstItem[kSecImportItemIdentity as String] else {
            throw LokiPushError.invalidCertificateData
        }

        // Safely cast to SecIdentity using CFGetTypeID
        guard CFGetTypeID(identityRef as CFTypeRef) == SecIdentityGetTypeID() else {
            throw LokiPushError.invalidCertificateData
        }

        let identity = identityRef as! SecIdentity
        return identity
    }

    class CustomSessionDelegate: NSObject, URLSessionDelegate {
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                do {
                    let identity = try LokiClient().loadIdentity()
                    let credential = URLCredential(identity: identity, certificates: nil, persistence: .forSession)
                    completionHandler(.useCredential, credential)
                } catch {
                    Logger(subsystem: "ProtonCore", category: "Performance.LokiClient").error("Failed to load client certificate: \(error)")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}
