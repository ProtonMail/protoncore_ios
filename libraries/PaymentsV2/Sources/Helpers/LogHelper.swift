//
//  LogHelper.swift
//  ProtonCore-PaymentsV2 - Created on 7/11/2024.
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

public protocol LogHelperProviding {
    func logEvent(_ event: [String: Any])
    func returnTransactionLog() -> URL?
    func deleteLog()
}

public final class LogHelper: LogHelperProviding {

    private static let fileName = "payment_log.txt"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
        return formatter
    }()

    public init() {}

    // MARK: Helpers

    private func logFileURL() throws -> URL {
        let appSupportURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return appSupportURL.appendingPathComponent(Self.fileName)
    }

    // MARK: Events

    public func logEvent(_ event: [String: Any]) {
        let timestamp = dateFormatter.string(from: .now)
        let entry = "\(timestamp): \(event)\n"

        guard let entryData = entry.data(using: .utf8) else {
            debugPrint("Payment log encoding failed.")
            return
        }

        do {
            var url = try logFileURL()
            let isNewFile = !FileManager.default.fileExists(atPath: url.path)

            if isNewFile {
                try entryData.write(to: url, options: [.atomic, .completeFileProtection])

                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try url.setResourceValues(resourceValues)
            } else {
                let fileHandle = try FileHandle(forWritingTo: url)

                defer {
                    try? fileHandle.close()
                }

                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: entryData)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    public func returnTransactionLog() -> URL? {
        guard let url = try? logFileURL(), FileManager.default.fileExists(atPath: url.path) else { return nil }

        #if DEBUG
        if let content = try? String(contentsOf: url) {
            debugPrint("Payment log: \n \(content)")
        }
        #endif

        return url
    }

    public func deleteLog() {
        do {
            let url = try logFileURL()
            try FileManager.default.removeItem(at: url)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
