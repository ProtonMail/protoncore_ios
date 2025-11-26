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

public enum LogStatus {
    case inProgress
    case close
}

public protocol LogHelperProviding {
    static func create() async -> LogHelper
    func logEvent(_ event: [String: Any], type: LogStatus) async
    func logEventSync(_ event: [String: Any], type: LogStatus)
    func returnTransactionLog() -> URL?
    func deleteLogs() async
}

extension LogHelperProviding {
    func logEvent(_ event: [String: Any]) async {

        await logEvent(event, type: .inProgress)
    }

    func logEventSync(_ event: [String: Any]) {
        logEventSync(event, type: .inProgress)
    }
}

public class LogHelper: LogHelperProviding {

    private struct Constants {
        static let fileName = "TransactionLog.txt"
    }

    private let backgroundQueue = DispatchQueue(label: "com.protonCore.payments.logger")

    public typealias TransactionLog = [[String: Any]]
    public private(set) var transactionLog = TransactionLog()
    public private(set) var transactionLogs = [TransactionLog]()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"

        return dateFormatter
    }()

    private init() {}

    private func runInBackground<T>(_ task: @escaping () -> T) async -> T {
        await withCheckedContinuation { continuation in
            backgroundQueue.async {
                let result = task()
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: Public

    public static func create() async -> LogHelper {
        let logHelper = LogHelper()
        await logHelper.load()
        return logHelper
    }

    public func logEvent(_ event: [String: Any], type: LogStatus) async {
        await runInBackground { [weak self] in
            guard let self else { return }
            let formattedEvent = [dateFormatter.string(from: Date.now): event]
            transactionLog.append(formattedEvent)
        }

        if type == .close {
            await save()
        }
    }

    public func logEventSync(_ event: [String: Any], type: LogStatus) {
        Task { await logEvent(event, type: type) }
    }

    public func returnTransactionLog() -> URL? {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentDirectory.appendingPathComponent(Constants.fileName)

#if DEBUG
        // Printing the log in Debug mode to easy end to end testing
        do {
            let content = try String(contentsOf: fileURL)
            debugPrint("TransactionLog:\n \(content)")
        } catch {
            debugPrint("Error reading file: \(error)")
        }
#endif

        if FileManager.default.fileExists(atPath: fileURL.path()) {
            return fileURL
        } else {
            return nil
        }
    }

    public func deleteLogs() async {
        await runInBackground {
            do {
                let url = URL.documentsDirectory.appending(path: Constants.fileName)
                try FileManager.default.removeItem(at: url)
                debugPrint("File successfully deleted at path: \(url)")
            } catch {
                debugPrint(error)
            }
        }
    }

    // MARK: Private

    private static func toJSONString(dic: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted) else {
            debugPrint("Something is wrong while converting dictionary to JSON data.")
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            debugPrint("Something is wrong while converting JSON data to JSON string.")
            return nil
        }
        return jsonString
    }

    private func save() async {
        await runInBackground { [weak self] in
            guard let self else { return }

            transactionLogs.append(transactionLog)
            guard let jsonString = transactionLogs.toJSONString() else {
                debugPrint("Transaction log conversion to JSONString failed")
                return
            }

            let data = Data(jsonString.utf8)
            let url = URL.documentsDirectory.appending(path: Constants.fileName)

            do {
                try data.write(to: url, options: [.atomic, .completeFileProtection])
                debugPrint("File successfully saved at path: \(url)")
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }

    internal func load() async {
        await runInBackground { [weak self] in
            guard let self else { return }

            let url = URL.documentsDirectory.appending(path: Constants.fileName)
            do {
                let stringData = try String(contentsOf: url)
                guard let data = stringData.data(using: .utf8) else {
                    debugPrint("Cannot convert string to data")
                    return
                }
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [TransactionLog] else {
                    debugPrint("Impossible to generate TransactionLogs from data")
                    return
                }
                transactionLogs = jsonArray
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
