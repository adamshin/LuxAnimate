// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BrushEngine",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "BrushEngine",
            targets: ["BrushEngine"]),
    ],
    dependencies: [
        .package(path: "../Geometry"),
        .package(path: "../Color"),
    ],
    targets: [
        .target(
            name: "BrushEngine",
            dependencies: [
                "Geometry",
                "Color",
                "ShaderTypes",
            ]),
        .target(
            name: "ShaderTypes",
            publicHeadersPath: ".")
    ]
)
