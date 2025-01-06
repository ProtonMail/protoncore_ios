//
//  PCAsyncViewModel.swift
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

@MainActor
public struct PCAsyncViewModel {

    let url: URL?
    let placeholderImage: UIImage?

    func downloadImage() async -> UIImage? {
        do {
            guard let url else { return placeholderImage }

            // Check if the image is cached already
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                // Save returned image data into the cache
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                guard let image = UIImage(data: data) else {
                    return placeholderImage
                }
                return image
            }
        } catch {
            debugPrint("Error downloading: \(error)")
            return placeholderImage
        }
    }
}
