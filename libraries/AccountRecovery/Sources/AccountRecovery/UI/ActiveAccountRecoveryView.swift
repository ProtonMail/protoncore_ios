//
//  Created on 4/7/23.
//
//  Copyright (c) 2023 Proton AG
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
import SwiftUI
import ProtonCoreUIFoundations

/// View shown for the Grace period state of the **Account Recovery** process
public struct ActiveAccountRecoveryView: View {

    @StateObject var viewModel: AccountRecoveryView.ViewModel
    @State var isAnimating: Bool = false

    public var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top, spacing: 10) {
                IconProvider.exclamationCircle
                Text(key1,
                     bundle: AccountRecoveryModule.resourceBundle,
                     comment: "Grace period intro, with interpolated email, and in bold")
            }
            HStack(spacing: 12) {
                Image(AccountRecovery.ImageNames.passwordResetLockClock,
                      bundle: AccountRecoveryModule.resourceBundle)
                VStack(alignment: .leading) {
                    Text("Password reset requested", comment: "heading for callout block")
                        .font(.title3)
                        .foregroundColor(ColorProvider.TextNorm)
                    Text("You can change your password in \(viewModel.remainingTime.asRemainingTimeString()).")
                }
            }
            .padding(12)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(ColorProvider.BackgroundNorm)
            .cornerRadius(12)

            Text("To make sure it's really you trying to reset your password, we wait \(viewModel.remainingTime.asRemainingTimeString()) before approving requests.")

            Text(key2)

                Button {
                    isAnimating.toggle()
                    Task { @MainActor in
                        await viewModel.cancelPressed()
                        isAnimating.toggle()
                    }
                } label: {
                    ZStack(alignment: .trailing) {
                        Text(ARTranslation.graceViewCancelButtonCTA.l10n)
                            .frame(maxWidth: .infinity)

                        if isAnimating {
                            ProgressView()
                                .padding(.trailing, 16)
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 48)
                }
                .buttonStyle(SolidButton())
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
        }
        .foregroundColor(ColorProvider.TextWeak)
            .padding(16)
            .frame(maxHeight: .infinity)
            .background(ColorProvider.BackgroundDeep)
    }

    let title = ARTranslation.graceViewTitle.l10n


    var key1: LocalizedStringKey { 
        var key = "We received a password reset request for **\(viewModel.email)**."
        if #unavailable(iOS 15) {
            key = key
                .replacingOccurrences(of: "**", with: "")
        }
        return LocalizedStringKey(key)
    }

    var key2: LocalizedStringKey {
        var key = "If you didn't ask to reset your password, **cancel this request now**."
        if #unavailable(iOS 15) {
            key = key
                .replacingOccurrences(of: "**", with: "")
        }
        return LocalizedStringKey(key)
    }

    public init(viewModel: AccountRecoveryView.ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private func makeKeyDroppingMarkdownIfNeeded(_ value: String) -> LocalizedStringKey {
        LocalizedStringKey(value)
    }
}

#if DEBUG
struct ActiveAccountRecoveryView_Previews: PreviewProvider {
    static var viewModel = {
        let vm = AccountRecoveryView.ViewModel()
        vm.email = "norbert@example.com"
        vm.remainingTime = 3600 * 72
        vm.state = .grace
        return vm
    }()

    static var previews: some View {
        ActiveAccountRecoveryView(viewModel: Self.viewModel)
    }
}
#endif
#endif
