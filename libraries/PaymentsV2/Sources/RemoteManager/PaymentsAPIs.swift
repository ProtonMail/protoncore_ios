//
//  PaymentsAPIs.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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
import ProtonCoreDoh
import ProtonCoreLog

public struct APIRequest: @unchecked Sendable {
    public let url: URL
    public let body: [String: Any]?
}

public enum PaymentsAPIsError: LocalizedError {
    case malformedURL(url: String)

    public var errorDescription: String? {
        switch self {
        case .malformedURL(let url):
            return PaymentsV2Localizer.APIs_malformed_url_request.l10n
        }
    }

    public var failureReason: String? {
        switch self {
        case .malformedURL(let url):
            return  "The expected url: \(url) is wrong or malformed"
        }
    }
}

public protocol PaymentsAPIsProviding {

    func url(for api: RequestType) throws -> APIRequest
}

public struct PaymentsAPIs: PaymentsAPIsProviding, Sendable {

    private struct Constants {
        static func moduleNameSpace(requestType: RequestType) -> String {
            switch requestType {
            case .userTransactionUUID:
                return "/auth/"
            default:
                return "/payments/"
            }
        }

        static func apiVersion(requestType: RequestType) -> APIv {
            switch requestType {
            case .userTransactionUUID:
                return .v4
            case .appleStatus:
                return .v6
            default:
                return .v5
            }
        }

        static func urlString(hostURL: String, requestType: RequestType) -> String {
            return hostURL + Constants.moduleNameSpace(requestType: requestType) + Constants.apiVersion(requestType: requestType).rawValue + requestType.requestEndpoint
        }
    }

    private enum APIv: String {
        case v4
        case v5
        case v6
    }

    private let doh: DoHInterface
    private let version: APIv = .v5

    public func url(for api: RequestType) throws -> APIRequest {

        let urlString = Constants.urlString(hostURL: doh.getCurrentlyUsedHostUrl(), requestType: api)
        var urlComponents = URLComponents(string: urlString)

        if let queryItems = api.queryComponents {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            let error = PaymentsAPIsError.malformedURL(url: urlString)
            PMLog.error(error.failureReason ?? "PaymentsV2 - malformedURL", sendToExternal: true)
            throw error
        }

        return APIRequest(url: url, body: api.body)
    }

    public init(doh: DoHInterface & ServerConfig) {
        self.doh = doh
    }
}

public enum RequestType {

    // MARK: Tokens
    case createToken(token: Token)
    case checkToken(token: String)

    // MARK: Subscription
    case getCurrentSubscription
    case createSubscription(newSubscription: NewSubscription)
    case checkSubscription(subscription: Subscription)
    case cancelSubscription(cancelSubscription: CancelSubscription)
    case subscriptionLatest // returns latest cancelled sub check and then delete if not needed
    case changeRenewSubscription(renewSubscription: RenewSubscription)

    // MARK: Payments
    case paymentStatus(vendor: VendorType)
    case legacyAppleStatus
    case appleStatus

    // MARK: Plans
    case availablePlans(currency: String?, vendor: String?, state: Int?, timeStamp: Int?)

    // MARK: Miscellaneous
    case icon(name: String)
    case userTransactionUUID
}

extension RequestType {

    var requestEndpoint: String {
        switch self {
        case .createToken:
            return "/tokens"
        case .checkToken(let token):
            return "/tokens/\(token)"
        case .getCurrentSubscription, .createSubscription, .cancelSubscription:
            return "/subscription"
        case .checkSubscription: // Docs: POST request, PUT has been deprecated
            return "/subscription/check"
        case .subscriptionLatest:
            return "/subscription/latest"
        case .changeRenewSubscription:
            return "/subscription/renew"
        case .paymentStatus(let vendor):
            return "/status/\(vendor.rawValue)"
        case .legacyAppleStatus:
            return "/status/apple"
        case .appleStatus:
            return "/status/apple"
        case .availablePlans:
            return "/plans"
        case .icon(let iconName):
            return "/resources/icons/\(iconName)"
        case .userTransactionUUID:
            return "/sessions/uuid"
        }
    }

    var body: [String: Any]? {
        switch self {
        case .createToken(let body):
            return body.toDictionary()
        case .checkToken:
            return nil
        case .getCurrentSubscription:
            return nil
        case .createSubscription(let newSub):
            return newSub.newSubscription.toDictionary() // This is required because NewSubscription is a Composed struct
        case .cancelSubscription(let subscription):
            return subscription.toDictionary()
        case .checkSubscription(let subscription):
            return subscription.toDictionary()
        case .subscriptionLatest:
            return nil
        case .changeRenewSubscription(let renew):
            return renew.toDictionary()
        case .paymentStatus:
            return nil
        case .legacyAppleStatus:
            return nil
        case .appleStatus:
            return nil
        case .availablePlans:
            return nil
        case .icon:
            return nil
        case .userTransactionUUID:
            return nil
        }
    }

    var queryComponents: [URLQueryItem]? {
        switch self {
        case .createToken:
            return nil
        case .checkToken:
            return nil
        case .getCurrentSubscription:
            return nil
        case .createSubscription:
            return nil
        case .cancelSubscription:
            return nil
        case .checkSubscription:
            return nil
        case .subscriptionLatest:
            return nil
        case .changeRenewSubscription:
            return nil
        case .paymentStatus:
            return nil
        case .legacyAppleStatus:
            return nil
        case .appleStatus:
            return nil
        case .availablePlans(let currency, let vendor, let state, let timestamp):
            let queryParams: [String: Any?] = ["currency": currency,
                                               "vendor": vendor,
                                               "timestamp": timestamp,
                                               "state": state]

            return generateQueryParameters(parameters: queryParams)
        case .icon:
            return nil
        case .userTransactionUUID:
            return nil
        }
    }

    private func generateURLComponents(string: String) -> URLComponents? {

        guard let components = URLComponents(string: string) else {
            return nil
        }

        return components
    }

    private func generateQueryParameters(parameters: [String: Any?]) -> [URLQueryItem]? {

        var queryItems: [URLQueryItem] = []
        // the dictionary is sorted to allow testing the generated url
        parameters.sorted(by: { $0.0 < $1.0 }).forEach { key, value in
            if let value = value {
                queryItems.append(URLQueryItem(name: key.capitalizedFirst, value: String(describing: value)))
            }
        }

        return queryItems.isEmpty ? nil : queryItems
    }
}
