// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DotNetMDPhysical",
    products: [
        .library(
            name: "DotNetMDPhysical",
            targets: ["DotNetMDPhysical", "DotNetMDLogical"]),
        .executable(
            name: "Sample",
            targets: ["Sample"])
    ],
    targets: [
        .target(
            name: "DotNetMDPhysical"),
        .target(
            name: "DotNetMDLogical",
            dependencies: [ "DotNetMDPhysical" ]),
        .executableTarget(
            name: "Sample",
            dependencies: [ "DotNetMDPhysical", "DotNetMDLogical" ],
            path: "Sample"),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMDPhysical", "DotNetMDLogical" ])
    ]
)
