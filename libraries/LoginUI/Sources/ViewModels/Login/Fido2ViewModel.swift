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
import ProtonCoreUIFoundations
import ProtonCoreServices

@available(iOS 15.0, macOS 12.0, *)
extension Fido2View {

    public class ViewModel: NSObject, ObservableObject {

        var state: Fido2ViewModelState = .initial
        @Published var isLoading = false
        @Published var bannerState: BannerState = .none
        public weak var delegate: TwoFAProviderDelegate?

#if DEBUG
        static var initial: ViewModel = .init()
#endif

        override private init() { }

        public init(authenticationOptions: AuthenticationOptions) {
            self.state = .configured(authenticationOptions: authenticationOptions)
        }

        func startSignature() {
            guard case let .configured(authenticationOptions) = state else { return }

            let controller = makeAuthController(relyingPartyIdentifier: authenticationOptions.relyingPartyIdentifier,
                                                challenge: authenticationOptions.challenge,
                                                allowedCredentials: authenticationOptions.allowedCredentialIds.map {
                ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(
                    credentialID: $0,
                    transports: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
                )
                                                }
            )
            controller.performRequests()
        }

        private func makeAuthController(relyingPartyIdentifier: String,
                                        challenge: Data,
                                        allowedCredentials: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor]) -> ASAuthorizationController {
            let provider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)

            let request = provider.createCredentialAssertionRequest(challenge: challenge)
            request.allowedCredentials = allowedCredentials

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.presentationContextProvider = self
            controller.delegate = self
            return controller
        }

        func provideFido2Signature(_ signature: Fido2Signature) {
            isLoading = true
            Task {
                do {
                    try await delegate?.providerDidObtain(factor: signature)
                    // We don't update isLoading here, it would be too early as
                    // there are still some requests working to fetch the UserData
                } catch {
                    await MainActor.run {
                        isLoading = false
                        bannerState = .error(content: .init(message: error.localizedDescription))
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2View.ViewModel: ASAuthorizationControllerDelegate {

    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentialAssertion as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            if case .configured(let authenticationOptions) = state {
                provideFido2Signature(Fido2Signature(credentialAssertion: credentialAssertion, authenticationOptions: authenticationOptions))
            } else {
                PMLog.error("Invalid state: received a signature for which we don't keep the challenge")
                bannerState = .error(content: .init(message: "Unexpected FIDO2 signature"))
            }
        default:
            PMLog.error("Received unknown authorization type: \(authorization.credential)", sendToExternal: true)
            bannerState = .error(content: .init(message: LUITranslation.twofa_unexpected_authorization_type.l10n))
        }
    }

    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        PMLog.error("Secure Key authorization failed with error: \(error.localizedDescription)", sendToExternal: true)
        guard let authorizationError = error as? ASAuthorizationError,
              authorizationError.code != .canceled else {
            // do nothing, it's user caused
            return
        }
        bannerState = .error(content: .init(message: error.localizedDescription))
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2View.ViewModel: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2Signature {
    init(credentialAssertion: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion, authenticationOptions: AuthenticationOptions) {
        self = .init(signature: credentialAssertion.signature,
                     credentialID: credentialAssertion.credentialID,
                     authenticatorData: credentialAssertion.rawAuthenticatorData,
                     clientData: credentialAssertion.rawClientDataJSON,
                     authenticationOptions: authenticationOptions)
    }
}

@available(iOS 15.0, macOS 12.0, *)
enum Fido2ViewModelState {
    case initial
    case configured(authenticationOptions: AuthenticationOptions)

}

#endif
