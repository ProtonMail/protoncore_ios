// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TrustKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "TrustKit",
            targets: ["TrustKit"]
        ),
        .library(
            name: "TrustKitDynamic",
            type: .dynamic,
            targets: ["TrustKit"]
        ),
        .library(
            name: "TrustKitStatic",
            type: .static,
            targets: ["TrustKit"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TrustKit",
            dependencies: [],
            path: "TrustKit",            
            publicHeadersPath: "public"
        ),
    ]
)
