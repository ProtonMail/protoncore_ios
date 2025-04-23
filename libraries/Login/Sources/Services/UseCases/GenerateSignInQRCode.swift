//
//  Created on 12.03.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCoreCrypto

public protocol SecureHashGenerator {
    func random(bits: Int32) throws -> Data
}

public protocol ClientIdProvider {
    func clientId() -> String
}

public struct GenerateSignInQRCode {

    private let hashGenerator: SecureHashGenerator
    private let clientIdProvider: ClientIdProvider

    public static let QRCodeVersion: Int = 0

    public init(hashGenerator: SecureHashGenerator, clientIdProvider: ClientIdProvider) {
        self.hashGenerator = hashGenerator
        self.clientIdProvider = clientIdProvider
    }

    public struct Response {
        public let version: Int
        public let userCode: String
        public let encryptionKeyBase64: String?
        public let clientId: String

        public var encryptionKey: Data? {
            guard let encryptionKeyBase64 = self.encryptionKeyBase64 else {
                return nil
            }
            return Base64.decode(base64: encryptionKeyBase64)
        }

        public var text: String {
            "\(version):\(userCode):\(encryptionKeyBase64 ?? ""):\(clientId)"
        }
    }

    /// userCode comes from call to /session/forks
    public func invoke(userCode: String, withEncryptionKey: Bool) throws -> Response {
        let clientId = clientIdProvider.clientId()

        var base64EncryptionKey: String? = nil

        if withEncryptionKey {
            let encryptionKey = try hashGenerator.random(bits: 256)
            base64EncryptionKey = Base64.encode(raw: encryptionKey)
        }

        return Response(
            version: Self.QRCodeVersion,
            userCode: userCode,
            encryptionKeyBase64: base64EncryptionKey,
            clientId: clientId)
    }
}
