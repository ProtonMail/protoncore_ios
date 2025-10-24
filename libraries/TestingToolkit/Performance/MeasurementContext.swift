//
//  MeasurementContext.swift
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

import XCTest

// Extension to add jsonString method for compatibility
extension Dictionary where Key == String, Value == Any {
    func jsonString() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
}

public enum MeasurementError: Error {
    case missingConfiguration(String)
    case invalidConfiguration(String)
    case networkError(Error)
    case timeout
    case metricsLimitExceeded(current: Int, max: Int)

    public var localizedDescription: String {
        switch self {
        case .missingConfiguration(let message):
            return "Missing configuration: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Operation timed out"
        case .metricsLimitExceeded(let current, let max):
            return "Metrics limit exceeded: \(current) metrics, maximum allowed: \(max)"
        }
    }
}

// DefaultLogger removed - using PMLog directly

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public class MeasurementContext: NSObject, XCTestObservation {
    public static let shared = MeasurementContext(MeasurementConfig.self)

    private let profilesQueue = DispatchQueue(label: "measurement.profiles", attributes: .concurrent)
    private var _measurementProfiles: [String: MeasurementProfile] = [:]
    public var measurementConfig: MeasurementConfig.Type
    private let lokiClient: LokiClientProtocol

    // Track measurement errors that should fail tests
    private let errorsQueue = DispatchQueue(label: "measurement.errors", attributes: .concurrent)
    private var _measurementErrors: [String: [MeasurementError]] = [:]

    // Flag to indicate if testBundleDidFinish will need to write logs
    private var _expectsTestBundleFinish = false
    private let bundleFinishQueue = DispatchQueue(label: "measurement.bundlefinish")

    public var expectsTestBundleFinish: Bool {
        get { bundleFinishQueue.sync { _expectsTestBundleFinish } }
        set { bundleFinishQueue.sync { _expectsTestBundleFinish = newValue } }
    }

    /// Check if testBundleDidFinish is expected to run and write performance logs
    public func shouldPreserveLogFile() -> Bool {
        return bundleFinishQueue.sync { _expectsTestBundleFinish }
    }

    /// Check if there are any measurement profiles with data to push
    public func hasMeasurements() -> Bool {
        let profiles = profilesQueue.sync { _measurementProfiles }
        return !profiles.isEmpty
    }

    private var measurementProfiles: [String: MeasurementProfile] {
        get {
            return profilesQueue.sync { _measurementProfiles }
        }
        set {
            profilesQueue.async(flags: .barrier) { self._measurementProfiles = newValue }
        }
    }

    private var measurementErrors: [String: [MeasurementError]] {
        get {
            return errorsQueue.sync { _measurementErrors }
        }
        set {
            errorsQueue.async(flags: .barrier) { self._measurementErrors = newValue }
        }
    }

    public init(_ measurementConfig: MeasurementConfig.Type, lokiClient: LokiClientProtocol = LokiClient()) {
        self.measurementConfig = measurementConfig
        self.lokiClient = lokiClient
        super.init()

        // XCTestObservationCenter.shared.addTestObserver must be called on main thread
        // If not on main thread, do nothing to avoid crashes
        if Thread.isMainThread {
            XCTestObservationCenter.shared.addTestObserver(self)
        } else {
            DispatchQueue.main.async {
                XCTestObservationCenter.shared.addTestObserver(self)
            }
        }
    }

    public func setWorkflow(_ workflow: String, forTest testName: String) -> MeasurementProfile {
        let profile = MeasurementProfile(workflow: workflow)
        profilesQueue.async(flags: .barrier) {
            self._measurementProfiles[testName] = profile
        }

        // Set flag to indicate testBundleDidFinish will need to write logs
        expectsTestBundleFinish = true

        // Set environment variable to preserve PMLog file in tearDown
        setenv("PRESERVE_PMLOG_FOR_PERFORMANCE", "true", 1)

        return profile
    }

    public func addMetric(_ key: String, _ value: String, forTest testName: String) {
        let profile = profilesQueue.sync { _measurementProfiles[testName] }
        guard let profile = profile else {
            return
        }
        profile.addMetricToMeasures(key, value)
    }

    public func addMetadata(_ key: String, _ value: String, forTest testName: String) {
        let profile = profilesQueue.sync { _measurementProfiles[testName] }
        guard let profile = profile else {
            return
        }
        for measure in profile.measuresList {
            measure.addMetadata(key: key, value: value)
        }
    }

    public func addTestRunData(testName: String, status: String) {
        let profile = profilesQueue.sync { _measurementProfiles[testName] }
        guard let profile = profile else {
            return
        }
        for measure in profile.measuresList {
            measure.addTestNameMetadata(key: "test", value: testName)
        }
        profile.addMetricToMeasures("status", status)
    }

    public func pushToLoki() async throws {
        guard let endpoint = measurementConfig.lokiEndpoint, !endpoint.isEmpty else {
            let error = MeasurementError.missingConfiguration("Loki endpoint not configured")
            // Record error for all active test profiles
            let profiles = profilesQueue.sync { _measurementProfiles }
            for testName in profiles.keys {
                self.recordMeasurementError(error, forTest: testName)
            }
            throw error
        }

        let payload: [String: Any] = ["streams": getProfilesStreams()]
        let jsonPayload = payload.jsonString()

        // Performance logs are now handled in tearDown, not here
        // Just do the actual push to Loki

        do {
            try await lokiClient.pushToLoki(entry: jsonPayload, lokiEndpoint: endpoint)
        } catch {
            let measurementError = MeasurementError.networkError(error)
            // Record error for all active test profiles
            let profiles = profilesQueue.sync { _measurementProfiles }
            for testName in profiles.keys {
                self.recordMeasurementError(measurementError, forTest: testName)
            }
            throw measurementError
        }
    }

    private func getProfilesStreams() -> [[String: Any]] {
        var streams: [[String: Any]] = []
        let profiles = profilesQueue.sync { _measurementProfiles }
        for (testName, profile) in profiles {
            let profileStreams = profile.getProfileMetricsStreams()
            streams.append(contentsOf: profileStreams)
        }
        return streams
    }

    private var allTestResults: [(testName: String, status: String)] = []

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        guard let testRun = testCase.testRun else { return }

        // Note: Measurement error checking is now handled in ProtonCoreBaseTestCase.tearDown()
        // to ensure proper test failure reporting

        let status = testRun.totalFailureCount == 0 ? "succeeded" : "failed"
        allTestResults.append((testName: testCase.name, status: status))
    }

    public func testBundleDidFinish(_ testBundle: Bundle) {
        // Performance measurements are now handled in individual test tearDown
        // This method is kept for compatibility but does minimal work

        for result in allTestResults {
            self.addTestRunData(testName: result.testName, status: result.status)
        }

        // Clear flags and cleanup
        expectsTestBundleFinish = false
        unsetenv("PRESERVE_PMLOG_FOR_PERFORMANCE")
    }

    /// Records a measurement error for a specific test that should cause test failure
    public func recordMeasurementError(_ error: MeasurementError, forTest testName: String) {
        errorsQueue.sync {
            if self._measurementErrors[testName] == nil {
                self._measurementErrors[testName] = []
            }
            self._measurementErrors[testName]?.append(error)
        }
    }

}
