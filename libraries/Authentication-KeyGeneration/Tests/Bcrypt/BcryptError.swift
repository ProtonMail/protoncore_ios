public enum BcryptError: Error {
    case invalidSaltLength
    case invalidSalt
    case emptyPassword
    case invalidCost
    case passwordTooLong
}
