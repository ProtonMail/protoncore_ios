//
//  Created on 18.03.2025.
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
import UIKit

@MainActor
public struct ScanQRCodeInstructionsView: View {

    @StateObject var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // Adding a NavigationStack inside a UINavigationController leads to issues with layout and pushing views to the NavigationStack
    // So instead of adding a NavigationStack we rely on the original UINavigationController
    @State private var navController: WeakReference<UINavigationController>?

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let sectionPadding: CGFloat = 44
        static let leadingTrailingPadding: CGFloat = 16
        static let noSpacing: CGFloat = .zero
        static let lineSpacing: CGFloat = 0.25
        static let scanImageHeight: CGFloat = 96
        static let scanButtonHeight: CGFloat = 48
        static let scanButtonTopPadding: CGFloat = 28
        static let scanButtonBottomPadding: CGFloat = 20
        static let bodyTextSpacing: CGFloat = 12
        static let titleTextSpacing: CGFloat = 16
        static let infoBoxesVerticalSpacing: CGFloat = 8
    }

    public var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            scanImage
            instructions
            Spacer()
            informationBoxes
            scanButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(ColorProvider.BackgroundNorm))
        .navigationTitle(LUITranslation.sign_in_to_another_device.l10n)
        .background(
            NavigationControllerAccessor(callback: { nav in
                navController = WeakReference(value: nav)
            })
        )
        .onReceive(viewModel.$showQRCodeScanner) { show in
            if show {
                let hostingViewController = HidingNavigationBarUIHostingController(
                    rootView: AnyView(ScanQRCodeView(
                        viewModel: .init(dependencies: .init(passphrase: viewModel.passphrase, userEmail: viewModel.userEmail, apiService: viewModel.apiService))))
                )
                navController?.value?.pushViewController(hostingViewController, animated: true)
                viewModel.showQRCodeScanner = false
            }
        }
    }

    var scanImage: some View {
        Image(uiImage: IconProvider.scanQRCode)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(height: Constants.scanImageHeight)
            .padding(.top, Constants.sectionPadding)
    }

    var instructions: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            Text(LUITranslation.sign_in_with_qr_code_title.l10n)
                .font(.title2)
                .lineSpacing(Constants.lineSpacing)
                .foregroundStyle(ColorProvider.White)
            Text(LUITranslation.sign_in_with_qr_code_scan_instructions.l10n)
                .modifier(InstructionsTextViewModifier(lineSpacing: Constants.lineSpacing))
                .padding(.top, Constants.titleTextSpacing)
            Text(AttributedString.markdown(LUITranslation.sign_in_with_qr_code_access_qr_code_instructions.l10n))
                .modifier(InstructionsTextViewModifier(lineSpacing: Constants.lineSpacing))
                .padding(.top, Constants.bodyTextSpacing)
        }
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.top, Constants.sectionPadding)
    }

    var informationBoxes: some View {
        VStack(alignment: .leading, spacing: Constants.infoBoxesVerticalSpacing) {
            InformationBox(text: AttributedString.markdown(LUITranslation.sign_in_with_qr_code_warning_one.l10n))
            InformationBox(text: AttributedString.markdown(LUITranslation.sign_in_with_qr_code_warning_two.l10n))
        }
        .padding(.horizontal, Constants.leadingTrailingPadding)
    }

    var scanButton: some View {
        PCButton(style: .constant(.init(mode: .solid)),
                 content: .constant(.init(title: LUITranslation.scan_qr_code_title.l10n,
                                          action: viewModel.handleScanQRButtonPress)))
        .frame(height: Constants.scanButtonHeight)
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.top, Constants.scanButtonTopPadding)
        .padding(.bottom, Constants.scanButtonBottomPadding)
    }

    struct InstructionsTextViewModifier: ViewModifier {

        var lineSpacing: CGFloat

        func body(content: Content) -> some View {
            content
                .font(.subheadline)
                .lineSpacing(lineSpacing)
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorProvider.TextWeak)
        }
    }
}

struct NavigationControllerAccessor: UIViewControllerRepresentable {
    var callback: (UINavigationController?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Access the UINavigationController once added to a navigation stack
        Task { @MainActor in
            self.callback(viewController.navigationController)
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class HidingNavigationBarUIHostingController: UIHostingController<AnyView> {
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}

class WeakReference<T: AnyObject> {
    weak var value: T?

    init(value: T?) {
        self.value = value
    }
}

#endif
