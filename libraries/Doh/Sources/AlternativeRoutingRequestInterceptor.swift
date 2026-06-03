//
//  AlternativeRoutingRequestInterceptor.swift
//  ProtonCore-Doh - Created on 27/01/22.
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
import ProtonCoreLog

public final class AlternativeRoutingRequestInterceptor: NSObject, URLSessionDelegate {

    public static let schemeMapping: [(String, String)] = [("coreioss", "https"), ("coreios", "http")]

    private enum RequestInterceptorError: Error {
        case noUrlInRequest
        case constructedUrlIsIncorrect
    }

    private let headersGetter: () -> [String: String]
    private let cookiesSynchronization: (URLResponse?, [String: String], @escaping () -> Void) -> Void
    private let cookiesStorage: HTTPCookieStorage?
    private let onAuthenticationChallengeContinuation: (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    private var dataTasksBySchemeTaskIdentifier: [ObjectIdentifier: URLSessionDataTask] = [:]
    private var stoppedSchemeTaskIdentifiers: Set<ObjectIdentifier> = []

    public init(headersGetter: @escaping () -> [String: String],
                cookiesSynchronization: @escaping (URLResponse?, [String: String], @escaping () -> Void) -> Void = { _, _, completion in completion() },
                cookiesStorage: HTTPCookieStorage?,
                onAuthenticationChallengeContinuation: @escaping (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) {
        self.headersGetter = headersGetter
        self.cookiesSynchronization = cookiesSynchronization
        self.cookiesStorage = cookiesStorage
        self.onAuthenticationChallengeContinuation = onAuthenticationChallengeContinuation
    }

}

#if canImport(WebKit)
import WebKit

/// Wraps a non-`Sendable` closure so it can be handed to another thread.
///
/// The interceptor hops work to the main thread to satisfy `WKURLSchemeTask`'s
/// threading contract. The captured values (`WKURLSchemeTask`, `URLResponse`, …)
/// are not `Sendable`, but the hand-off is single-threaded — the closure is built
/// on the URLSession completion thread and executed exactly once on the main
/// thread — so the unchecked conformance is safe.
private struct UncheckedSendableClosure: @unchecked Sendable {
    private let body: () -> Void
    init(_ body: @escaping () -> Void) { self.body = body }
    func execute() { body() }
}

extension AlternativeRoutingRequestInterceptor: WKURLSchemeHandler {

    public func setup(webViewConfiguration: WKWebViewConfiguration) {
        for (custom, _) in AlternativeRoutingRequestInterceptor.schemeMapping {
            webViewConfiguration.setURLSchemeHandler(self, forURLScheme: custom)
        }
    }

    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        var request = urlSchemeTask.request

        guard var urlString = request.url?.absoluteString else {
            urlSchemeTask.didFailWithError(RequestInterceptorError.noUrlInRequest)
            return
        }

        // Implements rewriting the request if alternative routing is on. Rewriting request means:
        // 1. Changing the custom scheme "coreios" in the request url to "http"
        // 2. Replacing the "-api" suffix appended to the first part of url host by captcha JS code.
        //    It's required because there is no proxy domain with -api suffix)
        //    NOTE: It's applicable only to human verification but it doesn't influence other usecases so we can leave single implemention.
        // 3. Adding the appropriate proxying headers for all requests BUT to `/captcha`.
        //    The request for captcha is the API request that should go directly through proxy, so headers are removed.
        //    NOTE: It's applicable only to human verification but it doesn't influence other usecases so we can leave single implemention.
        // 4. Changing the custom scheme "coreios" to "http" in the "Origin" header
        var apiRange: Range<String.Index>?
        for (custom, original) in AlternativeRoutingRequestInterceptor.schemeMapping where urlString.contains(custom) {
            urlString = urlString.replacingOccurrences(of: custom, with: original)
            if let range = urlString.range(of: "-api") {
                apiRange = range
                urlString = urlString.replacingCharacters(in: range, with: "")
            }
            let isCaptcha = urlString.contains("/captcha?")
            for (key, value) in headersGetter() {
                request.setValue(isCaptcha ? nil : value, forHTTPHeaderField: key)
            }
            if let origin = request.value(forHTTPHeaderField: "Origin") {
                request.setValue(origin.replacingOccurrences(of: custom, with: original), forHTTPHeaderField: "Origin")
            }
            guard let url = URL(string: urlString) else {
                urlSchemeTask.didFailWithError(RequestInterceptorError.constructedUrlIsIncorrect)
                return
            }
            request.url = url
        }

        performRequest(request, apiRange, urlSchemeTask)
    }

    private func performRequest(_ request: URLRequest, _ apiRange: Range<String.Index>?, _ urlSchemeTask: WKURLSchemeTask) {
        guard let urlString = request.url?.absoluteString else {
            urlSchemeTask.didFailWithError(RequestInterceptorError.noUrlInRequest)
            return
        }
        #if DEBUG_CORE_INTERNALS
        PMLog.debug("request interceptor starts request to \(urlString) with \(DoHConstants.dohHostHeader): \(request.allHTTPHeaderFields?[DoHConstants.dohHostHeader] ?? "")")
        #endif
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = cookiesStorage
        configuration.httpCookieAcceptPolicy = .always
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        #if DEBUG_CORE_INTERNALS
        let cookies = request.url.flatMap { configuration.httpCookieStorage?.cookies(for: $0) } ?? []
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        PMLog.debug("[COOKIES][REQUEST][INTERCEPTOR] \(headers)")
        #endif
        let task = session.dataTask(with: request) { data, response, error in
            Task { [weak self, data, response, error] in
                guard let self else { return }
                let transformedResponse: URLResponse?
                if let response {
                    transformedResponse = await self.transformedResponse(response, request.allHTTPHeaderFields, shouldRestoreAPISuffix: apiRange != nil)
                } else {
                    transformedResponse = nil
                }
                await self.performOnMain {
                    guard self.shouldSendCallbacks(to: urlSchemeTask) else {
                        self.clearTaskState(for: urlSchemeTask)
                        return
                    }
                    if let transformedResponse {
                        urlSchemeTask.didReceive(transformedResponse)
                    }
                    if let data {
                        urlSchemeTask.didReceive(data)
                    }
                    if let error {
                        urlSchemeTask.didFailWithError(error)
                    } else {
                        urlSchemeTask.didFinish()
                    }
                    self.clearTaskState(for: urlSchemeTask)
                }
            }
        }
        performOnMainSync {
            register(task, for: urlSchemeTask)
        }
        task.resume()
    }

    private func cookiesSynchronization(_ response: URLResponse?, _ requestHeaders: [String: String]) async {
        await withUnsafeContinuation { c in
            cookiesSynchronization(response, requestHeaders) {
                c.resume()
            }
        }
    }

    // Implements rewriting the response if alternative routing is on. Rewriting response means:
    // 1. Enabling the Content Security Policy for captcha with proxy domains by adding the proxy domains
    //    to frame-src. Both the original and `-api` variants are added. Also, if all "http" is allowed via frame-src,
    //    we add the custom scheme "coreios" there as well.
    //    The reason for adding to frame-src is that captcha is being shown in a frame and if CSP is not set up properly,
    //    the system blocks the loading of the frame even before our interceptor. We never have the chance to control it.
    //    NOTE: It's applicable only to human verification but it doesn't influence other usecases so we can leave single implemention.
    // 2. Changing all the urls starting with "http" to "coreios" in the headers
    // 3. Adding back (if needed) the the "-api" suffix appended to the first part of url host by captcha JS code.
    //    NOTE: It's applicable only to human verification but it doesn't influence other usecases so we can leave single implemention.
    // 4. Changing the "http" scheme back to the custom one "coreios" in the response url
    public func transformAndProcessResponse(_ response: URLResponse, _ requestHeaders: [String: String]?, _ apiRange: Range<String.Index>?, _ urlSchemeTask: WKURLSchemeTask) async {
        let transformedResponse = await transformedResponse(response, requestHeaders, shouldRestoreAPISuffix: apiRange != nil)
        await performOnMain {
            guard self.shouldSendCallbacks(to: urlSchemeTask) else {
                self.clearTaskState(for: urlSchemeTask)
                return
            }
            urlSchemeTask.didReceive(transformedResponse)
        }
    }

    private func transformedResponse(_ response: URLResponse, _ requestHeaders: [String: String]?, shouldRestoreAPISuffix: Bool) async -> URLResponse {
        await cookiesSynchronization(response, requestHeaders ?? [:])
        guard let httpResponse = response as? HTTPURLResponse,
              var urlString = httpResponse.url?.absoluteString
        else {
            return response
        }

        var headers: [String: String] = httpResponse.allHeaderFields as? [String: String] ?? [:]
        headers = headers.mapValues { (originalValue: String) -> String in
            var value = originalValue
            for (custom, original) in AlternativeRoutingRequestInterceptor.schemeMapping {
                value = value.replacingOccurrences(of: "\(original)://", with: "\(custom)://")
                if let range = value.range(of: "frame-src 'self' blob: "), let host = URL(string: urlString)?.host {
                    value.insert(contentsOf: "\(custom)://\(host) ", at: range.upperBound)

                    if let index = host.firstIndex(of: ".") {
                        var hostWithAPI = host
                        hostWithAPI.insert(contentsOf: "-api", at: index)
                        value.insert(contentsOf: "\(custom)://\(hostWithAPI) ", at: range.upperBound)
                    }
                }

                [
                    "script-src",
                    "style-src",
                    "img-src",
                    "frame-src",
                    "connect-src",
                    "font-src",
                    "media-src"
                ] .forEach {
                    if let range = value.range(of: $0) {
                        value.insert(contentsOf: " \(custom):", at: range.upperBound)
                    }
                }

            }
            return value
        }

        if shouldRestoreAPISuffix {
            urlString = addAPISuffixToHost(in: urlString)
        }

        for (custom, original) in AlternativeRoutingRequestInterceptor.schemeMapping where urlString.contains(original) {
            urlString = urlString.replacingOccurrences(of: original, with: custom)
        }

        guard let url = URL(string: urlString),
              let newResponse = HTTPURLResponse(url: url, statusCode: httpResponse.statusCode, httpVersion: nil, headerFields: headers)
        else {
            return response
        }

        return newResponse
    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        let task = performOnMainSync {
            markTaskAsStopped(urlSchemeTask)
        }
        task?.cancel()

        let request = urlSchemeTask.request
        if let urlString = request.url?.absoluteString {
            // we only log here and not report the task termination back to WebKit
            PMLog.debug("request interceptor stops request to \(urlString) with \(DoHConstants.dohHostHeader): \(request.allHTTPHeaderFields?[DoHConstants.dohHostHeader] ?? "")")
        }
    }

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        onAuthenticationChallengeContinuation(challenge, completionHandler)
    }

    private func addAPISuffixToHost(in urlString: String) -> String {
        guard var components = URLComponents(string: urlString),
              var host = components.host,
              host.contains("-api") == false
        else {
            return urlString
        }
        guard let index = host.firstIndex(of: ".") else { return urlString }
        host.insert(contentsOf: "-api", at: index)
        components.host = host
        return components.string ?? urlString
    }

    /// Runs `block` synchronously on the main thread.
    ///
    /// Only called from WebKit's `start`/`stop` entry points, which WebKit invokes
    /// on the main thread, so this never blocks a Swift Concurrency cooperative
    /// thread. The `Thread.isMainThread` check keeps it correct (and the `.sync`
    /// fallback safe) should that assumption ever change.
    private func performOnMainSync<T>(_ block: () -> T) -> T {
        if Thread.isMainThread {
            return block()
        } else {
            return DispatchQueue.main.sync(execute: block)
        }
    }

    /// Runs `block` on the main thread without blocking the calling thread.
    ///
    /// Used from the URLSession completion handler, which runs on a Swift
    /// Concurrency cooperative thread. `DispatchQueue.main.sync` there would block a
    /// cooperative-pool thread, whereas suspending on a continuation does not. The
    /// `WKURLSchemeTask` callbacks and task bookkeeping run inside `block` so they
    /// always happen on the main thread.
    private func performOnMain(_ block: @escaping () -> Void) async {
        let block = UncheckedSendableClosure(block)
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            DispatchQueue.main.async {
                block.execute()
                continuation.resume()
            }
        }
    }

    private func schemeTaskIdentifier(for urlSchemeTask: WKURLSchemeTask) -> ObjectIdentifier {
        ObjectIdentifier(urlSchemeTask as AnyObject)
    }

    private func register(_ dataTask: URLSessionDataTask, for urlSchemeTask: WKURLSchemeTask) {
        let identifier = schemeTaskIdentifier(for: urlSchemeTask)
        stoppedSchemeTaskIdentifiers.remove(identifier)
        dataTasksBySchemeTaskIdentifier[identifier] = dataTask
    }

    private func markTaskAsStopped(_ urlSchemeTask: WKURLSchemeTask) -> URLSessionDataTask? {
        let identifier = schemeTaskIdentifier(for: urlSchemeTask)
        // Always record the stop so any callback that arrives afterwards is
        // suppressed, even when no in-flight data task is registered yet. The marker
        // is cleared again by `clearTaskState` (when the completion handler runs) and
        // by `register` (if the identity is later reused), so it does not accumulate.
        stoppedSchemeTaskIdentifiers.insert(identifier)
        return dataTasksBySchemeTaskIdentifier.removeValue(forKey: identifier)
    }

    private func shouldSendCallbacks(to urlSchemeTask: WKURLSchemeTask) -> Bool {
        let identifier = schemeTaskIdentifier(for: urlSchemeTask)
        return stoppedSchemeTaskIdentifiers.contains(identifier) == false
    }

    private func clearTaskState(for urlSchemeTask: WKURLSchemeTask) {
        let identifier = schemeTaskIdentifier(for: urlSchemeTask)
        stoppedSchemeTaskIdentifiers.remove(identifier)
        dataTasksBySchemeTaskIdentifier.removeValue(forKey: identifier)
    }
}

#endif
