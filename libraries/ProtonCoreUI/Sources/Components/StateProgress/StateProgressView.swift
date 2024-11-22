//
//  StateProgressView.swift
//  ProtonCoreUI - Created on 7/11/2024.
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

import SwiftUI

public struct StateProgressView: View {

    private struct Constants {
        static var progressViewScale: CGFloat = 0.9
    }

    @Binding public var progressCompleted: Bool
    public let stateProgressText: String
    public let stateCompleteText: String?

    public init(progressCompleted: Binding<Bool>,
                stateProgressText: String,
                stateCompleteText: String? = nil) {
        _progressCompleted = progressCompleted
        self.stateProgressText = stateProgressText
        self.stateCompleteText = stateCompleteText
    }

    public var body: some View {
        HStack {
            if progressCompleted {
                Theme.icon.checkmark
                    .foregroundColor(Theme.color.iconAccent)
            } else {
                ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: Theme.color.iconAccent))
                      .scaleEffect(Constants.progressViewScale, anchor: .center)
            }

            Text(titleForSate())
                .font(.callout)
        }
    }

    private func titleForSate() -> String {
        guard let completeText = stateCompleteText else {
           return stateProgressText
        }

        return progressCompleted ? completeText : stateProgressText
    }
}

#Preview {
    StateProgressView(progressCompleted: .constant(false), stateProgressText: "In progress", stateCompleteText: "Task completed")
}
