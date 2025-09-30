//
//  MemoryMeasurement.swift
//  ProtonCore-Performance - Created on 09.09.2025.
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
import os.log

/// Memory measurement that provides accurate memory usage data to Loki
/// Uses mach task_info APIs for reliable measurements with proper error handling
public class MemoryMeasurement: Measurement {

    private var startMemory: UInt64 = 0
    private var peakMemory: UInt64 = 0

    private static let logger = OSLog(subsystem: "ProtonCore.Performance", category: "MemoryMeasurement")
    private static var hasLoggedTaskInfoFailure = false // Prevent spam logging

    public init() {}

    public func onStartMeasurement(measurementProfile: MeasurementProfile) {
        startMemory = getCurrentMemoryUsage()
        peakMemory = startMemory
    }

    public func onStopMeasurement(measurementProfile: MeasurementProfile) {
        let endMemory = getCurrentMemoryUsage()
        peakMemory = max(peakMemory, endMemory)

        // Safe delta calculation with overflow protection
        let memoryDelta: Int64
        if endMemory > startMemory {
            let delta = endMemory - startMemory
            memoryDelta = delta > Int64.max ? Int64.max : Int64(delta)
        } else {
            let delta = startMemory - endMemory
            memoryDelta = delta > Int64.max ? Int64.min : -Int64(delta)
        }

        // Add memory metrics to Loki with safe conversion to KB
        measurementProfile.addMetricToMeasures("memory_peak_kb", String(format: "%.2f", safeConvertToKB(peakMemory)))
        measurementProfile.addMetricToMeasures("memory_delta_kb", String(format: "%.2f", Double(memoryDelta) / 1024.0))
        measurementProfile.addMetricToMeasures("memory_start_kb", String(format: "%.2f", safeConvertToKB(startMemory)))
        measurementProfile.addMetricToMeasures("memory_end_kb", String(format: "%.2f", safeConvertToKB(endMemory)))

        // Add raw values for debugging (in bytes)
        measurementProfile.addMetricToMeasures("memory_peak_bytes", String(peakMemory))
        measurementProfile.addMetricToMeasures("memory_delta_bytes", String(memoryDelta))
    }

    /// Safe conversion to KB with overflow protection
    private func safeConvertToKB(_ bytes: UInt64) -> Double {
        // For extremely large memory values, use Double to prevent precision loss
        return Double(bytes) / 1024.0
    }

    /// Get current memory usage using mach APIs with proper error handling
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()

        // Platform-independent calculation without magic constants
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info_data_t>.size /
            MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            // Log the failure once per session to avoid spam, but make it visible
            if !Self.hasLoggedTaskInfoFailure {
                os_log(.error, log: Self.logger,
                       "task_info failed with kern_return_t = %d. Memory measurements may be inaccurate. This could be due to sandbox restrictions or system limitations.", result)
                Self.hasLoggedTaskInfoFailure = true
            }
            return 0
        }

        return info.resident_size
    }
}
