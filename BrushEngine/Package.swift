// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BrushEngine",
    products: [
        .library(
            name: "BrushEngine",
            targets: ["BrushEngine"]),
    ],
    targets: [
        .target(
            name: "BrushEngine"),
    ]
)
