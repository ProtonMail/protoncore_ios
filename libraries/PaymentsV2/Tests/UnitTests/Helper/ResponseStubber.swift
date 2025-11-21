//
//  ResponseStubber.swift
//  ProtonCore
//
//  Created by Tiziano Bruni on 04/11/2025.
//

import Foundation
import ProtonCorePaymentsV2

public struct ResponseStubber {

    public static func remoteResponseFor(transactionState: TransactionHandlerState) -> [String: Any] {

        switch transactionState {
        case .fetchUserUUID:
            return [
                "Code": 1000,
                "UUID": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
            ]
        case .creatingTransactionToken:
            return [
                "Code": 1000,
                "Status": 1,
                "Token": "IM_A_TOKEN",
                "Data": NSNull()
            ]
        case .iapStatusCheck:
            return Bundle.main.loadJsonDataToDic(from: "IAPStatus.json")
        case .fetchProtonPlans:
            return Bundle.main.loadJsonDataToDic(from: "availablePlans.json")
        case .createNewSubscription:
            return ["Code": 1000]
        case .generatingReceipt:
            return [
                "Code": 1000,
                "Token": "abc",
                "Status": 1,
                "Data": NSNull()
            ]
        case .waitingTokenResponse:
            return ["Code": 1000,
                    "Status": 1]
        default:
            return [:]
        }
    }
}
