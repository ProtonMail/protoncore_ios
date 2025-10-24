//
//  XCTMetricLokiAdapter.swift
//  ProtonCore-TestingToolkit-Performance
//
//  Bridge between XCTest's XCTMetric protocol and the
//  ProtonCore-Performance measurement pipeline.
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
import Foundation
import os.log

/// Adapter that forwards XCTest's performance callbacks to a
/// `MeasurementProfile` from the ProtonCore-Performance SDK.
///
/// This adapter implements the XCTMetric protocol by:
/// - Forwarding startMeasuring/stopMeasuring to registered Measurement objects
/// - Adding XCTest-specific labels (xct_metric, xct_status, xct_iteration) to Loki streams
/// - Returning empty measurements from reportMeasurements since data flows through Loki
@available(iOS 14.0, macOS 11.0, *)
public final class XCTMetricLokiAdapter: NSObject, XCTMetric {

    /// Weak reference to the profile that owns the custom measurements.
    private weak var measurementProfile: MeasurementProfile?
    /// Optional human-readable name – appears as a Loki label.
    private let metricName: String
    /// Logger for debugging the adapter
    private let logger = Logger(subsystem: "ProtonCore", category: "Performance.XCTMetricAdapter")
    /// Iteration counter for multiple XCTest runs
    private var iteration = 0
    /// Track if measurement failed
    private var measurementFailed = false
    /// MeasureBlock to store measurements (created during startMeasuring)
    private var currentMeasureBlock: MeasureBlock?

    public init(profile: MeasurementProfile, name: String = "XCTMetricLokiAdapter") {
        self.measurementProfile = profile
        self.metricName = name
        super.init()
        print("Created XCTMetric adapter with name: \(name)")
        logger.info("Created XCTMetric adapter with name: \(name)")
    }

    public func startMeasuring() {
        guard let profile = measurementProfile else {
            logger.warning("No measurement profile available for startMeasuring")
            return
        }

        iteration += 1
        logger.debug("Starting measurement iteration \(self.iteration) for metric: \(self.metricName)")

        // Create a MeasureBlock to store the measurements
        currentMeasureBlock = MeasureBlock(profile: profile)

        // Add XCTest-specific labels so you can filter on them in Loki/Grafana.
        currentMeasureBlock?.addMetric(key: "xct_metric", value: metricName)

        logger.debug("Created MeasureBlock for iteration \(self.iteration)")
        logger.debug("Profile measuresList count before: \(profile.measuresList.count)")

        // DON'T call startMeasurement() here - it will be called in reportMeasurements()
        // This avoids double measurement calls
        // Removed xct_iteration to stay within 10 metric limit
    }

    public func stopMeasuring() {
        guard let profile = measurementProfile else {
            logger.warning("No measurement profile available for stopMeasuring")
            return
        }

        logger.debug("Stopping measurement iteration \(self.iteration) for metric: \(self.metricName)")

        // Measurements will be triggered in reportMeasurements() to avoid duplication
        logger.debug("Measurements will be collected in reportMeasurements() to avoid duplication")

        // The MeasureBlock will be added to measuresList in reportMeasurements()
        // Don't add it here to avoid duplication
        logger.debug("stopMeasuring completed, MeasureBlock will be added in reportMeasurements()")

        // Record the overall test outcome in the MeasureBlock
        let status = measurementFailed ? "failed" : "succeeded"
        currentMeasureBlock?.addMetric(key: "xct_status", value: status)

        // Finalize the measurement block
        currentMeasureBlock?.stopMeasurement()
        currentMeasureBlock = nil

        logger.info("Completed measurement for \(self.metricName), status: \(status)")
    }

    public func reportMeasurements(from startTime: XCTPerformanceMeasurementTimestamp, to endTime: XCTPerformanceMeasurementTimestamp) throws -> [XCTPerformanceMeasurement] {
        print("CRITICAL: reportMeasurements called for \(self.metricName) iteration \(self.iteration) from \(startTime) to \(endTime)")
        logger.debug("reportMeasurements called for \(self.metricName) iteration \(self.iteration) from \(startTime) to \(endTime)")

        // CRITICAL FIX: XCTest calls reportMeasurements multiple times (once per iteration)
        // We only want to collect measurements ONCE at the end, not for each iteration
        guard let profile = measurementProfile else {
            print("ERROR: No measurement profile available for reportMeasurements!")
            logger.warning("No measurement profile available for reportMeasurements")
            return []
        }

        print("Profile found: \(profile), measurements: \(profile.measurements.count)")

        // Skip measurement collection if we've already done it for this test
        // XCTest runs multiple iterations, but we only want one consolidated result
        let existingMeasureBlocks = profile.measuresList.filter { measureBlock in
            // Check if any existing block has our metric name
            return measureBlock.metricsData["xct_metric"] as? String == self.metricName
        }

        if !existingMeasureBlocks.isEmpty {
            logger.debug("Measurements already collected for \(self.metricName), skipping iteration \(self.iteration)")
            print("Measurements already collected for \(self.metricName), skipping iteration \(self.iteration)")
            return []
        }

        // If we don't have a current measure block, create one now
        if currentMeasureBlock == nil {
            logger.debug("Creating MeasureBlock in reportMeasurements (startMeasuring wasn't called)")
            iteration += 1
            currentMeasureBlock = MeasureBlock(profile: profile)

            // Add XCTest-specific labels
            currentMeasureBlock?.addMetric(key: "xct_metric", value: metricName)
            // Removed xct_iteration to stay within 10 metric limit
        }

        // CRITICAL: Add our measure block to the profile's measuresList FIRST
        // so all measurements will add their metrics to it
        if let measureBlock = currentMeasureBlock {
            // Check if this MeasureBlock is already in the list to avoid duplicates
            let alreadyExists = profile.measuresList.contains { $0 === measureBlock }
            if !alreadyExists {
                logger.debug("Adding MeasureBlock to profile's measuresList for measurements")
                profile.measuresList.append(measureBlock)
            } else {
                logger.debug("MeasureBlock already exists in measuresList, skipping duplicate addition")
            }
        }

        // Trigger measurements for this iteration - they will all add to the same MeasureBlock
        logger.debug("Triggering measurements for iteration \(self.iteration)")
        profile.measurements.forEach { measurement in
            // All measurements will add their metrics to the currentMeasureBlock
            // since it's now in the profile's measuresList
            measurement.onStartMeasurement(measurementProfile: profile)
            measurement.onStopMeasurement(measurementProfile: profile)
        }

        // Finalize the measure block (it's already in the profile's measuresList)
        if let measureBlock = currentMeasureBlock {
            logger.debug("Profile measuresList count: \(profile.measuresList.count)")

            // Add test status
            let status = measurementFailed ? "failed" : "succeeded"
            measureBlock.addMetric(key: "xct_status", value: status)

            // Finalize the measurement block
            measureBlock.stopMeasurement()

            // DON'T add to measuresList again - it's already there
            logger.info("Finalized MeasureBlock for \(self.metricName), status: \(status)")
        }

        // Reset for next iteration
        currentMeasureBlock = nil

        // XCTest expects us to return performance measurements, but our SDK handles
        // measurement collection differently. We return an empty array since our
        // measurements are pushed to Loki through the normal SDK pipeline.
        return []
    }

    /// Call this method to mark the measurement as failed and fail the XCTest
    public func markAsFailed() {
        measurementFailed = true

        // Also record a generic measurement error to fail the test
        let error = MeasurementError.invalidConfiguration("Measurement marked as failed")
        recordMeasurementError(error)
    }

    /// Call this method to mark the measurement as failed with a specific error message
    public func markAsFailed(reason: String) {
        measurementFailed = true

        // Record the specific error to fail the test
        let error = MeasurementError.invalidConfiguration("Measurement failed: \(reason)")
        recordMeasurementError(error)
    }

    /// Records a measurement error that should fail the test
    public func recordMeasurementError(_ error: MeasurementError) {
        measurementFailed = true
        // Try to get the current test name for error recording
        if let testName = getCurrentTestName() {
            MeasurementContext.shared.recordMeasurementError(error, forTest: testName)
        }
    }

    /// Gets the current test name from XCTest context
    private func getCurrentTestName() -> String? {
        // Try to get test name from the measurement profile's context
        // Since this adapter is tied to a specific measurement profile,
        // we can try to find the test name from the measurement context
        logger.warning("Cannot determine current test name for measurement error recording in XCTMetricLokiAdapter")
        return nil
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        print("XCTMetric copy() called - creating copy of \(metricName)")
        // The metric is essentially stateless apart from the profile reference,
        // so a shallow copy is sufficient.
        let copy = XCTMetricLokiAdapter(profile: measurementProfile!, name: metricName)
        copy.iteration = self.iteration // Preserve iteration count
        copy.measurementFailed = self.measurementFailed // Preserve failure state
        copy.currentMeasureBlock = self.currentMeasureBlock // Preserve current measurement state
        print("Copy created successfully with iteration: \(copy.iteration)")
        return copy
    }
}

extension MeasurementProfile {
    /// Returns an `XCTMetric` that forwards calls to this profile.
    ///
    /// - Parameter name: Optional label that will appear in Loki as `xct_metric`.
    /// - Returns: An `XCTMetric` ready to be passed to XCTest's `measure(metrics:_:)`.
    @available(iOS 14.0, macOS 11.0, *)
    public func asXCTMetric(named name: String = "performance") -> XCTMetric {
        print("Creating XCTMetric adapter with name: \(name)")
        let adapter = XCTMetricLokiAdapter(profile: self, name: name)
        print("XCTMetric adapter created successfully: \(adapter)")
        return adapter
    }
}

extension MeasurementContext {
    /// Convenience method to create a measurement profile and XCTMetric in one call.
    ///
    /// - Parameters:
    ///   - workflow: The workflow name for the measurement
    ///   - testName: The test name (usually `self.name`)
    ///   - metricName: The name for the XCTMetric (appears as `xct_metric` in Loki)
    ///   - measurements: Array of measurements to add to the profile
    ///   - sli: Service Level Indicator name
    /// - Returns: Tuple containing the profile and XCTMetric
    @available(iOS 14.0, macOS 11.0, *)
    public func createXCTMetricProfile(
        workflow: String,
        forTest testName: String,
        metricName: String,
        measurements: [Measurement] = [DurationMeasurement()],
        sli: String
    ) -> (profile: MeasurementProfile, metric: XCTMetric) {
        let profile = setWorkflow(workflow, forTest: testName)

        // Add all measurements
        measurements.forEach { profile.addMeasurement($0) }

        // Set SLI
        profile.setServiceLevelIndicator(sli)

        // Create XCTMetric
        let metric = profile.asXCTMetric(named: metricName)

        return (profile: profile, metric: metric)
    }
}
