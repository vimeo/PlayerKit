// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PlayerKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "PlayerKit", 
            targets: ["PlayerKit"]
        )
    ],
    targets: [
        .target(
            name: "PlayerKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "PlayerKit-iOSTests",
            dependencies: [],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)