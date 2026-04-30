// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TaigiDictNative",
    defaultLocalization: "zh-Hant",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "TaigiDictCore",
            targets: ["TaigiDictCore"]
        ),
    ],
    dependencies: [
        // TODO: pin to a release tag or commit after the first successful
        // dependency resolution in Xcode Cloud.
        .package(
            url: "https://github.com/PhoenixEmik/SwiftyOpenCC.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "TaigiDictCore",
            dependencies: [
                .product(name: "OpenCC", package: "SwiftyOpenCC"),
            ]
        ),
        .testTarget(
            name: "TaigiDictCoreTests",
            dependencies: ["TaigiDictCore"]
        ),
    ]
)
