//
//  Created on 20.09.2024.
//
//  Copyright (c) 2024 Proton AG
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

public struct Cloudflare: DoHProviderInternal {
    public let description = "Cloudflare DoH"

    let supported: [DNSRecordType] = [.a, .txt]

    let networkingEngine: DoHNetworkingEngine

    init(networkingEngine: DoHNetworkingEngine) {
        self.networkingEngine = networkingEngine
    }

    public var queryUrl = URL(string: "https://1.1.1.1/dns-query")!
}
