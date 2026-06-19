//
//  DoHCookiesSynchronizer.swift
//  ProtonCore-Doh - Created on 24/03/22.
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

final class DoHCookieSynchronizer {

    let cookieStorage: HTTPCookieStorage
    weak var doh: DoH?

    init(cookieStorage: HTTPCookieStorage, doh: DoH) {
        self.cookieStorage = cookieStorage
        self.doh = doh
    }

    func synchronizeCookies(
        for host: ProductionHosts,
        with headers: [String: String]
    ) async {

        // The feature works as follows:
        // 1. Get the cookies for default host from the response headers
        // 2. Set these cookies (they wouldn't be set otherwise because they are not proxy domain cookies)
        // 3. Set cookies with the same properties for proxy domains
        // It works because backend always sets the cookies for the default host, never for proxy domain

        guard let doh = doh else {
            return
        }

        let domains = doh.fetchAllProxyDomainUrls(for: host)
        // this ensures we don't do any unnecessary work if no proxy domain is in use
        guard !domains.isEmpty else {
            return
        }

        let url = host.url

        await MainActor.run { [weak self] in
            let newCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
            self?.cookieStorage.setCookies(newCookies, for: url, mainDocumentURL: url)

            guard let cookieDicts = self?.cookieStorage.cookies(for: url)?.map(\.properties) else {
                return
            }

            for domain in domains {
                guard let domainUrl = URL(string: doh.hostUrl(for: domain, proxying: host)) else { continue }

                let domainCookies = cookieDicts.compactMap { properties -> HTTPCookie? in
                    guard var properties else { return nil }

                    if properties[.domain] != nil {
                        properties[.domain] = domain as NSString
                    }
                    if properties[.originURL] != nil {
                        properties[.originURL] = domainUrl as NSURL
                    }
                    guard let newCookie = HTTPCookie(properties: properties) else { return nil }
                    return newCookie
                }

                // Store the proxy-domain cookies as first-party cookies for that domain.
                //
                // Passing `mainDocumentURL: nil` made CFNetwork treat these as cross-site
                // (partitioned) cookies, which routes every subsequent cookie write — including
                // URLSession's own automatic `Set-Cookie` storage happening on its worker
                // threads — through the partitioned-domain merge path
                // (`MemoryCookies::setCookiesWithPartitionedDomains`). That path is not safe
                // against the concurrent mutation that occurs when this synchronizer and
                // URLSession write to the same `HTTPCookieStorage` at the same time, and crashed
                // inside CFNetwork's cookie sorting (`_mungeCookies` / `cookieHeaderSort`).
                // Storing them first-party (matching the default-host write above) keeps the
                // cookies unpartitioned and off that path.
                self?.cookieStorage.setCookies(domainCookies, for: domainUrl, mainDocumentURL: domainUrl)
            }
        }
    }
}
