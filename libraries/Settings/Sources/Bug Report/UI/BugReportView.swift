//
//  BugReportView.swift
//  ProtonCore-Settings - Created on 28.05.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
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
@MainActor
public struct BugReportView: View {
    @ObservedObject public var viewModel: ViewModel

    @FocusState private var focusedField: FocusedField?

    enum FocusedField {
        case title
        case description
    }

    enum Constants {
        static let smallSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 12
        static let mediumLargeSpacing: CGFloat = 16
    }

    /// Constructor taking a view model and where to connect it to
    /// - Parameter viewModel: The ViewModel that holds the data for this view
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.mediumLargeSpacing) {
                    titleSection
                    descriptionSection

                    PCButton(
                        style: .constant(.init(mode: .solid)),
                        content: .constant(.init(
                            title: BugReportTranslations.sendReport.l10n,
                            isEnabled: viewModel.sendButtonIsEnabled,
                            isAnimating: viewModel.viewState == .loading,
                            action: viewModel.sendReportTapped)
                        )
                    )
                    .padding(.top, Constants.mediumLargeSpacing)
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .bannerDisplayable(bannerState: $viewModel.bannerState, configuration: .default())
            .navigationTitle(BugReportTranslations.bugReport.l10n)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { viewModel.dismissView() }, label: {
                        Image("ic-cross-big", bundle: PMUIFoundations.bundle)
                            .foregroundStyle(ColorProvider.IconNorm)
                    })
                }
            })
            .onAppear {
                focusedField = .title
            }
        }
    }

    @ViewBuilder
    var titleSection: some View {
        VStack(alignment: .leading, spacing: Constants.smallSpacing) {
            Text(BugReportTranslations.title.l10n)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(ColorProvider.TextNorm)

            TextField("", text: $viewModel.title)
                .padding(.vertical, Constants.mediumSpacing)
                .padding(.horizontal, Constants.mediumLargeSpacing)
                .focused($focusedField, equals: .title)
                .background(ColorProvider.BackgroundNorm)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(focusedField == .title ? ColorProvider.BrandNorm : ColorProvider.BackgroundNorm, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Constants.smallSpacing) {
            Text(BugReportTranslations.whatWentWrong.l10n)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(ColorProvider.TextNorm)

            ZStack(alignment: .topLeading) {
                if viewModel.description.isEmpty {
                    Text(BugReportTranslations.whatWentWrongPlaceholder.l10n)
                        .font(.body)
                        .foregroundColor(ColorProvider.TextHint)
                }
                TextView(text: $viewModel.description)
                    .focused($focusedField, equals: .description)
            }
            .padding(.vertical, Constants.mediumSpacing)
            .padding(.horizontal, Constants.mediumLargeSpacing)
            .background(ColorProvider.BackgroundNorm)
            .cornerRadius(cornerRadius)
            .frame(height: 155, alignment: .top)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(focusedField == .description ? ColorProvider.BrandNorm : ColorProvider.BackgroundNorm, lineWidth: 1)
            )
        }
    }

    private var cornerRadius: CGFloat {
        switch Brand.currentBrand {
        case .proton, .vpn:
            return 8.0
        case .pass, .wallet:
            return 16.0
        }
    }
}

struct TextView: UIViewRepresentable {

    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}

@available(iOS 15.0, *)
#Preview {
    Brand.currentBrand = .wallet
    return BugReportView(viewModel: .init(dependencies: .mock()))
        .background(ColorProvider.BackgroundNorm)
}

#endif
