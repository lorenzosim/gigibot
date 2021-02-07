// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "gigibot",
    dependencies: [],
    targets: [
        .target(
          name: "gigibot",
          dependencies: ["gigi"]),
        .target(
            name: "gigi",
            dependencies: []),
        .testTarget(
            name: "gigiTests",
            dependencies: ["gigi"]),
    ]
)
