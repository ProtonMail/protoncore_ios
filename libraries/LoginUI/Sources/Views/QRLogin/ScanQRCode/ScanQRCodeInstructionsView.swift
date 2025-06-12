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
import ProtonCoreObservability

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
        static let bodyTextSpacing: CGFloat = 8
        static let titleTextSpacing: CGFloat = 10
        static let contentSpacerMinHeight: CGFloat = 24
        static let tinySpacing: CGFloat = 4
        static let numberTextWidth: CGFloat = 16
    }

    public var body: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            content
            scanButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(viewModel.$showQRCodeScanner) { show in
            guard show else {
                return
            }

            let hostingViewController = HidingNavigationBarUIHostingController(
                rootView: AnyView(ScanQRCodeView(
                    viewModel: .init(dependencies: .init(passphrase: viewModel.passphrase, userEmail: viewModel.userEmail, apiService: viewModel.apiService))))
            )
            navController?.value?.pushViewController(hostingViewController, animated: true)
            viewModel.showQRCodeScanner = false
        }
        .onAppear {
            ObservabilityEnv.report(.qrLoginScanQRCodeScreenState(stateId: .instructions))
        }
        .background(
            NavigationControllerAccessor(callback: { nav in
                navController = WeakReference(value: nav)
            })
        )
        .background(ColorProvider.BackgroundNorm)
        .navigationTitle(LUITranslation.sign_in_to_another_device.l10n)
        .navigationBarHidden(false)
    }

    var content: some View {
        VStack(alignment: .center, spacing: Constants.noSpacing) {
            scanImage
            instructions
            Spacer(minLength: Constants.contentSpacerMinHeight)
            informationBox
        }
        .modifier(FillHeightInScrollView())
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
        VStack(alignment: .leading, spacing: Constants.noSpacing) {
            Text(AttributedString.markdown("**\(LUITranslation.sign_in_with_qr_code_title.l10n)**"))
                .font(.title2)
                .lineSpacing(Constants.lineSpacing)
                .foregroundStyle(ColorProvider.TextNorm)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, Constants.titleTextSpacing)
            ForEach(Array([
                AttributedString.markdown(LUITranslation.scan_qr_code_first_step.l10n),
                AttributedString.markdown(LUITranslation.scan_qr_code_second_step.l10n),
                AttributedString.markdown(LUITranslation.scan_qr_code_third_step.l10n),
                AttributedString.markdown(LUITranslation.scan_qr_code_fourth_step.l10n),
            ].enumerated()), id: \.offset) { (index, text) in
                numberedTextItem(number: index + 1, text: text)
                    .padding(.top, Constants.bodyTextSpacing)
            }
        }
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.top, Constants.sectionPadding)
    }

    var informationBox: some View {
        InformationBox(
            title: AttributedString.markdown("**\(LUITranslation.security_tips.l10n)**"),
            tips: [
                AttributedString.markdown(LUITranslation.security_first_tip.l10n),
                AttributedString.markdown(LUITranslation.security_second_tip.l10n),
                AttributedString.markdown(LUITranslation.security_third_tip.l10n)
            ])
        .padding(.horizontal, Constants.leadingTrailingPadding)
    }

    var scanButton: some View {
        PCButton(style: .constant(.init(mode: .solid())),
                 content: .constant(.init(title: LUITranslation.scan_qr_code_title.l10n,
                                          action: viewModel.handleScanQRButtonPress)))
        .frame(height: Constants.scanButtonHeight)
        .padding(.horizontal, Constants.leadingTrailingPadding)
        .padding(.top, Constants.scanButtonTopPadding)
        .padding(.bottom, Constants.scanButtonBottomPadding)
    }

    func numberedTextItem(number: Int, text: AttributedString) -> some View {
        HStack(alignment: .top, spacing: Constants.tinySpacing) {
            Text("\(number).")
                // frame(width: textWidth) makes sure the text is aligned
                // without it there is a 2-3 pixel difference in alignment between the first item and the second.
                .frame(width: Constants.numberTextWidth)
                .modifier(InstructionsTextViewModifier(lineSpacing: Constants.lineSpacing))
            Text(text)
                .modifier(InstructionsTextViewModifier(lineSpacing: Constants.lineSpacing))
        }
    }

    struct InstructionsTextViewModifier: ViewModifier {

        var lineSpacing: CGFloat

        func body(content: Content) -> some View {
            content
                .font(.subheadline)
                .lineSpacing(lineSpacing)
                .multilineTextAlignment(.leading)
                .foregroundStyle(ColorProvider.TextNorm)
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
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

class WeakReference<T: AnyObject> {
    weak var value: T?

    init(value: T?) {
        self.value = value
    }
}

struct FillHeightInScrollView: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#endif
