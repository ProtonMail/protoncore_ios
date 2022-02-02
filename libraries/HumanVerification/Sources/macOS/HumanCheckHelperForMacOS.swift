//
//  HumanCheckHelperForMacOS.swift
//  ProtonCore-HumanVerification - Created on 2/1/16.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import AppKit
import ProtonCore_APIClient
import ProtonCore_Networking
import ProtonCore_Services
import enum ProtonCore_DataModel.ClientApp

public class HumanCheckHelper: HumanVerifyDelegate {
    public let version: HumanVerificationVersion = .v3
    private let rootViewController: NSViewController?
    private weak var responseDelegate: HumanVerifyResponseDelegate?
    private weak var paymentDelegate: HumanVerifyPaymentDelegate?
    private let apiService: APIService
    private let supportURL: URL
    private var verificationCompletion: ((HumanVerifyFinishReason) -> Void)?
    private var coordinatorV3: HumanCheckV3Coordinator?
    private let clientApp: ClientApp
    
    public init(apiService: APIService,
                supportURL: URL? = nil,
                viewController: NSViewController? = nil,
                clientApp: ClientApp,
                responseDelegate: HumanVerifyResponseDelegate? = nil,
                paymentDelegate: HumanVerifyPaymentDelegate? = nil) {
        self.apiService = apiService
        self.supportURL = supportURL ?? HVCommon.defaultSupportURL(clientApp: clientApp)
        self.rootViewController = viewController
        self.clientApp = clientApp
        self.responseDelegate = responseDelegate
        self.paymentDelegate = paymentDelegate
    }

    public func onHumanVerify(parameters: HumanVerifyParameters, currentURL: URL?, completion: (@escaping (HumanVerifyFinishReason) -> Void)) {

        // check if payment token exists
        if let paymentToken = paymentDelegate?.paymentToken {
            let client = TestApiClient(api: self.apiService)
            let route = client.createHumanVerifyRoute(destination: nil, type: VerifyMethod(predefinedMethod: .payment), token: paymentToken)
            // retrigger request and use header with payment token
            completion(.verification(header: route.header, verificationCodeBlock: { result, _, verificationFinishBlock in
                self.paymentDelegate?.paymentTokenStatusChanged(status: result == true ? .success : .fail)
                if result {
                    verificationFinishBlock?()
                } else {
                    // if request still has an error, start human verification UI
                    self.startMenuCoordinator(parameters: parameters, completion: completion)
                }
            }))
        } else {
            // start human verification UI
            startMenuCoordinator(parameters: parameters, completion: completion)
        }
    }

    private func startMenuCoordinator(parameters: HumanVerifyParameters, completion: (@escaping (HumanVerifyFinishReason) -> Void)) {
        prepareV3Coordinator(parameters: parameters)
        responseDelegate?.onHumanVerifyStart()
        verificationCompletion = completion
    }
    
    private func prepareV3Coordinator(parameters: HumanVerifyParameters) {
        coordinatorV3 = HumanCheckV3Coordinator(rootViewController: rootViewController, apiService: apiService, parameters: parameters, clientApp: clientApp)
        coordinatorV3?.delegate = self
        coordinatorV3?.start()
    }

    public func getSupportURL() -> URL {
        return supportURL
    }
}

extension HumanCheckHelper: HumanCheckMenuCoordinatorDelegate {
    func verificationCode(tokenType: TokenType, verificationCodeBlock: @escaping (SendVerificationCodeBlock)) {
        let client = TestApiClient(api: self.apiService)
        let route = client.createHumanVerifyRoute(destination: tokenType.destination, type: tokenType.verifyMethod, token: tokenType.token)
        verificationCompletion?(.verification(header: route.header, verificationCodeBlock: { result, error, finish in
            verificationCodeBlock(result, error, finish)
            if result {
                self.responseDelegate?.onHumanVerifyEnd(result: .success)
            }
        }))
    }

    func close() {
        verificationCompletion?(.close)
        self.responseDelegate?.onHumanVerifyEnd(result: .cancel)
    }
    
    func closeWithError(code: Int, description: String) {
        verificationCompletion?(.closeWithError(code: code, description: description))
        self.responseDelegate?.onHumanVerifyEnd(result: .cancel)
    }
}
