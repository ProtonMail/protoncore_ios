//
//  Created on 11.03.2025.
//
//  Copyright (c) 2025 Proton AG
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

public struct SignInWithQRCodeView: View {

    private enum Constants {
        static let noSpacing: CGFloat = .zero
    }

    @StateObject var viewModel: ViewModel

    public var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            switch viewModel.state {
            case .qrCode:
                QRCodeInstructionsView(qrCodeText: viewModel.qrCodeText)
                    .onAppear {
                        viewModel.generateANewQRCodeText()
                    }
                    .onDisappear {
                        viewModel.cancelQRCodeRefresh()
                        viewModel.stopPollingFork()
                    }
            case .genericFail:
                SignInWithQRCodeGenericFailedView(
                    handleTryAgainPress: {
                        viewModel.handleTryAgainPressed()
                    }, handleBackPress: {
                        viewModel.handleBackPressed()
                    })
            case .requirePasswordFail:
                SignInWithQRCodeRequirePassFailedView(
                    handleBackPress: {
                        viewModel.handleBackPressed()
                    })
            }
        }
        .bannerDisplayable(bannerState: $viewModel.bannerState, configuration: .init(position: .bottom, dismissDuration: nil))
        .background(
            NavigationControllerAccessor(callback: { navController in
                viewModel.navigationController = navController
            })
        )
        .background(ColorProvider.BackgroundNorm)
    }
}

extension AttributedString {
    static func markdown(_ string: String) -> AttributedString {
        (try? AttributedString(markdown: string)) ?? AttributedString(string)
    }
}

#endif
