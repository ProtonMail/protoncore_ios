//
//  Created on 13/7/23.
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

public struct InsecureAccountRecoveryView: View {

    @StateObject var viewModel: AccountRecoveryView.ViewModel

    public var body: some View {
        VStack(spacing: 24) {
            Image(AccountRecovery.ImageNames.passwordResetPeriodEnd,
                  bundle: AccountRecoveryModule.resourceBundle
            )
            Text(line1) +
            Text(viewModel.email)
                .fontWeight(.bold) +
            Text(line2) +
            Text(viewModel.remainingTime.asRemainingTimeString(allowingDays: true))
                .fontWeight(.bold) +
            Text(period)

            Text(line3)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

        }
        .padding(16)
        .navigationTitle(ARTranslation.insecureViewTitle.l10n)
        .navigationBarTitleDisplayMode(.inline)
    }

    let line1 = ARTranslation.insecureViewLine1.l10n
    let line2 = ARTranslation.insecureViewLine2.l10n
    let period = "."
    let line3 = ARTranslation.insecureViewLine3.l10n

    public init(viewModel: AccountRecoveryView.ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct InsecureAccountRecoveryView_Previews: PreviewProvider {
    static var viewModel = {
        let vm = AccountRecoveryView.ViewModel()
        vm.email = "norbert@example.com"
        vm.remainingTime = 3600 * 72
        return vm
    }()

    static var previews: some View {
        ActiveAccountRecoveryView(viewModel: Self.viewModel)
    }
}
