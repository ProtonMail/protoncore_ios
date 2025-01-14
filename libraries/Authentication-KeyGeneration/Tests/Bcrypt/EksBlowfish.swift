/// EksBlowfish (Expensive key schedule Blowfish) is a block cipher based on Blowfish.
///
/// This work is based on
/// 1. Applied Cryptography, Second Edition by Bruce Schneier, section 14 and the corresponding code in Part V.
/// 2. The OpenBSD implementation of bcrypt at https://github.com/openbsd/src/blob/master/lib/libc/crypt/bcrypt.c.
///   The function names and variable names are kept the same as in the OpenBSD implementation.
@usableFromInline enum EksBlowfish {
    @usableFromInline static let N = 16  // Cipher Rounds

    @usableFromInline
    static func setup(password: [UInt8], salt: [UInt8], cost: Int) -> (p: [UInt32], s: [[UInt32]]) {
        assert(cost >= 4 && cost <= 31, "Cost must be between 4 and 31, is \(cost)")
        assert(salt.count == 16, "Salt must be 16 bytes long, is \(salt.count)")
        assert(password.count > 0 && password.count <= 72, "Password must be between 1 and 72 bytes long, is \(password.count)")

        var (p, s) = expandState(password: password, salt: salt, p: Self.initialP, s: Self.initialS)

        var i = 1 &<< cost

        while i > 0 {
            (p, s) = expand0State(key: password, p: p, s: s)
            (p, s) = expand0State(key: salt, p: p, s: s)
            i &-= 1
        }

        return (p, s)
    }

    @usableFromInline
    static func stream2word(data: [UInt8], j: inout Int) -> UInt32 {
        var word: UInt32 = 0

        var i = 0
        while i < 4 {
            if j >= data.count {
                j = 0
            }
            word = (word &<< 8) | UInt32(truncatingIfNeeded: data[j])
            i &+= 1
            j &+= 1
        }

        return word
    }

    @usableFromInline
    static func expand0State(key: [UInt8], p: [UInt32], s: [[UInt32]]) -> ([UInt32], [[UInt32]]) {
        var p = p

        var j = 0
        var i = 0
        while i < Self.N &+ 2 {
            p[i] ^= stream2word(data: key, j: &j)
            i &+= 1
        }

        var dataL: UInt32 = 0
        var dataR: UInt32 = 0

        i = 0
        j = 0
        while i < Self.N &+ 2 {
            encipher(xl: &dataL, xr: &dataR, p: p, s: s)

            p[i] = dataL
            p[i &+ 1] = dataR
            i &+= 2
        }

        var s = s
        i = 0
        while i < 4 {
            var k = 0
            while k < 256 {
                encipher(xl: &dataL, xr: &dataR, p: p, s: s)

                s[i][k] = dataL
                s[i][k &+ 1] = dataR
                k &+= 2
            }
            i &+= 1
        }

        return (p, s)
    }

    @usableFromInline
    static func expandState(password: [UInt8], salt: [UInt8], p: [UInt32], s: [[UInt32]]) -> ([UInt32], [[UInt32]]) {
        var p = p

        var j = 0
        var i = 0
        while i < Self.N &+ 2 {
            p[i] ^= stream2word(data: password, j: &j)
            i &+= 1
        }

        j = 0
        i = 0
        var dataL: UInt32 = 0
        var dataR: UInt32 = 0

        while i < Self.N &+ 2 {
            dataL ^= stream2word(data: salt, j: &j)
            dataR ^= stream2word(data: salt, j: &j)
            encipher(xl: &dataL, xr: &dataR, p: p, s: s)

            p[i] = dataL
            p[i &+ 1] = dataR
            i &+= 2
        }

        var s = s
        i = 0
        while i < 4 {
            var k = 0
            while k < 256 {
                dataL ^= stream2word(data: salt, j: &j)
                dataR ^= stream2word(data: salt, j: &j)
                encipher(xl: &dataL, xr: &dataR, p: p, s: s)

                s[i][k] = dataL
                s[i][k &+ 1] = dataR
                k &+= 2
            }
            i &+= 1
        }

        return (p, s)
    }

    @usableFromInline
    static func encipher(xl: inout UInt32, xr: inout UInt32, p: [UInt32], s: [[UInt32]]) {
        var Xl = xl
        var Xr = xr

        Xl ^= p[0]

        func F(s: [[UInt32]], x: UInt32) -> UInt32 {
            let a = s[0][Int(truncatingIfNeeded: (x &>> 24) & 0xff)]
            let b = s[1][Int(truncatingIfNeeded: (x &>> 16) & 0xff)]
            let c = s[2][Int(truncatingIfNeeded: (x &>> 8) & 0xff)]
            let d = s[3][Int(truncatingIfNeeded: (x & 0xff))]

            return (a &+ b) ^ c &+ d
        }

        var i = 1
        while i <= 16 {
            Xr ^= F(s: s, x: Xl) ^ p[i]
            Xl ^= F(s: s, x: Xr) ^ p[i + 1]
            i &+= 2
        }

        xl = Xr ^ p[17]
        xr = Xl
    }

}
