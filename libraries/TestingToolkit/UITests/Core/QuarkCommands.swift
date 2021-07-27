//
//  QuarkCommands.swift
//  ProtonCore-TestingToolkit-UITests-Core - Created on 23.07.21.
//
//  Copyright (c) 2021 Proton Technologies AG
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
import Crypto
import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Payments
import ProtonCore_Services

public final class QuarkCommands {
    private let serviceManager = AnonymousServiceManager()
    private let sessionUID = "PaymentsUITestsSessionId"
    private let doh: DoH & ServerConfig
    
    public init(doh: DoH & ServerConfig) {
        self.doh = doh
    }
    
    public func createUser(username: String, password: String, plan: AccountPlan = .free, completion: ((Result<(), Error>) -> Void)? = nil) {
        let route = CreateUser(username: username, password: password, plan: plan)
        executeCommand(route: route, completion: completion)
    }
    
    public func unban(completion: ((Result<(), Error>) -> Void)? = nil) {
        let route = UnbanRequest()
        executeCommand(route: route, completion: completion)
    }
    
    private func executeCommand(route: Request, completion: ((Result<(), Error>) -> Void)? = nil) {
        PMAPIService.noTrustKit = true
        let apiService = PMAPIService(doh: doh, sessionUID: sessionUID)
        apiService.serviceDelegate = serviceManager
        apiService.exec(route: route) { _, response in
            if response.httpCode == 200 {
                completion?(.success(()))
            } else {
                completion?(.failure(response.error!))
            }
        }
    }

    class CreateUser: QuarkRequestProtocol {
        let username: String
        let password: String
        let plan: AccountPlan
        
        init(username: String, password: String, plan: AccountPlan = .free) {
            self.username = username
            self.password = password
            self.plan = plan
        }
        
        var path: String {
            if plan == .free {
                return "/internal/quark/user:create?-N=\(username)&-p=\(password)"
            } else {
                return "/internal/quark/payments:seed-delinquent?username=\(username)&password=\(password)&plan=\(plan.rawValue)&cycle=12"
            }
        }
    }
    
    class UnbanRequest: QuarkRequestProtocol {
        var path: String {
            return "/internal/quark/jail:unban"
        }
    }
    
    class AnonymousServiceManager: APIServiceDelegate {
        var locale: String { return "en_US" }
        var appVersion: String = "WebDrive_1.0.0"
        var userAgent: String?
        func onUpdate(serverTime: Int64) {
            CryptoUpdateTime(serverTime)
        }
        func isReachable() -> Bool { return true }
        func onDohTroubleshot() { }
        func onHumanVerify() { }
        func onChallenge(challenge: URLAuthenticationChallenge, credential: AutoreleasingUnsafeMutablePointer<URLCredential?>?) -> URLSession.AuthChallengeDisposition {
            let dispositionToReturn: URLSession.AuthChallengeDisposition = .performDefaultHandling
            return dispositionToReturn
        }
    }
}

protocol QuarkRequestProtocol: Request { }

extension QuarkRequestProtocol {
    var isAuth: Bool {
        return false
    }
}
