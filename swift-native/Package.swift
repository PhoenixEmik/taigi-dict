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
        .library(
            name: "TaigiDictUI",
            targets: ["TaigiDictUI"]
        ),
        .executable(
            name: "TaigiDictPreviewApp",
            targets: ["TaigiDictPreviewApp"]
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
        .target(
            name: "TaigiDictUI",
            dependencies: ["TaigiDictCore"]
        ),
        .executableTarget(
            name: "TaigiDictPreviewApp",
            dependencies: [
                "TaigiDictCore",
                "TaigiDictUI",
            ]
        ),
        .testTarget(
            name: "TaigiDictCoreTests",
            dependencies: ["TaigiDictCore"]
        ),
        .testTarget(
            name: "TaigiDictUITests",
            dependencies: [
                "TaigiDictCore",
                "TaigiDictUI",
            ]
        ),
    ]
)
