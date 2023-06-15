// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DotNetMD",
    products: [
        .library(
            name: "DotNetMD",
            targets: ["DotNetMDFormat", "DotNetMD"]),
        .executable(
            name: "Sample",
            targets: ["Sample"])
    ],
    targets: [
        .target(
            name: "DotNetMDFormat"),
        .target(
            name: "DotNetMD",
            dependencies: [ "DotNetMDFormat" ]),
        .executableTarget(
            name: "Sample",
            dependencies: [ "DotNetMDFormat", "DotNetMD" ],
            path: "Sample"),
        .testTarget(
            name: "UnitTests",
            dependencies: [ "DotNetMDFormat", "DotNetMD" ])
    ]
)
