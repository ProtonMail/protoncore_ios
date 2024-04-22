//
//  SignInMock.swift
//  ProtonCore-Login - Created on 05/11/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
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
import ProtonCoreCryptoGoInterface
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif

public class CryptoGoMethodsMock: CryptoGoMethods {

    public init() {}

    @PropertyStub(\CryptoGoMethodsMock.ConstantsAES256, initialGet: .empty) public var ConstantsAES256Stub
    public var ConstantsAES256: String {
        get { ConstantsAES256Stub() }
        set { ConstantsAES256Stub(newValue) }
    }

    @FuncStub(CryptoGoMethodsMock.CryptoKey(_:), initialReturn: nil) public var CryptoKeyBinKeyStub
    public func CryptoKey(_ binKeys: Data?) -> CryptoKey? {
        CryptoKeyBinKeyStub(binKeys)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoKey(fromArmored:), initialReturn: nil) public var CryptoKeyFromArmoredStub
    public func CryptoKey(fromArmored armored: String?) -> CryptoKey? {
        CryptoKeyFromArmoredStub(armored)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPGPMessage(fromArmored:), initialReturn: nil) public var CryptoPGPMessageStub
    public func CryptoPGPMessage(fromArmored armored: String?) -> CryptoPGPMessage? {
        CryptoPGPMessageStub(armored)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPGPSplitMessage(_:dataPacket:), initialReturn: nil) public var CryptoPGPSplitMessageStub
    public func CryptoPGPSplitMessage(_ keyPacket: Data?, dataPacket: Data?) -> CryptoPGPSplitMessage? {
        CryptoPGPSplitMessageStub(keyPacket, dataPacket)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPGPSplitMessage(fromArmored:), initialReturn: nil) public var CryptoPGPSplitMessageFromArmoredStub
    public func CryptoPGPSplitMessage(fromArmored encrypted: String?) -> CryptoPGPSplitMessage? {
        CryptoPGPSplitMessageFromArmoredStub(encrypted)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPlainMessage(_:), initialReturn: nil) public var CryptoPlainMessageStub
    public func CryptoPlainMessage(_ data: Data?) -> CryptoPlainMessage? {
        CryptoPlainMessageStub(data)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPlainMessage(from:), initialReturn: nil) public var CryptoPlainMessageFromStub
    public func CryptoPlainMessage(from text: String?) -> CryptoPlainMessage? {
        CryptoPlainMessageFromStub(text)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoKeyRing(_:), initialReturn: nil) public var CryptoKeyRingStub
    public func CryptoKeyRing(_ key: CryptoKey?) -> CryptoKeyRing? {
        CryptoKeyRingStub(key)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPGPSignature(_:), initialReturn: nil) public var CryptoPGPSignatureStub
    public func CryptoPGPSignature(_ data: Data?) -> CryptoPGPSignature? {
        CryptoPGPSignatureStub(data)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoPGPSignature(fromArmored:), initialReturn: nil) public var CryptoPGPSignatureFromArmoredStub
    public func CryptoPGPSignature(fromArmored armored: String?) -> CryptoPGPSignature? {
        CryptoPGPSignatureFromArmoredStub(armored)
    }

    @FuncStub(CryptoGoMethodsMock.HelperGo2IOSReader(_:), initialReturn: nil) public var HelperGo2IOSReaderStub
    public func HelperGo2IOSReader(_ reader: CryptoReaderProtocol?) -> HelperGo2IOSReader? {
        HelperGo2IOSReaderStub(reader)
    }

    @FuncStub(CryptoGoMethodsMock.HelperMobileReadResult(_:eof:data:), initialReturn: nil) public var HelperMobileReadResultStub
    public func HelperMobileReadResult(_ n: Int, eof: Bool, data: Data?) -> HelperMobileReadResult? {
        HelperMobileReadResultStub(n, eof, data)
    }

    @FuncStub(CryptoGoMethodsMock.HelperMobile2GoReader(_:), initialReturn: nil) public var HelperMobile2GoReaderStub
    public func HelperMobile2GoReader(_ reader: HelperMobileReaderProtocol?) -> HelperMobile2GoReader? {
        HelperMobile2GoReaderStub(reader)
    }

    @FuncStub(CryptoGoMethodsMock.HelperMobile2GoWriter(_:), initialReturn: nil) public var HelperMobile2GoWriterStub
    public func HelperMobile2GoWriter(_ writer: CryptoWriterProtocol?) -> HelperMobile2GoWriter? {
        HelperMobile2GoWriterStub(writer)
    }

    @FuncStub(CryptoGoMethodsMock.HelperMobile2GoWriterWithSHA256(_:), initialReturn: nil) public var HelperMobile2GoWriterWithSHA256Stub
    public func HelperMobile2GoWriterWithSHA256(_ writer: CryptoWriterProtocol?) -> HelperMobile2GoWriterWithSHA256? {
        HelperMobile2GoWriterWithSHA256Stub(writer)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoSigningContext(_:isCritical:), initialReturn: nil) public var CryptoSigningContextStub
    public func CryptoSigningContext(_ value: String?, isCritical: Bool) -> CryptoSigningContext? {
        CryptoSigningContextStub(value, isCritical)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoVerificationContext(_:isRequired:requiredAfter:), initialReturn: nil) public var CryptoVerificationContextStub
    public func CryptoVerificationContext(_ value: String?, isRequired: Bool, requiredAfter: Int64) -> CryptoVerificationContext? {
        CryptoVerificationContextStub(value, isRequired, requiredAfter)
    }

    @FuncStub(CryptoGoMethodsMock.SrpAuth, initialReturn: nil) public var SrpAuthStub
    public func SrpAuth(_ version: Int, _ username: String?, _ password: Data?, _ b64salt: String?, _ signedModulus: String?, _ serverEphemeral: String?) -> SrpAuth? {
        SrpAuthStub(version, username, password, b64salt, signedModulus, serverEphemeral)
    }

    @FuncStub(CryptoGoMethodsMock.SrpNewAuth, initialReturn: nil) public var SrpNewAuthStub
    public func SrpNewAuth(_ version: Int, _ username: String?, _ password: Data?, _ b64salt: String?, _ signedModulus: String?, _ serverEphemeral: String?, _ error: NSErrorPointer) -> SrpAuth? {
        SrpNewAuthStub(version, username, password, b64salt, signedModulus, serverEphemeral, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpNewAuthForVerifier, initialReturn: nil) public var SrpNewAuthForVerifierStub
    public func SrpNewAuthForVerifier(_ password: Data?, _ signedModulus: String?, _ rawSalt: Data?, _ error: NSErrorPointer) -> SrpAuth? {
        SrpNewAuthForVerifierStub(password, signedModulus, rawSalt, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpRandomBits, initialReturn: nil) public var SrpRandomBitsStub
    public func SrpRandomBits(_ bits: Int, _ error: NSErrorPointer) -> Data? {
        SrpRandomBitsStub(bits, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpRandomBytes, initialReturn: nil) public var SrpRandomBytesStub
    public func SrpRandomBytes(_ byes: Int, _ error: NSErrorPointer) -> Data? {
        SrpRandomBytesStub(byes, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpProofs, initialReturn: .crash) public var SrpProofsStub
    public func SrpProofs() -> SrpProofs {
        SrpProofsStub()
    }

    @FuncStub(CryptoGoMethodsMock.SrpNewServerFromSigned, initialReturn: nil) public var SrpNewServerFromSignedStub
    public func SrpNewServerFromSigned(_ signedModulus: String?, _ verifier: Data?, _ bitLength: Int, _ error: NSErrorPointer) -> SrpServer? {
        SrpNewServerFromSignedStub(signedModulus, verifier, bitLength, error)
    }

    @FuncStub(CryptoGoMethodsMock.ArmorUnarmor, initialReturn: nil) public var ArmorUnarmorStub
    public func ArmorUnarmor(_ input: String?, _ error: NSErrorPointer) -> Data? {
        ArmorUnarmorStub(input, error)
    }

    @FuncStub(CryptoGoMethodsMock.ArmorArmorKey, initialReturn: .empty) public var ArmorArmorKeyStub
    public func ArmorArmorKey(_ input: Data?, _ error: NSErrorPointer) -> String {
        ArmorArmorKeyStub(input, error)
    }

    @FuncStub(CryptoGoMethodsMock.ArmorArmorWithType, initialReturn: .empty) public var ArmorArmorWithTypeStub
    public func ArmorArmorWithType(_ input: Data?, _ armorType: String?, _ error: NSErrorPointer) -> String {
        ArmorArmorWithTypeStub(input, armorType, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoGenerateKey, initialReturn: nil) public var CryptoGenerateKeyStub
    public func CryptoGenerateKey(_ name: String?, _ email: String?, _ keyType: String?, _ bits: Int, _ error: NSErrorPointer) -> CryptoKey? {
        CryptoGenerateKeyStub(name, email, keyType, bits, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewKey, initialReturn: nil) public var CryptoNewKeyStub
    public func CryptoNewKey(_ binKeys: Data?, _ error: NSErrorPointer) -> CryptoKey? {
        CryptoNewKeyStub(binKeys, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewKeyFromArmored, initialReturn: nil) public var CryptoNewKeyFromArmoredStub
    public func CryptoNewKeyFromArmored(_ armored: String?, _ error: NSErrorPointer) -> CryptoKey? {
        CryptoNewKeyFromArmoredStub(armored, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoGenerateSessionKey, initialReturn: nil) public var CryptoGenerateSessionKeyStub
    public func CryptoGenerateSessionKey(_ error: NSErrorPointer) -> CryptoSessionKey? {
        CryptoGenerateSessionKeyStub(error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoGenerateSessionKeyAlgo, initialReturn: nil) public var CryptoGenerateSessionKeyAlgoStub
    public func CryptoGenerateSessionKeyAlgo(_ algo: String?, _ error: NSErrorPointer) -> CryptoSessionKey? {
        CryptoGenerateSessionKeyAlgoStub(algo, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoGetUnixTime, initialReturn: .crash) public var CryptoGetUnixTimeStub
    public func CryptoGetUnixTime() -> Int64 {
        CryptoGetUnixTimeStub()
    }

    @FuncStub(CryptoGoMethodsMock.CryptoUpdateTime) public var CryptoUpdateTimeStub
    public func CryptoUpdateTime(_ newTime: Int64) {
        CryptoUpdateTimeStub(newTime)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoSetKeyGenerationOffset) public var CryptoSetKeyGenerationOffsetStub
    public func CryptoSetKeyGenerationOffset(_ offset: Int64) {
        CryptoSetKeyGenerationOffsetStub(offset)
    }

    @FuncStub(CryptoGoMethodsMock.HelperFreeOSMemory) public var HelperFreeOSMemoryStub
    public func HelperFreeOSMemory() {
        HelperFreeOSMemoryStub()
    }

    @FuncStub(CryptoGoMethodsMock.HelperGenerateKey, initialReturn: .empty) public var HelperGenerateKeyStub
    public func HelperGenerateKey(_ name: String?, _ email: String?, _ passphrase: Data?, _ keyType: String?, _ bits: Int, _ error: NSErrorPointer) -> String {
        HelperGenerateKeyStub(name, email, passphrase, keyType, bits, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptMessageArmored, initialReturn: .empty) public var HelperDecryptMessageArmoredStub
    public func HelperDecryptMessageArmored(_ privateKey: String?, _ passphrase: Data?, _ ciphertext: String?, _ error: NSErrorPointer) -> String {
        HelperDecryptMessageArmoredStub(privateKey, passphrase, ciphertext, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptSessionKey, initialReturn: nil) public var HelperDecryptSessionKeyStub
    public func HelperDecryptSessionKey(_ privateKey: String?, _ passphrase: Data?, _ encryptedSessionKey: Data?, _ error: NSErrorPointer) -> CryptoSessionKey? {
        HelperDecryptSessionKeyStub(privateKey, passphrase, encryptedSessionKey, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptSessionKeyExplicitVerify, initialReturn: nil) public var HelperDecryptSessionKeyExplicitVerifyStub
    public func HelperDecryptSessionKeyExplicitVerify(_ dataPacket: Data?, _ sessionKey: (any ProtonCoreCryptoGoInterface.CryptoSessionKey)?, _ publicKeyRing: CryptoKeyRing?, _ verifyTime: Int64, _ error: NSErrorPointer) -> HelperExplicitVerifyMessage? {
        HelperDecryptSessionKeyExplicitVerifyStub(dataPacket, sessionKey, publicKeyRing, verifyTime, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptAttachment, initialReturn: nil) public var HelperDecryptAttachmentStub
    public func HelperDecryptAttachment(_ keyPacket: Data?, _ dataPacket: Data?, _ keyRing: CryptoKeyRing?, _ error: NSErrorPointer) -> CryptoPlainMessage? {
        HelperDecryptAttachmentStub(keyPacket, dataPacket, keyRing, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptExplicitVerify, initialReturn: nil) public var HelperDecryptExplicitVerifyStub
    public func HelperDecryptExplicitVerify(_ pgpMessage: CryptoPGPMessage?, _ privateKeyRing: CryptoKeyRing?, _ publicKeyRing: CryptoKeyRing?, _ verifyTime: Int64, _ error: NSErrorPointer) -> HelperExplicitVerifyMessage? {
        HelperDecryptExplicitVerifyStub(pgpMessage, privateKeyRing, publicKeyRing, verifyTime, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperDecryptExplicitVerifyWithContext, initialReturn: nil) public var HelperDecryptExplicitVerifyWithContextStub
    public func HelperDecryptExplicitVerifyWithContext(_ pgpMessage: CryptoPGPMessage?, _ privateKeyRing: CryptoKeyRing?, _ publicKeyRing: CryptoKeyRing?, _ verifyTime: Int64, _ verificationContext: CryptoVerificationContext?, _ error: NSErrorPointer) -> HelperExplicitVerifyMessage? {
        HelperDecryptExplicitVerifyWithContextStub(pgpMessage, privateKeyRing, publicKeyRing, verifyTime, verificationContext, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperEncryptSessionKey, initialReturn: nil) public var HelperEncryptSessionKeyStub
    public func HelperEncryptSessionKey(_ publicKey: String?, _ sessionKey: CryptoSessionKey?, _ error: NSErrorPointer) -> Data? {
        HelperEncryptSessionKeyStub(publicKey, sessionKey, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperEncryptMessageArmored, initialReturn: .empty) public var HelperEncryptMessageArmoredStub
    public func HelperEncryptMessageArmored(_ key: String?, _ plaintext: String?, _ error: NSErrorPointer) -> String {
        HelperEncryptMessageArmoredStub(key, plaintext, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperEncryptSignMessageArmored, initialReturn: .empty) public var HelperEncryptSignMessageArmoredStub
    public func HelperEncryptSignMessageArmored(_ publicKey: String?, _ privateKey: String?, _ passphrase: Data?, _ plaintext: String?, _ error: NSErrorPointer) -> String {
        HelperEncryptSignMessageArmoredStub(publicKey, privateKey, passphrase, plaintext, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperEncryptBinaryMessageArmored, initialReturn: .empty) public var HelperEncryptBinaryMessageArmoredStub
    public func HelperEncryptBinaryMessageArmored(_ key: String?, _ data: Data?, _ error: NSErrorPointer) -> String {
        HelperEncryptBinaryMessageArmoredStub(key, data, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperEncryptAttachment, initialReturn: nil) public var HelperEncryptAttachmentStub
    public func HelperEncryptAttachment(_ plainData: Data?, _ filename: String?, _ keyRing: CryptoKeyRing?, _ error: NSErrorPointer) -> CryptoPGPSplitMessage? {
        HelperEncryptAttachmentStub(plainData, filename, keyRing, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperUpdatePrivateKeyPassphrase, initialReturn: .empty) public var HelperUpdatePrivateKeyPassphraseStub
    public func HelperUpdatePrivateKeyPassphrase(_ privateKey: String?, _ oldPassphrase: Data?, _ newPassphrase: Data?, _ error: NSErrorPointer) -> String {
        HelperUpdatePrivateKeyPassphraseStub(privateKey, oldPassphrase, newPassphrase, error)
    }

    @FuncStub(CryptoGoMethodsMock.HelperGetJsonSHA256Fingerprints, initialReturn: nil) public var HelperGetJsonSHA256FingerprintsStub
    public func HelperGetJsonSHA256Fingerprints(_ publicKey: String?, _ error: NSErrorPointer) -> Data? {
        HelperGetJsonSHA256FingerprintsStub(publicKey, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpMailboxPassword, initialReturn: nil) public var SrpMailboxPasswordStub
    public func SrpMailboxPassword(_ password: Data?, _ salt: Data?, _ error: NSErrorPointer) -> Data? {
        SrpMailboxPasswordStub(password, salt, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpArgon2PreimageChallenge, initialReturn: .empty) public var SrpArgon2PreimageChallengeStub
    public func SrpArgon2PreimageChallenge(_ b64Challenge: String?, _ deadlineUnixMilli: Int64, _ error: NSErrorPointer) -> String {
        SrpArgon2PreimageChallengeStub(b64Challenge, deadlineUnixMilli, error)
    }

    @FuncStub(CryptoGoMethodsMock.SrpECDLPChallenge, initialReturn: .empty) public var SrpECDLPChallengeStub
    public func SrpECDLPChallenge(_ b64Challenge: String?, _ deadlineUnixMilli: Int64, _ error: NSErrorPointer) -> String {
        SrpECDLPChallengeStub(b64Challenge, deadlineUnixMilli, error)
    }

    @FuncStub(CryptoGoMethodsMock.SubtleDecryptWithoutIntegrity, initialReturn: nil) public var SubtleDecryptWithoutIntegrityStub
    public func SubtleDecryptWithoutIntegrity(_ key: Data?, _ input: Data?, _ iv: Data?, _ error: NSErrorPointer) -> Data? {
        SubtleDecryptWithoutIntegrityStub(key, input, iv, error)
    }

    @FuncStub(CryptoGoMethodsMock.SubtleDeriveKey, initialReturn: nil) public var SubtleDeriveKeyStub
    public func SubtleDeriveKey(_ password: String?, _ salt: Data?, _ n: Int, _ error: NSErrorPointer) -> Data? {
        SubtleDeriveKeyStub(password, salt, n, error)
    }

    @FuncStub(CryptoGoMethodsMock.SubtleEncryptWithoutIntegrity, initialReturn: nil) public var SubtleEncryptWithoutIntegrityStub
    public func SubtleEncryptWithoutIntegrity(_ key: Data?, _ input: Data?, _ iv: Data?, _ error: NSErrorPointer) -> Data? {
        SubtleEncryptWithoutIntegrityStub(key, input, iv, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoRandomToken, initialReturn: nil) public var CryptoRandomTokenStub
    public func CryptoRandomToken(_ size: Int, _ error: NSErrorPointer) -> Data? {
        CryptoRandomTokenStub(size, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewKeyRing, initialReturn: nil) public var CryptoNewKeyRingStub
    public func CryptoNewKeyRing(_ key: CryptoKey?, _ error: NSErrorPointer) -> CryptoKeyRing? {
        CryptoNewKeyRingStub(key, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPMessage, initialReturn: nil) public var CryptoNewPGPMessageStub
    public func CryptoNewPGPMessage(_ data: Data?) -> CryptoPGPMessage? {
        CryptoNewPGPMessageStub(data)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPMessageFromArmored, initialReturn: nil) public var CryptoNewPGPMessageFromArmoredStub
    public func CryptoNewPGPMessageFromArmored(_ armored: String?, _ error: NSErrorPointer) -> CryptoPGPMessage? {
        CryptoNewPGPMessageFromArmoredStub(armored, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPSplitMessage, initialReturn: nil) public var CryptoNewPGPSplitMessageStub
    public func CryptoNewPGPSplitMessage(_ keyPacket: Data?, _ dataPacket: Data?) -> CryptoPGPSplitMessage? {
        CryptoNewPGPSplitMessageStub(keyPacket, dataPacket)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPSplitMessageFromArmored, initialReturn: nil) public var CryptoNewPGPSplitMessageFromArmoredStub
    public func CryptoNewPGPSplitMessageFromArmored(_ encrypted: String?, _ error: NSErrorPointer) -> CryptoPGPSplitMessage? {
        CryptoNewPGPSplitMessageFromArmoredStub(encrypted, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPSignature, initialReturn: nil) public var CryptoNewPGPSignatureStub
    public func CryptoNewPGPSignature(_ data: Data?) -> CryptoPGPSignature? {
        CryptoNewPGPSignatureStub(data)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPGPSignatureFromArmored, initialReturn: nil) public var CryptoNewPGPSignatureFromArmoredStub
    public func CryptoNewPGPSignatureFromArmored(_ armored: String?, _ error: NSErrorPointer) -> CryptoPGPSignature? {
        CryptoNewPGPSignatureFromArmoredStub(armored, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPlainMessage, initialReturn: nil) public var CryptoNewPlainMessageStub
    public func CryptoNewPlainMessage(_ data: Data?) -> CryptoPlainMessage? {
        CryptoNewPlainMessageStub(data)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewPlainMessageFromString, initialReturn: nil) public var CryptoNewPlainMessageFromStringStub
    public func CryptoNewPlainMessageFromString(_ text: String?) -> CryptoPlainMessage? {
        CryptoNewPlainMessageFromStringStub(text)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewClearTextMessageFromArmored, initialReturn: nil) public var CryptoNewClearTextMessageFromArmoredStub
    public func CryptoNewClearTextMessageFromArmored(_ signedMessage: String?, _ error: NSErrorPointer) -> CryptoClearTextMessage? {
        CryptoNewClearTextMessageFromArmoredStub(signedMessage, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoNewSessionKeyFromToken, initialReturn: nil) public var CryptoNewSessionKeyFromTokenStub
    public func CryptoNewSessionKeyFromToken(_ token: Data?, _ algo: String?) -> CryptoSessionKey? {
        CryptoNewSessionKeyFromTokenStub(token, algo)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoEncryptMessageWithPassword, initialReturn: nil) public var CryptoEncryptMessageWithPasswordStub
    public func CryptoEncryptMessageWithPassword(_ message: CryptoPlainMessage?, _ password: Data?, _ error: NSErrorPointer) -> CryptoPGPMessage? {
        CryptoEncryptMessageWithPasswordStub(message, password, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoDecryptMessageWithPassword, initialReturn: nil) public var CryptoDecryptMessageWithPasswordStub
    public func CryptoDecryptMessageWithPassword(_ message: CryptoPGPMessage?, _ password: Data?, _ error: NSErrorPointer) -> CryptoPlainMessage? {
        CryptoDecryptMessageWithPasswordStub(message, password, error)
    }

    @FuncStub(CryptoGoMethodsMock.CryptoEncryptSessionKeyWithPassword, initialReturn: nil) public var CryptoEncryptSessionKeyWithPasswordStub
    public func CryptoEncryptSessionKeyWithPassword(_ sk: CryptoSessionKey?, _ password: Data?, _ error: NSErrorPointer) -> Data? {
        CryptoEncryptSessionKeyWithPasswordStub(sk, password, error)
    }
}
