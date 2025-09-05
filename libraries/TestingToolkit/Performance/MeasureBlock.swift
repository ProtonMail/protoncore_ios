//
//  MeasureBlock.swift
//  ProtonCore-Performance - Created on 13.06.2024.
//
// Copyright (c) 2025. Proton Technologies AG
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
import XCTest
import os.log

public class MeasureBlock {
    public let profile: MeasurementProfile
    private var labels: [String: Any] = [:]
    private var metrics: [String: Any] = [:]
    private var metadata: [String: Any] = [:]
    private let logger = Logger(subsystem: "ProtonCore", category: "Performance.MeasureBlock")

    public init(profile: MeasurementProfile) {
        self.profile = profile
        self.labels = profile.sharedLabels
        self.metadata = profile.sharedMetadata
        self.labels["sli"] = profile.serviceLevelIndicator ?? "unknown"
    }

    internal func startMeasurement() {
        profile.measuresList.append(self)
        if let sli = self.labels["sli"] as? String, sli == "unknown" {
            logger.warning("MeasurementProfile: measure block for profile with workflow: \"\(self.profile.workflow)\" expected Service Level Indicator to be set via profile.setServiceLevelIndicator() but it wasn't.")
        }
        profile.measurements.forEach { $0.onStartMeasurement(measurementProfile: profile) }
    }

    @discardableResult
    internal func stopMeasurement() -> MeasureBlock {
        profile.measurements.forEach { $0.onStopMeasurement(measurementProfile: profile) }
        return self
    }

    public func getMeasureStream() -> [String: Any] {
        let timestamp = Int(Date().timeIntervalSince1970 * 1_000_000_000) // Nanoseconds since epoch

        let values: [[Any]] = [[
            "\(timestamp)",
            metrics.jsonString(),
            metadata
        ]]

        return [
            "stream": labels,
            "values": values
        ]
    }

    internal func addLabel(key: String, value: String) {
        labels[key] = value
    }

    internal func addLabels(_ data: [String: String]) {
        labels.merge(data) { (_, new) in new }
    }

    public func addMetric(key: String, value: String) {
        do {
            try validateMetricsSize {
                metrics[key] = value
            }
        } catch let measurementError as MeasurementError {
            logger.warning("Failed to add metric '\(key)': \(measurementError)")
            // Record error for the current test
            if let testName = getCurrentTestName() {
                MeasurementContext.shared.recordMeasurementError(measurementError, forTest: testName)
            }
        } catch {
            logger.warning("Failed to add metric '\(key)': \(error)")
        }
    }

    public func addMetrics(_ data: [String: String]) {
        do {
            try validateMetricsSize {
                metrics.merge(data) { (_, new) in new }
            }
        } catch let measurementError as MeasurementError {
            logger.warning("Failed to add metrics: \(measurementError)")
            // Record error for the current test
            if let testName = getCurrentTestName() {
                MeasurementContext.shared.recordMeasurementError(measurementError, forTest: testName)
            }
        } catch {
            logger.warning("Failed to add metrics: \(error)")
        }
    }

    public func addMetadata(key: String, value: String) {
        metadata[key] = value
    }

    public func addTestNameMetadata(key: String, value: String) {
        metadata[key] = trimSpecialChars(value)
    }

    private func trimSpecialChars(_ name: String) -> String {
        let trimmedString = name.trimmingCharacters(in: CharacterSet(charactersIn: "-[]{}"))
        let components = trimmedString.split(separator: " ")
        return components.joined(separator: "_")
    }

    public func addMetadata(_ data: [String: String]) {
        metadata.merge(data) { (_, new) in new }
    }

    // Public getter for metrics (needed for XCTMetric adapter)
    public var metricsData: [String: Any] {
        return metrics
    }

    private func validateMetricsSize(_ block: () throws -> Void) throws {
        let maxMetricsCount = 50
        guard metrics.count < maxMetricsCount else {
            throw MeasurementError.metricsLimitExceeded(current: metrics.count, max: maxMetricsCount)
        }
        try block()
    }

    /// Gets the current test name from the metadata or labels
    private func getCurrentTestName() -> String? {
        // Try to get test name from metadata first
        if let testName = metadata["test"] as? String {
            return testName
        }

        // Try to get test name from labels
        if let testName = labels["test"] as? String {
            return testName
        }

        // If no test name is found, log a warning and return nil
        // The error will still be logged but won't fail a specific test
        logger.warning("Cannot determine current test name for measurement error recording")
        return nil
    }
}

extension Dictionary {
    func jsonString() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
}
