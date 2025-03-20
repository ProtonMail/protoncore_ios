//
//  Created on 13.03.2025.
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
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    let text: String

    var body: some View {
        if let uiImage = generateQRCode(from: text) {
            Image(uiImage: uiImage)
                // Avoid blur when resized
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            EmptyView()
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)

        filter.setValue(data, forKey: "inputMessage")

        // Available correction levels, lowest on the left, highest on the right: (L, M, Q, H)
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // Scale up the image so it’s not tiny
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

#endif
