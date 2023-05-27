// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WinMD",
    products: [
        .library(
            name: "WinMD",
            targets: ["WinMD", "WinMDGraph"]),
        .executable(
            name: "Sample",
            targets: ["Sample"])
    ],
    targets: [
        .target(
            name: "WinMD"),
        .target(
            name: "WinMDGraph",
            dependencies: [ "WinMD" ]),
        .executableTarget(
            name: "Sample",
            dependencies: [ "WinMD", "WinMDGraph" ],
            path: "Sample"),
        .testTarget(
            name: "WinMDTests",
            dependencies: [ "WinMD", "WinMDGraph" ])
    ]
)
