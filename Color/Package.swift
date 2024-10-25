// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Color",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Color",
            targets: ["Color"]),
    ],
    targets: [
        .target(
            name: "Color"),

    ]
)
