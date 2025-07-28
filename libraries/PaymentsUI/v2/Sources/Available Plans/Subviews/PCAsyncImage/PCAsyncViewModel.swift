//
//  PCAsyncViewModel.swift
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

@MainActor
public struct PCAsyncViewModel {

    let placeholderImage: UIImage?
    let downloader: DownloaderProviding

    public init(placeholderImage: UIImage?,
                downloader: DownloaderProviding) {
        self.placeholderImage = placeholderImage
        self.downloader = downloader
    }

    func getImage() async -> UIImage? {
        guard let image = await downloader.downloadAsset() else {
            return placeholderImage
        }

        return image
    }
}
