@usableFromInline
struct Base64 {
    @usableFromInline
    static let encodingTable: [UInt8] = [
        0x2e, 0x2f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b,
        0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
        0x59, 0x5A, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b,
        0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
        0x79, 0x7a, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
    ]

    @usableFromInline
    static let decodingTable: [UInt8] = [
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, 0, 1, 54, 55,
        56, 57, 58, 59, 60, 61, 62, 63, .max, .max,
        .max, .max, .max, .max, .max, 2, 3, 4, 5, 6,
        7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
        27, .max, .max, .max, .max, .max, .max, 28, 29, 30,
        31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        51, 52, 53, .max, .max, .max, .max, .max,
    ]

    @usableFromInline
    static func encode(_ bytes: [UInt8], count: Int) -> [UInt8] {
        guard bytes.count > 0 || count > 0 else {
            return []
        }

        let len = min(bytes.count, count)

        var offset: Int = 0
        var c1: UInt8
        var c2: UInt8
        var result: [UInt8] = []

        while offset < len {
            c1 = bytes[offset] & 0xff
            offset &+= 1
            result.append(encodingTable[Int(truncatingIfNeeded: (c1 &>> 2) & 0x3f)])
            c1 = (c1 & 0x03) &<< 4
            if offset >= len {
                result.append(encodingTable[Int(truncatingIfNeeded: c1 & 0x3f)])
                break
            }

            c2 = bytes[offset] & 0xff
            offset &+= 1
            c1 |= (c2 &>> 4) & 0x0f
            result.append(encodingTable[Int(truncatingIfNeeded: c1 & 0x3f)])
            c1 = (c2 & 0x0f) &<< 2
            if offset >= len {
                result.append(encodingTable[Int(truncatingIfNeeded: c1 & 0x3f)])
                break
            }

            c2 = bytes[offset] & 0xff
            offset &+= 1
            c1 |= (c2 &>> 6) & 0x03
            result.append(encodingTable[Int(truncatingIfNeeded: c1 & 0x3f)])
            result.append(encodingTable[Int(truncatingIfNeeded: c2 & 0x3f)])
        }

        return result
    }

    private static func char64(of x: UInt8) -> UInt8 {
        x > 127 ? 255 : decodingTable[Int(truncatingIfNeeded: x)]
    }

    @usableFromInline
    static func decode(_ s: [UInt8], count maxolen: Int) -> [UInt8] {
        let maxolen = maxolen

        var off = 0
        var olen = 0
        var result = [UInt8](repeating: 0, count: maxolen)

        var c1: UInt8
        var c2: UInt8
        var c3: UInt8
        var c4: UInt8
        var o: UInt8

        while off < s.count - 1 && olen < maxolen {
            c1 = char64(of: s[off])
            off &+= 1
            c2 = char64(of: s[off])
            off &+= 1
            if c1 == UInt8.max || c2 == UInt8.max {
                break
            }

            o = c1 &<< 2
            o |= (c2 & 0x30) &>> 4
            result[olen] = o
            olen &+= 1
            if olen >= maxolen || off >= s.count {
                break
            }

            c3 = char64(of: s[off])
            off &+= 1

            if c3 == UInt8.max {
                break
            }

            o = (c2 & 0x0f) &<< 4
            o |= (c3 & 0x3c) &>> 2
            result[olen] = o
            olen &+= 1
            if olen >= maxolen || off >= s.count {
                break
            }

            c4 = char64(of: s[off])
            off &+= 1
            o = (c3 & 0x03) &<< 6
            o |= c4
            result[olen] = o
            olen &+= 1
        }

        return Array(result[0..<olen])
    }
}
