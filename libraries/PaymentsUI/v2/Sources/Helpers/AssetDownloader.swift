//
//  AssetDownloader.swift
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

public protocol DownloaderProviding {
    func downloadAsset()  async -> UIImage?
}

// Default DownloaderProviding implementation using URLSession+URLCache
public struct AssetDownloader: DownloaderProviding {

    private let iconStringURL = "https://mail.proton.me/api/payments/v5/resources/icons/"

    let iconName: String

    public func downloadAsset() async -> UIImage? {

        do {
            guard let url = URL(string: iconStringURL + iconName) else { return nil }
            // Check if the image is cached already
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                // Save returned image data into the cache
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
    return UIImage(data: data)
            }
        } catch {
            debugPrint("Error downloading: \(error)")
            return nil
        }
    }
}

extension AssetDownloader: Equatable {
    public static func == (lhs: AssetDownloader, rhs: AssetDownloader) -> Bool {
        return lhs.iconName == rhs.iconName
    }
}

extension AssetDownloader: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.iconName)
    }
}
