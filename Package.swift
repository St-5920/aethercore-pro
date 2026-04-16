// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AetherCorePro",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AetherCorePro",
            targets: ["AetherCorePro"]
        )
    ],
    targets: [
        .target(
            name: "AetherCorePro",
            dependencies: [],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "AetherCoreProTests",
            dependencies: ["AetherCorePro"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)