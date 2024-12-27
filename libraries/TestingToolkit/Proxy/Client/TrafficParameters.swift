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
    
    public var type: String {
        return self.rawValue
    }
}

public enum LatencyLevel: Int, Codable {
    case none = 0
    case low = 50
    case moderate = 150
    case high = 300
    case very_high = 600
    case critical = 1000
    case extreme = 5000

    public var latencyMs: Int {
        return self.rawValue
    }
}

public enum BandwidthLimit: Int, Codable {
    case gprs = 56        // ~56 kbps
    case edge = 236       // ~236 kbps
    case _2G = 256        // ~256 kbps
    case _3G = 2048       // ~2 Mbps
    case _4G = 10000      // ~10 Mbps
    case wifi = 54000     // ~54 Mbps
    case broadband = 100000 // ~100 Mbps
    case none = 2147483647 // Unlimited or unavailable bandwidth

    /// Bandwidth in bytes per second (Bps).
    public var speedBytesPerSec: Int {
        if self == .none {
            return self.rawValue
        }
        return self.rawValue * 8
    }
}

