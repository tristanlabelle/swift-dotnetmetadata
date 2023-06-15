// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DotNetMD",
    products: [
        .library(
            name: "DotNetMD",
            targets: ["DotNetMDPhysical", "DotNetMD"]),
        .executable(
            name: "Sample",
            targets: ["Sample"])
    ],
    targets: [
        .target(
            name: "DotNetMDPhysical"),
        .target(
            name: "DotNetMD",
            dependencies: [ "DotNetMDPhysical" ]),
        .executableTarget(
            name: "Sample",
            dependencies: [ "DotNetMDPhysical", "DotNetMD" ],
            path: "Sample"),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMDPhysical", "DotNetMD" ])
    ]
)
