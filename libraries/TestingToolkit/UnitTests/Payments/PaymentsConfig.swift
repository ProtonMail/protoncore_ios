//
//  PaymentsConfig.swift
//  ProtonCore-TestingToolkit - Created on 03.06.2021.
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

import ProtonCore_Doh
import ProtonCore_Log
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Payments

class TestDoHMail: DoH, ServerConfig {
    var defaultHost: String = "https://test.xyz"
    var captchaHost: String = "https://test.xyz"
    var humanVerificationV3Host: String = "https://verify.test.xyz"
    var accountHost: String = "https://account.test.xyz"
    var apiHost: String = "abcabcabcabcabcabcabcabcabcabcabcabc.xyz"
    var defaultPath: String = "/api"
    var signupDomain: String = "test.xyz"
    static let `default` = TestDoHMail()
}

class TestAuthDelegate: AuthDelegate {
    func authCredential(sessionUID _: String) -> AuthCredential? {
        return AuthCredential(sessionID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date().addingTimeInterval(60 * 60), userName: "userName", userID: "userID", privateKey: nil, passwordKeySalt: nil)
    }
    func credential(sessionUID _: String) -> Credential? {
        Credential.init(UID: "sessionID", accessToken: "accessToken", refreshToken: "refreshToken", expiration: Date().addingTimeInterval(60 * 60), userName: "userName", userID: "userID", scope: [])
    }
    func onLogout(sessionUID uid: String) { }
    func onUpdate(credential: Credential, sessionUID: String) { }
    func onRefresh(sessionUID: String, service: APIService, complete: @escaping AuthRefreshResultCompletion) { }
}

class TestAPIServiceDelegate: APIServiceDelegate {
    var locale: String { return "en_US" }
    func isReachable() -> Bool { return true }
    var userAgent: String? { return "" }
    var additionalHeaders: [String: String]?
    func onUpdate(serverTime: Int64) { }
    var appVersion: String { return "iOS_1.12.0" }
    func onDohTroubleshot() {
        // swiftlint:disable no_print
        PMLog.info("\(#file): \(#function)")
    }
}

class TestStoreKitManagerDelegate: StoreKitManagerDelegate {
    let api: APIService
    let paymentTokenStorage: PaymentTokenStorage
    let servicePlan: ServicePlanDataServiceProtocol
    var _productIds: Set<String> = Set()
    var _isUnlocked: Bool = true
    var _isSignedIn: Bool = true
    var _activeUsername: String?
    var _userId: String?
    
    init (api: APIService, tokenStorage: PaymentTokenStorage, servicePlanDataService: ServicePlanDataServiceProtocol) {
        self.api = api
        self.paymentTokenStorage = tokenStorage
        self.servicePlan = servicePlanDataService
    }
    var apiService: APIService? { return api }
    var productIds: Set<String> { return _productIds }
    var tokenStorage: PaymentTokenStorage? { return paymentTokenStorage }
    var isUnlocked: Bool { return _isUnlocked }
    var isSignedIn: Bool { return _isSignedIn }
    var activeUsername: String? { return _activeUsername }
    var userId: String? { return _userId }
    var servicePlanDataService: ServicePlanDataServiceProtocol? { return servicePlan }
}

class TokenStorage: PaymentTokenStorage {
    public static var `default` = TokenStorage()
    var token: PaymentToken?
    
    func add(_ token: PaymentToken) { self.token = token }
    func get() -> PaymentToken? { return token }
    func clear() { self.token = nil }
}

class UserCachedStatus: ServicePlanDataStorage {
    var servicePlansDetails: [Plan]?
    var defaultPlanDetails: Plan?
    var currentSubscription: Subscription?
    var paymentsBackendStatusAcceptsIAP: Bool = true
    var credits: Credits?
    var paymentMethods: [PaymentMethod]?
}
