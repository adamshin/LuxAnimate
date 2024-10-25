// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BrushEngine",
    products: [
        .library(
            name: "BrushEngine",
            targets: ["BrushEngine"]),
    ],
    dependencies: [
        .package(path: "../Geometry")
    ],
    targets: [
        .target(
            name: "BrushEngine",
            dependencies: ["Geometry"]),
    ]
)
