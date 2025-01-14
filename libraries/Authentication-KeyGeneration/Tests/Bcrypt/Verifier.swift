extension Bcrypt {
    /// Verifies a password against a hash.
    /// - Parameters:
    ///   - password: the password to verify.
    ///   - hash: the hash to verify against.
    /// - Throws: ``BcryptError``
    /// - Returns: `true` if the password matches the hash, `false` otherwise.
    @inlinable
    public static func verify(password: String, hash: String) throws -> Bool {
        try verify(password: Array(password.utf8), hash: Array(hash.utf8))
    }

    /// Verifies a password against a hash.
    /// - Parameters:
    ///   - password: the password to verify.
    ///   - hash: the hash to verify against.
    /// - Throws: ``BcryptError``
    /// - Returns: `true` if the password matches the hash, `false` otherwise.
    @inlinable
    public static func verify(password: [UInt8], hash goodHash: [UInt8]) throws -> Bool {
        let prefix = goodHash.prefix(7)

        let version = BcryptVersion(identifier: Array(prefix[1...2]))
        let cost = prefix[4...5].reduce(0) { $0 * 10 + Int($1 - 48) }

        let salt = Array(goodHash[7...28])

        let newHash = try Bcrypt.hash(password: password, cost: cost, salt: salt, version: version)

        return newHash == goodHash
    }
}
