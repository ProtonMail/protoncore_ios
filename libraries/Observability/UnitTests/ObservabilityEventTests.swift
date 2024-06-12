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

    let ios_core_external_account_available_signup_total_v2 = """
    {
        "$id": "https://proton.me/ios_core_external_account_available_signup_total_v2.schema.json",
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
                            "failed",
                            "apiMightBeBlocked",
                            "notAvailable"
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
        try ExternalAccountAvailableStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .externalAccountAvailableSignupTotal(status: status),
                                                              schema: ios_core_external_account_available_signup_total_v2)
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
                            "plan_selection",
                            "change_password",
                            "change_mailbox_password",
                            "change_password_2fa"
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

    let ios_core_accountRecovery_screenView_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "screen_id": {
                        "type": "string",
                        "enum": [
                            "gracePeriodInfo",
                            "cancelResetPassword",
                            "passwordChangeInfo",
                            "recoveryCancelledInfo",
                            "recoveryExpiredInfo"
                        ]
                    }
                },
                "required": ["screen_id"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_accountRecovery_screenView_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.AccountRecoveryScreenViewTotal",
        "description": "Screen views for account recovery",
        "additionalProperties": false
    }
    """

    func testAccountRecoveryScreenViewEvent() throws {
        try AccountRecoveryScreenViewScreenID.allCases.forEach { screenName in
            let issues = try validatePayloadAccordingToSchema(
                event: .accountRecoveryScreenView(screenID: screenName),
                schema: ios_core_accountRecovery_screenView_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }

    let ios_core_accountRecovery_cancellation_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http1xx",
                            "http200",
                            "http2xx",
                            "http3xx",
                            "http400",
                            "http4xx",
                            "http5xx",
                            "connectionError",
                            "notConnected",
                            "parseError",
                            "sslError",
                            "wrongPassword",
                            "cancellation",
                            "tooManyRequests",
                            "unknown"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_accountRecovery_cancellation_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.AccountRecoveryCancellationTotal",
        "description": "Cancel an account recovery attempt.",
        "additionalProperties": false
    }
    """

    func testAccountRecoveryCancellationTotalEvent() throws {
        try AcccountRecoveryCancellationHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(
                event: .accountRecoveryCancellationTotal(status: status),
                schema: ios_core_accountRecovery_cancellation_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - planSelectionCheckout event

    let ios_core_plan_selection_checkout_total_v2 = """
    {
        "$id": "https://proton.me/ios_core_plan_selection_checkout_total_v2.schema.json",
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
                            "failed",
                            "processingInProgress",
                            "apiMightBeBlocked",
                            "canceled"
                        ]
                    },
                    "plan": {
                        "type": "string",
                        "enum": [
                            "unlimited",
                            "plus",
                            "free",
                            "paid"
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
        try PlanSelectionCheckoutStatus.allCases.forEach { status in
            try PlanName.allCases.forEach { plan in
                let issues = try validatePayloadAccordingToSchema(event: .planSelectionCheckoutTotal(status: status, plan: plan),
                                                                  schema: ios_core_plan_selection_checkout_total_v2)
                XCTAssertEqual(issues, .noIssues)
            }
        }
    }

    // MARK: - changePasswordUpdateLoginPassword event

    let ios_core_changePassword_updateLoginPassword_total_v2 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http200",
                            "http2xx",
                            "http4xx",
                            "http401",
                            "http5xx",
                            "invalidCredentials",
                            "invalidUserName",
                            "invalidModulusID",
                            "invalidModulus",
                            "cantHashPassword",
                            "cantGenerateVerifier",
                            "cantGenerateSRPClient",
                            "keyUpdateFailed",
                            "unknown"
                        ]
                    },
                    "twoFactorMode": {
                        "type": "string",
                        "enum": ["disabled", "totp", "webauthn"]
                    }
                },
                "required": ["status", "twoFactorMode"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_changePassword_updateLoginPassword_total_v2.schema.json",
        "title": "me.proton.core.observability.domain.metrics.ChangePasswordUpdateLoginPasswordTotal",
        "description": "Upgrade password request.",
        "additionalProperties": false
    }
    """

    func testChangePasswordUpdateLoginPasswordEvent() throws {
        try PasswordChangeHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .updateLoginPassword(status: status, twoFactorMode: .webauthn),
                                                              schema: ios_core_changePassword_updateLoginPassword_total_v2)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - changePasswordUpdateMailboxPassword event

    let ios_core_changePassword_updateMailboxPassword_total_v2 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http200",
                            "http2xx",
                            "http4xx",
                            "http401",
                            "http5xx",
                            "invalidCredentials",
                            "invalidUserName",
                            "invalidModulusID",
                            "invalidModulus",
                            "cantHashPassword",
                            "cantGenerateVerifier",
                            "cantGenerateSRPClient",
                            "keyUpdateFailed",
                            "unknown"
                        ]
                    },
                    "twoFactorMode": {
                        "type": "string",
                        "enum": ["disabled", "totp", "webauthn"]
                    }
                },
                "required": ["status", "twoFactorMode"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_changePassword_updateMailboxPassword_total_v2.schema.json",
        "title": "me.proton.core.observability.domain.metrics.ChangePasswordUpdateMailboxPasswordTotal",
        "description": "Updating user keys for password change request.",
        "additionalProperties": false
    }
    """

    func testChangePasswordUpdateMailboxPasswordEvent() throws {
        try PasswordChangeHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .updateMailboxPassword(status: status, twoFactorMode: .totp),
                                                              schema: ios_core_changePassword_updateMailboxPassword_total_v2)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - protonAccountAvailableSignup event

    let ios_core_proton_account_available_signup_total_v2 = """
    {
        "$id": "https://proton.me/ios_core_proton_account_available_signup_total_v2.schema.json",
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
                            "failed",
                            "apiMightBeBlocked",
                            "notAvailable"
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
        try ProtonAccountAvailableSignupStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .protonAccountAvailableSignupTotal(status: status),
                                                              schema: ios_core_proton_account_available_signup_total_v2)
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - Dynamic plans events

    let ios_core_checkout_dynamicPlans_getDynamicSubscription_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http2xx",
                            "http409",
                            "http422",
                            "http4xx",
                            "http5xx",
                            "unknown"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_checkout_dynamicPlans_getDynamicSubscription_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.CheckoutGetDynamicSubscriptionTotal",
        "description": "Querying for a current dynamic subscription.",
        "additionalProperties": false
    }
    """

    func testProtonCurrentPlanLoadEvent() throws {
        try DynamicPlansHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(
                event: .currentPlanLoad(status: status),
                schema: ios_core_checkout_dynamicPlans_getDynamicSubscription_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }

    let ios_core_checkout_dynamicPlans_getDynamicPlans_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http2xx",
                            "http409",
                            "http422",
                            "http4xx",
                            "http5xx",
                            "unknown"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_checkout_dynamicPlans_getDynamicPlans_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.CheckoutGetDynamicPlansTotal",
        "description": "Querying for a current dynamic subscription.",
        "additionalProperties": false
    }
    """

    func testProtonAvailablePlansLoadEvent() throws {
        try DynamicPlansHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(
                event: .availablePlansLoad(status: status),
                schema: ios_core_checkout_dynamicPlans_getDynamicPlans_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }

    // MARK: - Push notifications events

    let ios_core_pushNotifications_permission_requested_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "result": {
                        "type": "string",
                        "enum": ["accepted", "rejected"]
                    }
                },
                "required": ["result"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_pushNotifications_permission_requested_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.PushNotificationsPermissionRequestedTotal",
        "description": "Count of requests for push notifications permissions on the client.",
        "additionalProperties": false
    }
    """

    func testPushNotificationsPermissionRequestedEvent() throws {
        try PushNotificationsPermissionsResponse.allCases.forEach { result in
            let issues = try validatePayloadAccordingToSchema(
                event: .pushNotificationsPermissionsRequested(result: result),
                schema: ios_core_pushNotifications_permission_requested_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }

    let ios_core_pushNotifications_received_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "result": {
                        "type": "string",
                        "enum": ["handled", "ignored"]
                    },
                    "application_status": {
                        "type": "string",
                        "enum": ["active", "inactive"]
                    }
                },
                "required": ["result", "application_status"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_pushNotifications_received_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.PushNotificationsReceivedTotal",
        "description": "Count of incoming push notifications.",
        "additionalProperties": false
    }
    """

    func testPushNotificationsReceivedEvent() throws {
        try PushNotificationsReceivedResult.allCases.forEach { result in
            try ApplicationStatus.allCases.forEach { applicationStatus in
                let issues = try validatePayloadAccordingToSchema(
                    event: .pushNotificationsReceived(result: result,
                                                      applicationStatus: applicationStatus),
                    schema: ios_core_pushNotifications_received_total_v1
                )
                XCTAssertEqual(issues, .noIssues)
            }
        }
    }

    let ios_core_pushNotifications_token_registration_total_v1 = """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "properties": {
            "Labels": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "http1xx",
                            "http200",
                            "http2xx",
                            "http3xx",
                            "http400",
                            "http401",
                            "http403",
                            "http408",
                            "http421",
                            "http422",
                            "http4xx",
                            "http500",
                            "http503",
                            "http5xx",
                            "connectionError",
                            "sslError",
                            "unknown"
                        ]
                    }
                },
                "required": ["status"],
                "additionalProperties": false
            },
            "Value": {
                "type": "integer",
                "minimum": 1
            }
        },
        "required": ["Labels", "Value"],
        "$id": "https://proton.me/ios_core_pushNotifications_token_registration_total_v1.schema.json",
        "title": "me.proton.core.observability.domain.metrics.PushNotificationsTokenRegistrationTotal",
        "description": "Count of device registrations with APNS tokens to Proton backend.",
        "additionalProperties": false
    }
    """

    func testPushNotificationsTokenRegistrationEvent() throws {
        try PushNotificationsHTTPResponseCodeStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(
                event: .pushNotificationsTokenRegistered(status: status),
                schema: ios_core_pushNotifications_token_registration_total_v1
            )
            XCTAssertEqual(issues, .noIssues)
        }
    }


    // MARK: - WebAuthn events

    let ios_core_login_2fa_auth_total_v1 = """
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
        "Labels": {
            "type": "object",
            "properties": {
                "status": {
                    "type": "string",
                    "enum": ["http2xx", "http4xx", "http5xx", "unknown"]
                },
                "twoFAType": {
                    "type": "string",
                    "enum": ["totp", "webauthn"]
                }
            },
            "required": ["status", "twoFAType"],
            "additionalProperties": false
        },
        "Value": {
            "type": "integer",
            "minimum": 1
        }
    },
    "required": ["Labels", "Value"],
    "$id": "https://proton.me/ios_core_login_2fa_auth_total_v1.schema.json",
    "title": "me.proton.core.observability.domain.metrics.LoginAuthWith2FATotal",
    "description": "Perform an auth, using 2FA.",
    "additionalProperties": false
}
"""

    let ios_core_webauthn_request_total_v1 = """
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
        "Labels": {
            "type": "object",
            "properties": {
                "status": {
                    "type": "string",
                    "enum": [
                        "authorizedFIDO2",
                            "authorizedPasskey",
                            "authorizedUnsupportedType",
                            "authorizedMissingChallenge",
                            "errorCanceled",
                            "errorFailed",
                            "errorInvalidResponse",
                            "errorNotHandled",
                            "errorUnknown",
                            "errorNotInteractive",
                            "errorOther"
                    ]
                }
            },
            "required": ["status"],
            "additionalProperties": false
        },
        "Value": {
            "type": "integer",
            "minimum": 1
        }
    },
    "required": ["Labels", "Value"],
    "$id": "https://proton.me/ios_core_webauthn_request_total_v1.schema.json",
    "title": "me.proton.core.observability.domain.metrics.WebAuthnRequestTotal",
    "description": "Authenticating for 2FA with WebAuthn.",
    "additionalProperties": false
}
"""

    func testLogin2FAAuthEvent() throws {
        try HTTPResponseCodeStatus.allCases.forEach { status in
            try TwoFAType.allCases.forEach { type in
                let issues = try validatePayloadAccordingToSchema(event: .loginAuthWith2FATotalEvent(status: status,
                                                                                                     twoFAType: type),
                                                                  schema: ios_core_login_2fa_auth_total_v1)
                XCTAssertEqual(issues, .noIssues)
            }
        }
    }

    func testWebAuthnRequestEvent() throws {
        try WebAuthnRequestStatus.allCases.forEach { status in
            let issues = try validatePayloadAccordingToSchema(event: .webAuthnRequestTotal(status: status),
                                                              schema: ios_core_webauthn_request_total_v1)
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
