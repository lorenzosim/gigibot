// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "gigi",
    dependencies: [],
    targets: [
        .target(
            name: "gigi",
            dependencies: []),
        .testTarget(
            name: "gigiTests",
            dependencies: ["gigi"]),
    ]
)
