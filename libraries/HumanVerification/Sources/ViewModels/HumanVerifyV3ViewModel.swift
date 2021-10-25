//
//  RecaptchaViewModel.swift
//  ProtonCore-HumanVerification - Created on 20/01/21.
//
//  Copyright (c) 2021 Proton Technologies AG
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

import UIKit
import WebKit
import class WebKit.WKWebView
import ProtonCore_Networking
import ProtonCore_Services

class HumanVerifyV3ViewModel {

    // MARK: - Private properties

    private var token: String?
    private var tokenMethod: VerifyMethod?

    let apiService: APIService
    let scriptName = "iOS"
    
    var startToken: String?
    var methods: [VerifyMethod]?
    var onVerificationCodeBlock: ((@escaping SendVerificationCodeBlock) -> Void)?

    // MARK: - Public properties and methods

    init(api: APIService, startToken: String?, methods: [VerifyMethod]?) {
        self.apiService = api
        self.startToken = startToken
        self.methods = methods
    }

    var getURL: URL {
        let host = apiService.doh.getHostUrl()
        let methods = methods?.map { $0.rawValue } ?? []
        let methodsStr = methods.joined(separator:",")
        return URL(string: "\(host)?token=\(startToken ?? "")&methods=\(methodsStr)&theme=\(getTheme)&locale=\(getLocale)&defaultCountry=\(getCountry)&embed=true")!
    }
    
    func finalToken(method: VerifyMethod, token: String, complete: @escaping SendVerificationCodeBlock) {
        self.token = token
        self.tokenMethod = method
        onVerificationCodeBlock?({ (res, error, finish) in
            complete(res, error, finish)
        })
    }
    
    func getToken() -> TokenType {
        return TokenType(verifyMethod: tokenMethod, token: token)
    }
    
    func interpretMessage(message: WKScriptMessage, validMessage: (() -> ())? = nil, notificationMessage: ((String) -> ())? = nil, complete: @escaping SendVerificationCodeBlock) {
        guard message.name == scriptName, let string = message.body as? String, let json = try? JSONSerialization.jsonObject(with: Data(string.utf8), options: []) as? [String: Any] else { return }
        if let type = json["type"] as? String {
            switch type {
            case MessageType.human_verification_success.rawValue:
                guard let messageSuccess: MessageSuccess = decode(json: json), let method = VerifyMethod(rawValue: messageSuccess.payload.type) else { return }
                validMessage?()
                finalToken(method: method, token: messageSuccess.payload.token, complete: complete)
            case MessageType.notification.rawValue:
                guard let messageNotification: MessageNotification = decode(json: json), messageNotification.payload.type == .success else { return }
                notificationMessage?(messageNotification.payload.text)
            default: break
            }
        }
    }
    
    private func decode<T: Decodable>(json: [String : Any]) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private var getTheme: Int {
        if #available(iOS 12.0, *) {
            if let vc = UIApplication.shared.keyWindow?.rootViewController, vc.traitCollection.userInterfaceStyle == .dark {
                return 1
            } else {
                return 2
            }
        } else {
            return 0
        }
    }
    
    private var getLocale: String {
        return Locale.current.identifier
    }
    
    private var getCountry: String {
        return Locale.current.regionCode ?? ""
    }
}
