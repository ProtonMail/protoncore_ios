//
//  ObservabilityEventTests.swift
//  ProtonCore-Observability-Tests - Created on 16.12.22.
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

import XCTest
import JSONSchema
@testable import ProtonCoreObservability

final class ObservabilityEventTests: XCTestCase {

    func testEnvelope() throws {
        let dummyEvent = ObservabilityEvent(name: "dummy name", version: .v1, data: "dummy data")
        let eventData = try jsonEncoder.encode(dummyEvent)
        let eventJsonObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: eventData, options: []) as? [String: Any])
        guard let name = eventJsonObject["Name"] as? String else { XCTFail(); return }
        XCTAssertEqual(name, "dummy name")
        guard let version = eventJsonObject["Version"] as? Int else { XCTFail(); return }
        XCTAssertEqual(version, 1)
        guard let data = eventJsonObject["Data"] as? String else { XCTFail(); return }
        XCTAssertEqual(data, "dummy data")
        guard let timestamp = eventJsonObject["Timestamp"] as? TimeInterval else { XCTFail(); return }
        XCTAssertEqual(timestamp, Date().timeIntervalSince1970, accuracy: 1.0)
    }

    // MARK: - externalAccountAvailableSignup event

    let ios_core_external_account_available_signup_total_v1 = """
    {
        "$id": "https://proton.me/ios_core_external_account_available_signup_total_v1.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core external account availability in signup process",
        "description": "Metric for the success or failure of the external account availability in the signup process",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "successful",
                            "failed"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testExternalAccountAvailableSignupEvent() throws {
        try SuccessOrFailureStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .externalAccountAvailableSignupTotal(status: status),
                                                              schema: ios_core_external_account_available_signup_total_v1)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - humanVerificationOutcome event

    let ios_core_human_verification_outcome_total_v2 = """
    {
        "$id": "https://proton.me/ios_core_human_verification_outcome_total_v2.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core human verification status",
        "description": "Metric for the status of human verification outcome",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "successful",
                            "failed",
                            "canceled",
                            "addressAlreadyTaken",
                            "invalidVerificationCode"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testHumanVerificationOutcomeEvent() throws {
        try HumanVerificationOutcomeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .humanVerificationOutcomeTotal(status: status),
                                                              schema: ios_core_human_verification_outcome_total_v2)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - humanVerificationScreenLoad event

    let ios_core_human_verification_screen_load_total_v1 = """
    {
        "$id": "https://proton.me/ios_core_human_verification_screen_load_total_v1.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core human verification screen load",
        "description": "Metric for the status of human verification screen load",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "successful",
                            "failed"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testHumanVerificationScreenLoadEvent() throws {
        try SuccessOrFailureStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .humanVerificationScreenLoadTotal(status: status),
                                                              schema: ios_core_human_verification_screen_load_total_v1)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - screenLoadCount event

    let ios_core_screen_load_count_total_v1 = """
    {
        "$id": "https://proton.me/ios_core_screen_load_count_total_v1.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core screen load count",
        "description": "Metric for the screen load count of each screen",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "screen_name": {
                        "type": "string",
                        "enum": [
                            "external_account_available",
                            "proton_account_available",
                            "password_creation",
                            "set_recovery_method",
                            "email_verification",
                            "congratulation",
                            "create_proton_account_with_current_email",
                            "plan_selection"
                        ]
                    }
                },
                "required": ["screen_name"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testScreenLoadCountEvent() throws {
        try ScreenName.allCases.forEach { screenName in
            let issues = try validatePayloadAccordingToSchema(event: .screenLoadCountTotal(screenName: screenName),
                                                              schema: ios_core_screen_load_count_total_v1)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - planSelectionCheckout event

    let ios_core_plan_selection_checkout_total_v1 = """
    {
        "$id": "https://proton.me/ios_core_plan_selection_checkout_total_v1.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core plan selection checkout status",
        "description": "Metric for the status of plan selection checkout",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "successful",
                            "failed"
                        ]
                    },
                    "plan": {
                        "type": "string",
                        "enum": [
                            "unlimited",
                            "plus",
                            "free"
                        ]
                    }
                },
                "required": ["status", "plan"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testPlanSelectionCheckoutEvent() throws {
        try SuccessOrFailureStatus.allCases.forEach { status in
            try PlanName.allCases.forEach { plan in
                let issues = try validatePayloadAccordingToSchema(event: .planSelectionCheckoutTotal(status: status, plan: plan),
                                                                  schema: ios_core_plan_selection_checkout_total_v1)
                XCTAssertEqual(issues, .noIssues)
            }
        }
    }

    // MARK: - protonAccountAvailableSignup event

    let ios_core_proton_account_available_signup_total_v1 = """
    {
        "$id": "https://proton.me/ios_core_proton_account_available_signup_total_v1.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "iOS Core proton account availability in signup process",
        "description": "Metric for the success or failure of the proton account availability in signup process",
        "type": "object",
        "properties": {
            "Value": {
                "type": "integer",
                "minimum": 1
            },
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "successful",
                            "failed"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            }
        },
        "required": ["Value", "Labels"],
        "additionalProperties": false
    }
    """

    func testProtonAccountAvailableSignupEvent() throws {
        try SuccessOrFailureStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .protonAccountAvailableSignupTotal(status: status),
                                                              schema: ios_core_proton_account_available_signup_total_v1)
            XCTAssertEqual(issues, .noIssues)
        }
    }
}

// MARK: - helpers

private let jsonEncoder = JSONEncoder()

private func validatePayloadAccordingToSchema<T>(event: ObservabilityEvent<T>, schema: String) throws -> [String] where T: Encodable {
    let data = try jsonEncoder.encode(event.data)
    let objectForValidation = try JSONSerialization.jsonObject(with: data, options: [])
    let schemaData = try XCTUnwrap(schema.data(using: .utf8))
    let schemaObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: schemaData, options: []) as? [String: Any])
    return try JSONSchema.validate(objectForValidation, schema: schemaObject).errors.map { $0.map(\.description) } ?? []
}

extension ValidationError: Equatable {
    public static func == (lhs: JSONSchema.ValidationError, rhs: JSONSchema.ValidationError) -> Bool {
        lhs.description == rhs.description
    }
}

private extension Array where Element == String {
    static var noIssues: Self { [] }
}
