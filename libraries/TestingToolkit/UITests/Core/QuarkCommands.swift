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

import ProtonCore_Doh
import ProtonCore_Networking
import ProtonCore_Services

public final class QuarkCommands {
    private let serviceManager = AnonymousServiceManager()
    private let sessionUID = "PaymentsUITestsSessionId"
    private let doh: DoH & ServerConfig
    
    public init(doh: DoH & ServerConfig) {
        self.doh = doh
    }
    
    public func createUser(
        username: String, password: String, protonPlanName: String, completion: ((Result<(), Error>) -> Void)? = nil
    ) {
        let route = CreateUser(username: username, password: password, protonPlanName: protonPlanName)
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
        let protonPlanName: String
        
        init(username: String, password: String, protonPlanName: String) {
            self.username = username
            self.password = password
            self.protonPlanName = protonPlanName
        }
        
        var path: String {
            if protonPlanName == "free" {
                return "/internal/quark/user:create?-N=\(username)&-p=\(password)&-k=RSA2048"
            } else {
                return "/internal/quark/payments:seed-delinquent?username=\(username)&password=\(password)&plan=\(protonPlanName)&cycle=12"
            }
        }
    }
    
    class UnbanRequest: QuarkRequestProtocol {
        var path: String {
            return "/internal/quark/jail:unban"
        }
    }
    
    class AnonymousServiceManager: APIServiceDelegate {
        var locale: String { Locale.autoupdatingCurrent.identifier }
        var appVersion: String = "WebDrive_1.0.0"
        var userAgent: String?
        func onUpdate(serverTime: Int64) {}
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
