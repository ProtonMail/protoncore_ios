// swift-tools-version:5.7

import PackageDescription

var products: [Product] = []
var targets: [Target] = []

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
    // adding dynamic and static variant of the libraries.
    // commented out for now because I'm not sure if the clients will indeed need that
//    products.append(contentsOf: [
//        .library(name: newProduct + "-Dynamic", type: .dynamic, targets: [newProduct]),
//        .library(name: newProduct + "-Static", type: .static, targets: [newProduct])
//    ])
    return products
}

func add(products newProducts: [Product], targets newTargets: [Target]) {
    products = products + newProducts
    targets = targets + newTargets
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
    static let featureSwitch: String = "ProtonCoreFeatureSwitch"
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
    static let passwordRequest: String = "ProtonCorePasswordRequest"
    static let payments: String = "ProtonCorePayments"
    static let paymentsUI: String = "ProtonCorePaymentsUI"
    static let paymentsUIResourcesiOS: String = "ProtonCorePaymentsUIResourcesiOS"
    static let pushNotifications: String = "ProtonPushNotifications"
    static let quarkCommands: String = "ProtonCoreQuarkCommands"
    static let services: String = "ProtonCoreServices"
    static let settings: String = "ProtonCoreSettings"
    static let subscriptions: String = "ProtonCoreSubscriptions"
    static let testingToolkit: String = "ProtonCoreTestingToolkit"
    static let testingToolkitTestData: String = "ProtonCoreTestingToolkitTestData"
    static let testingToolkitUnitTestsAccountDeletion: String = "ProtonCoreTestingToolkitUnitTestsAccountDeletion"
    static let testingToolkitUnitTestsAuthentication: String = "ProtonCoreTestingToolkitUnitTestsAuthentication"
    static let testingToolkitUnitTestsAuthenticationKeyGeneration: String = "ProtonCoreTestingToolkitUnitTestsAuthenticationKeyGeneration"
    static let testingToolkitUnitTestsCore: String = "ProtonCoreTestingToolkitUnitTestsCore"
    static let testingToolkitUnitTestsDataModel: String = "ProtonCoreTestingToolkitUnitTestsDataModel"
    static let testingToolkitUnitTestsDoh: String = "ProtonCoreTestingToolkitUnitTestsDoh"
    static let testingToolkitUnitTestsFeatureSwitch: String = "ProtonCoreTestingToolkitUnitTestsFeatureSwitch"
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
    static let swiftBCrypt: String = "SwiftBCrypt"
    static let swiftOTP: String = "SwiftOTP"
    static let snapshotTesting: String = "SnapshotTesting"
    static let snapshotTestingPackage: String = "swift-snapshot-testing"
    static let trustKit: String = "TrustKit"
    static let sdWebImage: String = "SDWebImage"

    // MARK: - Plugin names

    static let obfuscatedConstantsGenerationPlugin = "ObfuscatedConstantsGenerationPlugin"
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
    static var featureSwitch: Target.Dependency { .target(name: .featureSwitch) }
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
    static var passwordRequest: Target.Dependency { .target(name: .passwordRequest) }
    static var payments: Target.Dependency { .target(name: .payments) }
    static var paymentsUI: Target.Dependency { .target(name: .paymentsUI) }
    static var paymentsUIResourcesiOS: Target.Dependency { .target(name: .paymentsUIResourcesiOS,
                                                                   condition: .when(platforms: [.iOS])) }
    static var pushNotifications: Target.Dependency { .target(name: .pushNotifications) }
    static var quarkCommands: Target.Dependency { .target(name: .quarkCommands) }
    static var services: Target.Dependency { .target(name: .services) }
    static var settings: Target.Dependency { .target(name: .settings) }
    static var subscriptions: Target.Dependency { .target(name: .subscriptions) }
    static var testingToolkit: Target.Dependency { .target(name: .testingToolkit) }
    static var testingToolkitTestData: Target.Dependency { .target(name: .testingToolkitTestData) }
    static var testingToolkitUnitTestsAccountDeletion: Target.Dependency { .target(name: .testingToolkitUnitTestsAccountDeletion) }
    static var testingToolkitUnitTestsAuthentication: Target.Dependency { .target(name: .testingToolkitUnitTestsAuthentication) }
    static var testingToolkitUnitTestsAuthenticationKeyGeneration: Target.Dependency { .target(name: .testingToolkitUnitTestsAuthenticationKeyGeneration) }
    static var testingToolkitUnitTestsCore: Target.Dependency { .target(name: .testingToolkitUnitTestsCore) }
    static var testingToolkitUnitTestsDataModel: Target.Dependency { .target(name: .testingToolkitUnitTestsDataModel) }
    static var testingToolkitUnitTestsDoh: Target.Dependency { .target(name: .testingToolkitUnitTestsDoh) }
    static var testingToolkitUnitTestsFeatureSwitch: Target.Dependency { .target(name: .testingToolkitUnitTestsFeatureSwitch) }
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
    static var snapshotTesting: Target.Dependency { .product(name: .snapshotTesting, package: .snapshotTestingPackage) }
    static var swiftBCrypt: Target.Dependency { .product(name: .swiftBCrypt, package: .swiftBCrypt) }
    static var swiftOTP: Target.Dependency { .product(name: .swiftOTP, package: .swiftOTP) }
    static var trustKit: Target.Dependency { .product(name: .trustKit, package: .trustKit) }
    static var sdWebImage: Target.Dependency { .product(name: .sdWebImage, package: .sdWebImage) }
    
    // MARK: - Helpers
    
    static var cryptoGoUsedInTests: Target.Dependency { .cryptoPatchedGoImplementation }
}

extension Array where Element == SwiftSetting {
    static let spm: [SwiftSetting] = [.define("SPM")]
}

// MARK: - Module definitions

// MARK: AccountDeletion

add(
    product: .accountDeletion,
    targets: [
        .target(name: .accountDeletion,
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
                ],
                swiftSettings: .spm),

        .testTarget(name: .accountDeletion + "Tests",
                    dependencies: [
                        .accountDeletion,
                        .testingToolkitUnitTestsAccountDeletion,
                        .testingToolkitUnitTestsDoh,
                        .testingToolkitUnitTestsNetworking,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/AccountDeletion/Tests/UnitTests",
                    swiftSettings: .spm),
        
        .testTarget(name: .accountDeletion + "LocalizationTests",
                    dependencies: [
                        .accountDeletion,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/AccountDeletion/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: AccountRecovery

add(
    product: .accountRecovery,
    targets: [
        .target(name: .accountRecovery,
                dependencies: [
                    .featureSwitch,
                    .pushNotifications,
                    .services,
                    .authentication,
                    .dataModel,
                    .uiFoundations,
                    .networking,
                    .passwordRequest
                ],
                path: "libraries/AccountRecovery/Sources",
                resources: [.process("Resources")],
                swiftSettings: .spm),

        .testTarget(name: .accountRecovery + "Tests",
                    dependencies: [
                        .accountRecovery,
                    ],
                    path: "libraries/AccountRecovery/Tests",
                    resources: [.process("Resources")],
                    swiftSettings: .spm)
    ]
)

// MARK: AccountSwitcher

add(
    product: .accountSwitcher,
    targets: [
        .target(name: .accountSwitcher,
                dependencies: [
                    .uiFoundations,
                    .log,
                    .utilities,
                    .accountSwitcherResourcesiOS
                ],
                path: "libraries/AccountSwitcher/Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm),

        .target(name: .accountSwitcherResourcesiOS,
                path: "libraries/AccountSwitcher/Resources-iOS",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm),

        .testTarget(name: .accountSwitcher + "Tests",
                    dependencies: [
                        .accountSwitcher,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/AccountSwitcher/Tests/UnitTests",
                    exclude: ["__Snapshots__"],
                    swiftSettings: .spm),
        
        .testTarget(name: .accountSwitcher + "LocalizationTests",
                    dependencies: [
                        .accountSwitcher,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/AccountSwitcher/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: APIClient

add(
    product: .apiClient,
    targets: [
        .target(name: .apiClient,
                dependencies: [
                    .dataModel,
                    .networking,
                    .services
                ],
                path: "libraries/APIClient/Sources",
                swiftSettings: .spm),

        .testTarget(name: .apiClient + "Tests",
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
                    resources: [.process("TestData")],
                    swiftSettings: .spm)
    ]
)

// MARK: Authentication-KeyGeneration

add(
    product: .authenticationKeyGeneration,
    targets: [
        .target(name: .authenticationKeyGeneration,
                dependencies: [
                    .hash,
                    .featureSwitch,
                    .crypto,
                    .cryptoGoInterface,
                    .authentication
                ],
                path: "libraries/Authentication-KeyGeneration/Sources",
                swiftSettings: .spm),
        
        .testTarget(name: .authenticationKeyGeneration + "Tests",
                    dependencies: [
                        .swiftBCrypt,
                        .authenticationKeyGeneration,
                        .obfuscatedConstants,
                        .cryptoGoUsedInTests,
                        .ohhttpStubs
                    ],
                    path: "libraries/Authentication-KeyGeneration/Tests",
                    resources: [.process("TestData")],
                    swiftSettings: .spm)
    ]
)

// MARK: Authentication

add(
    product: .authentication,
    targets: [
        .target(name: .authentication,
                dependencies: [
                    .apiClient,
                    .crypto,
                    .cryptoGoInterface,
                    .featureSwitch,
                    .services
                ],
                path: "libraries/Authentication/Sources",
                swiftSettings: .spm),
        
        .testTarget(name: .authentication + "Tests",
                    dependencies: [
                        .authentication,
                        .cryptoGoInterface,
                        .cryptoGoUsedInTests,
                        .testingToolkitUnitTestsAuthentication,
                        .testingToolkitUnitTestsObservability,
                        .ohhttpStubs
                    ],
                    path: "libraries/Authentication/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: Challenge

add(
    product: .challenge,
    targets: [
        .target(name: .challenge,
                dependencies: [
                    .dataModel,
                    .foundations,
                    .uiFoundations
                ],
                path: "libraries/Challenge/Sources",
                swiftSettings: .spm),
        
        .testTarget(name: .challenge + "Tests",
                    dependencies: [
                        .challenge
                    ],
                    path: "libraries/Challenge/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: Common

add(
    product: .common,
    targets: [
        .target(name: .common,
                dependencies: [
                    .networking,
                    .services,
                    .uiFoundations
                ],
                path: "libraries/Common/Sources",
                swiftSettings: .spm)
    ]
)

// MARK: Crypto

add(
    product: .crypto,
    targets: [
        .target(name: .crypto,
                dependencies: [
                    .cryptoGoInterface,
                    .dataModel
                ],
                path: "libraries/Crypto/Sources",
                swiftSettings: .spm),

         .testTarget(name: .crypto + "Tests",
                     dependencies: [
                         .crypto,
                         .cryptoGoUsedInTests,
                         .utilities
                     ],
                     path: "libraries/Crypto/Tests",
                     resources: [
                         .process("Resources")
                     ],
                     swiftSettings: .spm),
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
        .target(name: .cryptoGoImplementation,
                dependencies: [
                    .goLibsCryptoGo,
                    .cryptoGoInterface,
                ],
                path: "libraries/CryptoGoImplementation/Crypto-Go",
                swiftSettings: .spm),

        .target(name: .cryptoPatchedGoImplementation,
                dependencies: [
                    .goLibsCryptoPatchedGo,
                    .cryptoGoInterface
                ],
                path: "libraries/CryptoGoImplementation/Crypto-patched-Go",
                swiftSettings: .spm),

        .target(name: .cryptoVPNPatchedGoImplementation,
                dependencies: [
                    .goLibsCryptoVPNPatchedGo,
                    .cryptoGoInterface
                ],
                path: "libraries/CryptoGoImplementation/Crypto+VPN-patched-Go",
                swiftSettings: .spm),

        .target(name: .cryptoSearchGoImplementation,
                dependencies: [
                    .goLibsCryptoSearchGo,
                    .cryptoGoInterface
                ],
                path: "libraries/CryptoGoImplementation/Crypto+Search-Go",
                swiftSettings: .spm),

         .testTarget(name: .cryptoGoImplementation + "Tests",
                     dependencies: [
                         .goLibsCryptoGo,
                         .cryptoGoImplementation,
                         .cryptoGoInterface
                     ],
                     path: "libraries/CryptoGoImplementation/Tests-Crypto-Go",
                     swiftSettings: .spm),

         .testTarget(name: .cryptoPatchedGoImplementation + "Tests",
                     dependencies: [
                         .goLibsCryptoPatchedGo,
                         .cryptoPatchedGoImplementation,
                         .cryptoGoInterface
                     ],
                     path: "libraries/CryptoGoImplementation/Tests-Crypto-patched-Go",
                     swiftSettings: .spm),

         .testTarget(name: .cryptoVPNPatchedGoImplementation + "Tests",
                     dependencies: [
                         .goLibsCryptoVPNPatchedGo,
                         .cryptoVPNPatchedGoImplementation,
                         .cryptoGoInterface
                     ],
                     path: "libraries/CryptoGoImplementation/Tests-Crypto+VPN-patched-Go",
                     swiftSettings: .spm),

         .testTarget(name: .cryptoSearchGoImplementation + "Tests",
                     dependencies: [
                         .goLibsCryptoSearchGo,
                         .cryptoSearchGoImplementation,
                         .cryptoGoInterface
                     ],
                     path: "libraries/CryptoGoImplementation/Tests-Crypto+Search-Go",
                     swiftSettings: .spm)
    ]
)

// MARK: CryptoGoInterface

add(
    product: .cryptoGoInterface,
    targets: [
        .target(name: .cryptoGoInterface,
                path: "libraries/CryptoGoInterface/Sources",
                swiftSettings: .spm)
    ]
)

// MARK: DataModel

add(
    product: .dataModel,
    targets: [
        .target(name: .dataModel,
                dependencies: [
                    .utilities
                ],
                path: "libraries/DataModel/Sources",
                swiftSettings: .spm),
        
        .testTarget(name: .dataModel + "Tests",
                    dependencies: [
                        .dataModel,
                        .testingToolkitUnitTestsDataModel
                    ],
                    path: "libraries/DataModel/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: DoH

add(
    product: .doh,
    targets: [
        .target(name: .doh,
            dependencies: [
                .featureSwitch,
                .log,
                .utilities
            ],
            path: "libraries/DoH/Sources",
            swiftSettings: .spm),
        
        .testTarget(name: .doh + "UnitTests",
                    dependencies: [
                        .doh,
                        .authentication,
                        .challenge,
                        .services,
                        .obfuscatedConstants,
                        .testingToolkitUnitTestsDoh,
                        .ohhttpStubs
                    ],
                    path: "libraries/Doh/Tests/Unit",
                    swiftSettings: .spm),
        
        .testTarget(name: .doh + "IntegrationTests",
                    dependencies: [
                        .doh,
                        .environment,
                        .authentication,
                        .observability,
                        .services,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch
                    ],
                    path: "libraries/Doh/Tests/Integration",
                    swiftSettings: .spm)
    ]
)

// MARK: Environment

add(
    product: .environment,
    targets: [
        .target(name: .environment,
            dependencies: [
                .doh,
                .trustKit
            ],
            path: "libraries/Environment/Sources",
            swiftSettings: .spm),

        .testTarget(name: .environment + "Tests",
                    dependencies: [
                        .environment,
                        .testingToolkitUnitTestsDoh,
                        .ohhttpStubs
                    ],
                    path: "libraries/Environment/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: Features

add(
    product: .features,
    targets: [
        .target(name: .features,
            dependencies: [
                .dataModel,
                .hash,
                .crypto,
                .cryptoGoInterface,
                .keyManager,
                .authentication,
                .networking
            ],
            path: "libraries/Features/Sources",
            swiftSettings: .spm)
    ]
)

// MARK: FeatureSwitch

add(
    product: .featureSwitch,
    targets: [
        .target(name: .featureSwitch,
                dependencies: [
                    .foundations,
                    .utilities
                ],
                path: "libraries/FeatureSwitch",
                exclude: ["Tests"],
                sources: ["Sources"],
                resources: [.process("Resources"),],
                swiftSettings: .spm),

        .testTarget(name: .featureSwitch + "Tests",
                    dependencies: [
                        .featureSwitch,
                        .doh,
                        .testingToolkitUnitTestsDoh
                    ],
                    path: "libraries/FeatureSwitch/Tests",
                    resources: [.process("Resources")],
                    swiftSettings: .spm)
    ]
)

// MARK: ForceUpgrade

add(
    product: .forceUpgrade,
    targets: [
        .target(name: .forceUpgrade,
                dependencies: [
                    .uiFoundations,
                    .networking
                ],
                path: "libraries/ForceUpgrade/Sources",
                resources: [
                    .process("Shared/Resources")
                ],
                swiftSettings: .spm),

        .testTarget(name: .forceUpgrade + "Tests",
                dependencies: [
                    .forceUpgrade,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/ForceUpgrade/Tests/UnitTests",
                swiftSettings: .spm),
        
        .testTarget(name: .forceUpgrade + "LocalizationTests",
                    dependencies: [
                        .forceUpgrade,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/ForceUpgrade/Tests/LocalizationTests",
                    swiftSettings: .spm)
        
    ]
)

// MARK: Foundations

add(
    product: .foundations,
    targets: [
        .target(name: .foundations,
                dependencies: [
                    .log
                ],
                path: "libraries/Foundations/Sources",
                swiftSettings: .spm)
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
        .target(name: .hash,
                path: "libraries/Hash/Sources",
                swiftSettings: .spm),

        .testTarget(name: .hash + "Tests",
                dependencies: [ 
                    .hash
                ],
                path: "libraries/Hash/Tests",
                swiftSettings: .spm)
    ]
)

// MARK: HumanVerification

add(
    product: .humanVerification,
    targets: [
        .target(name: .humanVerification,
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
                    .humanVerificationResourcesiOS,
                    .humanVerificationResourcesmacOS
                ],
                path: "libraries/HumanVerification/Sources",
                swiftSettings: .spm),

        .target(name: .humanVerificationResourcesiOS,
                path: "libraries/HumanVerification/Resources-iOS",
                resources: [
                    .process("Resources-iOS")
                ],
                swiftSettings: .spm),

        .target(name: .humanVerificationResourcesmacOS,
                path: "libraries/HumanVerification/Resources-macOS",
                resources: [
                    .process("Resources-macOS")
                ],
                swiftSettings: .spm),

        .testTarget(name: .humanVerification + "Tests",
                    dependencies: [
                        .challenge,
                        .humanVerification,
                        .cryptoGoUsedInTests,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsDoh,
                        .testingToolkitUnitTestsObservability,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/HumanVerification/Tests/UnitTests",
                    exclude: ["__Snapshots__"],
                    swiftSettings: .spm),
        
        .testTarget(name: .humanVerification + "LocalizationTests",
                    dependencies: [
                        .humanVerification,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/HumanVerification/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: Keymaker

add(
    product: .keymaker,
    targets: [
        .target(name: .keymaker,
                dependencies: [
                    .cryptoGoInterface,
                    .ellipticCurveKeyPair
                ],
                path: "libraries/Keymaker/Sources",
                swiftSettings: .spm),

        .testTarget(name: .keymaker + "Tests",
                    dependencies: [
                        .keymaker,
                        .cryptoGoUsedInTests,
                        .cryptoSwift
                    ],
                    path: "libraries/Keymaker/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: KeyManager

add(
    product: .keyManager,
    targets: [
        .target(name: .keyManager,
                dependencies: [
                    .cryptoGoInterface,
                    .crypto,
                    .dataModel
                ],
                path: "libraries/KeyManager/Sources",
                swiftSettings: .spm),

        .testTarget(name: .keyManager + "Tests",
                    dependencies: [
                        .keyManager,
                        .cryptoGoUsedInTests
                    ],
                    path: "libraries/KeyManager/Tests",
                    resources: [.process("TestData")],
                    swiftSettings: .spm)
    ]
)

// MARK: Log

add(
    product: .log,
    targets: [
        .target(name: .log,
                path: "libraries/Log/Sources",
                swiftSettings: .spm),

        .testTarget(name: .log + "Tests",
                    dependencies: [
                        .log
                    ],
                    path: "libraries/Log/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: Login

add(
    product: .login,
    targets: [
        .target(name: .login,
                dependencies: [
                    .log,
                    .foundations,
                    .dataModel,
                    .observability,
                    .crypto,
                    .cryptoGoInterface,
                    .authentication,
                    .authenticationKeyGeneration,
                    .trustKit
                ],
                path: "libraries/Login/Sources",
                resources: [.process("Resources")],
                swiftSettings: .spm),
        
        .testTarget(name: .login + "UnitTests",
                    dependencies: [
                        .login,
                        .challenge,
                        .crypto,
                        .cryptoGoInterface,
                        .cryptoGoUsedInTests,
                        .authentication,
                        .authenticationKeyGeneration,
                        .obfuscatedConstants,
                        .testingToolkitTestData,
                        .testingToolkitUnitTestsAuthenticationKeyGeneration,
                        .testingToolkitUnitTestsLogin,
                        .testingToolkitUnitTestsObservability,
                        .ohhttpStubs,
                        .trustKit
                    ],
                    path: "libraries/Login/Tests/UnitTests",
                    resources: [
                        .process("Mocks/Responses")
                    ],
                    swiftSettings: .spm),
        
        .testTarget(name: .login + "IntegrationTests",
                    dependencies: [
                        .login,
                        .crypto,
                        .cryptoGoInterface,
                        .cryptoGoUsedInTests,
                        .quarkCommands,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch,
                        .trustKit
                    ],
                    path: "libraries/Login/Tests/IntegrationTests",
                    swiftSettings: .spm),
        
        .testTarget(name: .login + "LocalizationTests",
                    dependencies: [
                        .login,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/Login/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: LoginUI

add(
    product: .loginUI,
    targets: [
        .target(name: .loginUI,
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
                    .trustKit
                ],
                path: "libraries/LoginUI/Sources",
                resources: [
                    .process("Resources/Translations")
                ],
                swiftSettings: .spm),

        .target(name: .loginUIResourcesiOS,
                path: "libraries/LoginUI/Resources",
                resources: [
                    .process("Resources-iOS")
                ],
                swiftSettings: .spm),
        
        .testTarget(name: .loginUI + "UnitTests",
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
                    ],
                    swiftSettings: .spm),
        
        .testTarget(name: .loginUI + "IntegrationTests",
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
                        .testingToolkitUnitTestsLoginUI,
                        .trustKit
                    ],
                    path: "libraries/LoginUI/Tests/IntegrationTests",
                    swiftSettings: .spm),
        
            .testTarget(name: .loginUI + "LocalizationTests",
                        dependencies: [
                            .loginUI,
                            .testingToolkitUnitTestsCore
                        ],
                        path: "libraries/LoginUI/Tests/LocalizationTests",
                        swiftSettings: .spm)
    ]
)

// MARK: MissingScopes

add(
    product: .missingScopes,
    targets: [
        .target(name: .missingScopes,
                dependencies: [
                    .apiClient,
                    .authentication,
                    .services,
                    .uiFoundations,
                    .passwordRequest
                ],
                path: "libraries/MissingScopes/Sources",
                swiftSettings: .spm),

        .testTarget(name: .missingScopes + "Tests",
                    dependencies: [
                        .missingScopes,
                        .testingToolkitUnitTestsNetworking,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/MissingScopes/Tests",
                    exclude: ["SnapshotTests/__Snapshots__"],
                    swiftSettings: .spm)
    ]
)

// MARK: Networking

add(
    product: .networking,
    targets: [
        .target(name: .networking,
                dependencies: [
                    .environment,
                    .log,
                    .utilities,
                    .alamofire,
                    .trustKit
                ],
                path: "libraries/Networking/Sources",
                swiftSettings: .spm),

        .testTarget(name: .networking + "Tests",
                    dependencies: [
                        .networking,
                        .testingToolkitUnitTestsNetworking,
                        .ohhttpStubs,
                        .trustKit
                    ],
                    path: "libraries/Networking/Tests/UnitTests",
                    swiftSettings: .spm),
        
        .testTarget(name: .networking + "LocalizationTests",
                    dependencies: [
                        .networking,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/Networking/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: ObfuscatedConstants

add(
    product: .obfuscatedConstants,
    targets: [
        .target(name: .obfuscatedConstants,
                dependencies: [
                    .dataModel,
                    .networking,
                    .cryptoSwift,
                    .swiftOTP,
                    .trustKit
                ],
                path: "libraries/ObfuscatedConstants/Sources",
                exclude: ["Template"],
                swiftSettings: .spm)
    ]
)

// MARK: Observability

add(
    product: .observability,
    targets: [
        .target(name: .observability,
                dependencies: [
                    .networking,
                    .utilities
                ],
                path: "libraries/Observability/Sources",
                swiftSettings: .spm),

        .testTarget(name: .observability + "UnitTests",
                    dependencies: [
                        .observability,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch,
                        .testingToolkitUnitTestsNetworking,
                        .testingToolkitUnitTestsObservability,
                        .testingToolkitUnitTestsServices,
                        .jsonSchema
                    ],
                    path: "libraries/Observability/UnitTests",
                    swiftSettings: .spm),
        
        .testTarget(name: .observability + "IntegrationTests",
                    dependencies: [
                        .observability,
                        .authentication,
                        .networking,
                        .services,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch,
                        .testingToolkitUnitTestsObservability
                    ],
                    path: "libraries/Observability/IntegrationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: Password Request

add(
    product: .passwordRequest,
    targets: [
        .target(name: .passwordRequest,
                dependencies: [
                    .authentication,
                    .networking,
                    .services,
                    .uiFoundations
                ],
                path: "libraries/PasswordRequest/Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm
        ),
        
        .testTarget(name: .passwordRequest + "UnitTests",
                    dependencies: [
                        .authentication,
                        .passwordRequest,
                        .networking,
                        .services,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch,
                        .testingToolkitUnitTestsNetworking,
                        .testingToolkitUnitTestsAuthentication,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/PasswordRequest/Tests/UnitTests",
                    swiftSettings: .spm
        ),
        
        .testTarget(name: .passwordRequest + "LocalizationTests",
                    dependencies: [
                        .passwordRequest,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/PasswordRequest/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: Payments

add(
    product: .payments,
    targets: [
        .target(name: .payments,
                dependencies: [
                    .authentication,
                    .foundations,
                    .hash,
                    .log,
                    .networking,
                    .services,
                    .reachabilitySwift,
                    .subscriptions
                ],
                path: "libraries/Payments/Sources",
                swiftSettings: .spm),

        .testTarget(name: .payments + "Tests",
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
                        .testingToolkitUnitTestsPayments,
                        .testingToolkitUnitTestsServices,
                        .ohhttpStubs
                    ],
                    path: "libraries/Payments/Tests/UnitTests",
                    resources: [
                        .process("AppStoreLocalTest"),
                        .process("Mocks/Responses")
                    ],
                    swiftSettings: .spm),

        .testTarget(name: .payments + "IntegrationTests",
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
                    path: "libraries/Payments/Tests/IntegrationTests",
                    swiftSettings: .spm),
        
        .testTarget(name: .payments + "LocalizationTests",
                    dependencies: [
                        .payments,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/Payments/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: PaymentsUI

add(
    product: .paymentsUI,
    targets: [
        .target(name: .paymentsUI,
                dependencies: [
                    .log,
                    .foundations,
                    .uiFoundations,
                    .observability,
                    .payments,
                    .paymentsUIResourcesiOS,
                    .sdWebImage
                ],
                path: "libraries/PaymentsUI/Sources",
                resources: [
                    .process("Resources/Translations")
                ],
                swiftSettings: .spm),

        .target(name: .paymentsUIResourcesiOS,
                path: "libraries/PaymentsUI/Resources",
                resources: [
                    .process("Resources-iOS")
                ],
                swiftSettings: .spm),

        .testTarget(name: .paymentsUI + "Tests",
                    dependencies: [
                        .featureSwitch,
                        .paymentsUI,
                        .obfuscatedConstants,
                        .subscriptions,
                        .testingToolkitUnitTestsDataModel,
                        .testingToolkitUnitTestsObservability,
                        .testingToolkitUnitTestsPayments,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/PaymentsUI/Tests/UnitTests",
                    exclude: ["__Snapshots__"],
                    swiftSettings: .spm),
        
        .testTarget(name: .paymentsUI + "LocalizationTests",
                    dependencies: [
                        .paymentsUI,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/PaymentsUI/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: PushNotifications

add(
    product: .pushNotifications,
    targets: [
        .target(name: .pushNotifications,
                dependencies: [
                    .log,
                    .dataModel,
                    .keymaker,
                    .networking,
                    .crypto,
                    .cryptoGoInterface,
                    .featureSwitch,
                    .services
                ],
                path: "libraries/PushNotifications/Sources",
                swiftSettings: .spm),

        .testTarget(name: .pushNotifications + "Tests",
                    dependencies: [
                        .pushNotifications,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/PushNotifications/Tests",
                    swiftSettings: .spm)
    ]
)

// MARK: QuarkCommands

add(
    product: .quarkCommands,
    targets: [
        .target(name: .quarkCommands,
                dependencies: [
                    .doh,
                    .environment,
                    .log,
                    .networking,
                    .services
                ],
                path: "libraries/QuarkCommands/Sources",
                swiftSettings: .spm),

        .testTarget(name: .quarkCommands + "Tests",
                    dependencies: [
                        .quarkCommands,
                        .testingToolkitUnitTestsDoh,
                        .ohhttpStubs,
                    ],
                    path: "libraries/QuarkCommands/Tests",
                    resources: [.process("Mocks")],
                    swiftSettings: .spm)
    ]
)

// MARK: Services

add(
    product:. services,
    targets: [
        .target(name: .services,
                dependencies: [
                    .observability,
                    .utilities
                ],
                path: "libraries/Services/Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm),

        .testTarget(name: .services + "UnitTests",
                    dependencies: [
                        .authentication,
                        .challenge,
                        .services,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsDoh,
                        .testingToolkitUnitTestsFeatureSwitch,
                        .testingToolkitUnitTestsNetworking,
                        .testingToolkitUnitTestsObservability,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/Services/Tests/Unit",
                    swiftSettings: .spm),
        
        .testTarget(name: .services + "IntegrationTests",
                    dependencies: [
                        .services,
                        .authentication,
                        .challenge,
                        .login,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsFeatureSwitch
                    ],
                    path: "libraries/Services/Tests/Integration",
                    swiftSettings: .spm),
        
        .testTarget(name: .services + "LocalizationTests",
                    dependencies: [
                        .services,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/Services/Tests/Localization",
                    swiftSettings: .spm)
    ]
)

// MARK: Settings

add(
    product: .settings,
    targets: [
        .target(name: .settings,
                dependencies: [
                    .uiFoundations
                ],
                path: "libraries/Settings/Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm),

        .testTarget(name: .settings + "Tests",
                    dependencies: [
                        .settings,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/Settings/Tests",
                    exclude: [
                        "Resources",
                        "Security/Presentation/__Snapshots__",
                        "Settings/Presentation/__Snapshots__"
                    ],
//                    resources: [
//                        .copy("Resources")
//                    ],
                    swiftSettings: .spm)
    ]
)

// MARK: Subscriptions

add(product: .subscriptions,
    targets: [
        .target(name: .subscriptions,
                dependencies: [
                    .featureSwitch
                ],
                path: "libraries/Subscriptions/Sources",
                swiftSettings: .spm),
        .testTarget(name: .subscriptions + "Tests",
                    dependencies: [
                        .subscriptions,
                        .featureSwitch,
                        .testingToolkitUnitTestsFeatureSwitch
                    ],
                    path: "libraries/Subscriptions/Tests",
                    swiftSettings: .spm)
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
        .testingToolkitUnitTestsDataModel,
        .testingToolkitUnitTestsDoh,
        .testingToolkitUnitTestsFeatureSwitch,
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
        .target(name: .testingToolkitTestData,
                dependencies: [
                    .dataModel,
                    .networking,
                    .cryptoSwift
                ],
                path: "libraries/TestingToolkit/TestData",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsAccountDeletion,
                dependencies: [
                    .accountDeletion,
                    .testingToolkitUnitTestsCore,
                    .testingToolkitUnitTestsNetworking
                ],
                path: "libraries/TestingToolkit/UnitTests/AccountDeletion",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsAuthentication,
                dependencies: [
                    .authentication,
                    .testingToolkitUnitTestsCore,
                    .testingToolkitUnitTestsServices
                ],
                path: "libraries/TestingToolkit/UnitTests/Authentication",
                swiftSettings: .spm),
        
            .target(name: .testingToolkitUnitTestsAuthenticationKeyGeneration,
                    dependencies: [
                        .authenticationKeyGeneration,
                        .testingToolkitUnitTestsAuthentication,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration",
                    swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsCore,
                dependencies: [
                    .utilities,
                    .snapshotTesting
                ],
                path: "libraries/TestingToolkit/UnitTests/Core",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsDataModel,
                dependencies: [
                    .dataModel,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/TestingToolkit/UnitTests/DataModel",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsDoh,
                dependencies: [
                    .doh,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/TestingToolkit/UnitTests/Doh",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsFeatureSwitch,
                dependencies: [
                    .featureSwitch,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/TestingToolkit/UnitTests/FeatureSwitch",
                swiftSettings: .spm),
        
            .target(name: .testingToolkitUnitTestsLogin,
                    dependencies: [
                        .login,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsAuthentication,
                        .testingToolkitUnitTestsDataModel,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/TestingToolkit/UnitTests/Login",
                    swiftSettings: .spm),
        
            .target(name: .testingToolkitUnitTestsLoginUI,
                    dependencies: [
                        .loginUI,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsAuthentication,
                        .testingToolkitUnitTestsDataModel,
                        .testingToolkitUnitTestsLogin,
                        .testingToolkitUnitTestsServices
                    ],
                    path: "libraries/TestingToolkit/UnitTests/LoginUI",
                    swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsNetworking,
                dependencies: [
                    .networking,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/TestingToolkit/UnitTests/Networking",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsObservability,
                dependencies: [
                    .observability,
                    .testingToolkitUnitTestsCore
                ],
                path: "libraries/TestingToolkit/UnitTests/Observability",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsPayments,
                dependencies: [
                    .payments,
                    .testingToolkitUnitTestsCore,
                    .ohhttpStubs
                ],
                path: "libraries/TestingToolkit/UnitTests/Payments",
                swiftSettings: .spm),

        .target(name: .testingToolkitUnitTestsServices,
                dependencies: [
                    .services,
                    .testingToolkitUnitTestsCore,
                    .testingToolkitUnitTestsDataModel,
                    .testingToolkitUnitTestsDoh,
                    .testingToolkitUnitTestsFeatureSwitch,
                    .testingToolkitUnitTestsNetworking
                ],
                path: "libraries/TestingToolkit/UnitTests/Services",
                swiftSettings: .spm),
        
        .target(name: .testingToolkitUITestsAccountDeletion,
                dependencies: [
                    .accountDeletion,
                    .doh,
                    .quarkCommands,
                    .fusion
                ],
                path: "libraries/TestingToolkit/UITests/AccountDeletion",
                swiftSettings: .spm),
        
        .target(name: .testingToolkitUITestsAccountSwitcher,
                dependencies: [
                    .accountSwitcher,
                    .doh,
                    .quarkCommands,
                    .fusion
                ],
                path: "libraries/TestingToolkit/UITests/AccountSwitcher",
                swiftSettings: .spm),
        
        .target(name: .testingToolkitUITestsCore,
                dependencies: [
                    .doh,
                    .log,
                    .quarkCommands,
                    .fusion
                ],
                path: "libraries/TestingToolkit/UITests/Core",
                swiftSettings: .spm),
        
        .target(name: .testingToolkitUITestsHumanVerification,
                dependencies: [
                    .humanVerification,
                    .doh,
                    .quarkCommands,
                    .fusion
                ],
                path: "libraries/TestingToolkit/UITests/HumanVerification",
                swiftSettings: .spm),
        
        .target(name: .testingToolkitUITestsLogin,
                dependencies: [
                    .humanVerification,
                    .loginUI,
                    .paymentsUI,
                    .doh,
                    .quarkCommands,
                    .fusion,
                ],
                path: "libraries/TestingToolkit/UITests/Login",
                swiftSettings: .spm),
    
        .target(name: .testingToolkitUITestsPaymentsUI,
                dependencies: [
                    .paymentsUI,
                    .doh,
                    .quarkCommands,
                    .fusion
                ],
                path: "libraries/TestingToolkit/UITests/PaymentsUI",
                swiftSettings: .spm)
    ]
)

// MARK: TroubleShooting

add(
    product: .troubleShooting,
    targets: [
        .target(name: .troubleShooting,
                dependencies: [
                    .foundations,
                    .uiFoundations,
                    .doh,
                    .utilities,
                    .troubleShootingResourcesiOS
                ],
                path: "libraries/TroubleShooting/Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: .spm),

        .target(name: .troubleShootingResourcesiOS,
                path: "libraries/TroubleShooting/Resources",
                resources: [
                    .process("Resources-iOS")
                ],
                swiftSettings: .spm),

        .testTarget(name: .troubleShooting + "Tests",
                    dependencies: [
                        .troubleShooting,
                        .services,
                        .environment,
                        .testingToolkitUnitTestsCore,
                        .testingToolkitUnitTestsDoh
                    ],
                    path: "libraries/TroubleShooting/Tests/UnitTests",
                    exclude: ["__Snapshots__"],
                    swiftSettings: .spm),
        
        .testTarget(name: .troubleShooting + "LocalizationTests",
                    dependencies: [
                        .troubleShooting,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/TroubleShooting/Tests/LocalizationTests",
                    swiftSettings: .spm)
    ]
)

// MARK: - UIFoundations

add(
    product: .uiFoundations,
    targets: [
        .target(name: .uiFoundations,
                dependencies: [
                    .foundations,
                    .log,
                    .utilities,
                    .uiFoundationsResourcesiOS,
                    .uiFoundationsResourcesmacOS
                ],
                path: "libraries/UIFoundations/Sources",
                swiftSettings: .spm),

        .target(name: .uiFoundationsResourcesiOS,
                path: "libraries/UIFoundations/Resources-iOS",
                resources: [
                    .process("Resources-iOS"),
                    .process("Resources-Shared")
                ],
                swiftSettings: .spm),

        .target(name: .uiFoundationsResourcesmacOS,
                path: "libraries/UIFoundations/Resources-macOS",
                resources: [
                    .process("Resources-Shared")
                ],
                swiftSettings: .spm),

        .testTarget(name: .uiFoundations + "Tests",
                    dependencies: [
                        .uiFoundations,
                        .testingToolkitUnitTestsCore
                    ],
                    path: "libraries/UIFoundations/Tests",
                    exclude: ["__Snapshots__"],
                    swiftSettings: .spm)
    ]
)

// MARK: Utilities

add(
    product: .utilities,
    targets: [
        .target(name: .utilities,
                dependencies: [
                    .log
                ],
                path: "libraries/Utilities/Sources",
                swiftSettings: .spm),

        .testTarget(name: .utilities + "Tests",
                    dependencies: [
                        .utilities
                    ],
                    path: "libraries/Utilities/Tests",
                    swiftSettings: .spm)
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
                targets: [.obfuscatedConstantsGenerationPlugin])
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            exact: "5.4.4"
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
            url: "https://github.com/ProtonMail/apple-fusion",
            from: "2.0.1"
        ),
        .package(
            url: "https://github.com/kylef/JSONSchema.swift",
            from: "0.6.0"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            exact: "3.4.3"
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
            from: "1.10.0"
        ),
        .package(
            url: "https://github.com/ProtonMail/TrustKit",
            exact: "1.0.3"
        ),
        .package(
            url: "https://github.com/tannerdsilva/SwiftBCrypt.git",
            from: "0.2.0"
        ),
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            "0.0.0"..<"5.16.0"
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
