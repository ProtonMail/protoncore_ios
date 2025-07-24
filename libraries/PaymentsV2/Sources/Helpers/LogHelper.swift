//
//  Helpers.swift
//  ProtonCore
//
//  Created by Tiziano Bruni on 22/07/2025.
//

import Foundation

public class LogHelper {

    private let savePath = URL.documentsDirectory.appending(path: "TransactionLog.txt")
    private var transactionLog: [String: Any] = [:]

    public enum LogStatus {
        case inProgress
        case close
    }

    // MARK: Public

    public func logEvent(_ event: [String: Any], type: LogStatus = .inProgress) {
        transactionLog.merge(event) { (_, second) in second }
        if type == .close {
            save()
        }
    }

    public func returnTransactionLog() -> URL? {

        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirectory.appendingPathComponent("TransactionLog.txt")

        // TODO: Remove this after implementing the append functionality to the log file
        do {
            let content = try String(contentsOf: fileURL)
            debugPrint(content)
        } catch {
            debugPrint("Error reading file: $error)")
        }

        return fileURL
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

    private func save() {
        do {
            guard let jsonString = LogHelper.toJSONString(dic: transactionLog) else {
                debugPrint("Transaction log conversion to JSONString failed")
                return
            }

            try jsonString.write(to: savePath, atomically: true, encoding: .utf8)

        } catch {
            debugPrint("Unable to save data.")
        }
    }
}
