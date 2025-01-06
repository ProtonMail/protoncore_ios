//
//  PCAsyncImage.swift
//  ProtonUIFoundations - Created on 6/1/2025.
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

public struct PCAsyncImage<ImageView: View, PlaceholderView: View>: View {
    // Image URL
    private let viewModel: PCAsyncViewModel

    @ViewBuilder private var content: (Image) -> ImageView
    @ViewBuilder private var placeholder: () -> PlaceholderView
    // Image
    @State private var image: UIImage?

    public init(url: URL?,
                placeholderImage: UIImage?,
                content: @escaping (Image) -> ImageView,
                placeholder: @escaping () -> PlaceholderView,
                image: UIImage? = nil) {
        self.viewModel = PCAsyncViewModel(url: url, placeholderImage: placeholderImage)
        self.content = content
        self.placeholder = placeholder
        self.image = image
    }

    public var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await viewModel.downloadImage()
                        }
                    }
            }
        }
    }
}
