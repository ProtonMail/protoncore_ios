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

import SwiftUI
import ProtonCoreUIFoundations

/// View shown for the Grace period state of the **Account Recovery** process
public struct ActiveAccountRecoveryView: View {

    @StateObject var viewModel: AccountRecoveryView.ViewModel
    @State var isAnimating: Bool = false


    public var body: some View {
        VStack(spacing: 24) {
            Image(AccountRecovery.ImageNames.passwordResetPeriodStart,
                      bundle: AccountRecoveryModule.resourceBundle
                )
            Text(title)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading) {
                    Text(line1) +
                    Text(viewModel.email)
                        .fontWeight(.bold) +
                    Text(line2) +
                    Text(viewModel.remainingTime.asRemainingTimeString())
                        .fontWeight(.bold) +
                    Text(period)

                    Text(line3)
                }

                Button {
#if os(iOS) // limiting to iOS only for now
                    isAnimating.toggle()
                    Task { @MainActor in
                        try await viewModel.cancelPressed()
                        isAnimating.toggle()
                    }
#endif
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
            .background(ColorProvider.BackgroundNorm as Color)
    }

    let title = ARTranslation.graceViewTitle.l10n

    let line1 = ARTranslation.graceViewLine1.l10n
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
        vm.remainingTime = 3600*72
        vm.state = .grace
        return vm
    }()

    static var previews: some View {
        ActiveAccountRecoveryView(viewModel: Self.viewModel)
    }
}
#endif

