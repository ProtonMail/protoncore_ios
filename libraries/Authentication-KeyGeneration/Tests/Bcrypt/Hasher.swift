extension Bcrypt {
    @usableFromInline static let cipherText = Array("OrpheanBeholderScryDoubt".utf8)
    @usableFromInline static let maxSalt = 16
    @usableFromInline static let saltSpace = 22
    @usableFromInline static let words = 6
    @usableFromInline static let hashSpace = 60

    /// Hashes a password using the bcrypt algorithm.
    /// - Parameters:
    ///   - password: the password to hash.
    ///   - cost: number of rounds to apply the key derivation function, used as log2(cost). Must be between 4 and 31.
    ///   - version: the version of the bcrypt algorithm to use. Defaults to `v2b`.
    /// - Throws: ``BcryptError``
    /// - Returns: the hashed password.
    @inlinable
    public static func hash(password: String, cost: Int = 10, version: BcryptVersion = .v2b) throws -> String {
        String(
            decoding: try hash(password: Array(password.utf8), cost: cost, salt: Self.generateRandomSalt(), version: version),
            as: UTF8.self
        )
    }

    /// Hashes a password using the bcrypt algorithm.
    /// - Parameters:
    ///   - password: the password to hash.
    ///   - cost: number of rounds to apply the key derivation function, used as log2(cost). Must be between 4 and 31.
    ///   - salt: the salt to use for the hash.
    ///   - version: the version of the bcrypt algorithm to use. Defaults to `v2b`.
    /// - Throws: ``BcryptError``
    /// - Returns: the hashed password.
    @inlinable
    public static func hash(password: String, cost: Int = 10, salt: [UInt8], version: BcryptVersion = .v2b) throws -> String {
        String(
            decoding: try hash(password: Array(password.utf8), cost: cost, salt: salt, version: version),
            as: UTF8.self
        )
    }

    /// Hashes a password using the bcrypt algorithm.
    /// - Parameters:
    ///   - password: the password to hash.
    ///   - cost: number of rounds to apply the key derivation function, used as log2(cost). Must be between 4 and 31.
    ///   - version: the version of the bcrypt algorithm to use. Defaults to `v2b`.
    /// - Throws: ``BcryptError``
    /// - Returns: the hashed password.
    @inlinable
    public static func hash(password: [UInt8], cost: Int = 10, version: BcryptVersion = .v2b) throws -> [UInt8] {
        try hash(password: password, cost: cost, salt: Self.generateRandomSalt(), version: version)
    }

    /// Hashes a password using the bcrypt algorithm.
    /// - Parameters:
    ///   - password: the password to hash.
    ///   - cost: number of rounds to apply the key derivation function, used as log2(cost). Must be between 4 and 31.
    ///   - salt: the salt to use for the hash.
    ///   - version: the version of the bcrypt algorithm to use. Defaults to `v2b`.
    /// - Throws: ``BcryptError``
    /// - Returns: the hashed password.
    @inlinable
    public static func hash(password: [UInt8], cost: Int = 10, salt: [UInt8], version: BcryptVersion = .v2b) throws -> [UInt8] {
        guard (salt.count * 3 / 4) - 1 < Self.maxSalt else {
            throw BcryptError.invalidSaltLength
        }

        let cSalt = Base64.decode(salt, count: Self.maxSalt)

        guard password.count > 0 else {
            throw BcryptError.emptyPassword
        }

        let password =
            if password[password.endIndex - 1] == 0 {
                Array(password[password.startIndex..<password.endIndex - 1]) + [0]
            } else {
                password + [0]
            }

        switch version {
        case .v2a: break
        case .v2b:
            guard password.count <= 72 else {
                throw BcryptError.passwordTooLong
            }
        }

        if cost < 4 || cost > 31 {
            throw BcryptError.invalidCost
        }

        let (p, s) = EksBlowfish.setup(password: password, salt: cSalt, cost: cost)

        var cData = [UInt32](repeating: 0, count: Self.words)

        var i = 0
        var j = 0
        while i < Self.words {
            cData[i] = EksBlowfish.stream2word(data: Self.cipherText, j: &j)
            i &+= 1
        }

        i = 0
        while i < 64 {
            var j = 0
            var xl: UInt32 = 0
            var xr: UInt32 = 0
            while j < Self.words / 2 {
                xl = cData[j * 2]
                xr = cData[j * 2 + 1]
                EksBlowfish.encipher(xl: &xl, xr: &xr, p: p, s: s)
                cData[j * 2] = xl
                cData[j * 2 + 1] = xr
                j &+= 1
            }
            i &+= 1
        }

        var cipherText = Self.cipherText
        i = 0
        while i < Self.words {
            cipherText[4 * i + 3] = UInt8(cData[i] & 0xff)
            cipherText[4 * i + 2] = UInt8((cData[i] &>> 8) & 0xff)
            cipherText[4 * i + 1] = UInt8((cData[i] &>> 16) & 0xff)
            cipherText[4 * i + 0] = UInt8((cData[i] &>> 24) & 0xff)
            i &+= 1
        }

        var output = [UInt8]()

        let cost: [UInt8] =
            switch cost {
            case 0...9:
                [0x30, UInt8(cost + 0x30)]
            default:
                [UInt8(cost / 10 + 0x30), UInt8(cost % 10 + 0x30)]
            }

        let prefix = version.identifier + cost + [36]

        output += prefix
        output += salt
        output += Base64.encode(cipherText, count: 4 * Self.words - 1)

        return output
    }

    // $2a$12$R9h/cIPz0gi.URNNX3kh2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUW
    // \__/\/ \____________________/\_____________________________/
    // Alg Cost      Salt                        Hash
    @usableFromInline
    static func generateRandomSalt() -> [UInt8] {
        var salt = [UInt8](repeating: 0, count: saltSpace)

        var cSalt = [UInt8](repeating: 0, count: maxSalt)
        var i = 0
        while i < maxSalt {
            cSalt[i] = UInt8.random(in: .min ... .max)
            i &+= 1
        }

        let encodedSalt = Base64.encode(cSalt, count: Self.hashSpace)
        i = 0
        while i < encodedSalt.count {
            if i < saltSpace {
                salt[i] = encodedSalt[i]
            }
            i &+= 1
        }

        return salt
    }
}
