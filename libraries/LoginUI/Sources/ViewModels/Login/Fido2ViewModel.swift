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

import Foundation
import AuthenticationServices

@available(iOS 15.0, macOS 12.0, *)
public class Fido2ViewModel: NSObject {
    let challenge: Data
    let relyingPartyIdentifier: String
    let allowedCredentials: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor]

    public init(challenge: Data, relyingPartyIdentifier: String, allowedCredentialIds: [Data]) {
        self.challenge = challenge
        self.relyingPartyIdentifier = relyingPartyIdentifier
        self.allowedCredentials = allowedCredentialIds.map {
            ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: $0,
                                                                    transports: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
            )
        }
    }

    func startSignature() {
        let provider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        request.allowedCredentials = allowedCredentials
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Fido2ViewModel: ASAuthorizationControllerDelegate {

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // TODO: CP-7952
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
