//
//  Created on 30/4/24.
//
//  Copyright (c) 2024 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import Foundation
import AuthenticationServices
import ProtonCoreAuthentication
import ProtonCoreLog
import ProtonCoreLogin

@available(iOS 15.0, macOS 12.0, *)
public class Fido2ViewModel: NSObject, ObservableObject {

    var state: Fido2ViewModelState = .initial
    @Published var isLoading = false
    weak var delegate: TwoFactorViewControllerDelegate?

    #if DEBUG
    static var initial: Fido2ViewModel = .init()
    #endif

    override private init() { }

    public init(login: Login, challenge: Data, relyingPartyIdentifier: String, allowedCredentialIds: [Data]) {
        self.state = .configured(login: login,
                                 challenge: challenge,
                                 relyingPartyIdentifier: relyingPartyIdentifier,
                                 allowedCredentials: allowedCredentialIds.map {
            ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: $0,
                                                                    transports: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported)
                                 }
        )
    }

    func startSignature() {
        guard case let .configured(_, challenge, relyingPartyIdentifier, allowedCredentials) = state else { return }

        let provider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        request.allowedCredentials = allowedCredentials
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func provideFido2Signature(_ signature: Fido2Signature) {
        guard case let .configured(login, _, _, _) = state else { return }

        isLoading = true
        login.provideFido2Signature(signature) { [weak self] result in
            switch result {
            case let .success(status):
                switch status {
                case let .finished(data):
                    self?.delegate?.twoFactorViewControllerDidFinish(data: data) { [weak self] in
                        self?.isLoading = false
                    }
                case let .chooseInternalUsernameAndCreateInternalAddress(data):
                    login.availableUsernameForExternalAccountEmail(email: data.email) { [weak self] username in
                        self?.delegate?.createAddressNeeded(data: data, defaultUsername: username)
                        self?.isLoading = false
                    }
                case .ask2FA, .askFIDO2:
                    PMLog.error("Asking for 2FA validation after successful 2FA validation is an invalid state", sendToExternal: true)
                    self?.isLoading = false
                    // TODO: CP-7953
                case .askSecondPassword:
                    self?.delegate?.mailboxPasswordNeeded()
                    self?.isLoading = false
                case .ssoChallenge:
                    PMLog.error("Receiving SSO challenge after successful 2FA code is an invalid state", sendToExternal: true)
                    self?.isLoading = false
                    // TODO: CP-7953
                }
            case .failure:
                // TODO: CP-7953
                self?.isLoading = false
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2ViewModel: ASAuthorizationControllerDelegate {

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentialAssertion as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let signature = Fido2Signature(credentialAssertion: credentialAssertion)
            provideFido2Signature(signature)
        default:
            PMLog.error("Received unknown authorization type.")
            // TODO: CP-7953
        }
    }
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // TODO: CP-7953
        print(error)
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2ViewModel: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2Signature {
    init(credentialAssertion: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) {
        self = .init(signature: credentialAssertion.signature,
                     credentialID: credentialAssertion.credentialID,
                     authenticatorData: credentialAssertion.rawAuthenticatorData,
                     clientData: credentialAssertion.rawClientDataJSON)
    }
}

@available(iOS 15.0, macOS 12.0, *)
enum Fido2ViewModelState {
    case initial
    case configured(login: Login, challenge: Data, relyingPartyIdentifier: String, allowedCredentials: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor])
}

#endif
