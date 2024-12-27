//
//  Bundle.swift
//  ProtonCore-Performance - Created on 12.09.2024.
//
// Copyright (c) 2023. Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Foundation

public extension Bundle {
    /// Gets the JSON data from the `Bundle` and returns it as `Data?`.
    /// - Parameters:
    ///   - fileName: The filename with the extension.
    ///   - subdirectory: The subdirectory within the bundle where the file is located.
    /// - Returns: A `Data?` containing the file content. Value is `nil` in case an error occurs.
    func getDataFor(fileName: String, subdirectory: String? = nil) -> Data? {
        let fileNSString = fileName as NSString
        let fileNameOnly = fileNSString.deletingPathExtension
        let fileExtension = fileNSString.pathExtension

        guard !fileNameOnly.isEmpty, !fileExtension.isEmpty else {
            print("Invalid filename: \(fileName). Please provide a name with an extension.")
            return nil
        }

        guard let fileURL = self.url(forResource: fileNameOnly, withExtension: fileExtension, subdirectory: subdirectory) else {
            if let subdirectory = subdirectory {
                print("Could not find file \(fileName) in folder: \(subdirectory)")
            } else {
                print("Could not find file \(fileName) in the bundle.")
            }
            return nil
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("An error occurred while reading file \(fileNameOnly).\(fileExtension): \(error.localizedDescription)")
            return nil
        }
    }
}
