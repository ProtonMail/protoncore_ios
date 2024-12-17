//
//  TrafficParameters.swift
//  ProtonCore-Performance - Created on 12.09.2024.
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

//
//  TrafficParameters.swift
//  ProtonCore-Performance - Created on 12.09.2024.
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

public enum ContentType: String {
    case json = "application/json"
    case imageSvg = "image/svg+xml"
    case imagePng = "image/png"
    case octetStream = "application/octet-stream"
    case multipartFormData = "multipart/form-data"
    
    public var asHeader: [String: String] {
        return ["content-type": self.rawValue]
    }
    
    public var tyoe: String {
        return self.rawValue
    }
}

public enum LatencyLevel: Int, Codable {
    case NONE = 0
    case LOW = 50
    case MODERATE = 150
    case HIGH = 300
    case VERY_HIGH = 600
    case CRITICAL = 1000
    case EXTREME = 5000
    
    public var latencyMs: Int {
        return self.rawValue
    }
}

public enum BandwidthLimit: Int, Codable {
    case GPRS = 56        // ~56 kbps
    case EDGE = 236       // ~236 kbps
    case _2G = 256        // ~256 kbps
    case _3G = 2048       // ~2 Mbps
    case _4G = 10000      // ~10 Mbps
    case WIFI = 54000     // ~54 Mbps
    case BROADBAND = 100000 // ~100 Mbps
    case NONE = 2147483647 // Unlimited or unavailable bandwidth
    
    /// Bandwidth in bytes per second (Bps).
    public var speedBytesPerSec: Int {
        if self == .NONE {
            return self.rawValue
        }
        return self.rawValue * 8
    }
}

