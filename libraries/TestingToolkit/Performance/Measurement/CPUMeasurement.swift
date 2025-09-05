//
//  CPUMeasurement.swift
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

/// CPU measurement that provides accurate CPU usage data to Loki
/// Uses mach task_info APIs for reliable measurements with proper error handling
///
///
private let NANOSECONDS_PER_SECOND: Double = 1_000_000_000.0   // 1 s = 1 000 000 000 ns
private let NANOSECONDS_PER_SECOND_INT: UInt64 = 1_000_000_000   // 1 s = 1 000 000 000 ns
private let NANOSECONDS_PER_MICROSECOND: Double = 1_000.0     // 1 µs = 1 000 ns
private let NANOSECONDS_PER_MICROSECOND_INT: UInt64 = 1_000     // 1 µs = 1 000 ns

public class CPUMeasurement: Measurement {

    private var startTime: CFAbsoluteTime = 0
    private var startCPUTime: UInt64 = 0

    // High-resolution timing support (optional)
    private var useHighResolutionTiming: Bool = false
    private var startTicks: UInt64 = 0
    private var timebaseInfo = mach_timebase_info_data_t(numer: 0, denom: 0)

    private static let logger = OSLog(subsystem: "ProtonCore.Performance", category: "CPUMeasurement")
    private static var hasLoggedTaskInfoFailure = false // Prevent spam logging

    public init(useHighResolutionTiming: Bool = false) {
        self.useHighResolutionTiming = useHighResolutionTiming
        if useHighResolutionTiming {
            mach_timebase_info(&timebaseInfo)
        }
    }

    public func onStartMeasurement(measurementProfile: MeasurementProfile) {
        if useHighResolutionTiming {
            startTicks = mach_absolute_time()
        } else {
            startTime = CFAbsoluteTimeGetCurrent()
        }
        startCPUTime = getCurrentCPUTime()
    }

    public func onStopMeasurement(measurementProfile: MeasurementProfile) {
        let endCPUTime = getCurrentCPUTime()

        let wallTime: Double
        if useHighResolutionTiming {
            wallTime = nanosecondsSinceStart() / NANOSECONDS_PER_SECOND // Convert to seconds
        } else {
            let endTime = CFAbsoluteTimeGetCurrent()
            wallTime = endTime - startTime
        }

        // Calculate metrics using proper formulas with overflow protection
        let cpuTimeNs = endCPUTime - startCPUTime
        let cpuTimeSeconds: Double

        // Prevent overflow in extremely long-running processes
        if cpuTimeNs > UInt64.max / 2 {
            // Use Double for intermediate calculation to prevent overflow
            cpuTimeSeconds = Double(cpuTimeNs) / NANOSECONDS_PER_SECOND
        } else {
            cpuTimeSeconds = Double(cpuTimeNs) / NANOSECONDS_PER_SECOND
        }

        let cpuUsagePercent = wallTime > 0 ? min((cpuTimeSeconds / wallTime) * 100.0, 100.0) : 0.0

        // Add CPU metrics to Loki
        measurementProfile.addMetricToMeasures("cpu_usage_percent", String(format: "%.2f", cpuUsagePercent))
        measurementProfile.addMetricToMeasures("cpu_time_seconds", String(format: "%.6f", cpuTimeSeconds))
        measurementProfile.addMetricToMeasures("wall_time_seconds", String(format: "%.6f", wallTime))

        // Add timing method metadata for debugging
        measurementProfile.addMetricToMeasures("timing_method", useHighResolutionTiming ? "mach_absolute_time" : "CFAbsoluteTime")
    }

    /// Get current CPU time using mach APIs with proper error handling
    private func getCurrentCPUTime() -> UInt64 {
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
                       "task_info failed with kern_return_t = %d. CPU measurements may be inaccurate. This could be due to sandbox restrictions or system limitations.", result)
                Self.hasLoggedTaskInfoFailure = true
            }
            return 0
        }

        // Convert to nanoseconds with overflow protection
        let userTimeNs: UInt64
        let systemTimeNs: UInt64

        // Check for potential overflow before multiplication
        let maxSeconds = UInt64.max / NANOSECONDS_PER_SECOND_INT

        if UInt64(info.user_time.seconds) > maxSeconds || UInt64(info.system_time.seconds) > maxSeconds {
            // Extremely long-running process - use Double for calculation
            let userNs = Double(info.user_time.seconds) * NANOSECONDS_PER_SECOND +
            Double(info.user_time.microseconds) * NANOSECONDS_PER_MICROSECOND
            let sysNs = Double(info.system_time.seconds) * NANOSECONDS_PER_SECOND +
            Double(info.system_time.microseconds) * NANOSECONDS_PER_MICROSECOND
            return UInt64(userNs + sysNs)
        } else {
            // Normal case - direct calculation
            userTimeNs = UInt64(info.user_time.seconds) * NANOSECONDS_PER_SECOND_INT +
            UInt64(info.user_time.microseconds) * NANOSECONDS_PER_MICROSECOND_INT
            systemTimeNs = UInt64(info.system_time.seconds) * NANOSECONDS_PER_SECOND_INT +
            UInt64(info.system_time.microseconds) * NANOSECONDS_PER_MICROSECOND_INT
            return userTimeNs + systemTimeNs
        }
    }

    /// High-resolution wall-time calculation using mach_absolute_time
    private func nanosecondsSinceStart() -> Double {
        let now = mach_absolute_time()
        let elapsed = now - startTicks

        // Convert to nanoseconds using timebase
        let nanoseconds = Double(elapsed) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom)
        return nanoseconds
    }
}
