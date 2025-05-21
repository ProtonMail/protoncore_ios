//
//  PasswordPolicyView.swift
//  ProtonCore-Login - Created on 06/05/2025.
//
//  Copyright (c) 2025 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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
import ProtonCoreLogin

public struct PasswordPolicyView: View {

    @ObservedObject var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private enum Constants {
        static let verticalSpacing: CGFloat = 4
        static let bulletListHeaderSpacing: CGFloat = 2
        static let bulletIconHeight: CGFloat = 10
        static let bulletIconPadding: CGFloat = 3
        static let bulletListItemHSpacing: CGFloat = 4
    }

    public var body: some View {
        Group {
            if viewModel.exceptionalErrorMessage != nil || !viewModel.requirementsList.isEmpty {
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    if let exceptionalErrorMessage = viewModel.exceptionalErrorMessage {
                        Text(exceptionalErrorMessage)
                            .foregroundColor(ColorProvider.NotificationError)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if viewModel.requirementsList.count > 0 {
                        BulletedListView(items: viewModel.requirementsList)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                Color.clear.frame(height: 1) // <- this gives it a tiny height when empty
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    struct BulletedListView: View {
        let items: [PasswordPolicyView.BulletedListItem]

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(LUITranslation.password_must_contain.l10n)
                    .foregroundColor(ColorProvider.TextWeak)
                    .font(.caption)
                    .padding(.bottom, Constants.bulletListHeaderSpacing)
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .center, spacing: Constants.bulletListItemHSpacing) {
                        bulletIcon(for: item)
                        Text(item.text)
                            .strikethrough(item.struck)
                            .foregroundColor(item.struck ? ColorProvider.TextHint : ColorProvider.TextWeak)
                    }
                    .font(.caption)
                }
            }
        }

        func bulletIcon(for item: PasswordPolicyView.BulletedListItem) -> some View {
            let icon: Image = item.struck ? IconProvider.circleCheckmark : IconProvider.circleSmall
            let color: Color = item.struck ? ColorProvider.IconAccent : ColorProvider.IconDisabled

            return icon
                .renderingMode(.template)
                .resizable()
                .frame(width: Constants.bulletIconHeight, height: Constants.bulletIconHeight)
                .foregroundStyle(color)
                .padding(Constants.bulletIconPadding)
        }
    }
}

#if DEBUG
let policies = [
        PasswordPolicy.disallowCommonPasswordsMock,
        PasswordPolicy.atLeastOneNumberMock,
        PasswordPolicy.atLeastOneSpecialCharacterMock,
        PasswordPolicy.atLeastOneUpperCaseAndOneLowercaseMock
]

#Preview {
    PasswordPolicyView(viewModel: PasswordPolicyView.ViewModel(passwordPolicies: policies))
}
#endif

#endif
