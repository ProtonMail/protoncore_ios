//
//  AppSizeMeasurement.swift
//  ProtonCore-Performance - Created on 13.06.2024.
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

public class AppSizeMeasurement: Measurement {

    private let bundle: Bundle
    private let byteCountFormatter: ByteCountFormatter = {
      let formatter = ByteCountFormatter()
      formatter.countStyle = .binary
      formatter.allowedUnits = .useMB
      formatter.includesUnit = false
      return formatter
    }()

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func onStartMeasurement(measurementProfile: MeasurementProfile) {
        measurementProfile.addMetricToMeasures("app_size", appBundleSize(bundle))
    }

    public func onStopMeasurement(measurementProfile: MeasurementProfile) {
        // DO NOTHING HERE
    }

    private func appBundleSize(_ bundle: Bundle) -> String {
        let fileManager = FileManager.default
        guard let bundlePath = bundle.bundlePath as String? else {
            return "0"
        }

        guard let filesArray = try? fileManager.subpathsOfDirectory(atPath: bundlePath) else {
            return "0"
        }

        var fileSize: UInt64 = 0
        for fileName in filesArray {
            let filePath = bundlePath.appending("/\(fileName)")
            if let fileDictionary = try? fileManager.attributesOfItem(atPath: filePath),
               let fileBytes = fileDictionary[FileAttributeKey.size] as? UInt64 {
                fileSize += fileBytes
            }
        }

        return byteCountFormatter.string(fromByteCount: Int64(fileSize))
    }
}
