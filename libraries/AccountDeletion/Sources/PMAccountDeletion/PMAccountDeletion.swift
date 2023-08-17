//
//  PMAccountDeletion.swift
//  ProtonCore-AccountDeletion - Created on 20.01.22.
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

import UIKit
import PMUIFoundations
import PMAuthentication
import PMCommon
import TrustKit

public struct PMAccountDeletionConfiguration {
    
    let accountHost: String
    let accountHeaders: [String: String]
    let backImage: UIImage?
    let closeImage: UIImage?
    
    var deleteAccountWebviewTitle: String
    var accountDeletionSucceddedMessage: String
    var genericNetworkError: String
    var genericNetworkErrorBannerCloseButton: String

    public init(accountHost: String,
                accountHeaders: [String: String],
                backImage: UIImage?,
                closeImage: UIImage?,
                deleteAccountWebviewTitle: String,
                accountDeletionSucceddedMessage: String,
                genericNetworkError: String,
                genericNetworkErrorBannerCloseButton: String) {
        self.accountHost = accountHost
        self.accountHeaders = accountHeaders
        self.backImage = backImage
        self.closeImage = closeImage
        self.deleteAccountWebviewTitle = deleteAccountWebviewTitle
        self.accountDeletionSucceddedMessage = accountDeletionSucceddedMessage
        self.genericNetworkError = genericNetworkError
        self.genericNetworkErrorBannerCloseButton = genericNetworkErrorBannerCloseButton
    }
    
}

private var pmAccountDeletionConfiguration: PMAccountDeletionConfiguration! = nil

extension AccountDeletionService {
    
    public convenience init(api: APIService, configuration: PMAccountDeletionConfiguration) {
        pmAccountDeletionConfiguration = configuration
        self.init(api: api, doh: api.doh as! (DoH & ServerConfig))
    }
}

public extension AuthErrors {
    var userFacingMessageInNetworking: String {
        return localizedDescription
    }
}

extension LocalizedString {
    var delete_account_title: String { pmAccountDeletionConfiguration.deleteAccountWebviewTitle }
    var delete_network_error: String { pmAccountDeletionConfiguration.genericNetworkError }
    var delete_account_success: String { pmAccountDeletionConfiguration.accountDeletionSucceddedMessage }
    var delete_close_button: String { pmAccountDeletionConfiguration.genericNetworkErrorBannerCloseButton }
}

extension UIImage {
    static var backImage: UIImage? { pmAccountDeletionConfiguration.backImage }
    static var closeImage: UIImage? { pmAccountDeletionConfiguration.closeImage }
}

extension AuthService {
    public struct ForkSessionResponse: Codable, Equatable {
        public let code: Int
        public let selector: String
    }
    
    struct ForkSessionEndpoint: Request {

        var path: String {
            return "/auth/v4/sessions/forks"
        }
        
        var method: HTTPMethod {
            return .post
        }
        var parameters: [String: Any]? { [
            "ChildClientID": "WebAccountLite",
            "Independent": 1,
        ] }
      
        var isAuth: Bool {
            return true
        }
        
        var authRetry: Bool {
            return false
        }
        
        var authCredential: AuthCredential?
        
        init(auth: AuthCredential?) {
            self.authCredential = auth
        }
    }
}

extension Authenticator {
    public func forkSession(_ credential: Credential, completion: @escaping (Result<AuthService.ForkSessionResponse, AuthErrors>) -> Void) {
        let route = AuthService.ForkSessionEndpoint(auth: AuthCredential(credential))
        self.apiService.exec(route: route) { (result: Result<AuthService.ForkSessionResponse, Error>) in
            completion(result.mapError { $0 as NSError }.mapError(AuthErrors.serverError))
        }
    }
}

extension DoH {
    
    public func getAccountHost() -> String {
        pmAccountDeletionConfiguration.accountHost
    }
    
    public func getAccountHeaders() -> [String: String] {
        pmAccountDeletionConfiguration.accountHeaders
    }
    
    public func handleErrorResolvingProxyDomainIfNeeded(
        host: String, error: Error?,
        callCompletionBlockOn possibleCompletionBlock: DispatchQueue? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard let possibleCompletionBlock = possibleCompletionBlock else {
            completion(false)
            return
        }
        possibleCompletionBlock.async {
            completion(false)
        }
    }
}

public func handleAuthenticationChallenge(
    didReceive challenge: URLAuthenticationChallenge,
    noTrustKit: Bool,
    trustKit: TrustKit?,
    challengeCompletionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void,
    trustKitCompletionHandler: @escaping(URLSession.AuthChallengeDisposition,
                                         URLCredential?, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void = { disposition, credential, completionHandler in completionHandler(disposition, credential) }
) {
    if noTrustKit {
        guard let trust = challenge.protectionSpace.serverTrust else {
            challengeCompletionHandler(.performDefaultHandling, nil)
            return
        }
        let credential = URLCredential(trust: trust)
        challengeCompletionHandler(.useCredential, credential)
        
    } else if let tk = trustKit {
        let wrappedCompletionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void = { disposition, credential in
            trustKitCompletionHandler(disposition, credential, challengeCompletionHandler)
        }
        guard tk.pinningValidator.handle(challenge, completionHandler: wrappedCompletionHandler) else {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            challengeCompletionHandler(.performDefaultHandling, nil)
            return
        }
        
    } else {
        assertionFailure("TrustKit not initialized correctly")
        challengeCompletionHandler(.performDefaultHandling, nil)
        
    }
}
