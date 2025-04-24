//
//  SignInService.swift
//  ProtonCore-Login - Created on 05/11/2020.
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

import Foundation
import ProtonCoreAPIClient
import ProtonCoreAuthentication
import ProtonCoreAuthenticationKeyGeneration
import ProtonCoreDataModel
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreFeatureFlags
import ProtonCoreCrypto

public final class LoginService {

    public typealias AuthenticationManager = AuthenticatorInterface & AuthenticatorKeyGenerationInterface

    // MARK: - Properties

    let apiService: APIService
    var sessionId: String { apiService.sessionUID }
    let clientApp: ClientApp
    let authManager: AuthenticationManager
    var totpContext: TOTPContext?
    var fido2Context: FIDO2Context?
    var mailboxPassword: String?
    public private(set) var minimumAccountType: AccountType
    var username: String?

    let featureFlagsRepository: FeatureFlagsRepositoryProtocol

    var defaultSignUpDomain = "proton.me"
    var updatedSignUpDomains: [String]?
    var chosenSignUpDomain: String?
    public var currentlyChosenSignUpDomain: String {
        get {
            chosenSignUpDomain ?? updatedSignUpDomains?.first ?? defaultSignUpDomain
        }
        set {
            if allSignUpDomains.contains(newValue) {
                chosenSignUpDomain = newValue
            }
        }
    }
    public var allSignUpDomains: [String] {
        return updatedSignUpDomains ?? [defaultSignUpDomain]
    }
    public var startGeneratingAddress: (() -> Void)?
    public var startGeneratingKeys: (() -> Void)?

    public var ssoCallbackScheme: String?

    public init(api: APIService,
                clientApp: ClientApp,
                minimumAccountType: AccountType,
                authenticator: AuthenticationManager? = nil,
                featureFlagsRepository: FeatureFlagsRepositoryProtocol = FeatureFlagsRepository.shared,
                ssoCallbackScheme: String? = nil) {
        self.apiService = api
        self.minimumAccountType = minimumAccountType
        self.clientApp = clientApp
        self.featureFlagsRepository = featureFlagsRepository
        self.ssoCallbackScheme = ssoCallbackScheme
        authManager = authenticator ?? Authenticator(api: api)

    }

    // MARK: - Configuration

    public func updateAccountType(accountType: AccountType) {
        minimumAccountType = accountType
    }

    public func updateAllAvailableDomains(type: AvailableDomainsType, result: @escaping ([String]?) -> Void) {
        updatedSignUpDomains = nil
        availableDomains(type: type) { res in
            switch res {
            case .success(let domains):
                self.updatedSignUpDomains = domains
                result(domains)
            case .failure:
                self.updatedSignUpDomains = nil
                result(nil)
            }
        }
    }

    private func availableDomains(type: AvailableDomainsType, completion: @escaping (Result<([String]), LoginError>) -> Void) {
        let route = AvailableDomainsRequest(type: type)

        apiService.perform(request: route) { (_, result: Result<AvailableDomainResponse, ResponseError>) in
            switch result {
            case .failure(let error):
                completion(.failure(LoginError.generic(message: error.localizedDescription,
                                                       code: error.bestShotAtReasonableErrorCode,
                                                       originalError: error)))
            case .success(let response):
                completion(.success(response.domains))
            }
        }
    }

    public func refreshCredentials(completion: @escaping (Result<Credential, LoginError>) -> Void) {
        withAuthDelegateAvailable(completion) { authDelegate in
            guard let old = authDelegate.credential(sessionUID: self.sessionId) else {
                completion(.failure(.invalidState))
                return
            }
            authManager.refreshCredential(old) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error.asLoginError()))
                case .success(.askTOTP), .success(.ssoChallenge), .success(.askFIDO2), .success(.askAny2FA):
                    completion(.failure(.invalidState))
                case .success(.newCredential(let credential, _)), .success(.updatedCredential(let credential)), .success(.credentialLess(let credential)):
                    authDelegate.onUpdate(credential: credential, sessionUID: self.sessionId)
                    self.apiService.setSessionUID(uid: credential.UID)
                    completion(.success(credential))
                }
            }
        }
    }

    public func refreshCredentials() async throws -> Credential {
        guard let authDelegate = apiService.authDelegate,
              let oldCredential = authDelegate.credential(sessionUID: self.sessionId) else {
            throw LoginError.invalidState
        }
        let credential = try await authManager.refreshCredential(oldCredential)
        authDelegate.onUpdate(credential: credential, sessionUID: self.sessionId)
        apiService.setSessionUID(uid: credential.UID)
        return credential
    }

    public func refreshUserInfo(completion: @escaping (Result<User, LoginError>) -> Void) {
        withAuthDelegateAvailable(completion) { authDelegate in
            guard let credential = authDelegate.credential(sessionUID: sessionId) else {
                completion(.failure(.invalidState))
                return
            }
            authManager.getUserInfo(credential) {
                completion($0.mapError { $0.asLoginError() })
            }
        }
    }

    public func refreshUserData(backupPassword: String) async throws -> UserData {
        let credential = try await refreshCredentials()
        let user = try await authManager.getUserInfo()
        let addresses = try await authManager.getAddresses()
        let keySalts = try await authManager.getKeySalts()

        let passphrases = try BuildAndValidatePassphrases().buildPassphrases(
            salts: keySalts,
            mailboxPassword: backupPassword
        )

        return UserData(
            credential: .init(credential),
            user: user,
            salts: keySalts,
            passphrases: passphrases,
            addresses: addresses,
            scopes: credential.scopes
        )
    }

    // MARK: - Data gathering entry point

    func handleValidCredentials(credential: Credential, passwordMode: PasswordMode, mailboxPassword: String?, isSSO: Bool = false) async -> Result<LoginStatus, LoginError> {
        await withCheckedContinuation { continuation in
            self.handleValidCredentials(credential: credential, passwordMode: passwordMode, mailboxPassword: mailboxPassword, isSSO: isSSO) { result in
                continuation.resume(returning: result)
            }
        }
    }

    func handleValidCredentials(credential: Credential, passwordMode: PasswordMode, mailboxPassword: String?, isSSO: Bool = false, completion: @escaping (Result<LoginStatus, LoginError>) -> Void) {
        self.mailboxPassword = mailboxPassword
        withAuthDelegateAvailable(completion) { authDelegate in
            authDelegate.onSessionObtaining(credential: credential)
            self.apiService.setSessionUID(uid: credential.UID)

            authManager.getUserInfo { [weak self] result in
                guard let self else {
                    completion(.failure(LoginError.invalidState))
                    return
                }
                switch result {
                case .success(let user):
                    self.featureFlagsRepository.setApiService(self.apiService)

                    if !user.ID.isEmpty {
                        self.featureFlagsRepository.setUserId(user.ID)
                    }

                    Task {
                        try await self.featureFlagsRepository.fetchFlags()
                    }

                    if isSSO {
                        // TODO: Will be removed as part of GSSO
                        var ssoCredential = credential
                        ssoCredential.userName = user.name ?? ""
                        completion(.success(.finished(UserData(credential: .init(ssoCredential), user: user, salts: [], passphrases: [:], addresses: [], scopes: credential.scopes))))
                        return
                    }

                    /// There are accounts that are in 2 password mode, but don't effectively require a second password.
                    /// This is because those accounts have no keys (so key password = NULL != account password).
                    /// An example of accounts that happen to behave like this are the `accountType = .username` ones.
                    if passwordMode == .two && !user.keys.isEmpty && minimumAccountType != .username {
                        completion(.success(.askSecondPassword))
                        return
                    }

                    PMLog.debug("No mailbox password required, finishing up")
                    guard let mailboxPassword = mailboxPassword else {
                        completion(.failure(.invalidState))
                        return
                    }
                    self.getAccountDataPerformingAccountMigrationIfNeeded(
                        user: user, mailboxPassword: mailboxPassword, passwordMode: passwordMode, completion: completion
                    )
                case let .failure(error):
                    PMLog.error("Getting user info failed with \(error)", sendToExternal: true)
                    completion(.failure(error.asLoginError()))
                }
            }
        }
    }

    func handleSSOCredentials(credential: Credential, passwordMode: PasswordMode) async throws -> LoginStatus {
        guard let authDelegate = apiService.authDelegate else { throw LoginError.invalidState }
        authDelegate.onSessionObtaining(credential: credential)
        self.apiService.setSessionUID(uid: credential.UID)

        async let userResult = authManager.getUserInfo()
        async let addressesResult = authManager.getAddresses()
        async let keySaltsResult = authManager.getKeySalts()
        let (user, addresses, keySalts) = try await (userResult, addressesResult, keySaltsResult)

        var ssoCredential = credential
        ssoCredential.userName = user.name ?? ""

        return .finished(UserData(
            credential: .init(ssoCredential),
            user: user,
            salts: keySalts,
            passphrases: [:],
            addresses: addresses,
            scopes: credential.scopes
        ))
    }

    func handleForkedSessionCredentials(credential: Credential) async throws -> LoginStatus {
        guard let authDelegate = apiService.authDelegate else { throw LoginError.invalidState }
        authDelegate.onSessionObtaining(credential: credential)
        self.apiService.setSessionUID(uid: credential.UID)
        
        async let userResult = authManager.getUserInfo()
        async let addressesResult = authManager.getAddresses()
        let (user, addresses) = try await (userResult, addressesResult)
        
        // Verify the keys - make sure the keys are active and that they can be unlocked
        // DOC: https://protonag.atlassian.net/wiki/spaces/API/pages/55609920/Authentication+sessions+and+tokens#Getting-keys
        // "test that all the keys that have the property active = 1 can successfully decrypt according to the schema"
        let keyRingBuilder = KeyRingBuilder()
        let keys = (user.keys + addresses.toKeys())
            .filter({ $0.active ==  1 })

        _ = try keyRingBuilder.buildPrivateKeyRingUnlock(
            privateKeys: keys.map({ DecryptionKey(privateKey: ArmoredKey(value: $0.privateKey), passphrase: Passphrase(value: credential.mailboxPassword))})
        )

        var forkedCredential = credential
        forkedCredential.userName = user.name ?? user.email ?? ""
        forkedCredential.userID = user.ID

        let hasOnlyExternalAddresses = addresses.count > 0 && addresses.allSatisfy({ $0.isExternal })
        let hasNoAddresses = addresses.count == 0

        if (hasOnlyExternalAddresses || hasNoAddresses) && self.minimumAccountType == .internal {
            // We don't support the case when an external user / username user needs an internal address to use this client.
            // We would need to create a new custom flow to handle this case.
            throw LoginError.invalidState
        }

        return .finished(UserData(
            credential: .init(forkedCredential),
            user: user,
            salts: [],
            passphrases: [:],
            addresses: addresses,
            scopes: credential.scopes
        ))
    }

    func withAuthDelegateAvailable<T>(_ completion: (Result<T, LoginError>) -> Void, continuation: (AuthDelegate) -> Void) {
        guard let authDelegate = apiService.authDelegate else {
            completion(.failure(.invalidState))
            return
        }
        continuation(authDelegate)
    }
}
