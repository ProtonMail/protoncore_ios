// swift-tools-version:5.7

import PackageDescription

var products: [Product] = []
var targets: [Target] = []
var plugins: [Target.PluginUsage] = []

func products(from newProduct: String) -> [Product] {
    let products: [Product] = [
        .library(name: newProduct, targets: [newProduct])
    ]

    let binaryFrameworksNotSupportingDynamicLibrary: [String] = [
        .goLibsCryptoGo,
        .goLibsCryptoSearchGo,
        .goLibsCryptoPatchedGo,
        .goLibsCryptoVPNPatchedGo,
        .vCard
    ]

    guard binaryFrameworksNotSupportingDynamicLibrary.contains(newProduct) == false else {
        return products
    }

    return products
}

func add(products newProducts: [Product], targets newTargets: [Target]) {
    products += newProducts
    targets += newTargets
}

func add(product newProduct: String, targets newTargets: [Target]) {
    add(
        products: products(from: newProduct),
        targets: newTargets
    )
}

func add(products newProducts: [String], targets newTargets: [Target]) {
    add(
        products: newProducts.flatMap(products(from:)),
        targets: newTargets
    )
}

func coreTarget(name: String,
                dependencies: [PackageDescription.Target.Dependency]? = nil,
                path: String,
                exclude: [String]? = nil,
                sources: [String]? = nil,
                resources: [Resource]? = nil) -> Target {
    .target(name: name,
            dependencies: dependencies ?? [],
            path: path,
            exclude: exclude ?? [],
            sources: sources,
            resources: resources,
            publicHeadersPath: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: [.spm],
            linkerSettings: nil,
            plugins: plugins)
}

func coreTestTarget(name: String,
                    dependencies: [PackageDescription.Target.Dependency]? = nil,
                    path: String,
                    exclude: [String]? = nil,
                    resources: [Resource]? = nil) -> Target {
    .testTarget(name: name,
                dependencies: dependencies ?? [],
                path: path,
                exclude: exclude ?? [],
                resources: resources,
                cSettings: nil,
                cxxSettings: nil,
                swiftSettings: [.spm],
                linkerSettings: nil,
                plugins: plugins)
}

extension SwiftSetting {
    static let spm: SwiftSetting = .define("SPM")
}

extension String {

    // MARK: - Core module names
    static let accountDeletion: String = "ProtonCoreAccountDeletion"
    static let accountRecovery: String = "ProtonCoreAccountRecovery"
    static let accountSwitcher: String = "ProtonCoreAccountSwitcher"
    static let accountSwitcherResourcesiOS: String = "ProtonCoreAccountSwitcherResourcesiOS"
    static let apiClient: String = "ProtonCoreAPIClient"
    static let authentication: String = "ProtonCoreAuthentication"
    static let authenticationKeyGeneration: String = "ProtonCoreAuthenticationKeyGeneration"
    static let challenge: String = "ProtonCoreChallenge"
    static let common: String = "ProtonCoreCommon"
    static let crypto: String = "ProtonCoreCrypto"
    static let cryptoGoInterface: String = "ProtonCoreCryptoGoInterface"
    static let cryptoGoImplementation: String = "ProtonCoreCryptoGoImplementation"
    static let cryptoPatchedGoImplementation: String = "ProtonCoreCryptoPatchedGoImplementation"
    static let cryptoVPNPatchedGoImplementation: String = "ProtonCoreCryptoVPNPatchedGoImplementation"
    static let cryptoSearchGoImplementation: String = "ProtonCoreCryptoSearchGoImplementation"
    static let dataModel: String = "ProtonCoreDataModel"
    static let doh: String = "ProtonCoreDoh"
    static let environment: String = "ProtonCoreEnvironment"
    static let features: String = "ProtonCoreFeatures"
    static let featureFlags: String = "ProtonCoreFeatureFlags"
    static let forceUpgrade: String = "ProtonCoreForceUpgrade"
    static let foundations: String = "ProtonCoreFoundations"
    static let goLibsCryptoGo: String = "GoLibsCryptoGo"
    static let goLibsCryptoPatchedGo: String = "GoLibsCryptoPatchedGo"
    static let goLibsCryptoVPNPatchedGo: String = "GoLibsCryptoVPNPatchedGo"
    static let goLibsCryptoSearchGo: String = "GoLibsCryptoSearchGo"
    static let hash: String = "ProtonCoreHash"
    static let humanVerification: String = "ProtonCoreHumanVerification"
    static let humanVerificationResourcesiOS: String = "ProtonCoreHumanVerificationResourcesiOS"
    static let humanVerificationResourcesmacOS: String = "ProtonCoreHumanVerificationResourcesmacOS"
    static let keymaker: String = "ProtonCoreKeymaker"
    static let keyManager: String = "ProtonCoreKeyManager"
    static let log: String = "ProtonCoreLog"
    static let login: String = "ProtonCoreLogin"
    static let loginUI: String = "ProtonCoreLoginUI"
    static let loginUIResourcesiOS: String = "ProtonCoreLoginUIResourcesiOS"
    static let missingScopes: String = "ProtonCoreMissingScopes"
    static let networking: String = "ProtonCoreNetworking"
    static let obfuscatedConstants: String = "ProtonCoreObfuscatedConstants"
    static let observability: String = "ProtonCoreObservability"
    static let passwordChange: String = "ProtonCorePasswordChange"
    static let passwordRequest: String = "ProtonCorePasswordRequest"
    static let payments: String = "ProtonCorePayments"
    static let paymentsUI: String = "ProtonCorePaymentsUI"
    static let paymentsUIResourcesiOS: String = "ProtonCorePaymentsUIResourcesiOS"
    static let pushNotifications: String = "ProtonCorePushNotifications"
    static let quarkCommands: String = "ProtonCoreQuarkCommands"
    static let services: String = "ProtonCoreServices"
    static let settings: String = "ProtonCoreSettings"
    static let telemetry: String = "ProtonCoreTelemetry"
    static let testingToolkit: String = "ProtonCoreTestingToolkit"
    static let testingToolkitTestData: String = "ProtonCoreTestingToolkitTestData"
    static let testingToolkitUnitTestsAccountDeletion: String = "ProtonCoreTestingToolkitUnitTestsAccountDeletion"
    static let testingToolkitUnitTestsAuthentication: String = "ProtonCoreTestingToolkitUnitTestsAuthentication"
    static let testingToolkitUnitTestsAuthenticationKeyGeneration: String = "ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration"
    static let testingToolkitUnitTestsCore: String = "ProtonCoreTestingToolkitUnitTestsCore"
    static let testingToolkitUnitTestsCryptoGoInterface: String = "ProtonCoreTestingToolkitUnitTestsCryptoGoInterface"
    static let testingToolkitUnitTestsDataModel: String = "ProtonCoreTestingToolkitUnitTestsDataModel"
    static let testingToolkitUnitTestsDoh: String = "ProtonCoreTestingToolkitUnitTestsDoh"
    static let testingToolkitUnitTestsFeatureFlag: String = "ProtonCoreTestingToolkitUnitTestsFeatureFlag"
    static let testingToolkitUnitTestsLogin: String = "ProtonCoreTestingToolkitUnitTestsLogin"
    static let testingToolkitUnitTestsLoginUI: String = "ProtonCoreTestingToolkitUnitTestsLoginUI"
    static let testingToolkitUnitTestsNetworking: String = "ProtonCoreTestingToolkitUnitTestsNetworking"
    static let testingToolkitUnitTestsObservability: String = "ProtonCoreTestingToolkitUnitTestsObservability"
    static let testingToolkitUnitTestsPayments: String = "ProtonCoreTestingToolkitUnitTestsPayments"
    static let testingToolkitUnitTestsServices: String = "ProtonCoreTestingToolkitUnitTestsServices"
    static let testingToolkitUITestsAccountDeletion: String = "ProtonCoreTestingToolkitUITestsAccountDeletion"
    static let testingToolkitUITestsAccountSwitcher: String = "ProtonCoreTestingToolkitUITestsAccountSwitcher"
    static let testingToolkitUITestsCore: String = "ProtonCoreTestingToolkitUITestsCore"
    static let testingToolkitUITestsHumanVerification: String = "ProtonCoreTestingToolkitUITestsHumanVerification"
    static let testingToolkitUITestsLogin: String = "ProtonCoreTestingToolkitUITestsLogin"
    static let testingToolkitUITestsPaymentsUI: String = "ProtonCoreTestingToolkitUITestsPaymentsUI"
    static let troubleShooting: String = "ProtonCoreTroubleShooting"
    static let troubleShootingResourcesiOS: String = "ProtonCoreTroubleShootingResourcesiOS"
    static let uiFoundations: String = "ProtonCoreUIFoundations"
    static let uiFoundationsResourcesiOS: String = "ProtonCoreUIFoundationsResourcesiOS"
    static let uiFoundationsResourcestvOS: String = "ProtonCoreUIFoundationsResourcestvOS"
    static let uiFoundationsResourcesmacOS: String = "ProtonCoreUIFoundationsResourcesmacOS"
    static let utilities: String = "ProtonCoreUtilities"
    static let vCard: String = "ProtonCoreVCard"

    // MARK: - Dependencies names
    static let alamofire: String = "Alamofire"

    static let cryptoSwift: String = "CryptoSwift"
    static let ellipticCurveKeyPair: String = "EllipticCurveKeyPair"
    static let fusion: String = "fusion"
    static let fusionPackage: String = "apple-fusion"
    static let jsonSchema: String = "JSONSchema"
    static let jsonSchemaPackage: String = "JSONSchema.swift"
    static let lottie: String = "Lottie"
    static let lottiePackage: String = "lottie-ios"
    static let ohhttpStubs: String = "OHHTTPStubsSwift"
    static let ohhttpStubsPackage: String = "OHHTTPStubs"
    static let reachabilitySwift: String = "Reachability"
    static let reachabilitySwiftPackage: String = "Reachability.swift"
    static let sentry: String = "Sentry"
    static let sentryPackage: String = "sentry-cocoa"
    static let sdWebImage: String = "SDWebImage"
    static let swiftBCrypt: String = "SwiftBCrypt"
    static let swiftOTP: String = "SwiftOTP"
    static let snapshotTesting: String = "SnapshotTesting"
    static let snapshotTestingPackage: String = "swift-snapshot-testing"
    static let trustKit: String = "TrustKit"
    static let viewInspector: String = "ViewInspector"

    // MARK: - Plugin names

    static let obfuscatedConstantsGenerationPlugin: String = "ObfuscatedConstantsGenerationPlugin"
}

extension Target.Dependency {

    // MARK: - Core module targets

    static var accountDeletion: Target.Dependency { .target(name: .accountDeletion) }
    static var accountRecovery: Target.Dependency { .target(name: .accountRecovery) }
    static var accountSwitcher: Target.Dependency { .target(name: .accountSwitcher) }
    static var accountSwitcherResourcesiOS: Target.Dependency { .target(name: .accountSwitcherResourcesiOS,
                                                                        condition: .when(platforms: [.iOS])) }
    static var apiClient: Target.Dependency { .target(name: .apiClient) }
    static var authentication: Target.Dependency { .target(name: .authentication) }
    static var authenticationKeyGeneration: Target.Dependency { .target(name: .authenticationKeyGeneration) }
    static var challenge: Target.Dependency { .target(name: .challenge) }
    static var common: Target.Dependency { .target(name: .common) }
    static var crypto: Target.Dependency { .target(name: .crypto) }
    static var cryptoGoInterface: Target.Dependency { .target(name: .cryptoGoInterface) }
    static var cryptoGoImplementation: Target.Dependency { .target(name: .cryptoGoImplementation) }
    static var cryptoPatchedGoImplementation: Target.Dependency { .target(name: .cryptoPatchedGoImplementation) }
    static var cryptoVPNPatchedGoImplementation: Target.Dependency { .target(name: .cryptoVPNPatchedGoImplementation) }
    static var cryptoSearchGoImplementation: Target.Dependency { .target(name: .cryptoSearchGoImplementation) }
    static var dataModel: Target.Dependency { .target(name: .dataModel) }
    static var doh: Target.Dependency { .target(name: .doh) }
    static var environment: Target.Dependency { .target(name: .environment) }
    static var features: Target.Dependency { .target(name: .features) }
    static var featureFlags: Target.Dependency { .target(name: .featureFlags) }
    static var forceUpgrade: Target.Dependency { .target(name: .forceUpgrade) }
    static var foundations: Target.Dependency { .target(name: .foundations) }
    static var goLibsCryptoGo: Target.Dependency { .target(name: .goLibsCryptoGo) }
    static var goLibsCryptoPatchedGo: Target.Dependency { .target(name: .goLibsCryptoPatchedGo) }
    static var goLibsCryptoVPNPatchedGo: Target.Dependency { .target(name: .goLibsCryptoVPNPatchedGo) }
    static var goLibsCryptoSearchGo: Target.Dependency { .target(name: .goLibsCryptoSearchGo) }
    static var hash: Target.Dependency { .target(name: .hash) }
    static var humanVerification: Target.Dependency { .target(name: .humanVerification) }
    static var humanVerificationResourcesiOS: Target.Dependency { .target(name: .humanVerificationResourcesiOS,
                                                                          condition: .when(platforms: [.iOS])) }
    static var humanVerificationResourcesmacOS: Target.Dependency { .target(name: .humanVerificationResourcesmacOS,
                                                                            condition: .when(platforms: [.macOS])) }
    static var keymaker: Target.Dependency { .target(name: .keymaker) }
    static var keyManager: Target.Dependency { .target(name: .keyManager) }
    static var log: Target.Dependency { .target(name: .log) }
    static var login: Target.Dependency { .target(name: .login) }
    static var loginUI: Target.Dependency { .target(name: .loginUI) }
    static var loginUIResourcesiOS: Target.Dependency { .target(name: .loginUIResourcesiOS,
                                                                condition: .when(platforms: [.iOS])) }
    static var missingScopes: Target.Dependency { .target(name: .missingScopes) }
    static var networking: Target.Dependency { .target(name: .networking) }
    static var obfuscatedConstants: Target.Dependency { .target(name: .obfuscatedConstants) }
    static var observability: Target.Dependency { .target(name: .observability) }
    static var passwordChange: Target.Dependency { .target(name: .passwordChange) }
    static var passwordRequest: Target.Dependency { .target(name: .passwordRequest) }
    static var payments: Target.Dependency { .target(name: .payments) }
    static var paymentsUI: Target.Dependency { .target(name: .paymentsUI) }
    static var paymentsUIResourcesiOS: Target.Dependency { .target(name: .paymentsUIResourcesiOS,
                                                                   condition: .when(platforms: [.iOS])) }
    static var pushNotifications: Target.Dependency { .target(name: .pushNotifications) }
    static var quarkCommands: Target.Dependency { .target(name: .quarkCommands) }
    static var services: Target.Dependency { .target(name: .services) }
    static var settings: Target.Dependency { .target(name: .settings) }
    static var telemetry: Target.Dependency { .target(name: .telemetry) }
    static var testingToolkit: Target.Dependency { .target(name: .testingToolkit) }
    static var testingToolkitTestData: Target.Dependency { .target(name: .testingToolkitTestData) }
    static var testingToolkitUnitTestsAccountDeletion: Target.Dependency { .target(name: .testingToolkitUnitTestsAccountDeletion) }
    static var testingToolkitUnitTestsAuthentication: Target.Dependency { .target(name: .testingToolkitUnitTestsAuthentication) }
    static var testingToolkitUnitTestsAuthenticationKeyGeneration: Target.Dependency { .target(name: .testingToolkitUnitTestsAuthenticationKeyGeneration) }
    static var testingToolkitUnitTestsCore: Target.Dependency { .target(name: .testingToolkitUnitTestsCore) }
    static var testingToolkitUnitTestsCryptoGoInterface: Target.Dependency { .target(name: .testingToolkitUnitTestsCryptoGoInterface) }
    static var testingToolkitUnitTestsDataModel: Target.Dependency { .target(name: .testingToolkitUnitTestsDataModel) }
    static var testingToolkitUnitTestsDoh: Target.Dependency { .target(name: .testingToolkitUnitTestsDoh) }
    static var testingToolkitUnitTestsFeatureFlag: Target.Dependency { .target(name: .testingToolkitUnitTestsFeatureFlag) }
    static var testingToolkitUnitTestsLogin: Target.Dependency { .target(name: .testingToolkitUnitTestsLogin) }
    static var testingToolkitUnitTestsLoginUI: Target.Dependency { .target(name: .testingToolkitUnitTestsLoginUI) }
    static var testingToolkitUnitTestsNetworking: Target.Dependency { .target(name: .testingToolkitUnitTestsNetworking) }
    static var testingToolkitUnitTestsObservability: Target.Dependency { .target(name: .testingToolkitUnitTestsObservability) }
    static var testingToolkitUnitTestsPayments: Target.Dependency { .target(name: .testingToolkitUnitTestsPayments) }
    static var testingToolkitUnitTestsServices: Target.Dependency { .target(name: .testingToolkitUnitTestsServices) }

    static var testingToolkitUITestsAccountDeletion: Target.Dependency { .target(name: .testingToolkitUITestsAccountDeletion) }
    static var testingToolkitUITestsAccountSwitcher: Target.Dependency { .target(name: .testingToolkitUITestsAccountSwitcher) }
    static var testingToolkitUITestsCore: Target.Dependency { .target(name: .testingToolkitUITestsCore) }
    static var testingToolkitUITestsHumanVerification: Target.Dependency { .target(name: .testingToolkitUITestsHumanVerification) }
    static var testingToolkitUITestsLogin: Target.Dependency { .target(name: .testingToolkitUITestsLogin) }
    static var testingToolkitUITestsPaymentsUI: Target.Dependency { .target(name: .testingToolkitUITestsPaymentsUI) }

    static var troubleShooting: Target.Dependency { .target(name: .troubleShooting) }
    static var troubleShootingResourcesiOS: Target.Dependency { .target(name: .troubleShootingResourcesiOS,
                                                                        condition: .when(platforms: [.iOS])) }
    static var uiFoundations: Target.Dependency { .target(name: .uiFoundations) }
    static var uiFoundationsResourcesiOS: Target.Dependency { .target(name: .uiFoundationsResourcesiOS,
                                                                      condition: .when(platforms: [.iOS])) }
    static var uiFoundationsResourcestvOS: Target.Dependency { .target(name: .uiFoundationsResourcestvOS,
                                                                       condition: .when(platforms: [.tvOS])) }
    static var uiFoundationsResourcesmacOS: Target.Dependency { .target(name: .uiFoundationsResourcesmacOS,
                                                                        condition: .when(platforms: [.macOS])) }
    static var utilities: Target.Dependency { .target(name: .utilities) }
    static var vCard: Target.Dependency { .target(name: .vCard) }

    // MARK: - Dependencies targets

    static var alamofire: Target.Dependency { .product(name: .alamofire, package: .alamofire) }

    static var cryptoSwift: Target.Dependency { .product(name: .cryptoSwift, package: .cryptoSwift) }
    static var ellipticCurveKeyPair: Target.Dependency { .product(name: .ellipticCurveKeyPair, package: .ellipticCurveKeyPair) }
    static var fusion: Target.Dependency { .product(name: .fusion, package: .fusionPackage, condition: .when(platforms: [.iOS])) }
    static var jsonSchema: Target.Dependency { .product(name: .jsonSchema, package: .jsonSchemaPackage) }
    static var lottie: Target.Dependency { .product(name: .lottie, package: .lottiePackage) }
    static var ohhttpStubs: Target.Dependency { .product(name: .ohhttpStubs, package: .ohhttpStubsPackage) }
    static var reachabilitySwift: Target.Dependency { .product(name: .reachabilitySwift, package: .reachabilitySwiftPackage) }
    static var sentry: Target.Dependency { .product(name: .sentry, package: .sentryPackage) }
    static var snapshotTesting: Target.Dependency { .product(name: .snapshotTesting, package: .snapshotTestingPackage) }
    static var swiftBCrypt: Target.Dependency { .product(name: .swiftBCrypt, package: .swiftBCrypt) }
    static var swiftOTP: Target.Dependency { .product(name: .swiftOTP, package: .swiftOTP) }
    static var trustKit: Target.Dependency { .product(name: .trustKit, package: .trustKit) }
    static var sdWebImage: Target.Dependency { .product(name: .sdWebImage, package: .sdWebImage) }
    static var viewInspector: Target.Dependency { .product(name: .viewInspector, package: .viewInspector)}

    // MARK: - Helpers

    static var cryptoGoUsedInTests: Target.Dependency { .cryptoPatchedGoImplementation }
}

// MARK: - Module definitions

// MARK: AccountDeletion

add(
    product: .accountDeletion,
    targets: [
        coreTarget(name: .accountDeletion,
                   dependencies: [
                    .doh,
                    .foundations,
                    .log,
                    .utilities,
                    .uiFoundations,
                    .authentication,
                    .networking,
                    .services
                   ],
                   path: "libraries/AccountDeletion/Sources",
                   exclude: ["PMAccountDeletion"],
                   resources: [
                    .process("Shared/Resources")
                   ]),

        coreTestTarget(name: .accountDeletion + "Tests",
                       dependencies: [
                           .accountDeletion,
                           .testingToolkitUnitTestsAccountDeletion,
                           .testingToolkitUnitTestsDoh,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/AccountDeletion/Tests/UnitTests"),

        coreTestTarget(name: .accountDeletion + "LocalizationTests",
                       dependencies: [
                           .accountDeletion,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/AccountDeletion/Tests/LocalizationTests")
    ]
)

// MARK: AccountRecovery

add(
    product: .accountRecovery,
    targets: [
        coreTarget(name: .accountRecovery,
                   dependencies: [
                       .featureFlags,
                       .pushNotifications,
                       .services,
                       .authentication,
                       .dataModel,
                       .uiFoundations,
                       .networking,
                       .passwordRequest
                   ],
                   path: "libraries/AccountRecovery/Sources",
                   resources: [.process("Resources")]),

        coreTestTarget(name: .accountRecovery + "Tests",
                       dependencies: [
                           .accountRecovery,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsServices,
                           .viewInspector,
                       ],
                       path: "libraries/AccountRecovery/Tests",
                       resources: [.process("Resources")])
    ]
)

// MARK: AccountSwitcher

add(
    product: .accountSwitcher,
    targets: [
        coreTarget(name: .accountSwitcher,
                   dependencies: [
                       .uiFoundations,
                       .log,
                       .utilities,
                       .accountSwitcherResourcesiOS
                   ],
                   path: "libraries/AccountSwitcher/Sources",
                   resources: [
                       .process("Resources")
                   ]),

        coreTarget(name: .accountSwitcherResourcesiOS,
                   path: "libraries/AccountSwitcher/Resources-iOS",
                   resources: [
                       .process("Resources")
                   ]),

        coreTestTarget(name: .accountSwitcher + "Tests",
                       dependencies: [
                           .accountSwitcher,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/AccountSwitcher/Tests/UnitTests",
                       exclude: ["__Snapshots__"]),

        coreTestTarget(name: .accountSwitcher + "LocalizationTests",
                       dependencies: [
                           .accountSwitcher,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/AccountSwitcher/Tests/LocalizationTests")
    ]
)

// MARK: APIClient

add(
    product: .apiClient,
    targets: [
        coreTarget(name: .apiClient,
                   dependencies: [
                       .dataModel,
                       .networking,
                       .services
                   ],
                   path: "libraries/APIClient/Sources"),

        coreTestTarget(name: .apiClient + "Tests",
                       dependencies: [
                           .apiClient,
                           .authentication,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .challenge,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsAuthentication,
                           .ohhttpStubs,
                           .trustKit
                       ],
                       path: "libraries/APIClient/Tests",
                       resources: [.process("TestData")])
    ]
)

// MARK: Authentication-KeyGeneration

add(
    product: .authenticationKeyGeneration,
    targets: [
        coreTarget(name: .authenticationKeyGeneration,
                   dependencies: [
                       .authentication,
                       .crypto,
                       .cryptoGoInterface,
                       .hash,
                       .utilities
                   ],
                   path: "libraries/Authentication-KeyGeneration/Sources"),

        coreTestTarget(name: .authenticationKeyGeneration + "Tests",
                       dependencies: [
                           .authenticationKeyGeneration,
                           .cryptoGoUsedInTests,
                           .hash,
                           .obfuscatedConstants,
                           .ohhttpStubs,
                           .swiftBCrypt
                       ],
                       path: "libraries/Authentication-KeyGeneration/Tests",
                       resources: [.process("TestData")])
    ]
)

// MARK: Authentication

add(
    product: .authentication,
    targets: [
        coreTarget(name: .authentication,
                   dependencies: [
                       .apiClient,
                       .crypto,
                       .cryptoGoInterface,
                       .featureFlags,
                       .foundations,
                       .services
                   ],
                   path: "libraries/Authentication/Sources"),

        coreTestTarget(name: .authentication + "Tests",
                       dependencies: [
                           .authentication,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .testingToolkitUnitTestsAuthentication,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsObservability,
                           .ohhttpStubs
                       ],
                       path: "libraries/Authentication/Tests")
    ]
)

// MARK: Challenge

add(
    product: .challenge,
    targets: [
        coreTarget(name: .challenge,
                   dependencies: [
                       .dataModel,
                       .foundations,
                       .uiFoundations
                   ],
                   path: "libraries/Challenge/Sources"),

        coreTestTarget(name: .challenge + "Tests",
                       dependencies: [
                           .challenge
                       ],
                       path: "libraries/Challenge/Tests")
    ]
)

// MARK: Common

add(
    product: .common,
    targets: [
        coreTarget(name: .common,
                   dependencies: [
                       .networking,
                       .services,
                       .uiFoundations
                   ],
                   path: "libraries/Common/Sources")
    ]
)

// MARK: Crypto

add(
    product: .crypto,
    targets: [
        coreTarget(name: .crypto,
                   dependencies: [
                       .cryptoGoInterface,
                       .dataModel
                   ],
                   path: "libraries/Crypto/Sources"),

        coreTestTarget(name: .crypto + "Tests",
                       dependencies: [
                           .crypto,
                           .cryptoGoUsedInTests,
                           .utilities
                       ],
                       path: "libraries/Crypto/Tests",
                       resources: [
                           .process("Resources")
                       ]),
    ]
)

// MARK: CryptoGoImplementation

add(
    products: [
        .cryptoGoImplementation,
        .cryptoPatchedGoImplementation,
        .cryptoVPNPatchedGoImplementation,
        .cryptoSearchGoImplementation
    ],
    targets: [
        coreTarget(name: .cryptoGoImplementation,
                   dependencies: [
                       .goLibsCryptoGo,
                       .cryptoGoInterface,
                   ],
                   path: "libraries/CryptoGoImplementation/Crypto-Go"),

        coreTarget(name: .cryptoPatchedGoImplementation,
                   dependencies: [
                       .goLibsCryptoPatchedGo,
                       .cryptoGoInterface
                   ],
                   path: "libraries/CryptoGoImplementation/Crypto-patched-Go"),

        coreTarget(name: .cryptoVPNPatchedGoImplementation,
                   dependencies: [
                       .goLibsCryptoVPNPatchedGo,
                       .cryptoGoInterface
                   ],
                   path: "libraries/CryptoGoImplementation/Crypto+VPN-patched-Go"),

        coreTarget(name: .cryptoSearchGoImplementation,
                   dependencies: [
                       .goLibsCryptoSearchGo,
                       .cryptoGoInterface
                   ],
                   path: "libraries/CryptoGoImplementation/Crypto+Search-Go"),

        coreTestTarget(name: .cryptoGoImplementation + "Tests",
                       dependencies: [
                           .goLibsCryptoGo,
                           .cryptoGoImplementation,
                           .cryptoGoInterface
                       ],
                       path: "libraries/CryptoGoImplementation/Tests-Crypto-Go"),

        coreTestTarget(name: .cryptoPatchedGoImplementation + "Tests",
                       dependencies: [
                           .goLibsCryptoPatchedGo,
                           .cryptoPatchedGoImplementation,
                           .cryptoGoInterface
                       ],
                       path: "libraries/CryptoGoImplementation/Tests-Crypto-patched-Go"),

        coreTestTarget(name: .cryptoVPNPatchedGoImplementation + "Tests",
                       dependencies: [
                           .goLibsCryptoVPNPatchedGo,
                           .cryptoVPNPatchedGoImplementation,
                           .cryptoGoInterface
                       ],
                       path: "libraries/CryptoGoImplementation/Tests-Crypto+VPN-patched-Go"),

        coreTestTarget(name: .cryptoSearchGoImplementation + "Tests",
                       dependencies: [
                           .goLibsCryptoSearchGo,
                           .cryptoSearchGoImplementation,
                           .cryptoGoInterface
                       ],
                       path: "libraries/CryptoGoImplementation/Tests-Crypto+Search-Go")
    ]
)

// MARK: CryptoGoInterface

add(
    product: .cryptoGoInterface,
    targets: [
        coreTarget(name: .cryptoGoInterface,
                   path: "libraries/CryptoGoInterface/Sources")
    ]
)

// MARK: DataModel

add(
    product: .dataModel,
    targets: [
        coreTarget(name: .dataModel,
                   dependencies: [
                    .utilities
                   ],
                   path: "libraries/DataModel/Sources"),

        coreTestTarget(name: .dataModel + "Tests",
                       dependencies: [
                           .dataModel,
                           .testingToolkitUnitTestsDataModel
                       ],
                       path: "libraries/DataModel/Tests")
    ]
)

// MARK: DoH

add(
    product: .doh,
    targets: [
        coreTarget(name: .doh,
                   dependencies: [
                       .log,
                       .utilities
                   ],
                   path: "libraries/DoH/Sources"),

        coreTestTarget(name: .doh + "UnitTests",
                       dependencies: [
                           .doh,
                           .authentication,
                           .challenge,
                           .foundations,
                           .services,
                           .obfuscatedConstants,
                           .testingToolkitUnitTestsDoh,
                           .ohhttpStubs
                       ],
                       path: "libraries/Doh/Tests/Unit"),

        coreTestTarget(name: .doh + "IntegrationTests",
                       dependencies: [
                           .doh,
                           .authentication,
                           .environment,
                           .foundations,
                           .observability,
                           .services,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Doh/Tests/Integration")
    ]
)

// MARK: Environment

add(
    product: .environment,
    targets: [
        coreTarget(name: .environment,
                   dependencies: [
                       .doh,
                       .trustKit
                   ],
                   path: "libraries/Environment/Sources"),

        coreTestTarget(name: .environment + "Tests",
                       dependencies: [
                           .environment,
                           .testingToolkitUnitTestsDoh,
                           .ohhttpStubs
                       ],
                       path: "libraries/Environment/Tests")
    ]
)

// MARK: Features

add(
    product: .features,
    targets: [
        coreTarget(name: .features,
                   dependencies: [
                       .dataModel,
                       .hash,
                       .crypto,
                       .cryptoGoInterface,
                       .keyManager,
                       .authentication,
                       .networking
                   ],
                   path: "libraries/Features/Sources")
    ]
)

// MARK: - Unleash Feature flags

add(
    product: .featureFlags,
    targets: [
        coreTarget(name: .featureFlags,
                   dependencies: [
                       .log,
                       .networking,
                       .services,
                   ],
                   path: "libraries/FeatureFlags/Sources"),

        coreTestTarget(name: .featureFlags + "Tests",
                       dependencies: [
                           .featureFlags,
                           .utilities,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/FeatureFlags/Tests",
                       resources: [.process("FeatureFlagsTests/QueryResources")])
    ]
)

// MARK: ForceUpgrade

add(
    product: .forceUpgrade,
    targets: [
        coreTarget(name: .forceUpgrade,
                   dependencies: [
                       .uiFoundations,
                       .networking
                   ],
                   path: "libraries/ForceUpgrade/Sources",
                   resources: [
                       .process("Shared/Resources")
                   ]),

        coreTestTarget(name: .forceUpgrade + "Tests",
                       dependencies: [
                           .forceUpgrade,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/ForceUpgrade/Tests/UnitTests"),

        coreTestTarget(name: .forceUpgrade + "LocalizationTests",
                       dependencies: [
                           .forceUpgrade,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/ForceUpgrade/Tests/LocalizationTests")

    ]
)

// MARK: Foundations

add(
    product: .foundations,
    targets: [
        coreTarget(name: .foundations,
                   dependencies: [
                       .log
                   ],
                   path: "libraries/Foundations/Sources")
    ]
)

// MARK: GoLibs

add(
    products: [
        .goLibsCryptoGo,
        .goLibsCryptoPatchedGo,
        .goLibsCryptoVPNPatchedGo,
        .goLibsCryptoSearchGo
    ],
    targets: [
        .binaryTarget(name: .goLibsCryptoGo, path: "vendor/Crypto-Go/GoLibs.xcframework"),
        .binaryTarget(name: .goLibsCryptoPatchedGo, path: "vendor/Crypto-patched-Go/GoLibs.xcframework"),
        .binaryTarget(name: .goLibsCryptoVPNPatchedGo, path: "vendor/Crypto+VPN-patched-Go/GoLibs.xcframework"),
        .binaryTarget(name: .goLibsCryptoSearchGo, path: "vendor/Crypto+Search-Go/GoLibs.xcframework"),
    ]
)

// MARK: Hash

add(
    product: .hash,
    targets: [
        coreTarget(name: .hash,
                   path: "libraries/Hash/Sources"),

        coreTestTarget(name: .hash + "Tests",
                       dependencies: [
                           .hash
                       ],
                       path: "libraries/Hash/Tests")
    ]
)

// MARK: HumanVerification

add(
    product: .humanVerification,
    targets: [
        coreTarget(name: .humanVerification,
                   dependencies: [
                       .uiFoundations,
                       .foundations,
                       .utilities,
                       .apiClient,
                       .observability,
                       .crypto,
                       .cryptoGoInterface,
                       .dataModel,
                       .networking,
                       .telemetry,
                       .humanVerificationResourcesiOS,
                       .humanVerificationResourcesmacOS
                   ],
                   path: "libraries/HumanVerification/Sources"),

        coreTarget(name: .humanVerificationResourcesiOS,
                   path: "libraries/HumanVerification/Resources-iOS",
                   resources: [
                       .process("Resources-iOS")
                   ]),

        coreTarget(name: .humanVerificationResourcesmacOS,
                   path: "libraries/HumanVerification/Resources-macOS",
                   resources: [
                       .process("Resources-macOS")
                   ]),

        coreTestTarget(name: .humanVerification + "Tests",
                       dependencies: [
                           .challenge,
                           .humanVerification,
                           .cryptoGoUsedInTests,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsDoh,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsObservability,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/HumanVerification/Tests/UnitTests",
                       exclude: ["__Snapshots__"]),

        coreTestTarget(name: .humanVerification + "LocalizationTests",
                       dependencies: [
                           .humanVerification,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/HumanVerification/Tests/LocalizationTests")
    ]
)

// MARK: Keymaker

add(
    product: .keymaker,
    targets: [
        coreTarget(name: .keymaker,
                   dependencies: [
                       .cryptoGoInterface,
                       .ellipticCurveKeyPair
                   ],
                   path: "libraries/Keymaker/Sources"),

        coreTestTarget(name: .keymaker + "Tests",
                       dependencies: [
                           .keymaker,
                           .cryptoGoUsedInTests,
                           .testingToolkitUnitTestsCore,
                           .cryptoSwift
                       ],
                       path: "libraries/Keymaker/Tests")
    ]
)

// MARK: KeyManager

add(
    product: .keyManager,
    targets: [
        coreTarget(name: .keyManager,
                   dependencies: [
                       .cryptoGoInterface,
                       .crypto,
                       .dataModel
                   ],
                   path: "libraries/KeyManager/Sources"),

        coreTestTarget(name: .keyManager + "Tests",
                       dependencies: [
                           .keyManager,
                           .cryptoGoUsedInTests
                       ],
                       path: "libraries/KeyManager/Tests",
                       resources: [.process("TestData")])
    ]
)

// MARK: Log

add(
    product: .log,
    targets: [
        coreTarget(
            name: .log,
            dependencies: [.sentry],
            path: "libraries/Log/Sources"
        ),
        coreTestTarget(
            name: .log + "Tests",
            dependencies: [
                .log
            ],
            path: "libraries/Log/Tests"
        )
    ]
)

// MARK: Login

add(
    product: .login,
    targets: [
        coreTarget(name: .login,
                   dependencies: [
                       .log,
                       .foundations,
                       .dataModel,
                       .observability,
                       .crypto,
                       .cryptoGoInterface,
                       .authentication,
                       .authenticationKeyGeneration,
                       .trustKit,
                       .featureFlags
                   ],
                   path: "libraries/Login/Sources",
                   resources: [.process("Resources")]),

        coreTestTarget(name: .login + "UnitTests",
                       dependencies: [
                           .login,
                           .challenge,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .hash,
                           .authentication,
                           .authenticationKeyGeneration,
                           .obfuscatedConstants,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsAuthenticationKeyGeneration,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsLogin,
                           .testingToolkitUnitTestsObservability,
                           .ohhttpStubs,
                           .trustKit
                       ],
                       path: "libraries/Login/Tests/UnitTests",
                       resources: [
                           .process("Mocks/Responses")
                       ]),

        coreTestTarget(name: .login + "IntegrationTests",
                       dependencies: [
                           .login,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .quarkCommands,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsFeatureFlag,
                           .trustKit
                       ],
                       path: "libraries/Login/Tests/IntegrationTests"),

        coreTestTarget(name: .login + "LocalizationTests",
                       dependencies: [
                           .login,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Login/Tests/LocalizationTests")
    ]
)

// MARK: LoginUI

add(
    product: .loginUI,
    targets: [
        coreTarget(name: .loginUI,
                   dependencies: [
                       .log,
                       .foundations,
                       .uiFoundations,
                       .challenge,
                       .dataModel,
                       .troubleShooting,
                       .environment,
                       .observability,
                       .crypto,
                       .cryptoGoInterface,
                       .authentication,
                       .authenticationKeyGeneration,
                       .login,
                       .payments,
                       .paymentsUI,
                       .humanVerification,
                       .loginUIResourcesiOS,
                       .lottie,
                       .trustKit,
                       .telemetry
                   ],
                   path: "libraries/LoginUI/Sources",
                   resources: [
                       .process("Resources/Translations")
                   ]),

        coreTarget(name: .loginUIResourcesiOS,
                   path: "libraries/LoginUI/Resources",
                   resources: [
                       .process("Resources-iOS")
                   ]),

        coreTestTarget(name: .loginUI + "UnitTests",
                       dependencies: [
                           .loginUI,
                           .authentication,
                           .authenticationKeyGeneration,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .humanVerification,
                           .login,
                           .obfuscatedConstants,
                           .payments,
                           .paymentsUI,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsLoginUI,
                           .testingToolkitUnitTestsObservability,
                           .ohhttpStubs,
                           .trustKit
                       ],
                       path: "libraries/LoginUI/Tests/UnitTests",
                       exclude: [
                           "SnapshotTests/__Snapshots__",
                           "ViewControllerTests/__Snapshots__"
                       ],
                       resources: [
                           .process("Mocks/Responses")
                       ]),

        coreTestTarget(name: .loginUI + "IntegrationTests",
                       dependencies: [
                           .loginUI,
                           .authentication,
                           .authenticationKeyGeneration,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .humanVerification,
                           .login,
                           .obfuscatedConstants,
                           .payments,
                           .paymentsUI,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsLoginUI,
                           .trustKit
                       ],
                       path: "libraries/LoginUI/Tests/IntegrationTests"),

        coreTestTarget(name: .loginUI + "LocalizationTests",
                       dependencies: [
                           .loginUI,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/LoginUI/Tests/LocalizationTests")
    ]
)

// MARK: MissingScopes

add(
    product: .missingScopes,
    targets: [
        coreTarget(name: .missingScopes,
                   dependencies: [
                       .apiClient,
                       .authentication,
                       .services,
                       .uiFoundations,
                       .passwordRequest
                   ],
                   path: "libraries/MissingScopes/Sources"),

        coreTestTarget(name: .missingScopes + "Tests",
                       dependencies: [
                           .missingScopes,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/MissingScopes/Tests")
    ]
)

// MARK: Networking

add(
    product: .networking,
    targets: [
        coreTarget(name: .networking,
                   dependencies: [
                       .environment,
                       .log,
                       .utilities,
                       .alamofire,
                       .trustKit
                   ],
                   path: "libraries/Networking/Sources"),

        coreTestTarget(name: .networking + "Tests",
                       dependencies: [
                           .networking,
                           .testingToolkitUnitTestsNetworking,
                           .ohhttpStubs,
                           .trustKit
                       ],
                       path: "libraries/Networking/Tests/UnitTests"),

        coreTestTarget(name: .networking + "LocalizationTests",
                       dependencies: [
                           .networking,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Networking/Tests/LocalizationTests")
    ]
)

// MARK: ObfuscatedConstants

add(
    product: .obfuscatedConstants,
    targets: [
        coreTarget(name: .obfuscatedConstants,
                   dependencies: [
                       .cryptoSwift,
                       .dataModel,
                       .networking,
                       .swiftOTP,
                       .trustKit
                   ],
                   path: "libraries/ObfuscatedConstants/Sources",
                   exclude: ["Template"])
    ]
)

// MARK: Observability

add(
    product: .observability,
    targets: [
        coreTarget(name: .observability,
                   dependencies: [
                       .networking,
                       .utilities
                   ],
                   path: "libraries/Observability/Sources"),

        coreTestTarget(name: .observability + "UnitTests",
                       dependencies: [
                           .observability,
                           .challenge,
                           .foundations,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsObservability,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsServices,
                           .jsonSchema
                       ],
                       path: "libraries/Observability/UnitTests"),

        coreTestTarget(name: .observability + "IntegrationTests",
                       dependencies: [
                           .observability,
                           .authentication,
                           .foundations,
                           .networking,
                           .services,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsObservability
                       ],
                       path: "libraries/Observability/IntegrationTests")
    ]
)

// MARK: Password Change

add(
    product: .passwordChange,
    targets: [
        coreTarget(name: .passwordChange,
                   dependencies: [
                       .authentication,
                       .authenticationKeyGeneration,
                       .featureFlags,
                       .networking,
                       .observability,
                       .services,
                       .uiFoundations,
                       .utilities
                   ],
                   path: "libraries/PasswordChange/Sources",
                   resources: [.process("Resources")]),

        coreTestTarget(name: .passwordChange + "Tests",
                       dependencies: [
                           .authentication,
                           .authenticationKeyGeneration,
                           .crypto,
                           .cryptoGoInterface,
                           .cryptoGoUsedInTests,
                           .passwordChange,
                           .networking,
                           .services,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsAuthentication,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/PasswordChange/Tests",
                       exclude: ["__Snapshots__"])
    ]
)

// MARK: Password Request

add(
    product: .passwordRequest,
    targets: [
        coreTarget(name: .passwordRequest,
                   dependencies: [
                       .authentication,
                       .networking,
                       .services,
                       .uiFoundations
                   ],
                   path: "libraries/PasswordRequest/Sources",
                   resources: [
                       .process("Resources")
                   ]),

        coreTestTarget(name: .passwordRequest + "UnitTests",
                       dependencies: [
                           .authentication,
                           .passwordRequest,
                           .networking,
                           .services,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsAuthentication,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/PasswordRequest/Tests/UnitTests"),

        coreTestTarget(name: .passwordRequest + "LocalizationTests",
                       dependencies: [
                           .passwordRequest,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/PasswordRequest/Tests/LocalizationTests")
    ]
)

// MARK: Payments

add(
    product: .payments,
    targets: [
        coreTarget(name: .payments,
                   dependencies: [
                       .authentication,
                       .foundations,
                       .hash,
                       .log,
                       .networking,
                       .reachabilitySwift,
                       .services,
                       .featureFlags
                   ],
                   path: "libraries/Payments/Sources"),

        coreTestTarget(name: .payments + "Tests",
                       dependencies: [
                           .authentication,
                           .challenge,
                           .dataModel,
                           .doh,
                           .log,
                           .login,
                           .payments,
                           .services,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsPayments,
                           .testingToolkitUnitTestsServices,
                           .ohhttpStubs
                       ],
                       path: "libraries/Payments/Tests/UnitTests",
                       resources: [
                           .process("AppStoreLocalTest"),
                           .process("Mocks/Responses")
                       ]),

        coreTestTarget(name: .payments + "IntegrationTests",
                       dependencies: [
                           .authentication,
                           .challenge,
                           .dataModel,
                           .doh,
                           .environment,
                           .log,
                           .login,
                           .payments,
                           .services,
                           .testingToolkitTestData,
                           .testingToolkitUnitTestsPayments,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/Payments/Tests/IntegrationTests"),

        coreTestTarget(name: .payments + "LocalizationTests",
                       dependencies: [
                           .payments,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Payments/Tests/LocalizationTests")
    ]
)

// MARK: PaymentsUI

add(
    product: .paymentsUI,
    targets: [
        coreTarget(name: .paymentsUI,
                   dependencies: [
                       .log,
                       .foundations,
                       .uiFoundations,
                       .observability,
                       .payments,
                       .paymentsUIResourcesiOS,
                       .sdWebImage,
                       .featureFlags
                   ],
                   path: "libraries/PaymentsUI/Sources",
                   resources: [
                       .process("Resources/Translations")
                   ]),

        coreTarget(name: .paymentsUIResourcesiOS,
                   path: "libraries/PaymentsUI/Resources",
                   resources: [
                       .process("Resources-iOS")
                   ]),

        coreTestTarget(name: .paymentsUI + "Tests",
                       dependencies: [
                           .paymentsUI,
                           .obfuscatedConstants,
                           .testingToolkitUnitTestsDataModel,
                           .testingToolkitUnitTestsFeatureFlag,
                           .testingToolkitUnitTestsObservability,
                           .testingToolkitUnitTestsPayments,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/PaymentsUI/Tests/UnitTests",
                       exclude: ["__Snapshots__"]),

        coreTestTarget(name: .paymentsUI + "LocalizationTests",
                       dependencies: [
                           .paymentsUI,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/PaymentsUI/Tests/LocalizationTests")
    ]
)

// MARK: PushNotifications

add(
    product: .pushNotifications,
    targets: [
        coreTarget(name: .pushNotifications,
                   dependencies: [
                       .log,
                       .dataModel,
                       .keymaker,
                       .networking,
                       .crypto,
                       .cryptoGoInterface,
                       .featureFlags,
                       .services
                   ],
                   path: "libraries/PushNotifications/Sources"),

        coreTestTarget(name: .pushNotifications + "Tests",
                       dependencies: [
                           .pushNotifications,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/PushNotifications/Tests")
    ]
)

// MARK: QuarkCommands

add(
    product: .quarkCommands,
    targets: [
        coreTarget(name: .quarkCommands,
                   dependencies: [
                       .doh,
                       .environment,
                       .log,
                       .networking,
                       .services
                   ],
                   path: "libraries/QuarkCommands/Sources"),

        coreTestTarget(name: .quarkCommands + "Tests",
                       dependencies: [
                           .quarkCommands,
                           .foundations,
                           .testingToolkitUnitTestsDoh,
                           .ohhttpStubs,
                       ],
                       path: "libraries/QuarkCommands/Tests",
                       resources: [.process("Mocks")])
    ]
)

// MARK: Services

add(
    product: .services,
    targets: [
        coreTarget(name: .services,
                   dependencies: [
                       .observability,
                       .utilities,
                       .foundations
                   ],
                   path: "libraries/Services/Sources",
                   resources: [
                       .process("Resources")
                   ]),

        coreTestTarget(name: .services + "UnitTests",
                       dependencies: [
                           .services,
                           .authentication,
                           .challenge,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsDoh,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsObservability,
                           .testingToolkitUnitTestsServices
                       ],
                       path: "libraries/Services/Tests/Unit"),

        coreTestTarget(name: .services + "IntegrationTests",
                       dependencies: [
                           .services,
                           .authentication,
                           .challenge,
                           .login,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Services/Tests/Integration"),

        coreTestTarget(name: .services + "LocalizationTests",
                       dependencies: [
                           .services,
                           .challenge,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Services/Tests/Localization")
    ]
)

// MARK: Settings

add(
    product: .settings,
    targets: [
        coreTarget(name: .settings,
                   dependencies: [
                       .uiFoundations
                   ],
                   path: "libraries/Settings/Sources",
                   resources: [
                       .process("Resources")
                   ]),

        coreTestTarget(name: .settings + "Tests",
                       dependencies: [
                           .settings,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/Settings/Tests",
                       exclude: [
                           "Resources",
                           "Security/Presentation/__Snapshots__",
                           "Settings/Presentation/__Snapshots__"
                       ])
    ]
)

// MARK: Telemetry

add(
    product: .telemetry,
    targets: [
        coreTarget(name: .telemetry,
                   dependencies: [
                       .networking,
                       .services,
                       .featureFlags
                   ],
                   path: "libraries/Telemetry/Sources"),

        coreTestTarget(name: .telemetry + "Tests",
                       dependencies: [
                           .telemetry,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsNetworking,
                           .testingToolkitUnitTestsServices,
                           .testingToolkitUnitTestsFeatureFlag
                       ],
                       path: "libraries/Telemetry/Tests")
    ]
)

// MARK: TestingToolkit

add(
    products: [
        .testingToolkitTestData,
        .testingToolkitUnitTestsAccountDeletion,
        .testingToolkitUnitTestsAuthentication,
        .testingToolkitUnitTestsAuthenticationKeyGeneration,
        .testingToolkitUnitTestsCore,
        .testingToolkitUnitTestsCryptoGoInterface,
        .testingToolkitUnitTestsDataModel,
        .testingToolkitUnitTestsDoh,
        .testingToolkitUnitTestsFeatureFlag,
        .testingToolkitUnitTestsLogin,
        .testingToolkitUnitTestsLoginUI,
        .testingToolkitUnitTestsNetworking,
        .testingToolkitUnitTestsObservability,
        .testingToolkitUnitTestsPayments,
        .testingToolkitUnitTestsServices,

        .testingToolkitUITestsAccountDeletion,
        .testingToolkitUITestsAccountSwitcher,
        .testingToolkitUITestsCore,
        .testingToolkitUITestsHumanVerification,
        .testingToolkitUITestsLogin,
        .testingToolkitUITestsPaymentsUI
    ],
    targets: [
        coreTarget(name: .testingToolkitTestData,
                   dependencies: [
                       .dataModel,
                       .networking,
                       .cryptoSwift
                   ],
                   path: "libraries/TestingToolkit/TestData"),

        coreTarget(name: .testingToolkitUnitTestsAccountDeletion,
                   dependencies: [
                       .accountDeletion,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsNetworking
                   ],
                   path: "libraries/TestingToolkit/UnitTests/AccountDeletion"),

        coreTarget(name: .testingToolkitUnitTestsAuthentication,
                   dependencies: [
                       .authentication,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsServices
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Authentication"),

        coreTarget(name: .testingToolkitUnitTestsAuthenticationKeyGeneration,
                   dependencies: [
                       .authenticationKeyGeneration,
                       .testingToolkitUnitTestsAuthentication,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsServices
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration"),

        coreTarget(name: .testingToolkitUnitTestsCore,
                   dependencies: [
                       .utilities,
                       .snapshotTesting
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Core"),
        
        coreTarget(name: .testingToolkitUnitTestsCryptoGoInterface,
                   dependencies: [
                       .cryptoGoInterface,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/CryptoGoInterface"),

        coreTarget(name: .testingToolkitUnitTestsDataModel,
                   dependencies: [
                       .dataModel,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/DataModel"),

        coreTarget(name: .testingToolkitUnitTestsDoh,
                   dependencies: [
                       .doh,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Doh"),

        coreTarget(name: .testingToolkitUnitTestsFeatureFlag,
                   dependencies: [
                       .featureFlags,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/FeatureFlag"),

        coreTarget(name: .testingToolkitUnitTestsLogin,
                   dependencies: [
                       .login,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsAuthentication,
                       .testingToolkitUnitTestsDataModel,
                       .testingToolkitUnitTestsServices
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Login"),

        coreTarget(name: .testingToolkitUnitTestsLoginUI,
                   dependencies: [
                       .loginUI,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsAuthentication,
                       .testingToolkitUnitTestsDataModel,
                       .testingToolkitUnitTestsLogin,
                       .testingToolkitUnitTestsServices
                   ],
                   path: "libraries/TestingToolkit/UnitTests/LoginUI"),

        coreTarget(name: .testingToolkitUnitTestsNetworking,
                   dependencies: [
                       .networking,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Networking"),

        coreTarget(name: .testingToolkitUnitTestsObservability,
                   dependencies: [
                       .observability,
                       .testingToolkitUnitTestsCore
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Observability"),

        coreTarget(name: .testingToolkitUnitTestsPayments,
                   dependencies: [
                       .payments,
                       .testingToolkitUnitTestsCore,
                       .ohhttpStubs
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Payments"),

        coreTarget(name: .testingToolkitUnitTestsServices,
                   dependencies: [
                       .services,
                       .doh,
                       .foundations,
                       .networking,
                       .testingToolkitUnitTestsCore,
                       .testingToolkitUnitTestsDataModel,
                       .testingToolkitUnitTestsDoh,
                       .testingToolkitUnitTestsNetworking
                   ],
                   path: "libraries/TestingToolkit/UnitTests/Services"),

        coreTarget(name: .testingToolkitUITestsAccountDeletion,
                   dependencies: [
                       .accountDeletion,
                       .doh,
                       .quarkCommands,
                       .fusion
                   ],
                   path: "libraries/TestingToolkit/UITests/AccountDeletion"),

        coreTarget(name: .testingToolkitUITestsAccountSwitcher,
                   dependencies: [
                       .accountSwitcher,
                       .doh,
                       .quarkCommands,
                       .fusion
                   ],
                   path: "libraries/TestingToolkit/UITests/AccountSwitcher"),

        coreTarget(name: .testingToolkitUITestsCore,
                   dependencies: [
                       .doh,
                       .log,
                       .quarkCommands,
                       .fusion
                   ],
                   path: "libraries/TestingToolkit/UITests/Core"),

        coreTarget(name: .testingToolkitUITestsHumanVerification,
                   dependencies: [
                       .humanVerification,
                       .doh,
                       .quarkCommands,
                       .fusion
                   ],
                   path: "libraries/TestingToolkit/UITests/HumanVerification"),

        coreTarget(name: .testingToolkitUITestsLogin,
                   dependencies: [
                       .humanVerification,
                       .loginUI,
                       .paymentsUI,
                       .doh,
                       .quarkCommands,
                       .fusion,
                   ],
                   path: "libraries/TestingToolkit/UITests/Login"),

        coreTarget(name: .testingToolkitUITestsPaymentsUI,
                   dependencies: [
                       .paymentsUI,
                       .doh,
                       .quarkCommands,
                       .fusion
                   ],
                   path: "libraries/TestingToolkit/UITests/PaymentsUI")
    ]
)

// MARK: TroubleShooting

add(
    product: .troubleShooting,
    targets: [
        coreTarget(name: .troubleShooting,
                   dependencies: [
                       .foundations,
                       .doh,
                       .troubleShootingResourcesiOS,
                       .uiFoundations,
                       .utilities
                   ],
                   path: "libraries/TroubleShooting/Sources",
                   resources: [
                       .process("Resources")
                   ]),

        coreTarget(name: .troubleShootingResourcesiOS,
                   path: "libraries/TroubleShooting/Resources",
                   resources: [
                       .process("Resources-iOS")
                   ]),

        coreTestTarget(name: .troubleShooting + "Tests",
                       dependencies: [
                           .troubleShooting,
                           .services,
                           .environment,
                           .testingToolkitUnitTestsCore,
                           .testingToolkitUnitTestsDoh
                       ],
                       path: "libraries/TroubleShooting/Tests/UnitTests",
                       exclude: ["__Snapshots__"]),

        coreTestTarget(name: .troubleShooting + "LocalizationTests",
                       dependencies: [
                           .troubleShooting,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/TroubleShooting/Tests/LocalizationTests")
    ]
)

// MARK: - UIFoundations

add(
    product: .uiFoundations,
    targets: [
        coreTarget(name: .uiFoundations,
                   dependencies: [
                       .foundations,
                       .log,
                       .utilities,
                       .uiFoundationsResourcesiOS,
                       .uiFoundationsResourcestvOS,
                       .uiFoundationsResourcesmacOS
                   ],
                   path: "libraries/UIFoundations/Sources"),

        coreTarget(name: .uiFoundationsResourcesiOS,
                   path: "libraries/UIFoundations/Resources-iOS",
                   resources: [
                       .process("Resources-iOS"),
                       .process("Resources-Shared")
                   ]),

        coreTarget(name: .uiFoundationsResourcestvOS,
                   path: "libraries/UIFoundations/Resources-tvOS",
                   resources: [
                       .process("Resources-Shared")
                   ]),

        coreTarget(name: .uiFoundationsResourcesmacOS,
                   path: "libraries/UIFoundations/Resources-macOS",
                   resources: [
                       .process("Resources-Shared")
                   ]),

        coreTestTarget(name: .uiFoundations + "Tests",
                       dependencies: [
                           .uiFoundations,
                           .testingToolkitUnitTestsCore
                       ],
                       path: "libraries/UIFoundations/Tests",
                       exclude: ["__Snapshots__"])
    ]
)

// MARK: Utilities

add(
    product: .utilities,
    targets: [
        coreTarget(name: .utilities,
                   dependencies: [
                       .log
                   ],
                   path: "libraries/Utilities/Sources"),

        coreTestTarget(name: .utilities + "Tests",
                       dependencies: [
                           .utilities
                       ],
                       path: "libraries/Utilities/Tests")
    ]
)

// MARK: VCard

add(
    product: .vCard,
    targets: [
        .binaryTarget(name: .vCard, path: "vendor/VCard/VCard.xcframework")
    ]
)

// MARK: - Package definition

let package = Package(
    name: "ProtonCore",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: products + [
        .plugin(name: .obfuscatedConstantsGenerationPlugin,
                targets: [.obfuscatedConstantsGenerationPlugin]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            exact: "5.4.4"
        ),
        .package(
            url: "https://github.com/ProtonMail/apple-fusion",
            "2.0.1"..<"3.0.0"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift",
            from: "1.7.2"
        ),
        .package(
            url: "https://github.com/agens-no/EllipticCurveKeyPair",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/kylef/JSONSchema.swift",
            from: "0.6.0"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            exact: "4.3.3"
        ),
        .package(
            url: "https://github.com/AliSoftware/OHHTTPStubs",
            from: "9.1.0"
        ),
        .package(
            url: "https://github.com/ashleymills/Reachability.swift",
            from: "5.1.0"
        ),
        .package(
            url: "https://github.com/lachlanbell/SwiftOTP",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.15.0"
        ),
        .package(
            url: "https://github.com/tannerdsilva/SwiftBCrypt.git",
            from: "0.2.0"
        ),
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            "0.0.0"..<"5.16.0"
        ),
        .package(
            url: "https://github.com/ProtonMail/TrustKit",
            exact: "1.0.3"
        ),
        .package(
            url: "https://github.com/nalexn/ViewInspector.git",
            .upToNextMajor(from: "0.9.9")
        ),
        .package(
            url: "https://github.com/getsentry/sentry-cocoa.git",
            exact: "8.18.0"
        )
    ],
    targets: targets + [
        .plugin(name: .obfuscatedConstantsGenerationPlugin,
                capability: .command(
                    intent: .custom(verb: "generate-obfuscated-constants",
                                    description: "Generate obfuscated constants"),
                    permissions: [.writeToPackageDirectory(reason: "Generate ObfuscatedConstants.swift")]
                ),
                path: "libraries/ObfuscatedConstants/Plugin")
    ]
)
