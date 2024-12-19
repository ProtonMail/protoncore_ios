//
//  Crockford32.swift
//  ProtonCore-Login - Created on 19/12/2024.
//
//  Copyright (c) 2024 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

/// Translated to Swift from Android codebase
class Crockford32 {
    private static let ALPHANUMERIC = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
    private static let BASE32_LOOKUP: [Int] = [
        0xFF, 0xFF, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        0x17, 0x18, 0x19, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        0x17, 0x18, 0x19, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ]

    static func encode(_ bytes: Data) -> String {
        var i = 0
        var index = 0
        var digit: Int
        var currByte: Int
        var nextByte: Int
        var base32 = ""

        while i < bytes.count {
            currByte = Int(bytes[i])

            // Is the current digit going to span a byte boundary?
            if index > 3 {
                nextByte = i + 1 < bytes.count ? Int(bytes[i + 1]) : 0
                digit = currByte & (0xFF >> index)
                index = (index + 5) % 8
                digit = (digit << index) | (nextByte >> (8 - index))
                i += 1
            } else {
                digit = (currByte >> (8 - (index + 5))) & 0x1F
                index = (index + 5) % 8
                if index == 0 {
                    i += 1
                }
            }
            base32.append(ALPHANUMERIC[ALPHANUMERIC.index(ALPHANUMERIC.startIndex, offsetBy: digit)])
        }
        return base32
    }

    static func decode(_ base32: String) -> Data {
        var i = 0
        var index = 0
        var lookup: Int
        var offset = 0
        var digit: Int
        var bytes = [UInt8](repeating: 0, count: base32.count * 5 / 8)

        while i < base32.count {
            let char = base32[base32.index(base32.startIndex, offsetBy: i)]
            lookup = Int(char.asciiValue!) - Int(Character("0").asciiValue!)

            // Skip chars outside the lookup table
            if lookup < 0 || lookup >= BASE32_LOOKUP.count {
                i += 1
                continue
            }

            digit = BASE32_LOOKUP[lookup]

            // If this digit is not in the table, ignore it
            if digit == 0xFF {
                i += 1
                continue
            }

            if index <= 3 {
                index = (index + 5) % 8
                if index == 0 {
                    bytes[offset] |= UInt8(digit)
                    offset += 1
                    if offset >= bytes.count {
                        break
                    }
                } else {
                    bytes[offset] |= UInt8(digit << (8 - index))
                }
            } else {
                index = (index + 5) % 8
                bytes[offset] |= UInt8(digit >> index)
                offset += 1

                if offset >= bytes.count {
                    break
                }
                bytes[offset] |= UInt8(digit << (8 - index))
            }
            i += 1
        }
        return Data(bytes: bytes, count: bytes.count)
    }
}
