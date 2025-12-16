//
//  Bundle+Extension.swift
//  ProtonCore-PaymentsV2 - Created on 15/10/2024.
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

import Foundation
import ProtonCoreUtilities

#if DEBUG
extension Bundle {

    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder.decapitalisingFirstLetter

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            fatalError("Failed to decode \(file) from bundle: \(error).")
        }
    }

    func loadJsonDataToDic(from file: String) -> [String: Any] {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        guard let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            fatalError("Failed to generate json data from \(file).")
        }

        return jsonData
    }

    func loadJsonData(from file: String) -> Any {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        guard let jsonData = try? JSONSerialization.jsonObject(with: data) else {
            fatalError("Failed to generate json data from \(file).")
        }

        return jsonData
    }
}
#endif
