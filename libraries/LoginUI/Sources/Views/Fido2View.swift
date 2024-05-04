//
//  Fido2View.swift
//  ProtonCore-Login - Created on 30/04/2024.
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

#if os(iOS)

import SwiftUI
import ProtonCoreUIFoundations

@available(iOS 15.0, *)
public struct Fido2View: View {
    var viewModel: Fido2ViewModel

    public var body: some View {
        VStack {
            Text("Insert a security key linked to your Proton Account.")
            Link("Learn more", destination: URL(string: "https://proton.me/support/two-factor-authentication-2fa")!)
            Spacer()
            PCButton(
                style: .constant(.init(mode: .solid)),
                content: .constant(.init(
                    title: "Authenticate",
                    isEnabled: true,
                    isAnimating: false,
                    action: { viewModel.startSignature() })
                )
            )
        }.padding(10)
    }
}

#Preview {
    if #available(iOS 15.0, *) {
       return Fido2View(viewModel: Fido2ViewModel(challenge: Data([1, 2, 3]),
                                            relyingPartyIdentifier: "proton.me",
                                                 allowedCredentialIds: []))
    } else {
        return Text("🦖 This view is not available for iOS versions < 15.0")
    }
}

#endif