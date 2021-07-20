// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "IterateSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "IterateSDK",
            targets: ["IterateSDK"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "IterateSDK",
            dependencies: [],
            path: "IterateSDK",
            exclude: ["Info.plist"],
            resources: [
                .process("SDK/UI/Assets.xcassets"),
                .process("SDK/UI/Surveys.storyboard")
            ]
        ),
        .testTarget(
            name: "IterateSDKTests",
            dependencies: ["IterateSDK"],
            path: "IterateSDKTests",
            exclude: ["Info.plist"]
        )
    ]
)
