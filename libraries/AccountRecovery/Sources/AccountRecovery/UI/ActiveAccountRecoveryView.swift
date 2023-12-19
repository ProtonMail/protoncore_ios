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
@available(iOS 15, *)
public struct ActiveAccountRecoveryView: View {

    @StateObject var viewModel: AccountRecoveryView.ViewModel
    @State var isAnimating: Bool = false

    public var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top, spacing: 10) {
                IconProvider.exclamationCircle
                Text("We received a password reset request for **\(viewModel.email)**.",
                     bundle: AccountRecoveryModule.resourceBundle,
                     comment: "Grace period intro, with interpolated email")
            }
            HStack(spacing: 12) {
                Image(AccountRecovery.ImageNames.passwordResetLockClock,
                      bundle: AccountRecoveryModule.resourceBundle)
                VStack(alignment: .leading) {
                    Text("Password reset requested", comment: "heading")
                        .font(.title3)
                    Text("You can change your password in \(viewModel.remainingTime.asRemainingTimeString()).")
                }
            }
            .padding(12)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(ColorProvider.BackgroundNorm)
            .cornerRadius(12)

            Text("To make sure it's really you trying to reset your password, we wait \(viewModel.remainingTime.asRemainingTimeString()) before approving requests.")

            Text("If you didn't ask to reset your password, **cancel this request now**.")

                Button {
                    isAnimating.toggle()
                    Task { @MainActor in
                        try await viewModel.cancelPressed()
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
            .padding(16)
            .frame(maxHeight: .infinity)
            .background(ColorProvider.SidebarBackground as Color)
    }

    let title = ARTranslation.graceViewTitle.l10n

    let line1 = try! AttributedString(markdown: ARTranslation.graceViewLine1.l10n) 
    let line2 = ARTranslation.graceViewLine2.l10n
    let period = "."
    let line3 = ARTranslation.graceViewLine3.l10n

    public init(viewModel: AccountRecoveryView.ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
