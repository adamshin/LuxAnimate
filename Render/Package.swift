// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Render",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Render",
            targets: ["Render"]),
    ],
    dependencies: [
        .package(path: "../Geometry"),
        .package(path: "../Color"),
    ],
    targets: [
        .target(
            name: "Render",
            dependencies: [
                "Geometry",
                "Color",
                "Shaders",
            ]),
        .target(
            name: "Shaders",
            exclude: ["Shaders.metal"],
            publicHeadersPath: ".")
    ]
)
