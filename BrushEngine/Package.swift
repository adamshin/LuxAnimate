// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BrushEngine",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "BrushEngine",
            targets: ["BrushEngine"]),
    ],
    dependencies: [
        .package(path: "../Geometry"),
        .package(path: "../Color"),
        .package(path: "../Render"),
        .package(path: "../FileCoding"),
    ],
    targets: [
        .target(
            name: "BrushEngine",
            dependencies: [
                "Geometry",
                "Color",
                "Render",
                "FileCoding",
            ]),

    ]
)
