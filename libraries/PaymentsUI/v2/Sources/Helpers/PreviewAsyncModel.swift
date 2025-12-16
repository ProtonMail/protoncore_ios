//
//  PreviewAsyncModel.swift
//  ProtonCore-PaymentsUIV2 - Created on 6/1/2025.
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

public struct AsyncModel<VisualContent: View, ModelData>: View {
    // Standard view builder, accepting async-fetched data as a parameter
    var viewBuilder: (ModelData) -> VisualContent
    // data fetcher. Notice it can throw as well
    var model: () async throws -> ModelData?

    @State private var modelData: ModelData?
    @State private var error: Error?

    public var body: some View {
        safeView
            .task {
                do {
                    self.modelData = try await model()
                } catch {
                    self.error = error
                    // print detailed error info to console
                    debugPrint(error)
                }
            }
    }

    @ViewBuilder
    private var safeView: some View {
        if let modelData {
            viewBuilder(modelData)
        }
        // in case of error, its description rendered
        // right on preview to make troubleshooting faster
        else if let error {
            Text(error.localizedDescription)
                .foregroundStyle(Color.red)
        }
        // a stub for awaiting.
        // Actually, we should return some non-empty view from here
        // to make sure .task { } is triggered
        else {
            Text("Calculating async data...")
        }
    }
}


